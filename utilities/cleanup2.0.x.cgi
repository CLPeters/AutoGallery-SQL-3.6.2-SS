#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
##################################################################
##  cleanup2.0.x.cgi - Remove MySQL database tables from 2.0.x  ##
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
    Error("$@", 'cleanup2.0.x.cgi');
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
<title>Cleanup AutoGallery SQL 2.0.x MySQL Database</title>
$css
<style>
.bigger {font-size: 12px; font-weight: bold;}
</style>
</head>
<body>
<br />
<div align="center" class="bigger">
<a href="cleanup2.0.x.cgi?clean" class="link">Click here</a> to remove the 2.0.x MySQL database tables.
</div>
</body>
</html>
HTML
}



sub Cleanup
{
    $sql->Connect();
    $sql->Delete("DROP TABLE IF EXISTS ags_posts");
    $sql->Delete("DROP TABLE IF EXISTS ags_mods");
    $sql->Delete("DROP TABLE IF EXISTS ags_parts");
    $sql->Delete("DROP TABLE IF EXISTS ags_cheats");
    $sql->Disconnect();

print <<HTML;
<html>
<head>
<title>Cleanup AutoGallery SQL 2.0.x MySQL Database</title>
$css
<style>
.bigger {font-size: 12px; font-weight: bold;}
</style>
</head>
<body>
<br />
<div align="center" class="bigger">
The 2.0.x MySQL database tables have been removed.<br />
You may remove the cleanup2.0.x.cgi file from your server.
</div>
</body>
</html>
HTML
}
