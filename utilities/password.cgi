#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
###########################################################################
##  password.cgi - Utility to reset the control panel login information  ##
###########################################################################

my $css = undef;

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
    Error("$@", 'password.cgi');
}


sub main
{
    ParseRequest();

    $css = FileReadScalar("$TDIR/submit.css");

    if( $F{'Reset'} )
    {
        ResetPassword();
    }
    else
    {
        DisplayReset();
    }
}



sub DisplayReset
{
print <<HTML;
<html>
<head>
  <title>Password Reset</title>
$$css
</head>
<body>

<div align="center">

<h2>Password Reset</h2>

Clicking the link below will reset your control panel username and password to the default.

<br />
<br />

<a href="password.cgi?Reset=true">Reset your Password</a>

</div>

</body>
</html>
HTML
}



sub ResetPassword
{
    $DB->Connect();
    $DB->Delete("DELETE FROM ags_Moderators WHERE Username=?", ['admin']);
    $DB->Insert("INSERT INTO ags_Moderators VALUES (?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP(), ?, ?)", ['admin', '', 'webmaster@yoursite.com', 0, 0, 0, '', $P_ALL]);
    $DB->Disconnect();

    my $password = RandomPassword();

    DBDelete("$ADIR/.htpasswd", 'admin', ':');
    FileAppend("$ADIR/.htpasswd", 'admin:' . crypt($password, Salt()) . "\n");

print <<HTML;
<html>
<head>
  <title>Password Reset</title>
$$css
</head>
<body>

<div align="center">

<h2>Password Reset</h2>

Your <a href="admin/admin.cgi">control panel</a> username and password have been reset.

<br />
<br />

<b>Username:</b> admin<br />
<b>Password:</b> $password

</div>

</body>
</html>
HTML
}

