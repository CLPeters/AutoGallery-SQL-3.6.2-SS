#!/usr/bin/perl


if( !$ENV{'REMOTE_USER'} )
{
print <<HTML;
Content-type: text/html

<div align="center">
.htaccess password protection is required to access this script.<br />
See the .htaccess section of the software manual for assistance with this error.
</div>
HTML
exit;
}


print <<HTML;
Content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>AutoGallery SQL Control Panel</title>
</head>
<frameset cols="200,*" border="0">
  <frame name="menu" id="menu" frameborder="0" marginheight="0" marginwidth="0" scrolling="auto" src="menu.cgi" noresize>
  <frame name="main" id="main" frameborder="0" marginheight="0" marginwidth="0" scrolling="auto" src="main.cgi">
</frameset>
</html>
HTML
