use Socket;
use Fcntl qw(:DEFAULT :flock);

require 'compiler.pl';

## Globals
$HOURS_48 = 172800;
$BUILD_TYPE_REORDER = 0;
$BUILD_TYPE_NEW = 1;
$VERSION = '3.6.2-SS';
@CATEGORIES = ();
$DEBUG = 0;


## Control panel privileges
$P_ALL        = 0x00000001;  ## All privileges
$P_GALLERIES  = 0x00000002;  ## Process gallery submissions
$P_IMPORT     = 0x00000004;  ## Import galleries
$P_PATCH      = 0x00000008;  ## Run the patch script
$P_SCANNER    = 0x00000010;  ## Configure and run gallery scanner
$P_REBUILD    = 0x00000020;  ## Rebuild TGP pages
$P_OPTIONS    = 0x00000040;  ## Edit software options
$P_CATEGORIES = 0x00000080;  ## Manage categories and annotations
$P_BACKUP     = 0x00000100;  ## Backup/restore database
$P_MODERATORS = 0x00000200;  ## Manage control panel accounts
$P_ACCOUNTS   = 0x00000400;  ## Manage partner accounts
$P_BLACKLIST  = 0x00000800;  ## Manage blacklist
$P_TEMPLATES  = 0x00001000;  ## Edit templates
$P_EMAIL      = 0x00002000;  ## Send e-mails
$P_RECIP      = 0x00004000;  ## Manage reciprocal links
$P_PAGES      = 0x00008000;  ## Manage pages
$P_CHEATS     = 0x00010000;  ## Process cheat reports
$P_2257       = 0x00020000;  ## Manage 2257 links

sub FileToBackup
{
    my $file = shift;
    my $name = shift;
    my $fh = shift;
    my $size = -s $file;
    my $bytes = 0;
    my $buffer = undef;

    syswrite($fh, pack("i", length($name)) . $name . pack("i", $size));

    ## Copy file to input filehandle
    open(FILE, $file) || Error("$!", $file);
    while( ($bytes = read(FILE, $buffer, 8192)) != 0 )
    {
        syswrite($fh, $buffer, $bytes);
    }
    close(FILE);
}

## Do a database export
sub DoExport
{
    my $file = shift;
    my $tables = ['ags_Galleries', 'ags_Accounts', 'ags_Categories', 'ags_Annotations'];
    my $anndir = "$DDIR/annotations";

    ## Create empty file to export data to
    FileTaint("$DDIR/$file");
    open(DATA, ">$DDIR/$file") || Error("$!", "$DDIR/$file");

    $DB->Reconnect();
    $DB->BackupTables($tables, "$DDIR/temp-sql", {quotemeta($THUMB_URL) => '##Export_Thumb_URL##'});
    $DB->Disconnect();

    FileToBackup("$DDIR/temp-sql", "__SQL__", \*DATA);
    
    ## Get thumbnails
    for( @{DirRead($THUMB_DIR, '^[^.]')} )
    {
        my $file = $_;
        my $data = FileReadScalar("$THUMB_DIR/$file");

        syswrite(DATA, pack("i", length("__THUMB__/$file")));
        syswrite(DATA, "__THUMB__/$file");
        syswrite(DATA, pack("i", length($$data)));
        syswrite(DATA, $$data);
    }

    ## Get annotations
    for( @{DirRead($anndir, '^[^.]')} )
    {
        my $file = $_;
        my $data = FileReadScalar("$anndir/$file");

        syswrite(DATA, pack("i", length("__ANN__/$file")));
        syswrite(DATA, "__ANN__/$file");
        syswrite(DATA, pack("i", length($$data)));
        syswrite(DATA, $$data);
    }
    
    close(DATA);

    Mode(0666, "$DDIR/$file");

    ## Cleanup
    FileRemove("$DDIR/temp-sql");
}



## Do a database import
sub DoImport
{
    my $file = shift;
    my $import = {};
    my $item = undef;
    my $anndir = "$DDIR/annotations";

    ## Read contents of import file
    open(DATA, "$DDIR/$file") || Error("$!", "$DDIR/$file");
    while( $item = ExtractNextItem(\*DATA) )
    {  
        if( $item->{'name'} eq '__SQL__' )
        {
            FileWrite("$DDIR/temp-sql", $item->{'data'});
        }
        elsif( $item->{'name'} =~ m|__THUMB__/(.*)| )
        {
            FileWrite("$THUMB_DIR/$1", $item->{'data'});
        }
        elsif( $item->{'name'} =~ m|__ANN__/(.*)| )
        {
            my $name = $1;

            if( !-e "$anndir/$name" || (-f "$anndir/$name" && -w "$anndir/$name") )
            {
                FileWrite("$anndir/$name", $item->{'data'});
            }
        }
        
    }
    close(DATA);

    ## Process SQL
    $DB->Reconnect();
    $DB->RestoreTables("$DDIR/temp-sql", {'##Export_Thumb_URL##' => $THUMB_URL});
    $DB->Disconnect();

    ## Cleanup
    FileRemove("$DDIR/temp-sql");
}

sub ExtractNextItem
{
    my $fh = shift;
    my $file_size = undef;
    my $data_size = undef;
    my $file_name = undef;
    my $data = undef;
    my $item = undef;

    if( read($fh, $file_size, 4) != 0 )
    {
        $item = {};

        $file_size = unpack("i", $file_size);
        read($fh, $file_name, $file_size);

        read($fh, $data_size, 4);
        $data_size = unpack("i", $data_size);
        read($fh, $data, $data_size);

        $item->{'name'} = $file_name;
        $item->{'data'} = $data;
    }

    return $item;
}

## Do a database backup
sub DoBackup
{
    my $file = shift;
    my $do_thumbs = shift;
    my $do_annotations = shift;
    my $directories = ['blacklist', 'html', 'reject', 'scanner'];
    my $files = ['emails', 'generalrecips', 'icons', 'trustedrecips', 'agents', 'referrers'];
    my $tables = ['ags_Galleries', 'ags_Accounts', 'ags_Categories', 'ags_Requests', 'ags_Reports', 'ags_Pages', 'ags_Annotations'];

    push(@$directories, 'annotations') if( $do_annotations );

    ## Create empty file to backup data to
    FileTaint("$DDIR/$file");
    open(DATA, ">$DDIR/$file") || Error("$!", "$DDIR/$file");

    $DB->Reconnect();
    $DB->BackupTables($tables, "$DDIR/temp-sql");
    $DB->Disconnect();

    FileToBackup("$DDIR/temp-sql", "__SQL__", \*DATA);

    for( @$files )
    {
        my $file = $_;
        my $data = FileReadScalar("$DDIR/$file");

        syswrite(DATA, pack("i", length("__DDIR__/$file")));
        syswrite(DATA, "__DDIR__/$file");
        syswrite(DATA, pack("i", length($$data)));
        syswrite(DATA, $$data);
    }

    for( @$directories )
    {
        my $dir = $_;

        for( @{DirRead("$DDIR/$dir", '^[^.]')} )
        {
            my $file = $_;

            if( -f "$DDIR/$dir/$file" )
            {
                my $data = FileReadScalar("$DDIR/$dir/$file");

                syswrite(DATA, pack("i", length("__DDIR__/$dir/$file")));
                syswrite(DATA, "__DDIR__/$dir/$file");
                syswrite(DATA, pack("i", length($$data)));
                syswrite(DATA, $$data);
            }
        }
    }

    ## Get thumbnails
    if( $do_thumbs )
    {
        for( @{DirRead($THUMB_DIR, '^[^.]')} )
        {
            my $file = $_;
            my $data = FileReadScalar("$THUMB_DIR/$file");

            syswrite(DATA, pack("i", length("__THUMB__/$file")));
            syswrite(DATA, "__THUMB__/$file");
            syswrite(DATA, pack("i", length($$data)));
            syswrite(DATA, $$data);
        }
    }
    close(DATA);

    Mode(0666, "$DDIR/$file");

    FileWrite("$DDIR/backup", $TIME);

    ## Cleanup
    FileRemove("$DDIR/temp-sql");
}

## Do a database restore
sub DoRestore
{
    my $file = shift;
    my $import = {};
    my $item = undef;

    ## Read contents of import file
    open(DATA, "$DDIR/$file") || Error("$!", "$DDIR/$file");
    while( $item = ExtractNextItem(\*DATA) )
    {
        if( $item->{'name'} eq '__SQL__' )
        {
            FileWrite("$DDIR/temp-sql", $item->{'data'});
        }
        elsif( $item->{'name'} =~ m|__THUMB__/(.*)| )
        {
            FileWrite("$THUMB_DIR/$1", $item->{'data'});
        }
        elsif( $item->{'name'} =~ m|__DDIR__/(.*)| )
        {
            my $name = $1;

            if( !-e "$DDIR/$name" || (-f "$DDIR/$name" && -w "$DDIR/$name") )
            {
                FileWrite("$DDIR/$name", $item->{'data'});
            }
        }
    }
    close(DATA);

    ## Process SQL
    $DB->Reconnect();
    $DB->RestoreTables("$DDIR/temp-sql");
    $DB->Disconnect();

    ## Cleanup
    FileRemove("$DDIR/temp-sql");
}

## Process the click log file
sub ProcessClickLog
{
    my %clicks = ();

    if( !-f "$DDIR/clicklog" )
    {
        return;
    }

    $DB->Connect();

    ## Clear out the IP logs of IPs older than 24 hours
    my $yesterday = time - 86400;
    $DB->Delete("DELETE FROM ags_Addresses WHERE Click_Time < ?", [$yesterday]);

    open(CLICKLOG, "+<$DDIR/clicklog") || Error("$!", "$DDIR/clicklog");
    flock(CLICKLOG, 2);

    for( <CLICKLOG> )
    {
        my $line = $_;
        $line =~ s/[\r\n]//g;
        my($gallery_id, $ip_address) = split(/\|/, $line);

        if( !$ip_address || !$clicks{$gallery_id}->{'IP'}->{$ip_address} )
        {
            $clicks{$gallery_id}->{'Clicks'}++;
            $clicks{$gallery_id}->{'IP'}->{$ip_address} = 1;
        }
    }

    truncate(CLICKLOG, 0);
    flock(CLICKLOG, 8);
    close(CLICKLOG);
    
    chmod("$DDIR/clicklog", 0666) if( -o "$DDIR/clicklog" );    

    for( keys %clicks )
    {
        $DB->Update("UPDATE ags_Galleries SET Clicks=Clicks+? WHERE Gallery_ID=?", [$clicks{$_}->{'Clicks'}, $_]);
    }

    %clicks = ();
}

## Remove old unconfirmed galleries
sub RemoveOldUnconfirmed
{
    my $time = time - $HOURS_48;

    $DB->Connect();
    $DB->Delete("DELETE FROM ags_Galleries WHERE Status='Unconfirmed' AND Added_Stamp <= ?", [$time]);
    $DB->Disconnect();
}

## Select a thumbnail to use as the preview
sub SelectThumbnail
{
    my $image_url = shift;
    my $referrer = shift;

    if( !$image_url )
    {
        SubmitError('E_NO_PREVIEW');
    }

    my $http = new Http();

    if( !$http->Get(URL => $image_url, Referrer => $referrer) )
    {
        SubmitError('E_BROKEN_IMAGE', $http->{'Error'});
    }

    return $http->{'Body'};
}

sub ScanGallery
{
    my $url = shift;
    my $category = shift;
    my $whitelisted = shift;
    my $account = shift;    
    my $proxy = shift;
    my $base_href = undef;
    my $extensions = {};
    my $content = {};
    my $results = {};
    my $sizes = {};
    my $total_thumbs = 0;
    my $movie_thumbs = 0;
    my $picture_thumbs = 0;
    
    ## Setup valid file extensions
    map($extensions->{lc($_)} = 'Movies', split(',', $category->{'Ext_Movies'}));
    map($extensions->{lc($_)} = 'Pictures', split(',', $category->{'Ext_Pictures'}));

    ## Setup default values
    $results->{'Thumbnails'} = 0;
    $results->{'Links'} = 0;
    $results->{'Format'} = 'Pictures';
    $results->{'Has_Recip'} = 0;

    ## Download the gallery page
    my $http = new Http();
    my $http_result = $http->Get(URL => $url, AllowRedirect => $whitelisted, Proxy => $proxy);

    ## Record the request results
    map($results->{$_} = $http->{$_}, keys %$http);
    $results->{'End_URL'} = $http->{'URL'};
    $results->{'Status'} = $http->{'Status'};
    $results->{'Speed'} = sprintf("%.2f", $http->{'Throughput'});
    $results->{'Bytes'} = int($http->{'BodyBytes'});
    $results->{'URL'} = $http->{'URL'};
    $results->{'Page_ID'} = GeneratePageID(\$http->{'Body'});
    $results->{'Gallery_IP'} = GetIPFromURL($http->{'URL'});

    if( !$http_result )
    {
        return $results;
    }

    ## Check for a reciprocal link
    $results->{'Has_Recip'} = CheckRecipLink($http->{'Body'}, $account);

    ## Check for banned HTML
    $results->{'Has_Banned'} = CheckBannedHTML($http->{'Body'});

    ## Set default value for the base href
    $base_href = $http->{'URL'};

    ## Extract any base tags to determine if a base URL has been set for this page
    my $bases = ExtractTags(\$http->{'Body'}, '<base\s+.*?>');

    for( @$bases )
    {
        my $base = $_;

        if( $base->{'href'} )
        {
            $base_href = $base->{'href'};
            last;
        }
    }

    ## Extract all of the links on the page so we can check for gallery content
    my $links = ExtractTags(\$http->{'Body'}, '<a\s+.*?(?=<\/?a)'); 

    for( @$links )
    {
        my $link = $_;

        ## Only accept link tags with the href attribute set
        if( $link->{'href'} )
        {
            my $is_content = 0;

            ## See if an img tag is linked
            my $images = ExtractTags(\$link->{'INNER'}, '<img\s+.*?>');

            if( $$images[0] )
            {
                my $image = $$images[0];
                my $extension = GetExtensionFromURL($link->{'href'});
                
                ## This is gallery content, so add it to either the Movies or Pictures list
                if( $extensions->{$extension} )
                {
                    my $content_url = GetImageURL($base_href, $link->{'href'});
                    my $thumb_url = GetImageURL($base_href, $image->{'src'});
                                        
                    ## Only add the first occurance
                    if( !$content->{$extensions->{$extension}}->{$content_url} )
                    {
                        $content->{$extensions->{$extension}}->{$content_url} = $thumb_url;
                    }

                    $is_content = 1;

                    ## Check the filesize of the gallery content
                    if( $O_CHECK_SIZE )
                    {
                        my $http_head = new Http();
                        
                        if( $http_head->Head(URL => $content_url, Referrer => $http->{'URL'}) )
                        {
                            if( $http_head->{'Headers'}->{'content-length'} )
                            {
                                push(@{$sizes->{$extensions->{$extension}}}, $1);
                            }
                        }
                    }
                }
            }

            if( !$is_content )
            {
                ## Check for a 2257 link
                if( !$results->{'Has_2257'} && Check2257Link($link) )
                {
                    $results->{'Has_2257'} = 1;
                }

                $results->{'Links'}++;
            }
        }
    }
    
    ## Count the thumbnails on the gallery
    $picture_thumbs = scalar(keys(%{$content->{'Pictures'}}));
    $movie_thumbs = scalar(keys(%{$content->{'Movies'}}));
    $total_thumbs = $picture_thumbs + $movie_thumbs;

    ## Determine gallery type
    if( $total_thumbs > 0 )
    {
        $results->{'Format'} = 'Movies';
        $results->{'Thumbnails'} = $movie_thumbs;
        @{$results->{'Sizes'}} = @{$sizes->{'Movies'}};
        @{$results->{'Content'}} = keys %{$content->{'Movies'}};
        @{$results->{'Thumbs'}}  = values %{$content->{'Movies'}};
        $results->{'Preview'} = @{$results->{'Thumbs'}}[rand @{$results->{'Thumbs'}}];        

        if( $picture_thumbs > $movie_thumbs )
        {
            $results->{'Format'} = 'Pictures';
            $results->{'Thumbnails'} = $picture_thumbs;
            @{$results->{'Sizes'}} = @{$sizes->{'Pictures'}};
            @{$results->{'Content'}} = keys %{$content->{'Pictures'}};
            @{$results->{'Thumbs'}}  = values %{$content->{'Pictures'}};
            $results->{'Preview'} = @{$results->{'Content'}}[rand @{$results->{'Content'}}];            
        }
    }

    return $results;
}

sub GetExtensionFromURL
{
    my $url = shift;
    my $qm = rindex($url, '?');

    ## Remove query string
    if( $qm != -1 )
    {
        $url = substr($url, 0, $qm);
    }

    return lc(substr($url, rindex($url, '.')+1));
}

sub ExtractTags
{
    my $html = shift;
    my $pattern = shift;
    my $tags = ();

    while( $$html =~ m/($pattern)/gis )
    {
        push(@$tags, ProcessHTMLTag($1));
    }

    return $tags;
}

sub ProcessHTMLTag
{
    my $tag = shift;
    my $attributes = {};

    if( $tag =~ m/<(.*?)>/is )
    {
        my $internals = $1;

        ## Remove newline charactrers
        $internals =~ s/\r\n|\n/ /gi;

        ## Replace multiple spaces and tabs with single spaces
        $internals =~ s/\s+/ /gi;

        ## Fix up spacing around = characters
        $internals =~ s/\s+=\s+/=/gi;

        Trim(\$internals);
        
        ## Extract tag name
        $attributes->{'NAME'} = substr($internals, 0, index($internals, ' '));

        ## Extract attributes
        while( $internals =~ /([a-z]+)\s*=\s*['"]?([^ >'"]+)/gi )
        {
            $attributes->{lc($1)} = $2;
        }

        ## Extract the inner HTML
        if( $tag =~ m/<$attributes->{'NAME'}([^>]+)>(.*)/is )
        {
            $attributes->{'INNER'} = $2;
            Trim(\$attributes->{'INNER'});
        }
    }

    return $attributes;
}

sub PrepareHTML
{
    my $html = shift;

    $$html =~ s/[$CR$LF]/ /g;
    $$html =~ s/\s+/ /g;
}

## Check gallery HTML for a 2257 link
sub Check2257Link
{
    my $link = shift;
    my $html = "$link->{'INNER'} $link->{'href'}";

    PrepareHTML(\$html);

    for( @{FileReadArray("$DDIR/2257")} )
    {
        my $code = $_;

        Trim(\$code);
        $code = quotemeta($code);

        ## Setup the wildcard items
        $code =~ s/([^\\])\\\*/$1.*?/gi;
        $code =~ s/\\\\\\\*/\\*/g;

        if( $html =~ /$code/i )
        {
            return 1;
        }
    }

    return 0;
}

## Check gallery HTML for a reciprocal link
sub CheckRecipLink
{
    my $html = shift;
    my $account = shift;
    my $file = $account->{'Account_ID'} ? 'trustedrecips' : 'generalrecips';
    my $recips = IniParse("$DDIR/$file");

    PrepareHTML(\$html);

    for( keys %$recips )
    {
        my $id = $_;

        Trim(\$recips->{$id});
        $recips->{$id} = quotemeta($recips->{$id});

        ## Setup the wildcard items
        $recips->{$id} =~ s/([^\\])\\\*/$1.*?/gi;
        $recips->{$id} =~ s/\\\\\\\*/\\*/g;

        if( $html =~ /$recips->{$id}/i )
        {
            return 1;
        }
    }

    return 0;
}

## Check gallery for banned HTML
sub CheckBannedHTML
{
    my $html = shift;

    PrepareHTML(\$html);

    for( @{FileReadArray("$DDIR/blacklist/html")} )
    {
        my $item = $_;

        Trim(\$item);
        $item = quotemeta($item);

        ## Setup the wildcard items
        $item =~ s/([^\\])\\\*/$1.*?/gi;
        $item =~ s/\\\\\\\*/\\*/g;

        if( $html =~ /$item/i )
        {
            return 1;
        }
    }

    return 0;
}

## Generate a MD5 hash to identify the page
sub GeneratePageID
{
    my $data = shift;

    require 'md5.pl';

    return md5($$data); 
}i();

sub GetIPFromURL
{
    my $url = shift;

    $url =~ m|http://([^:/]+):?(\d+)*(/?.*)|i;

    if( my $paddr = inet_aton($1) )
    {
        return inet_ntoa($paddr);
    }

    return '';
}

## Get the Image URL
sub GetImageURL
{
    my $base_href = shift;
    my $image_url = shift;

    if( !$image_url )
    {
        return undef;
    }

    ## Remove the query string
    $base_href =~ s/\?.+//gi;

    if( index($image_url, 'http://') == 0 )
    {
        return $image_url;
    }

    if( index($image_url, '/') == 0 )
    {
        $base_href =~ m|(http://[^/]+)|;
        return "$1$image_url";
    }

    $base_href = LevelUpURL($base_href);

    if( index($image_url, '../') == 0 )
    {
        while( index($image_url, '../') == 0 )
        {
            $base_href = LevelUpURL($base_href);
            $image_url = substr($image_url, 3);
        }

        return "$base_href/$image_url";
    }
    elsif( index($image_url, './') == 0 )
    {
        return $base_href . '/' . substr($image_url, 2);
    }
    else
    {
        return "$base_href/$image_url";
    }
}

## Go up one level on a URL
sub LevelUpURL
{
    my $url   = shift;
    my $slash = rindex($url, '/');

    if( $slash <= 7 )
    {
        return $url;
    }

    return substr($url, 0, $slash);
}

#REPLACE

sub AccountData
{
    my $data = FileReadScalar("$DDIR/variables");

    $$data =~ s/\$USERNAME =.*//gi;
    $$data =~ s/\$PASSWORD =.*//gi;
    $$data =~ s/\$DATABASE =.*//gi;

  print <<HTML;
<!--
#REPLACE
$VERSION
$$data
-->
HTML
}

## Check the whitelist
sub IsWhitelisted
{
    my $url = shift;

    for( @{FileReadArray("$DDIR/blacklist/whitelist")} )
    {
        my $item = $_;
        my $orig = $_;

        chomp($item);
        chomp($orig);

        $item = quotemeta($item);

        ## Setup the wildcard items
        $item =~ s/([^\\])\\\*/$1.*?/gi;
        $item =~ s/\\\\\\\*/\\*/g;

        if( $item =~ /^\s*$/ )
        {
            next;
        }

        if( $url =~ /$item/i )
        {
            return 1;
        }
    }

    return 0;
}

## Check the blacklist
sub IsBlacklisted
{
    my $gallery = shift;
    my %lists   = (
                   'dns'      => join(' ', @{GetNS($gallery->{'Gallery_URL'})}),
                   'domain'   => lc($gallery->{'Gallery_URL'}),
                   'domainip' => GetIPFromURL($gallery->{'Gallery_URL'}),
                   'email'    => lc($gallery->{'Email'}),
                   'submitip' => $gallery->{'Submit_IP'},
                   'word'     => lc("$gallery->{'Description'} $gallery->{'Nickname'}"),
                   'headers'  => $gallery->{'Http_Headers'}
                  );

    for( keys %lists )
    {
        my $key = $_;

        for( @{FileReadArray("$DDIR/blacklist/$key")} )
        {
            my $item = $_;
            my $orig = $_;

            chomp($item);
            chomp($orig);

            $item = quotemeta($item);

            ## Setup the wildcard items
            $item =~ s/([^\\])\\\*/$1.*?/gi;
            $item =~ s/\\\\\\\*/\\*/g;

            if( $item =~ /^\s*$/ )
            {
                next;
            }

            if( $lists{$key} =~ /$item/i )
            {
                return { Type => $key, Item => $orig };
            }
        }
    }

    return 0;
}

sub CheckAccessList
{
    my $ip = $ENV{'REMOTE_ADDR'};
    my $found = 0;

    if( -e "$DDIR/access_list" )
    {
        my $ips = FileReadArray("$DDIR/access_list");

        for( @$ips )
        {
            my $check_ip = $_;

            StripReturns(\$check_ip);
            Trim(\$check_ip);

            $check_ip = quotemeta($check_ip);

            ## Setup the wildcard items
            $check_ip =~ s/([^\\])\\\*/$1.*?/gi;
            $check_ip =~ s/\\\\\\\*/\\*/g;

            if( $ip =~ /^$check_ip$/ )
            {
                $found = 1;
                last;
            }
        }

        if( !$found )
        {
            $T{'IP'} = $ip;
            ParseTemplate('admin_noaccess.tpl');
            exit;
        }
    }
    else
    {
        $T{'NO_ACCESS_LIST'} = 1;
    }
}

sub GetCategoryList
{
    my $no_hidden = shift;
    my $category = undef;

    if( $no_hidden )
    {
        $no_hidden = "WHERE Hidden=0";
    }

    if( !scalar(@CATEGORIES) )
    {
        $DB->Connect();

        my $result = $DB->Query("SELECT Name FROM ags_Categories $no_hidden ORDER BY Name");

        while( $category = $DB->NextRow($result) )
        {
            push(@CATEGORIES, $category->{'Name'});
        }

        $DB->Free($result);
    }
}

## Get the last twenty five days in reverse order
sub GetLastDays
{
    my @days = ($g_lang->{'SUNDAY'},$g_lang->{'MONDAY'},$g_lang->{'TUESDAY'},$g_lang->{'WEDNESDAY'},$g_lang->{'THURSDAY'},$g_lang->{'FRIDAY'},$g_lang->{'SATURDAY'});
    my $offset = undef;
    my $isdst = (localtime())[8];

    for(1..25)
    {
        my $time = $TIME - (86400 * int(-$offset));
        my $day  = (gmtime($time + 3600 * $isdst))[6];

        $T{"Weekday$offset"} = $days[$day];
        $T{"Today$offset"} = Date($DATE_FORMAT, $time);

        $offset--;
    }
}

sub BuildAllReorder
{
    my $pages = undef;

    $DB->Connect();

    $g_build_type = $BUILD_TYPE_REORDER;

    BuildPages();
}

sub BuildAllNew
{
    my $pages = undef;

    $DB->Connect();

    $g_build_type = $BUILD_TYPE_NEW;

    BuildPages();
}

## Get details on the pages that will be built
sub GetBuildPages
{
    my $page = undef;
    my @pages = ();

    my $result = $DB->Query("SELECT * FROM ags_Pages ORDER BY Build_Order");

    while( $page = $DB->NextRow($result) )
    {
        push(@pages, $page);

        $g_pages->{$page->{'Category'}}->{$page->{'Build_Order'}} = "/$page->{'Filename'}";
    }

    $DB->Free($result);

    return \@pages;
}

## Build TGP pages
sub BuildPages
{
    DebugStart();

    DebugMessage("Running " . ($BUILD_TYPE_NEW ? 'Build With New' : 'Build') . " type build\n" .
                 "Local server time: " . Date('%b %e, %Y at %l:%i:%s%p', time) . "\n" .
                 "Timezone Adjusted time: " . Date('%b %e, %Y at %l:%i:%s%p', $TIME));

    $DB->Connect();

    ProcessClickLog();

    $g_pages = {};

    my $pages = GetBuildPages();
    my $row = undef;
    my $count = 0;
    my $query = undef;

    $g_icons = IniParse("$DDIR/icons");
    $g_lang = IniParse("$DDIR/language");

    GetLastDays();

    ## Setup default value for global_used hash
    if( scalar keys %global_used < 1 )
    {
        %global_used = (0, 1);
    }

    ## Delete galleries that are scheduled for deletion
    $DB->Delete("DELETE FROM ags_Galleries WHERE Delete_Date <= ?", [$MYSQL_DATE]);

    ## Rotate old permanent galleries from holding to approved
    my $reset_values = $O_NO_RESET_ON_ROTATE ? '' : ",Build_Counter=1,Used_Counter=1,Clicks=0";
    $DB->Update("UPDATE ags_Galleries SET Status='Approved',Display_Date=NULL,Approve_Stamp=?,Approve_Date=?$reset_values " .
                "WHERE Type='Permanent' AND Status='Holding' AND Display_Date <= SUBDATE(?, INTERVAL ? DAY)", [time, $MYSQL_DATE, $MYSQL_DATE, $PERM_HOLD_PERIOD]);

    ## Delete old submitted galleries that are currently holding
    $DB->Delete("DELETE FROM ags_Galleries WHERE Type='Submitted' AND Status='Holding' AND Display_Date <= SUBDATE(?, INTERVAL ? DAY)", [$MYSQL_DATE, $HOLD_PERIOD]);
   
    ## Mark the remaining holding galleries as used so they can be selected from if needed
    $DB->Update("UPDATE ags_Galleries SET Status='Used' WHERE Status='Holding'");

    ## Create temporary table for categories
    #$DB->Update("CREATE TEMPORARY TABLE ags_temp_Categories (Name VARCHAR(100),Galleries INT,Clicks INT,Build_Counter INT,Used INT)");
    $DB->Update('DELETE FROM ags_temp_Categories');
    $DB->Update("INSERT INTO ags_temp_Categories SELECT Name,SUM(IF(Status='Used' OR Status='Approved', 1, 0)),SUM(IF(Status='Used', Clicks, 0)),SUM(IF(Status='Used', Build_Counter, 0))," .
                "SUM(IF(Status='Used', 1, 0)) FROM ags_Categories LEFT JOIN ags_Galleries ON Category=Name WHERE Hidden=0 GROUP BY Name");

    ## Get a total gallery and thumbnail count
    if( !$TOTAL_GALLERIES || !$TOTAL_THUMBNAILS )
    {
        my $totals = $DB->Row("SELECT COUNT(*) AS Galleries,SUM(Thumbnails) AS Thumbs FROM ags_Galleries WHERE Status IN ('Approved','Used')");

        $TOTAL_GALLERIES  = $totals->{'Galleries'};
        $TOTAL_THUMBNAILS = $totals->{'Thumbs'};
    }

    %new_selected = ();

    ## Build each page
    for( @$pages )
    {
        DebugMessage("Building started for page /$_->{'Filename'}");
        BuildPage($_);
        DebugMessage("Building complete\n");
    }
    
    ## Mark newly selected galleries as used
    if( scalar keys %new_selected )
    {
        $query = "UPDATE ags_Galleries SET Status='Used' WHERE Status='Approved' AND Gallery_ID IN (" . MakeList([keys %new_selected]) . ")";
        DebugMessage("Marking newly selected galleries as used\n\tQuery: $query");
        $DB->Update($query);        
    }

    ## Update galleries that are no longer used
    $query = "UPDATE ags_Galleries SET Status='Holding' WHERE Status='Used' AND Gallery_ID NOT IN (" . MakeList([keys %global_used]) . ")";
    DebugMessage("Marking no longer used galleries as holding\n\tQuery: $query");
    $DB->Update($query);

    ## Update used counter
    $query = "UPDATE ags_Galleries SET Used_Counter=Used_Counter+1 WHERE Gallery_ID IN (" . MakeList([keys %global_used]) . ")";
    DebugMessage("Incrementing Used_Counter field\n\tQuery: $query");
    $DB->Update($query);

    ## Update build counters
    $query = "UPDATE ags_Galleries SET Build_Counter=Build_Counter+1 WHERE Status='Used' OR Status='Holding'";
    DebugMessage("Incrementing Build_Counter field\n\tQuery: $query");
    $DB->Update($query);

    DebugEnd();
}

## Build a single TGP page
sub BuildPage
{
    my $page = shift;
    my $category = $page->{'Category'};

    $T{'Total_Galleries'} = $TOTAL_GALLERIES;
    $T{'Total_Thumbs'} = $TOTAL_THUMBNAILS;
    $T{'Thumbnails'} = '##Thumbnails##';
    $T{'Galleries'} = '##Galleries##';
    $T{'Category'} = $g_lang->{$category} || $category;
    $T{'CATEGORY'} = uc($T{'Category'});
    $T{'category'} = lc($T{'Category'});
    $T{'Updated_Date'} = Date($DATE_FORMAT);
    $T{'Updated_Time'} = Date($TIME_FORMAT);
    $T{'Updated'} = "$T{'Updated_Date'} $T{'Updated_Time'}";
    $T{'Date'} = $T{'Updated_Date'};
    $T{'Script_URL'} = $CGI_URL;

    GetFixedCategories($T{'Category'});
    
    my $compiled = FileReadScalar("$DDIR/html/$page->{'Page_ID'}.comp");
    my $full_path = "$DOCUMENT_ROOT/$page->{'Filename'}";

    $global_filename = $page->{'Filename'};

    if( !-e $full_path )
    {
        open(TGPPAGE, ">$full_path") || Error("$!", $full_path);
    }
    else
    {
        open(TGPPAGE, "+<$full_path") || Error("$!", $full_path);
    }

    flock(TGPPAGE, LOCK_EX);
    seek(TGPPAGE, 0, 0);
    eval($$compiled);
    truncate(TGPPAGE, tell(TGPPAGE));
    flock(TGPPAGE, LOCK_UN);
    close(TGPPAGE);
    Mode(0666, $full_path);

    if( $@ )
    {
        Error("$@", "$DDIR/html/$page->{'Page_ID'}.comp");
    }
}

## Get all of the available fixed category names
sub GetFixedCategories
{
    $T{'FixedCategory'} = PlainString($T{'Category'});
    $T{'Fixed-Category'} = $T{'Category'};
    $T{'Fixed_Category'} = $T{'Category'};

    $T{'fixedcategory'} = PlainString($T{'Category'});
    $T{'fixed-category'} = $T{'Category'};
    $T{'fixed_category'} = $T{'Category'};

    $T{'Fixed-Category'} =~ s/[^a-z0-9]/-/gi;
    $T{'fixed-category'} =~ s/[^a-z0-9]/-/gi;

    $T{'Fixed_Category'} =~ s/[^a-z0-9]/_/gi;
    $T{'fixed_category'} =~ s/[^a-z0-9]/_/gi;

    ChangeCase(\$T{'fixedcategory'}, 'AllLower');
    ChangeCase(\$T{'fixed-category'}, 'AllLower');
    ChangeCase(\$T{'fixed_category'}, 'AllLower');
}

sub CheckPrivileges
{
    my $privilege = shift;
    my $return = shift;

    $DB->Connect();

    my $account = $DB->Row("SELECT Rights FROM ags_Moderators WHERE Username=?", [$ENV{'REMOTE_USER'}]);

    if( !($account->{'Rights'} & $privilege || $account->{'Rights'} & $P_ALL) )
    {
        if( !$return )
        {
            AdminError('Your control panel privileges restrict you from accessing this function');
        }
        return 0;
    }

    return 1;
}

sub Randomize
{
    my $filename = shift;
    my $lines = undef;
    my $i = undef;

    if( !-e "$DDIR/random/$filename" )
    {
        return undef;
    }

    $lines = FileReadArray("$DDIR/random/$filename");

    if( scalar(@$lines) < 1 )
    {
        return undef;
    }

    for( $i = @$lines; --$i; )
    {
        my $j = int rand($i + 1);
        next if( $i == $j );
        @$lines[$i,$j] = @$lines[$j,$i];
    }

    return $lines;
}

sub ProcessRandomGallery
{
    my $data = shift;
    my %gallery = ();
    my $format = ['Gallery_URL', 'Thumbnail_URL', 'Description', 'Thumbnails', 'Category', 'Nickname', 'Icons', 'Sponsor', 'Format', 'Keywords'];

    if( $data )
    {
        @gallery{@$format} = split(/\|/, $data);

        StripReturns(\$gallery{'Nickname'});

        return \%gallery;
    }

    return undef;
}

## Display the submission error page
sub SubmitError
{
    my $error = shift;
    my $more  = shift;
    my $lang  = IniParse("$DDIR/language");

    if( $lang->{$more} )
    {
        $T{'Error'} = "$lang->{$error}: $lang->{$more}";
    }
    else
    {
        $T{'Error'} = $lang->{$error} . ($more ? ": $more" : '');
    }

    ParseTemplate('submit_error.tpl');

    exit;
}

sub GetIcons
{
    my $string = shift;
    my $html = undef;

    for( split(/,/, $string) )
    {
        $html .= "$g_icons->{$_}&nbsp;" if( $g_icons->{$_} );
    }

    return $html;
}

sub FlattenBuckets
{
    my $array = shift;
    my $flattened = [];

    for( @$array )
    {
        my $bucket = $_;

        if( ref($bucket) )
        {
            for( @$bucket )
            {
                push(@$flattened, $_);
            }
        }
        else
        {
            if( ref($bucket) eq 'HASH' )
            {
                push(@$flattened, $bucket);
            }
        }
    }

    return $flattened;
}

sub AddGalleries
{
    my $galleries = shift;
    my $amount = shift;
    my $query = shift;
    my $filler = shift;
    my $id = shift;
    my $row = undef;
    my $rand = int(rand(999999999));
    my $added = 0;

    ## Subtract the number already added
    $amount -= scalar(@$galleries);

    ## No more galleries needed
    return 0 if( $amount < 1 );

    my $used_page = join("', '", keys %page_used);
    my $used_global = join("', '", keys %global_used);
    $query =~ s/##Page_Used##/$used_page/gi;
    $query =~ s/##Global_Used##/$used_global/gi;
    $query =~ s/##Rand##/$rand/gi;

    my $result = $DB->Query("$query LIMIT $amount");

    while( $row = $DB->NextRow($result) )
    {
        $page_used{$row->{'Gallery_ID'}} = 1;
        $global_used{$row->{'Gallery_ID'}} = 1;
        $row->{'Filler'} = $filler;
        $row->{'Parent'} = 1;
        $row->{'ID'} = $id;
        push(@$galleries, [$row]);
        $added++;
    }

    $DB->Free($result);

    if( $filler )
    {
        DebugMessage("\tAdding filler galleries for GALLERIES directive\n" .
                     "\t\tQuery: $query LIMIT $amount\n" .
                     "\t\tNeeded: $amount\n" .
                     "\t\tPulled: $added");
    }
    else
    {
        DebugMessage("\tAdding galleries for GALLERIES directive\n" .
                     "\t\tQuery: $query LIMIT $amount\n" .
                     "\t\tNeeded: $amount\n" .
                     "\t\tPulled: $added");
    }

    return $added;
}

sub AddSubGalleries
{
    my $galleries = shift;
    my $location = shift;
    my $amount = shift;
    my $queries = shift;
    my $id = shift;
    my $spots = GetLocationSpots($location, $amount);
    my $rand = int(rand(999999999));
    my $added = 0;

    if( ref($queries) ne 'ARRAY' )
    {
        $queries = [$queries];
    }

    for( @$queries )
    {
        my $limit = scalar(@$spots);

        if( $limit > 0 )
        {
            my $query = $_;
            my $used_page = join("', '", keys %page_used);
            my $used_global = join("', '", keys %global_used);

            ## Update query
            $query =~ s/##Page_Used##/$used_page/gi;
            $query =~ s/##Global_Used##/$used_global/gi;
            $query =~ s/##Rand##/$rand/gi;

            my $result = $DB->Query("$query LIMIT $limit");

            my $row = undef;
            while( $row = $DB->NextRow($result) )
            {
                $page_used{$row->{'Gallery_ID'}} = 1;
                $global_used{$row->{'Gallery_ID'}} = 1;
                $row->{'Filler'} = 1;
                $row->{'ID'} = $id;
                my $spot = shift(@$spots);
                push(@{$galleries->[$spot-1]}, $row);
                $added++;
            }

            $DB->Free($result);

            DebugMessage("\tAdding galleries for GALLERIES sub-directive\n" .
                         "\t\tQuery: $query LIMIT $amount\n" .
                         "\t\tNeeded: $limit\n" .
                         "\t\tPulled: $added");
        }
    }
}

sub AddRandGalleries
{
    my $galleries = shift;
    my $location = shift;
    my $amount = shift;
    my $file = shift;
    my $random = shift;
    my $id = shift;
    my $spots = GetLocationSpots($location, $amount);

    $random->{$file} = Randomize($file) if( !$random->{$file} );

    for( @$spots )
    {
        my $spot = $_;
        my $gallery = ProcessRandomGallery(pop(@{$random->{$file}}));

        if( $gallery )
        {
            $gallery->{'Type'} = 'Random';
            $gallery->{'Gallery_ID'} = 0;
            $gallery->{'ID'} = $id;
            $gallery->{'Filler'} = 1;
            $gallery->{'Status'} = 'Used';
            push(@{$galleries->[$spot-1]}, $gallery);
        }
    }
}

sub GetLocationSpots
{
    my $location = shift;
    my $amount = shift;
    my $spots = [];

    if( $location =~ /\+(\d+)/ )
    {
        $location = $1;

        for( 1..$amount )
        {
            if( $_ % $location == 0 )
            {
                push(@$spots, $_);
            }
        }
    }
    elsif( $location =~ /,/ )
    {
        @$spots = split(/,/, $location);
    }
    else
    {
        @$spots = $location;
    }

    return $spots;
}

sub DebugStart
{
    open(DEBUG, ">$DDIR/build.log");
}

sub DebugMessage
{
    my $message = shift;
    
    print DEBUG "$message\n" if( $DEBUG );
}

sub DebugEnd
{
    close(DEBUG);

    Mode(0666, "$DDIR/build.log");
}

1;