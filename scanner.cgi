#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
######################################################
##  scanner.cgi - Gallery scanner                   ##
######################################################

my $cdir = '/home/soft/html/legacy/ags';


chdir($cdir) || die "Could not change into $cdir";


## Define penalties
my $penalty_report    = 0x00000001;
my $penalty_disabled  = 0x00000002;
my $penalty_delete    = 0x00000004;
my $penalty_blacklist = 0x00000008;


## Initialize variables
my $config      = $ARGV[0];
my $start_time  = undef;
my $stop_time   = undef;
my $stopped     = 0;
my $row         = undef;
my $results     = undef;
my $proxies     = undef;
my $result      = undef;
my $account     = {};
my $category    = {};
my $examined    = 0;
my $total       = 0;
my $t_blacklist = 0;
my $t_exception = 0;
my $t_delete    = 0;
my $t_disabled  = 0;


## Exception bitmasks
my %exception = (
                  'connection'   => 0x00000001,
                  'redirect'     => 0x00000002,
                  'broken_url'   => 0x00000004,
                  'blacklist'    => 0x00000008,
                  'banned_html'  => 0x00000010,
                  'no_recip'     => 0x00000020,
                  'thumb_change' => 0x00000040,
                  'max_links'    => 0x00000080,
                  'page_change'  => 0x00000100,
                  'no_2257'      => 0x00000200
                );


## Include the necessary helper scripts
require 'common.pl';
require 'mysql.pl';
require 'http.pl';
require 'ags.pl';
require 'image.pl';
require 'size.pl';


## Setup the default status
FileWrite("$DDIR/scanner/$config.sta", time . "|?|?");


## Enable the error log
$ERROR_LOG = 1;


## Load the configuration file
if( -e "$DDIR/scanner/$config" )
{
    require "$DDIR/scanner/$config";
}
else
{
    Error("Gallery scanner configuration '$config' does not exist", 'scanner.cgi');
}


## See if there is an instance of this running already
if( -e "$DDIR/scanner/$config.pid" )
{
    kill(9, FileReadLine("$DDIR/scanner/$config.pid"));
}


## Create the new pid file
FileWrite("$DDIR/scanner/$config.pid", $$);


## Close us off to the outside world
close STDIN;
close STDOUT;
close STDERR;


## Catch signals
$SIG{'INT'} = \&HandleSignal;
$SIG{'HUP'} = \&HandleSignal;


## Connect to the MySQL database
$DB->Connect();


## Set MySQL timeout values
if( AcceptableMysqlVersion() )
{
    $DB->Update("SET wait_timeout=86400");
    $DB->Update("SET interactive_timeout=86400");
}


## Get details on the categories
$result = $DB->Query("SELECT * FROM ags_Categories");
while( $row = $DB->NextRow($result) )
{
    $category->{$row->{'Name'}} = $row;
}
$DB->Free($result);


## Load annotations
$result = $DB->Query("SELECT * FROM ags_Annotations");
while( $row = $DB->NextRow($result) )
{
    $annotation->{$row->{'Unique_ID'}} = $row;
}
$DB->Free($result);


## Put the header on the report file
ReportHeader();


## Load proxies if using them
if( $use_proxy )
{
    $proxies = LoadProxies();
}


## Setup the MySQL query qualifier
$qualifier = SetupQualifier();


## Select the galleries to be scanned
$result = $DB->Query("SELECT * FROM ags_Galleries $qualifier");
$total = $DB->NumRows($result);


## Never check content size
$O_CHECK_SIZE = 0;


## Record the starting time
$start_time = time;


## Scan each gallery
while( $row = $DB->NextRow($result) )
{
    ## Local loop variables
    my $blacklisted = undef;
    my $whitelisted = undef;
    my $removed = undef;
    my $proxy = undef;
    my $image_id = $row->{'Gallery_ID'};
    my $changes = {};
    my $status = 0x00000000;


    ## Update the number of examined galleries
    $examined++;


    ## See if we should stop
    if( -e "$DDIR/scanner/$config.sto" )
    {
        $stopped = 1;
        last;
    }


    ## Make sure another instance hasn't taken over
    if( -e "$DDIR/scanner/$config.pid" && $$ != FileReadLine("$DDIR/scanner/$config.pid") )
    {
        exit;
    }


    ## Update status
    FileWrite("$DDIR/scanner/$config.sta", time . "|$examined|$total");


    ## Setup trusted partner account information
    my $account = {};
    if( $row->{'Account_ID'} )
    {
        $account = $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=?", [$row->{'Account_ID'}]);
    }


    ## See if the gallery is whitelisted
    $whitelisted = ($row->{'Type'} eq 'Permanent' || IsWhitelisted($row->{'Gallery_URL'}));


    ## Choose a random proxy
    if( $use_proxy )
    {
        $proxy = @$proxies[rand @$proxies];
    }


    ## Scan the gallery
    $results = ScanGallery($row->{'Gallery_URL'}, $category->{$row->{'Category'}}, $whitelisted, $account, $proxy);

    
    ## Broken gallery URL
    if( $results->{'Error'} )
    {
        ## Bad status code
        if( $results->{'Status'} )
        {
            if( $results->{'Code'} =~ /^3\d\d$/ )
            {
                ProcessGallery($row, $results, $exception{'redirect'});
            }
            else
            {
                ProcessGallery($row, $results, $exception{'broken_url'});
            }
        }
        ## Connection error
        else
        {
            ProcessGallery($row, $results, $exception{'connection'});
        }

        next;
    }


    if( $row->{'Type'} eq 'Submitted' )
    {
        ## Check the blacklist
        if( !$whitelisted && $blacklist )
        {
            $row->{'Http_Headers'} = $results->{'Headers'}->{'All'};
            $blacklisted = IsBlacklisted($row);
        }


        if( $blacklisted && (!$account->{'Account_ID'} || $account->{'Check_Black'}) )
        {
            $results->{'Blacklist_Item'} = $blacklisted->{'Item'};
            $status |= $exception{'blacklist'};
        }


        ## Check for banned HTML
        if( $results->{'Has_Banned'} && (!$account->{'Account_ID'} || $account->{'Check_HTML'}) )
        {
            $status |= $exception{'banned_html'};
        }


        ## Check reciprocal link
        if( !$results->{'Has_Recip'} && (!$account->{'Account_ID'} || $account->{'Check_Recip'}) )
        {
            $status |= $exception{'no_recip'};
        }


        ## See if thumb count has changed
        ## If the thumbnail count was zero, do not flag as a bad gallery.
        ## This almost certainly means the gallery was imported without a
        ## thumbnail count
        if( $results->{'Thumbnails'} != $row->{'Thumbnails'} && $row->{'Thumbnails'} != 0 )
        {
            $status |= $exception{'thumb_change'};
        }


        ## Check the number of external links
        if( $results->{'Links'} > $LINKS )
        {
            $status |= $exception{'max_links'};
        }


        ## Check page ID
        if( $row->{'Page_ID'} && $results->{'Page_ID'} ne $row->{'Page_ID'} )
        {
            $status |= $exception{'page_change'};
        }


        ## Update the gallery IP
        if( !$row->{'Gallery_IP'} )
        {
            $changes->{'Gallery_IP'} = $results->{'Gallery_IP'};
        }
        
        
    }


    ## Check for 2257 code (both submitted and permanent get checked for this)
    if( !$results->{'Has_2257'} )
    {
        $status |= $exception{'no_2257'};
    }


    ## Process the gallery if there were any exceptions
    if( $status )
    {
        $removed = ProcessGallery($row, $results, $status);
    }


    ## Process changes
    $changes->{'Thumbnails'} = $results->{'Thumbnails'} if( $update_count && $results->{'Thumbnails'} > 0 );
    $changes->{'Format'} = $results->{'Format'} if( $update_format );
    $changes->{'Page_ID'} = $results->{'Page_ID'};
    $changes->{'Scanned'} = 1;
    $changes->{'Speed'} = $results->{'Speed'};
    $changes->{'Page_Bytes'} = $results->{'Bytes'};
    $changes->{'Has_Recip'} = $results->{'Has_Recip'};


    ## Generate preview thumbnail
    if( $row->{'Allow_Thumb'} && !$removed && $results->{'Preview'} )
    {
        my $new_thumb = ($create_thumbs && !-e "$THUMB_DIR/$image_id.jpg" && IsEmptyString($row->{'Thumbnail_URL'}));
        my $redo_thumb = ($new_thumbs && (-e "$THUMB_DIR/$image_id.jpg" || $row->{'Has_Thumb'} || !IsEmptyString($row->{'Thumbnail_URL'})));

        if( $new_thumb || $redo_thumb )
        {
            my $http = new Http();

            if( $http->Get(URL => $results->{'Preview'},  Referrer => $row->{'Gallery_URL'}, AllowRedirect => 1) )
            {
                if( $new_thumb || $new_size )
                {
                    $THUMB_WIDTH = $width;
                    $THUMB_HEIGHT = $height;
                }
                else
                {
                    $THUMB_WIDTH = $row->{'Thumb_Width'};
                    $THUMB_HEIGHT = $row->{'Thumb_Height'};
                }

                my $format = $changes->{'Format'} || $row->{'Format'};

                AutoResize(\$http->{'Body'}, $image_id, $annotation->{$category->{$row->{'Category'}}->{"Ann_$format"}});

                if( -e "$THUMB_DIR/$image_id.jpg" )
                {
                    $changes->{'Has_Thumb'} = 1;
                    $changes->{'Thumb_Width'} = $THUMB_WIDTH;
                    $changes->{'Thumb_Height'} = $THUMB_HEIGHT;
                    $changes->{'Thumbnail_URL'} = "$THUMB_URL/$image_id.jpg";
                }
            }
        }
    }


    ## Download remote thumb
    if( $download_thumb )
    {
        if( $row->{'Has_Thumb'} && $row->{'Thumbnail_URL'} ne "$THUMB_URL/$row->{'Gallery_ID'}.jpg" )
        {
            my $http = new Http();

            if( $http->Get(URL => $row->{'Thumbnail_URL'}, Referrer => $row->{'Gallery_URL'}, AllowRedirect => 1) )
            {
                my $thumb_data = $http->{'Body'};
                my($d_width, $d_height) = imgsize(\$thumb_data);

                if( $d_width && $d_height )
                {
                    if( $download_resize )
                    {
                        $THUMB_WIDTH = $width;
                        $THUMB_HEIGHT = $height;

                        AutoResize(\$http->{'Body'}, $image_id, $annotation->{$category->{$row->{'Category'}}->{"Ann_$format"}});

                        $changes->{'Thumb_Width'} = $width;
                        $changes->{'Thumb_Height'} = $height;
                    }
                    else
                    {
                        FileWrite("$THUMB_DIR/$image_id.jpg", $http->{'Body'});
                        $changes->{'Thumb_Width'} = $d_width;
                        $changes->{'Thumb_Height'} = $d_height;
                    }

                    
                    $changes->{'Thumbnail_URL'} = "$THUMB_URL/$image_id.jpg";
                }
            }
        }
    }


        
    ## Update database information
    if( !$removed )
    {
        my @bind_values = ();
        my @bind_list = ();

        for( sort keys %$changes )
        {
            push(@bind_values, $changes->{$_});
            push(@bind_list, "$_=?");
        }

        $DB->Update("UPDATE ags_Galleries SET " . join(',', @bind_list) . " WHERE Gallery_ID=?", [@bind_values, $row->{'Gallery_ID'}]);
    }
}
$stop_time = time;

$DB->Free($result);
$DB->Disconnect();

#REPLACE

## Put the footer on the report file
ReportFooter();


## Update TGP Pages
BuildAllReorder() if( $build_pages );


## Send e-mail
SendCompleteEmail() if( $send_email );


sleep(10) if( !$stopped && (($stop_time - $start_time) < 10) );


## Remove the PID and status files
FileRemove("$DDIR/scanner/$config.pid");
FileRemove("$DDIR/scanner/$config.sta") if( -e "$DDIR/scanner/$config.sta" );
FileRemove("$DDIR/scanner/$config.sto") if( -e "$DDIR/scanner/$config.sto" );



########################################################################################################
########################################################################################################
########################################################################################################



sub SendCompleteEmail
{
    my $message = "=>[Subject]\n" .
                  "AutoGallery SQL Scanner Completed\n" .
                  "=>[Text]\n" .
                  "The AutoGallery SQL gallery scanner has completed it's task.\n" .
                  "$examined of $total galleries were examined.\n" .
                  "A report has been generated for you to view.\n" .
                  "$CGI_URL/admin/main.cgi?Run=DisplayReport&Page=report-$config.html\n" .
                  "=>[HTML]\n" .
                  "The AutoGallery SQL gallery scanner has completed it's task.<br />\n" .
                  "$examined of $total galleries were examined.<br />\n" .
                  "A report has been generated for you to view.<br />\n" .
                  "<a href=\"$CGI_URL/admin/main.cgi?Run=DisplayReport&Page=report-$config.html\">View Report</a>\n";

    $T{'To'} = $ADMIN_EMAIL;
    $T{'From'} = $ADMIN_EMAIL;

    Mail(\$message);
}



sub HandleSignal
{
    my $signal = shift;
    $stop_time = time;

    $DB->Free();
    $DB->Disconnect();

    $T{'Signal'} = "Exited on SIG$signal<br />"; 
    ReportFooter();

    ## Send e-mail
    SendCompleteEmail() if( $send_email );

    FileRemove("$DDIR/scanner/$config.pid");
    FileRemove("$DDIR/scanner/$config.sta") if( -e "$DDIR/scanner/$config.sta" );
    FileRemove("$DDIR/scanner/$config.sto") if( -e "$DDIR/scanner/$config.sto" );

    exit;
}



sub LoadProxies
{
    my $proxies = FileReadArray("$DDIR/proxies.txt");

    for( @$proxies )
    {
        $_ =~ s/\s//gi;
    }

    return $proxies;
}



sub ProcessGallery
{
    my $gallery = shift;
    my $results = shift;
    my $status  = shift;
    my $reason  = undef;
    my $removed = undef;
    my $penalty = 0x00000000;
    my %reasons = (
                    'connection'   => "Connection Error: $results->{'Error'}",
                    'redirect'     => "Redirecting URL: $results->{'Status'}",
                    'broken_url'   => "Broken URL: $results->{'Status'}",                    
                    'blacklist'    => "Blacklisted Data: $results->{'Blacklist_Item'}",
                    'banned_html'  => 'Blacklisted HTML',
                    'no_recip'     => 'No Reciprocal Link',
                    'thumb_change' => 'Thumbnail Count Changed',
                    'max_links'    => 'Too Many Links',
                    'page_change'  => 'Page Content Has Changed',
                    'no_2257'      => 'No 2257 Code On Gallery'
                  );


    ## Determine the most strict penalty based on the
    ## infractions that were found
    for( keys %exception )
    {
        if( $status & $exception{$_} && ${$_} >= $penalty )
        {
            $reason  = $reasons{$_};
            $penalty = ${$_};
        }
    }


    ## Blacklist
    if( $penalty & $penalty_blacklist )
    {
        $t_blacklist++;
        $t_exception++;

        $status  = 'Blacklisted';
        $removed = 1;

        RemoveGallery($gallery);

        if( $gallery->{'Type'} eq 'Submitted' )
        {
            AddBlacklist('domain', LevelUpURL($gallery->{'Gallery_URL'}));
            AddBlacklist('email', $gallery->{'Email'});
            AddBlacklist('submitip', $gallery->{'Submit_IP'});
        }
    }

    ## Delete
    elsif( $penalty & $penalty_delete )
    {
        $t_delete++;
        $t_exception++;

        $removed = 1;
        $status  = '<font color="red">Deleted</font>';

        RemoveGallery($gallery);
    }

    ## Pending
    elsif( $penalty & $penalty_disabled )
    {
        $t_disabled++;
        $t_exception++;

        $status = '<font color="blue">Moved to Disabled</font>';

        $DB->Update("UPDATE ags_Galleries SET Status='Disabled',Comments=? WHERE Gallery_ID=?", [$reason, $gallery->{'Gallery_ID'}]);
    }

    ## Display in report
    elsif( $penalty & $penalty_report )
    {
        $t_exception++;

        $status = '<font color="Green">Unchanged</font>';
    }

    ## Ignore
    else
    {
        return $removed;
    }

    
    UpdateReport($gallery, $status, $reason, $results);

    return $removed;
}



sub RemoveGallery
{
    my $gallery = shift;

    $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$gallery->{'Gallery_ID'}]);

    if( $gallery->{'Account_ID'} )
    {
        $DB->Update("UPDATE ags_Accounts SET Removed=Removed+1 WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
    }

    if( -e "$THUMB_DIR/$gallery->{'Gallery_ID'}.jpg" )
    {
        FileRemove("$THUMB_DIR/$gallery->{'Gallery_ID'}.jpg");
    }
}



sub AddBlacklist
{
    my $type = shift;
    my $item = shift;

    return if( $item =~ /^\s*$/ );
    
    $DEL = "\n";
    DBInsert("$DDIR/blacklist/$type", $item);
    $DEL = '|';
}



sub UpdateReport
{
    my $gallery = shift;
    my $status  = shift;
    my $reason  = shift;
    my $results = shift;
    my $row     = <<'HTML';
<tr>
<td width="75" valign="top">
<div class="padded" style="font-weight: bold;">
##Gallery_ID##
</div>
</td>
<td width="100" valign="top">
<div class="padded" style="font-weight: bold;">
##Status##
</div>
</td>
<td>
<div class="padded">
<a href="##Gallery_URL##" class="link" target="_blank">##Gallery_URL##</a><br />
##Reason##
##Proxy##
</td>
<td width="135" valign="top">
<div class="padded" style="visibility: ##Visibility##;">
<a href="" onClick="return deleteGallery('##Gallery_ID##', ##Permanent##);" class="link">[Delete]</a>
&nbsp;&nbsp;
<a href="" onClick="return quickBan('##Gallery_ID##', ##Permanent##);" class="link">[Blacklist]</a>
</td>
</tr>
<tr>
<td colspan="4" class="line"></td>
</tr>
HTML

    $T{'Gallery_ID'}  = $gallery->{'Gallery_ID'};
    $T{'Gallery_URL'} = $gallery->{'Gallery_URL'};
    $T{'Status'}      = $status;
    $T{'Reason'}      = $reason;
    $T{'Proxy'}       = $results->{'Proxy'} ? "<br />Proxy: $results->{'Proxy'}" : '';
    $T{'Visibility'}  = $status =~ /Unchanged|Pending/ ? 'visible' : 'hidden';
    $T{'Permanent'}   = ($which_galleries eq 'Permanent' ? 1 : 0);

    StringParseRet(\$row);

    FileAppend("$DDIR/report-$config.html", $row);
}



sub ReportHeader
{
my $head = <<'HTML';
<html>
<head>
<style>
td{font-family: Verdana; font-size: 11px;}
.padded{margin-top: 5px; margin-left: 5px; margin-bottom: 5px;}
.link{text-decoration: none; color: DarkBlue;}
.link:hover{text-decoration: none; color: Red;}
.line{height: 1px; background-color: #dcdcdc;}
.big{font-family: Arial; font-size: 16px;}
body{font-family: Arial;}
</style>
<script language="JavaScript">
function deleteGallery(id, perm)
{
    var url = null;

    if( perm )
    {
        url = "##Script_URL##/admin/main.cgi?Run=DeletePermanent&Permanent_ID=" + id;
    }
    else
    {
        url = "##Script_URL##/admin/main.cgi?Run=DeleteGallery&Gallery_ID=" + id;
    }

    if( !confirm('Are you sure you want to delete this gallery?') )
    {
        return false;
    }

    window.open(url, '_blank', 'menubar=no,height=100,width=350,scrollbars=yes,top=300,left=300');
    
    return false;
}

function quickBan(id, perm)
{
    if( perm )
    {
        alert("This feature is not available for permanent galleries");
    }
    else
    {
        var url = "##Script_URL##/admin/main.cgi?Run=DisplayQuickBan&Gallery_ID=" + id;

        window.open(url, '_blank', 'menubar=no,height=225,width=650,scrollbars=yes,top=300,left=300');
    }
    
    return false;
}
</script>
</head>

<body bgcolor="#ececec">

<div align="center">

<h3>Report For ##Date##<br />##Time##</h3>

<table bgcolor="#ffffff" width="80%" cellpadding="0" cellspacing="0" style="border: 1px solid black;">
HTML

    $T{'Script_URL'} = $CGI_URL;
    $T{'Date'}       = Date('%M %d, %Y %h:%i:%s %p');

    StringParseRet(\$head);

    FileWrite("$DDIR/report-$config.html", $head);
}



sub ReportFooter
{

my $foot = <<'HTML';
</table>

<h4>
##Signal##
##Examined## of ##Total## Galleries Examined<br />
##Run_Time##
</h4>

<table width="200">
<tr>
<td class="big">
<b>Exceptions</b>
</td>
<td class="big">
##Exception##
</td>
</tr>
<tr>
<td class="big">
<b>Moved to Disabled</b>
</td>
<td class="big">
##Disabled##
</td>
</tr>
<tr>
<td class="big">
<b>Deleted</b>
</td>
<td class="big">
##Deleted##
</td>
</tr>
<tr>
<td class="big">
<b>Blacklisted</b>
</td>
<td class="big">
##Blacklisted##
</td>
</tr>
</table>

</div>

</body>
</html>
HTML
    
    $T{'Blacklisted'} = $t_blacklist;
    $T{'Exception'}   = $t_exception;
    $T{'Deleted'}     = $t_delete;
    $T{'Disabled'}    = $t_disabled;
    $T{'Total'}       = $total;
    $T{'Examined'}    = $examined;
    $T{'Run_Time'}    = AgeString($stop_time-$start_time);

    StringParseRet(\$foot);

    FileAppend("$DDIR/report-$config.html", $foot);
}


sub AcceptableMysqlVersion
{
    my $version = $DB->Count('SELECT VERSION()');

    if( $version =~ /(\d+)\.(\d+)\.(\d+)/ )
    {
        $major = $1;
        $minor = $2;
        $patch = $3;

        if( $major < 4 )
        {
            return 0;
        }
        elsif( $minor > 0 )
        {
            return 1;
        }
        elsif( $patch < 3 )
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 0;
    }
}


sub SetupQualifier
{
    my $qualifier = undef;
    my @wheres = ('Allow_Scan=1');


    if( $no_thumb )
    {
        push(@wheres, "Has_Thumb=0");
    }

    if( $only_partner )
    {
        push(@wheres, "Account_ID!=''");
    }

    if( $only_type )
    {
        push(@wheres, "Type='$type'");
    }

    if( $only_status )
    {
        push(@wheres, "Status='$status'");
    }

    if( $only_sponsor )
    {
        push(@wheres, "Sponsor='" . AddSlashesString($sponsor_name) . "'");
    }

    if( $only_category )
    {
        push(@wheres, "Category='" . AddSlashesString($category_name) . "'");
    }

    if( $only_format )
    {
        push(@wheres, "Format='$format'");
    }

    if( $id_range )
    {
        push(@wheres, "Gallery_ID BETWEEN $start AND $end");
    }

    if( $zero_thumbs )
    {
        push(@wheres, "Thumbnails=0");
    }

    $qualifier = "WHERE " . join(' AND ', @wheres);
    
    return $qualifier;
}


sub AddSlashesString
{
    my $string = shift;

    $string =~ s/'/\\'/g;

    return $string;
}

