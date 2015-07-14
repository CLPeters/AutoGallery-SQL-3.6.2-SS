#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
###########################################################################
##  ags2.0.x.cgi - Utility to export data from AutoGallery SQL 2.0.x     ##
###########################################################################


$|++;

print "Content-type: text/html\n\n<pre>\n";


eval
{
    require 'ags.pl';
    $HEADER = 1;
    main();
};


err("$@", 'ags2.0.x.cgi') if( $@ );


sub main
{
    my $data = {};

    if( $VERSION !~ /^2\.0\.\d+/ )
    {
        print "Could not locate a 2.0.x installation of AutoGallery SQL";
        exit;
    }

    print "Exporting AutoGallery SQL v$VERSION data\n\n\n";



    ## Export all of the datafiles
    print "  Exporting datafiles............";

    $data->{'data'} = _GetBannedHTML() .
                      _GetBlacklist() .
                      _GetEmailLog() .
                      _GetIcons() .
                      _GetRecips();

    print "done\n";


    ## Export the MySQL database
    print "  Exporting MySQL database.......";

    my $sth = SQLQuery("SELECT * FROM ags_posts");

    while( $g = $sth->fetchrow_hashref )
    {
        $g->{'Gallery_ID'} = $g->{'pid'};
        $g->{'Email'} = $g->{'mail'};
        $g->{'Gallery_URL'} = $g->{'gurl'};
        $g->{'Description'} = $g->{'gdes'};
        $g->{'Thumbnails'} = $g->{'pics'};
        $g->{'Category'} = $g->{'cat'};
        $g->{'Sponsor'} = '';
        $g->{'Has_Thumb'} = 0;
        $g->{'Thumbnail_URL'} = undef;
        $g->{'Thumb_Width'} = undef;
        $g->{'Thumb_Height'} = undef;
        $g->{'Weight'} = $g->{'rate'};
        $g->{'Nickname'} = '';
        $g->{'Clicks'} = 0;
        $g->{'Type'} = 'Submitted';
        $g->{'Format'} = 'Pictures';
        $g->{'Status'} = 'Approved';
        $g->{'Confirm_ID'} = undef;
        $g->{'Added_Date'} = $g->{'sdate'};
        $g->{'Added_Stamp'} = $g->{'time'};
        $g->{'Approve_Date'} = $g->{'adate'};
        $g->{'Approve_Stamp'} = time;
        $g->{'Scheduled_Date'} = undef;
        $g->{'Display_Date'} = undef;
        $g->{'Delete_Date'} = undef;
        $g->{'Account_ID'} = $g->{'part'} eq '-' ? '' : $g->{'part'};
        $g->{'Moderator'} = $g->{'mod'} eq '-' ? '' : $g->{'mod'};
        $g->{'Submit_IP'} = $g->{'ip'};
        $g->{'Gallery_IP'} = '';
        $g->{'Scanned'} = 0;
        $g->{'Links'} = 0;
        $g->{'Has_Recip'} = $g->{'rfnd'};
        $g->{'Page_Bytes'} = 0;
        $g->{'Page_ID'} = '';
        $g->{'Speed'} = 0.0;
        $g->{'Icons'} = $g->{'icon'};
        $g->{'Allow_Scan'} = 1;
        $g->{'Allow_Thumb'} = 1;
        $g->{'Times_Selected'} = 0;
        $g->{'Used_Counter'} = 1;
        $g->{'Build_Counter'} = 1;
        $g->{'Keywords'} = '';
        $g->{'Comments'} = undef;
        $g->{'Tag'} = undef;

       
        if( $g->{'arch'} )
        {
            $g->{'Status'} = 'Used';
        }
        elsif( $g->{'app'} )
        {
            $g->{'Status'} = 'Approved';
        }
        elsif( $g->{'confd'} )
        {
            $g->{'Status'} = 'Pending';
            $g->{'Approve_Date'} = undef;
            $g->{'Approve_Stamp'} = undef;
        }
        else
        {
            $g->{'Status'} = 'Unconfirmed';
            $g->{'Approve_Date'} = undef;
            $g->{'Approve_Stamp'} = undef;
        }
        
        $data->{'sql'} .= "INSERT INTO ags_Galleries VALUES (" .
                  MakeList([$g->{'Gallery_ID'},
                  $g->{'Email'},
                  $g->{'Gallery_URL'},
                  $g->{'Description'},
                  $g->{'Thumbnails'},
                  $g->{'Category'},
                  $g->{'Sponsor'},
                  $g->{'Has_Thumb'},
                  $g->{'Thumbnail_URL'},
                  $g->{'Thumb_Width'},
                  $g->{'Thumb_Height'},
                  $g->{'Weight'},
                  $g->{'Nickname'},
                  $g->{'Clicks'},
                  $g->{'Type'},
                  $g->{'Format'},
                  $g->{'Status'},
                  $g->{'Confirm_ID'},
                  $g->{'Added_Date'},
                  $g->{'Added_Stamp'},
                  $g->{'Approve_Date'},
                  $g->{'Approve_Stamp'},
                  $g->{'Scheduled_Date'},
                  $g->{'Display_Date'},
                  $g->{'Delete_Date'},
                  $g->{'Account_ID'},
                  $g->{'Moderator'},
                  $g->{'Submit_IP'},
                  $g->{'Gallery_IP'},
                  $g->{'Scanned'},
                  $g->{'Links'},
                  $g->{'Has_Recip'},
                  $g->{'Page_Bytes'},
                  $g->{'Page_ID'},
                  $g->{'Speed'},
                  $g->{'Icons'},
                  $g->{'Allow_Scan'},
                  $g->{'Allow_Thumb'},
                  $g->{'Times_Selected'},
                  $g->{'Used_Counter'},
                  $g->{'Build_Counter'},
                  $g->{'Keywords'},
                  $g->{'Comments'},
                  $g->{'Tag'}]) . ");\n";
    }

    $sth->finish;

    $sth = SQLQuery("SELECT * FROM ags_parts");

    while( $g = $sth->fetchrow_hashref )
    {
        $g->{'Account_ID'} = $g->{'pid'};
        $g->{'Password'} = $g->{'pass'};
        $g->{'Email'} = $g->{'mail'};
        $g->{'Weight'} = 1.000;
        $g->{'Allowed'} = 10;
        $g->{'Submitted'} = 0;
        $g->{'Removed'} = 0;
        $g->{'Auto_Approve'} = 1;
        $g->{'Check_Recip'} = 0;
        $g->{'Check_Black'} = 1;
        $g->{'Check_HTML'} = 1;
        $g->{'Confirm'} = 0;
        $g->{'Icons'} = $g->{'icon'};


        $data->{'sql'} .= "INSERT INTO ags_Accounts VALUES (" .
                  MakeList([$g->{'Account_ID'},
                  $g->{'Password'},
                  $g->{'Email'},
                  $g->{'Weight'},
                  $g->{'Allowed'},
                  $g->{'Submitted'},
                  $g->{'Removed'},
                  $g->{'Auto_Approve'},
                  $g->{'Check_Recip'},
                  $g->{'Check_Black'},
                  $g->{'Check_HTML'},
                  $g->{'Confirm'},
                  $g->{'Icons'},
                  undef,
                  undef]) .
                  ");\n"; 

    }

    $sth->finish;

    print "done\n";

    open(DATA, ">$DDIR/upgrade.dat") || Error("$!", "$DDIR/upgrade.dat");
    syswrite(DATA, pack("i", length('__SQL__')) . '__SQL__' .  pack("i", length($data->{'sql'})) . $data->{'sql'});    
    syswrite(DATA, $data->{'data'});
    close(DATA);

    print "\n\nData export is complete, continue with\n" .
          "the next step in the upgrade process";

    SQLDisconnect();
}



sub _GetRecips
{
    my $recips = undef;

    for( @{dread("$DDIR/links", '^[^.]')} )
    {
        my $file = $_;
        my $temp = ${freadalls("$DDIR/links/$file")};

        _UnixFormat(\$temp);

        $temp =~ s/\n$//gm;

        $recips .= "=>[$file]\n$temp\n";
    }

    return WriteData("__DDIR__/trustedrecips", $recips). WriteData("generalrecips", $recips);
}



sub _GetIcons
{
    my $icons = undef;

    for( @{dread("$DDIR/icons", '^[^.]')} )
    {
        my $file = $_;
        my $temp = ${freadalls("$DDIR/icons/$file")};

        _UnixFormat(\$temp);

        $temp =~ s/\n$//gm;

        $icons .= "=>[$file]\n$temp\n";
    }

    return WriteData("__DDIR__/icons", $icons);
}



sub _GetEmailLog
{
    my $log = ${freadalls("$DDIR/dbs/email.log")};

    _UnixFormat(\$log);

    $log =~ s/ $//;
    $log =~ s/^ //;

    return WriteData("__DDIR__/emails", $log);
}



sub _GetBannedHTML
{
    my $banned = undef;

    for( @{dread("$DDIR/banned", '^[^.]')} )
    {
        my $temp = ${freadalls("$DDIR/banned/$_")};

        $temp =~ s/\r|\n//g;
        $temp =~ s/ $//;
        $temp =~ s/^ //;

        $banned .= "$temp\n";
    }

    return WriteData("__DDIR__/blacklist/html", $banned);
}



sub _GetBlacklist
{
    my %black = ('email.ban', 'email', 'IP.ban', 'submitip', 'url.ban', 'domain', 'word.ban', 'word');
    my $result = undef;

    for( keys %black )
    {
        my $file = $_;
        my $temp = ${freadalls("$DDIR/dbs/$file")};

        _UnixFormat(\$temp);

        $temp =~ s/ $//gm;
        $temp =~ s/^ //gm;
        
        $result .= WriteData("__DDIR__/blacklist/$black{$file}", $temp);
    }

    return $result;
}



sub WriteData
{
    my $file = shift;
    my $data = shift;
    my $result = undef;
    
    $result = pack("i", length("$file")) .
              "$file" .
              pack("i", length($data)) .
              $data;

    return $result;
}



sub _UnixFormat
{
    my $string = shift;
    my $CRLF   = "\r\n";
    my $CR     = "\r";
    my $LF     = "\n";

    $$string =~ s/$CRLF/$LF/g;
    $$string =~ s/$CR/$LF/g;
}



sub MakeList
{
    my $items = shift;

    for( @$items )
    {
        if( !defined $_ )
        {
            $_ = 'NULL';
        }
        else
        {
            AddSlashes(\$_);

            $_ = "'$_'";
        }
    }

    return join(',', @$items);
}



sub AddSlashes
{
    my $string = shift;

    $$string =~ s/'/\\'/g;
}

