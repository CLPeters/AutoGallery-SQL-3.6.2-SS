#!/usr/bin/perl

chdir('..');

$|++;

eval
{
    require 'common.pl';
    require 'ags.pl';
    require 'mysql.pl';
    require 'http.pl';
    require 'size.pl';
    $ERROR_LOG = 1;
    Header("Content-type: text/html\n\n");
    Main();
};


if( $@ )
{
    Error("$@", 'xml.cgi');
}


sub Main
{
    ParseRequest();

    ## Execute a thumbnail filter
    if( $F{'Command'} )
    {
        ThumbnailFilter();
    }

    elsif( $F{'Optimize'} )
    {
        OptimizeDatabase();
    }

    elsif( $F{'Backup'} )
    {
        BackupDatabase();
    }

    elsif( $F{'Restore'} )
    {
        RestoreDatabase();
    }

    elsif( $F{'Export'} )
    {
        ExportDatabase();
    }

    elsif( $F{'Import'} )
    {
        ImportDatabase();
    }

    elsif( $F{'Gallery_ID'} )
    {
        Scan();
    }

    ## Load preview thumbs
    elsif( $F{'Thumbs'} )
    {
        LoadThumbs();
    }

    ## Load full size image
    elsif( $F{'Full'} )
    {
        LoadFullImage();
    }

    elsif( $F{'ErrorLog'} )
    {
        CheckErrorLog();
    }
    
    elsif( $F{'StartScanner'} )
    {
        StartScanner();
    }

    elsif( $F{'QueryScanner'} )
    {
        QueryScanner();
    }

    elsif( $F{'StopScanner'} )
    {
        StopScanner();
    }
}



## Start the gallery scanner
sub StartScanner
{
    CheckPrivileges($P_SCANNER);

    my $pid = fork();

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;
        exec("./scanner.cgi $F{'Config'}");
    }
    else
    {
        sleep(1);

        if( -e "$DDIR/scanner/$F{'Config'}.pid" )
        {
            Output('Success', 'Started', $F{'Config'});
        }
        else
        {
            Output('Success', 'Could not be started', $F{'Config'});
        }
    }
}



## Stop the gallery scanner
sub StopScanner
{
    CheckPrivileges($P_SCANNER);

    if( -e "$DDIR/scanner/$F{'Config'}.pid" )
    {
        FileWrite("$DDIR/scanner/$F{'Config'}.sto", 'STOP');
    }

    Output("Success|$F{'Config'}");
}



## Query the gallery scanner to check it's status
sub QueryScanner
{
    my $message = undef;
    my @results = ('Success');

    CheckPrivileges($P_SCANNER);

    for( @{DirRead("$DDIR/scanner", '[^.]')} )
    {
        my $config = $_;

        if( -e "$DDIR/scanner/$config.pid" )
        {
            if( -e "$DDIR/scanner/$config.sta" )
            {
                my $info = FileReadSplit("$DDIR/scanner/$config.sta");

                if( time - $info->[0] < 120 )
                {
                    push(@results, "Scanning gallery $info->[1] of $info->[2]|$config");
                }
                else
                {
                    FileRemove("$DDIR/scanner/$config.pid");
                    FileRemove("$DDIR/scanner/$config.sta");

                    push(@results, "Not Running|$config");
                }
            }
            else
            {
                push(@results, "Status not available|$config");
            }
        }
        else
        {
            push(@results, "Not Running|$config");
        }
    }

    OutputLines(@results);
}



sub ExportDatabase
{
    CheckPrivileges($P_BACKUP);

    AdminError('E_NOT_WRITABLE', $F{'File'}) if( -f "$DDIR/$F{'File'}" && !-w "$DDIR/$F{'File'}" );

    my $pid = fork();

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;

        DoExport($F{'File'});
    }
    else
    {
        Output('Success');
    }
}



sub ImportDatabase
{
    CheckAccessList();
    CheckPrivileges($P_BACKUP);

    AdminError('E_NO_FILE', $F{'File'}) if( !-e "$DDIR/$F{'File'}" );

    my $pid = fork();

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;

        DoImport($F{'File'});
    }
    else
    {
        Output('Success');
    }
}



## Backup the MySQL database and datafiles
sub BackupDatabase
{
    CheckPrivileges($P_BACKUP);

    AdminError('E_NOT_WRITABLE', $F{'Backup_File'}) if( -f "$DDIR/$F{'Backup_File'}" && !-w "$DDIR/$F{'Backup_File'}" );

    my $pid = fork();

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;

        DoBackup($F{'Backup_File'}, $F{'Thumbs'}, $F{'Annotations'});
    }
    else
    {        
        Output('Success');
    }
}



## Restore the MySQL database and datafiles
sub RestoreDatabase
{
    CheckAccessList();
    CheckPrivileges($P_BACKUP);

    AdminError('E_NO_FILE', $F{'Backup_File'}) if( !-e "$DDIR/$F{'Backup_File'}" );

    my $pid = fork();

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;

        DoRestore($F{'Backup_File'});
    }
    else
    {
        Output('Success');
    }
}



sub OptimizeDatabase
{
    my $tables = IniParse("$DDIR/tables");

    $DB->Connect();

    for( keys %$tables )
    {
        $DB->Update("REPAIR TABLE `$_`");
        $DB->Update("OPTIMIZE TABLE `$_`");
    }

    $DB->Disconnect();

    Output('Success');
}



sub CheckErrorLog
{
    my @stat = stat("$DDIR/error_log");

    if( -e "$DDIR/last_error" )
    {
        my $last = FileReadScalar("$DDIR/last_error");

        if( $$last < $stat[9] )
        {
            FileWrite("$DDIR/last_error", $stat[9]);
            Output('New');
        }
    }
}



sub Scan
{
    my @return_data = ();
    my $not_accessible = "This gallery is not accessible.  The following error was generated when attempting to scan this gallery: ";
    my $no_thumbs = "This gallery does not appear to contain any valid thumbnails and therefore you " .
                    "will not be able to use the web based cropping utility. Note that all thumbnails " .
                    "must link directly to the full sized image or movie.";

    $DB->Connect();

    my $whitelisted = 0;
    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
            
    ## See if gallery is whitelisted
    if( $gallery->{'Type'} eq 'Permanent' || IsWhitelisted($gallery->{'Gallery_URL'}) )
    {
        $whitelisted = 1;
    }
      
    ## Get details about the category
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$gallery->{'Category'}]);


    ## Scan the gallery
    $O_CHECK_SIZE = 0;
    my $results = ScanGallery($gallery->{'Gallery_URL'}, $category, $whitelisted);  


    ## Broken gallery URL
    if( $results->{'Error'} )
    {
        OutputLines('Error', $not_accessible . $results->{'Error'});        
        exit;
    }

    ## No valid thumbs
    if( !$results->{'Thumbnails'} )
    {
        OutputLines('Error', $no_thumbs);
        exit;
    }
    
    ## Add thumbnails and content to the template
    for( my $i = 0; $i < scalar(@{$results->{'Thumbs'}}); $i++ )
    {
        my $thumb_url = $results->{'Thumbs'}[$i];
        my $full_url = $results->{'Format'} eq 'Pictures' ? $results->{'Content'}[$i] : $thumb_url;

        push(@return_data, "$full_url|$thumb_url");
    }

    @return_data = sort(@return_data);

    unshift(@return_data, $results->{'End_URL'});

    OutputLines(@return_data);

    $DB->Disconnect();
}



sub ValidFileExtension
{
    my %valid = ('jpg' => 1, 'jpeg' => 1, 'gif' => 1, 'bmp' => 1, 'png' => 1);
    my $filename = shift;
    my $extension = lc(substr($filename, rindex($filename, '.') + 1));

    if( !exists $valid{$extension} )
    {
        return 0;
    }

    return 1;
}



## Load full size image for control panel cropping
sub LoadFullImage
{
    my $filename = ThumbFileFromURL($F{'Full'});

    ## Strip out strange characters
    $filename =~ s/[^a-z0-9_\.]//gi;

    my $full_filename = "f$F{'Prefix'}$filename";

    if( !ValidFileExtension($filename) )
    {
        Output('Error', "Invalid file type: $filename");
    }

    if( !-e "$THUMB_DIR/cache/$full_filename" )
    {
        if( !-e "$THUMB_DIR/cache" || !-w "$THUMB_DIR/cache" )
        {
            Output('Error', "$THUMB_DIR/cache does not exist or has incorrect permissions");
            exit;
        }

        my $http = new Http();

        if( $http->Get(URL => $F{'Full'}, Referrer => $F{'Gallery_URL'}, AllowRedirect => 1) )
        {
            FileWrite("$THUMB_DIR/cache/$full_filename", $http->{'Body'});
            Output('Success', "$THUMB_URL/cache/$full_filename", $full_filename);
        }
        else
        {
            Output('Error', $http->{'Error'});
        }
    }
    else
    {
        Output('Success', "$THUMB_URL/cache/$full_filename", $full_filename);
    }
}



## Load preview thumbnails for control panel cropping interface
sub LoadThumbs
{
    my $pid = fork();

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;

        my @thumbs = split(/,/, $F{'Thumbs'});
        my $total = scalar(@thumbs);
        my $hotlink = 0;
        my $http = new Http();

        FileWrite("$THUMB_DIR/cache/$F{'Prefix'}.txt", "$total\n");

        ## Hotlink test
        my $test_thumb = (split(/\|/, $thumbs[0]))[1];
        if( $http->Get(URL => $test_thumb, Referrer => "$CGI_URL/admin/main.cgi?Run=DisplayCrop&Gallery_ID=" . int(rand(999999))) )
        {
            my($w, $h, $img) = imgsize(\$http->{'Body'});

            if( $w && $h )
            {
                $hotlink = 1;
            }
        }

        for( @thumbs )
        {
            my($full, $thumb) = split(/\|/, $_);
            my $filename = ThumbFileFromURL($thumb);
            my $result = 1;

            next if( !ValidFileExtension($filename) );

            if( !$hotlink )
            {
                if( !-e "$THUMB_DIR/cache/$F{'Prefix'}$filename" )
                {
                    if( $http->Get(URL => $thumb, Referrer => $F{'Gallery_URL'}, AllowRedirect => 1) )
                    {
                        FileWrite("$THUMB_DIR/cache/$F{'Prefix'}$filename", $http->{'Body'});
                    }
                    else
                    {
                        $result = 0;
                    }
                }

                FileAppend("$THUMB_DIR/cache/$F{'Prefix'}.txt", "$THUMB_URL/cache/$F{'Prefix'}$filename|$result|$filename|$full|$hotlink\n");
            }
            else
            {
                FileAppend("$THUMB_DIR/cache/$F{'Prefix'}.txt", "$thumb|$result|$filename|$full|$hotlink\n");
            }
        }
    }
}



## Process thumbnail filtering
sub ThumbnailFilter
{
    my $id = $F{'Gallery_ID'};
    my $argument;

    if( !CheckPrivileges($P_GALLERIES, 1) )
    {
        Output('ErrorClose', 'Your control panel privileges restrict you from accessing this function');
        exit;
    }

    require 'image.pl';

    if( !-e "$THUMB_DIR/$id.jpg" )
    {
        Output('ErrorClose', "This thumbnail cannot be modified because it is not\r\nlocated in the AutoGallery SQL thumbnail directory");
        exit;
    }

    $DB->Connect();

    ## See if the starting image is in the database, and if not add it
    if( $DB->Count("SELECT COUNT(*) FROM ags_Undos WHERE Image_ID=? AND Undo_Level=0", [$id]) < 1 )
    {
        $DB->Insert("INSERT INTO ags_Undos VALUES (?, 0, ?)", [$id, ${FileReadScalar("$THUMB_DIR/$id.jpg")}]);
    }


    if( $F{'Command'} eq 'reset' )
    {    
        my $undo = $DB->Row("SELECT * FROM ags_Undos WHERE Image_ID=? AND Undo_Level=0", [$id]);        

        FileWrite("$THUMB_DIR/$id.jpg", $undo->{'Image'});

        $DB->Update("DELETE FROM ags_Undos WHERE Image_ID=? AND Undo_Level > 0", [$id]);

        Output('Level', 0);
    }
    elsif( $F{'Command'} eq 'undo' )
    {
        my $level = $DB->Count("SELECT MAX(Undo_Level) FROM ags_Undos WHERE Image_ID=?", [$id]);
        my $undo = $DB->Row("SELECT * FROM ags_Undos WHERE Image_ID=? AND Undo_Level=?", [$id, ($level - 1)]);

        FileWrite("$THUMB_DIR/$id.jpg", $undo->{'Image'});

        $DB->Update("DELETE FROM ags_Undos WHERE Image_ID=? AND Undo_Level=?", [$id, $level]);

        $level--;

        Output('Level', $level);
    }
    elsif( $F{'Command'} eq 'done' )
    {
        ApplyFilter("$THUMB_DIR/$id.jpg", 'compress');
        $DB->Update("DELETE FROM ags_Undos WHERE Image_ID=?", [$id]);
        Output('Done', 1);
    }
    elsif( $F{'Command'} eq 'cancel' )
    {
        my $undo = $DB->Row("SELECT * FROM ags_Undos WHERE Image_ID=? AND Undo_Level=0", [$id]);

        if( $undo )
        {
            FileWrite("$THUMB_DIR/$id.jpg", $undo->{'Image'});
        }

        $DB->Update("DELETE FROM ags_Undos WHERE Image_ID=?", [$id]);

        Output('Done', 1);
    }
    else
    {
        ## Lock so only one process can access at a time
        open(LOCKER, "$DDIR/xmllock");
        flock(LOCKER, 2);

        if( $F{'Command'} eq 'sharpen' )
        {
            $argument = $F{'sSigma'};
        }        
        elsif( $F{'Command'} eq 'brightness' )
        {
            $argument = $F{'bAmount'};
        }
        elsif( $F{'Command'} eq 'annotation' )
        {
            $argument = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$F{'Annotation'}]);            
        }

        ApplyFilter("$THUMB_DIR/$id.jpg", $F{'Command'}, $argument);

        $level = $DB->Count("SELECT MAX(Undo_Level) FROM ags_Undos WHERE Image_ID=?", [$id]);

        $level++;

        $DB->Insert("INSERT INTO ags_Undos VALUES (?, ?, ?)", [$id, $level, ${FileReadScalar("$THUMB_DIR/$id.jpg")}]);

        flock(LOCKER, 8);
        close(LOCKER);

        Output('Level', $level);
    }
}



## Print output
sub Output
{
    print join('|', @_);
}


sub OutputLines
{
    print join("\n", @_);
}


## Get the filename from a URL
sub ThumbFileFromURL
{
    my $url = shift;
    my $query_start = rindex($url, '?');
    $url = substr($url, 0, rindex($url, '?')) if( $query_start != -1 );    
    return substr($url, rindex($url, '/') + 1);
}

