#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#############################################################
##  patch.cgi - Update files after a patch is uploaded     ##
#############################################################


chdir('..');


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
    Error("$@", 'patch.cgi');
}



sub main
{
    CheckPrivileges($P_PATCH);

    if( !-w 'cron.cgi' || !-w 'scanner.cgi' )
    {
        print 'Please set the permissions to 777 on the cron.cgi and scanner.cgi files' .
              ' and then run this script again';
    }
    else
    {
        SetupScripts();
        UpdateDatabase();
        RecompileTemplates();
        FileWriteNew("$DDIR/blacklist/headers");
        print 'Files have been patched successfully';
    }
}



sub SetupScripts
{
    my $cwd = GetCwd();
    my @scripts = qw(cron.cgi scanner.cgi);

    chomp($cwd);

    for( @scripts )
    {
        my $file = $_;
        my $data = FileReadScalar($file);

        $$data =~ s/\r//gi;
        $$data =~ s/\$cdir = '[^']+'/\$cdir = '$cwd'/;

        FileWrite($file, $$data);

        if( -o $file )
        {
            chmod(0755, $file);
        }
    }
}



sub RecompileTemplates
{
    my $compiler = new Compiler();

    $DB->Connect();

    my $result = $DB->Query("SELECT * FROM ags_Pages");

    while( $page = $DB->NextRow($result) )
    {
        my $success = $compiler->Compile("$DDIR/html/$page->{'Page_ID'}", $page->{'Category'}, $page->{'Page_ID'});

        if( $success )
        {
            FileWrite("$DDIR/html/$page->{'Page_ID'}.comp", $compiler->{'Code'});
        }
    }

    $DB->Free($result);
}




sub UpdateDatabase
{
    my $result = undef;

    $DB->Connect();

    ## Check that temporary table privileges are enabled
    #$DB->Update("CREATE TEMPORARY TABLE temp_ags_Init_Test (Ident INT)");
    

    ## Update ags_Accounts table
    $result = $DB->Query("DESCRIBE ags_Accounts");
    if( $DB->NumRows($result) == 13 )
    {
        $DB->Update("ALTER TABLE ags_Accounts ADD COLUMN (Start_Date DATE, End_Date DATE)");
    }
    $DB->Free($result);


    ## Update ags_Galleries table
    $result = $DB->Query("DESCRIBE ags_Galleries"); 
    if( $DB->NumRows($result) == 42 )
    {
        $DB->Update("ALTER TABLE ags_Galleries ADD COLUMN (Comments TEXT, Tag VARCHAR(64))");
    }
    $DB->Free($result);
    
    $DB->Update("ALTER TABLE ags_Galleries MODIFY COLUMN Status ENUM('Submitting','Unconfirmed','Pending','Approved','Used','Holding','Disabled') NOT NULL");
    $DB->Update("ALTER TABLE ags_Galleries MODIFY COLUMN Description TEXT NOT NULL");
    $DB->Update("ALTER TABLE ags_Pages MODIFY COLUMN Category VARCHAR(100)");



    ## Update the ags_Requests table
    my $columns = $DB->Columns('ags_Requests');
    if( !exists $columns->{'Added'} )
    {
        $DB->Update("ALTER TABLE ags_Requests ADD COLUMN Added INT");
    }

    $DB->Update("CREATE TABLE IF NOT EXISTS ags_temp_Categories (Name VARCHAR(100),Galleries INT,Clicks INT,Build_Counter INT,Used INT) TYPE=MyISAM");
}

