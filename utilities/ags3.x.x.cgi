#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
###########################################################################
##  ags3.x.x.cgi - Utility to upgrade data from AutoGallery SQL 3.x.x    ##
###########################################################################


$|++;

eval
{
    require 'common.pl';
    require 'ags.pl';
    require 'mysql.pl';
    Header("Content-type: text/html\n\n");
    main();
};


if( $@ )
{
    Error("$@", 'ags3.x.x.cgi');
}



sub main
{
    my $tables = IniParse("$DDIR/tables");


    print "<pre>\n";

    $sql->Connect();


    if( !PreUpgradeTests($tables) )
    {
        exit;
    }


    print "Converting AutoGallery SQL v$VERSION database...";


    ## Create the new tables
    $sql->Insert("CREATE TABLE IF NOT EXISTS ags_Requests ($tables->{'ags_Requests'}) TYPE=MyISAM");
    $sql->Insert("CREATE TABLE IF NOT EXISTS ags_Addresses ($tables->{'ags_Addresses'}) TYPE=MyISAM");
    $sql->Insert("CREATE TABLE IF NOT EXISTS ags_Annotations ($tables->{'ags_Annotations'}) TYPE=MyISAM");
    $sql->Insert("CREATE TABLE IF NOT EXISTS ags_Pages ($tables->{'ags_Pages'}) TYPE=MyISAM");
    $sql->Insert("CREATE TABLE IF NOT EXISTS ags_Undos ($tables->{'ags_Undos'}) TYPE=MyISAM");



    ## Determine if the ags_Galleries table has already been upgraded
    $sql->Query("DESCRIBE ags_Galleries");
    my $ags_galleries_rows = $sql->NumRows();
    $sql->Free();

    
    ## Has not been upgraded
    if( $ags_galleries_rows < 42 )
    {
        ## Rename the old ags_Galleries table
        $sql->Update("ALTER TABLE ags_Galleries RENAME TO old_temp_ags_Galleries");


        ## Create the new ags_Galleries table
        $sql->Insert("CREATE TABLE IF NOT EXISTS ags_Galleries ($tables->{'ags_Galleries'}) TYPE=MyISAM");
        

        ## Import galleries from the old ags_Galleries table
        $sql->Insert("INSERT INTO ags_Galleries SELECT " .
                     "Gallery_ID, " .
                     "Email, " .
                     "Gallery_URL, " .
                     "Description, " .
                     "Thumbnails, " .
                     "Category, " .
                     "'', " .
                     "Has_Thumb, " .
                     "IF(Has_Thumb, CONCAT('$THUMB_URL/', Gallery_ID, '.jpg'), NULL), " .
                     "IF(Has_Thumb, '$THUMB_WIDTH', NULL), " .
                     "IF(Has_Thumb, '$THUMB_HEIGHT', NULL), " .
                     "Rating, " .
                     "Nickname, " .
                     "Hits_Sent, " .
                     "'Submitted', " .
                     "'Pictures', " .
                     "IF((Status='Approved' AND Display_Date <= CURDATE()) OR Status='Archived', 'Used', Status), " .
                     "Confirm_ID, " .
                     "Submit_Date, " .
                     "UNIX_TIMESTAMP(CONCAT(Submit_Date, ' 12:00:00')), " .
                     "IF(Status='Approved' OR Status='Archived', Approve_Date, NULL), " .
                     "IF(Status='Approved' OR Status='Archived', UNIX_TIMESTAMP(CONCAT(Approve_Date, ' 12:00:00')), NULL), " .
                     "NULL, " .
                     "IF((Status='Approved' AND Display_Date <= CURDATE()) OR Status='Archived', Display_Date, NULL), " .
                     "NULL, " .
                     "Account_ID, " .
                     "CPanel_ID, " .
                     "Submit_IP, " .
                     "Gallery_IP, " .
                     "Scanned, " .
                     "Links, " .
                     "Has_Recip, " .
                     "Page_Bytes, " .
                     "'', " .
                     "Speed, " .
                     "Icons, " .
                     "1, " .
                     "1, " .
                     "1, " .
                     "IF((Status='Approved' AND Display_Date <= CURDATE()) OR Status='Archived', TO_DAYS(CURDATE()) - TO_DAYS(Display_Date) + 1, 1), " .
                     "IF((Status='Approved' AND Display_Date <= CURDATE()) OR Status='Archived', TO_DAYS(CURDATE()) - TO_DAYS(Display_Date) + 1, 1), " .
                     "'', " .
                     "'', " .
                     "'' " .
                     "FROM old_temp_ags_Galleries");

        
        ## Import permanent galleries into the new ags_Galleries table
        $sql->Insert("INSERT INTO ags_Galleries SELECT " .
                     "NULL, " .
                     "'$ADMIN_EMAIL', " . 
                     "Gallery_URL, " .
                     "Description, " .
                     "Thumbnails, " .
                     "Category, " .
                     "'', " .
                     "IF(Thumbnail_URL!='', 1, 0), " .
                     "IF(Thumbnail_URL!='', Thumbnail_URL, NULL), " .
                     "IF(Thumbnail_URL!='', '$THUMB_WIDTH', NULL), " .
                     "IF(Thumbnail_URL!='', '$THUMB_HEIGHT', NULL), " .
                     "Weight, " .
                     "Nickname, " .
                     "Hits_Sent, " .
                     "'Permanent', " .
                     "'Pictures', " .
                     "'Approved', " .
                     "NULL, " .
                     "CURDATE(), " .
                     "UNIX_TIMESTAMP(), " .
                     "CURDATE(), " .
                     "UNIX_TIMESTAMP(), " .
                     "NULL, " .
                     "NULL, " .
                     "NULL, " .
                     "'', " .
                     "'Upgrade', " .
                     "'$ENV{'REMOTE_ADDR'}', " .
                     "'', " .
                     "0, " .
                     "0, " .
                     "0, " .
                     "0, " .
                     "'', " .
                     "0, " .
                     "'', " .
                     "1, " .
                     "1, " .
                     "1, " .
                     "1, " .
                     "1, " .
                     "'', " .
                     "'', " .
                     "'' " .
                     "FROM ags_Permanent");


        ## Remove the old galleries table
        $sql->Update("DROP TABLE old_temp_ags_Galleries");
    }


    ## ags_CPanel -> ags_Moderators
    $sql->Update("ALTER TABLE ags_CPanel RENAME TO ags_Moderators");
    $sql->Update("ALTER TABLE ags_Moderators CHANGE CPanel_ID Username VARCHAR(32) NOT NULL");
    $sql->Update("UPDATE ags_Moderators SET Password='********'");


    ## Update ags_Categories table
    $sql->Update("ALTER TABLE ags_Categories DROP COLUMN Type");
    $sql->Update("ALTER TABLE ags_Categories DROP COLUMN Max_Approve");
    $sql->Update("ALTER TABLE ags_Categories ADD COLUMN (Ann_Pictures INT NOT NULL DEFAULT 0, Ann_Movies INT NOT NULL DEFAULT 0, Hidden TINYINT NOT NULL)");


    ## Update ags_Accounts table
    $sql->Update("ALTER TABLE ags_Accounts CHANGE Rating Weight FLOAT");
    $sql->Update("ALTER TABLE ags_Accounts CHANGE Recip Check_Recip TINYINT");
    $sql->Update("ALTER TABLE ags_Accounts CHANGE Blacklist Check_Black TINYINT");
    $sql->Update("ALTER TABLE ags_Accounts CHANGE HTML Check_HTML TINYINT");
    $sql->Update("ALTER TABLE ags_Accounts ADD COLUMN Confirm TINYINT AFTER Check_HTML");
    $sql->Update("UPDATE ags_Accounts SET Check_Black=(!Check_Black),Check_HTML=(!Check_HTML)");


    ## Update permanent gallery preview thumbnail filenames
    my $gallery = undef;

    $sql->Query("SELECT * FROM ags_Galleries WHERE Thumbnail_URL LIKE '$THUMB_URL/p%'");

    while( $gallery = $sql->NextRow() )
    {
        my $new_filename = "$gallery->{'Gallery_ID'}.jpg";
        my $new_thumb_url = "$THUMB_URL/$gallery->{'Gallery_ID'}.jpg";
        my $old_filename = $gallery->{'Thumbnail_URL'};

        $old_filename =~ s/$THUMB_URL\///gi;

        if( -e "$THUMB_DIR/$old_filename" && !-e "$THUMB_DIR/$new_filename" )
        {
            rename("$THUMB_DIR/$old_filename", "$THUMB_DIR/$new_filename");
            $sql->Update("UPDATE ags_Galleries SET Thumbnail_URL='$new_thumb_url' WHERE Gallery_ID='$gallery->{'Gallery_ID'}'");
        }        
    }

    $sql->Free();



    ## Add main pages
    DirCreate("$DDIR/html_old") if( !-e "$DDIR/html_old" );

    my $build_order = 1;
    my $main_pages_hash = {}; 
    my $main_directory = $MAIN_DIR;
    $main_directory =~ s/$DOCUMENT_ROOT//gi;
    $main_directory =~ s/^\///;
    $main_directory =~ s/\/$//;
    $main_directory = "$main_directory/" if( $main_directory ne '' );


    for( split(/,/, $MAIN_PAGES) )
    {
        my $page_name = $_;

        $main_pages_hash->{$page_name} = 1;

        $sql->Insert("INSERT INTO ags_Pages VALUES ( NULL, '$main_directory$page_name', 'Mixed', '$build_order')");

        my $page_id = $sql->InsertID();

        FileWrite("$DDIR/html/$page_id", ${FileReadScalar("$DDIR/html/$page_name")});

        $build_order++;
    }


    ## Add archive pages
    my $arch_directory = $ARCHIVE_DIR;
    $arch_directory =~ s/$DOCUMENT_ROOT\/?//gi;
    $arch_directory =~ s/^\///;
    $arch_directory =~ s/\/$//;
    $arch_directory = "$arch_directory/" if( $arch_directory ne '' );

    for( split(/,/, $PAGE_LIST) )
    {
        my $page_name = $_;
        my $category = PageToCategory($page_name) || 'Mixed';

        if( !$main_pages_hash->{$page_name} )
        {
            $sql->Insert("INSERT INTO ags_Pages VALUES ( NULL, '$arch_directory$page_name', '$category', '$build_order')");

            my $page_id = $sql->InsertID();

            FileWrite("$DDIR/html/$page_id", ${FileReadScalar("$DDIR/html/$page_name")});

            $build_order++;
        }

        FileWrite("$DDIR/html_old/$page_name", ${FileReadScalar("$DDIR/html/$page_name")});
        unlink("$DDIR/html/$page_name");
        FileWrite("$DDIR/html_old/$page_name.comp", ${FileReadScalar("$DDIR/html/$page_name.comp")});
        unlink("$DDIR/html/$page_name.comp");
    }


    
    ## Remove old gallery scanner configurations
    for( @{DirRead("$DDIR/scanner", '^[^.]')} )
    {
        unlink("$DDIR/scanner/$_");
    }


    print "done\n\nPlease continue with the next step of the upgrade process</pre>";
}




sub PreUpgradeTests
{
    my $tables = shift;
    my $existing_tables = {};
    my $row = {};
    my @errors = ();   


    ## Check to make sure a 3.0.x or 3.1.x installation is present
    if( $VERSION !~ /3\.[01]\./ )
    {
        push(@errors, "Could not locate an AutoGallery SQL version 3.0.x or 3.1.x installation.  Version is: $VERSION");
    }


    ## Make sure the new tables file has been uploaded
    if( !$tables->{'ags_Undos'} )
    {
        push(@errors, "Please upload the new tables file from the 3.6.x distribution");
    }


    ## Make sure the $sql variable has been defined in the mysql.pl file
    if( !$sql )
    {
        push(@errors, "mysql.pl file is not the correct version. Make sure you have NOT uploaded the mysql.pl file from the 3.6.x distribution");
    }


    ## Make sure tables haven't already been updated
    if( -e "$DDIR/html_old" )
    {
        push(@errors, "The upgrade process has already been completed and cannot be run again");
    }


    if( scalar @errors )
    {
        print "Please fix the following errors and then try running this script again:\n\n";

        for( @errors )
        {
            print "\t$_\n";
        }

        return 0;
    }


    ## Make sure we have the necessary MySQL privileges
    $sql->Update('CREATE TABLE ags_Temp_Priv_Check ( Identifier INT )');
    $sql->Update('ALTER TABLE ags_Temp_Priv_Check CHANGE Identifier New_Identifier TINYINT');
    $sql->Update('ALTER TABLE ags_Temp_Priv_Check ADD COLUMN Confirm INT AFTER New_Identifier');
    $sql->Update('ALTER TABLE ags_Temp_Priv_Check DROP COLUMN Confirm');
    $sql->Update('ALTER TABLE ags_Temp_Priv_Check RENAME TO renamed_ags_Temp_Priv_Check');
    $sql->Update('DROP TABLE renamed_ags_Temp_Priv_Check');



    ## See what tables are in the database and make sure
    ## that none of the conversion tables exist
    $sql->Query('SHOW TABLES');

    while( $row = $sql->NextRow() )
    {
        for( keys %$row )
        {
            $existing_tables->{$row->{$_}} = 1;
        }
    }

    $sql->Free();

    if( exists $existing_tables->{'old_temp_ags_Galleries'} && !exists $existing_tables->{'ags_Galleries'} )
    {
        $sql->Update("ALTER TABLE old_temp_ags_Galleries RENAME TO ags_Galleries");
    }
    elsif( exists $existing_tables->{'old_temp_ags_Galleries'} )
    {
        if( $sql->Count("SELECT COUNT(*) FROM ags_Galleries") < 1 )
        {
            $sql->Update("DROP TABLE ags_Galleries");
            $sql->Update("ALTER TABLE old_temp_ags_Galleries RENAME TO ags_Galleries");
        }
        else
        {
            $sql->Update("DROP TABLE old_temp_ags_Galleries");
        }
    }

    return 1;
}

