#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
##################################################################
##  cleanup2.1.x.cgi - Remove MySQL database tables from 2.1.x  ##
##################################################################

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
    Error("$@", 'cleanup2.1.x.cgi');
}


sub main
{
    $css = ${FileReadScalar("$TDIR/admin.css")};

    if( !$ENV{'QUERY_STRING'} )
    {
        DisplayConfirm();
    }
    else
    {
        Cleanup();
    }
}



sub DisplayConfirm
{
print <<HTML;
<html>
<head>
<title>Cleanup AutoGallery SQL 2.1.x MySQL Database</title>
$css
<style>
.bigger {font-size: 12px; font-weight: bold;}
</style>
</head>
<body>
<br />
<div align="center" class="bigger">
<a href="cleanup2.1.x.cgi?clean" class="link">Click here</a> to remove the 2.1.x MySQL database tables.
</div>
</body>
</html>
HTML
}



sub Cleanup
{
    $sql->Connect();
    $sql->Delete("DROP TABLE IF EXISTS a_Posts");
    $sql->Delete("DROP TABLE IF EXISTS a_Moderators");
    $sql->Delete("DROP TABLE IF EXISTS a_Partners");
    $sql->Delete("DROP TABLE IF EXISTS a_Cheats");
    $sql->Delete("DROP TABLE IF EXISTS a_Passphrase");
    $sql->Disconnect();

print <<HTML;
<html>
<head>
<title>Cleanup AutoGallery SQL 2.1.x MySQL Database</title>
$css
<style>
.bigger {font-size: 12px; font-weight: bold;}
</style>
</head>
<body>
<br />
<div align="center" class="bigger">
The 2.1.x MySQL database tables have been removed.<br />
You may remove the cleanup2.1.x.cgi file from your server.
</div>
</body>
</html>
HTML
}