#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#######################################################
##  init.cgi - Initialize the software installation  ##
#######################################################


my $passed = 1;
my $dbh = undef;
my $cwd = undef;


eval
{
    require 'common.pl';
    require 'ags.pl';
    Header("Content-type: text/html\n\n");

    $cwd = GetCwd();

    Main();
};


if( $@ )
{
    Error("$@", 'init.cgi');
}



sub Main
{
    ParseRequest();

    if( -e "$ADIR/.htpasswd" && -e "$DDIR/variables" )
    {
        ParseTemplate('init_done.tpl');
    }
    else
    {
        if( $F{'Username'} && $F{'Database'} )
        {
            eval("use DBI;");

            ## Attempt a connection to the MySQL server
            $dbh = DBI->connect("DBI:mysql:$F{'Database'}:$F{'Hostname'}", $F{'Username'}, $F{'Password'}, {'PrintError' => 0});
            
            ## Connection failed
            if( !$dbh )
            {
                HashToTemplate(\%F);
                $T{'Error'} = DBI->errstr();
                ParseTemplate('init_main.tpl');
            }

            ## Connection established
            else
            {
                ## Check create temporary table privileges
                my $result = 1; #$dbh->do("CREATE TEMPORARY TABLE temp_ags_Init_Test (Ident INT)");

                if( !$result )
                {
                    HashToTemplate(\%F);
                    $T{'Error'} = 'The privileges on your MySQL database are not set properly.<br />' .
                                  'Please see this <a href="http://www.jmbsoft.com/owners/kb/index.php?a=464" target="_blank">knowledge base article</a> for details.<br />' .
                                  'MySQL says: ' . $dbh->errstr();
                    ParseTemplate('init_main.tpl');
                }
                else
                {
                    ## Create database tables
                    CreateTables();

                    ## Record settings in the variables file
                    RecordSettings();

                    ## Setup the scanner.cgi and cron.cgi files
                    SetupScripts();

                    ## Setup .htaccess password protection
                    SetupLogin();

                    ParseTemplate('init_login.tpl');
                }
            }
        }
        else
        {
            ## Run the tests
            $T{'DBI'}       = ModuleTest('DBI');
            $T{'DBD'}       = ModuleTest('DBD::mysql');
            $T{'Templates'} = TemplatesTest();
            $T{'Language'}  = FileTest("$DDIR/language");
            $T{'Agents'}    = FileTest("$DDIR/agents");
            $T{'Referrers'} = FileTest("$DDIR/referrers");
            $T{'Scanner'}   = FileTest("scanner.cgi");
            $T{'Cron'}      = FileTest("cron.cgi");
            $T{'Admin'}     = DirectoryTest($ADIR);
            $T{'Data'}      = DirectoryTest($DDIR);


            ## All tests passed
            if( $passed )
            {
                $T{'Hostname'} = 'localhost';
                ParseTemplate('init_main.tpl');
            }

            ## One or more tests failed
            else
            {
                ParseTemplate('init_test.tpl');
            }
        }
    }
}



sub CreateTables
{
    my $tables = IniParse("$DDIR/tables");

    ## Disconnect from test connection
    $dbh->disconnect();

    $HOSTNAME = $F{'Hostname'};
    $USERNAME = $F{'Username'};
    $PASSWORD = $F{'Password'};
    $DATABASE = $F{'Database'};

    require 'mysql.pl';

    $DB->Connect();

    for( keys %$tables )
    {
        $DB->Insert("CREATE TABLE IF NOT EXISTS $_ ($tables->{$_}) TYPE=MyISAM");
    }

    $DB->Delete("DELETE FROM ags_Moderators");
    $DB->Insert("INSERT INTO ags_Moderators VALUES (?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP(), ?, ?)", ['admin', '', 'webmaster@yoursite.com', 0, 0, 0, '', $P_ALL]);

    $DB->Disconnect();
}



sub RecordSettings
{
    my $settings = "\$HOSTNAME = '$F{'Hostname'}';\n" .
                   "\$USERNAME = '$F{'Username'}';\n" .
                   "\$PASSWORD = '$F{'Password'}';\n" .
                   "\$DATABASE = '$F{'Database'}';\n1;\n";

    FileWrite("$DDIR/variables", $settings);                    
}



sub SetupScripts
{
    my @scripts = qw(cron.cgi scanner.cgi);

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



sub SetupLogin
{
    my $admin_htaccess = "AuthName \"AutoGallery SQL\"\n" .
                         "AuthType Basic\n" .
                         "AuthUserFile $cwd/admin/.htpasswd\n" .
                         "AuthGroupFile /dev/null\n" .
                         "require valid-user\n";

    my $data_htaccess  = "AuthName \"No Access\"\n" .
                         "AuthType Basic\n" .
                         "AuthUserFile /dev/null\n" .
                         "AuthGroupFile /dev/null\n" .
                         "require valid-user\n" .
                         "deny from all\n";


    $T{'Password'} = RandomPassword();

    FileWrite("$ADIR/.htaccess", $admin_htaccess);
    FileWrite("$DDIR/.htaccess", $data_htaccess);
    FileWrite("$ADIR/.htpasswd", 'admin:' . crypt($T{'Password'}, Salt()) . "\n");
}



sub ModuleTest
{
    my $module = shift;

    eval("use $module;");
    
    return Failed('Module Not Available') if( $@ );
    return Passed();
}



sub DirectoryTest
{
    my $dir = shift;

    if( -o $dir )
    {
        chmod(0755, $dir);
        return Passed();
    }
    else
    {
        if( !-w $dir )
        {
            return Failed("Incorrect Permissions");
        }
    }

    return Passed();
}



sub FileTest
{
    my $file = shift;

    if( !-w $file )
    {
        return Failed("Incorrect Permissions");
    }

    return Passed();
}



sub TemplatesTest
{
    for( @{DirRead($TDIR, '^(confirm|email|submit|remind|report|partner)')} )
    {
        return Failed("Incorrect Permissions<br>$_") if( !-w "$TDIR/$_" );
    }

    return Passed();
}



sub Failed
{
    my $message = shift;

    $passed = 0;

    return "<font color=\"red\">Failed</font><br>$message";
}



sub Passed
{
    return '<font color="blue">Passed</font>';
}
