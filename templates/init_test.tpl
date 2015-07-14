<html>
<head>
<title>Software Initialization Tests</title>
<style>
.line { border-bottom: 1px solid #dcdcdc; }
</style>
<!--[Include File ./templates/admin.css]-->
</head>
<body>

<br />

<div align="center">

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
AutoGallery SQL Initialization Tests
</td>
</tr>

<tr>
<td class="line">
Checking for DBI Perl module
</td>
<td class="line" align="center">
##DBI##
</td>
</tr>

<tr>
<td class="line">
Checking for DBD::mysql Perl module
</td>
<td class="line" align="center">
##DBD##
</td>
</tr>

<tr>
<td class="line">
Checking template files permissions
</td>
<td class="line" align="center">
##Templates##
</td>
</tr>

<tr>
<td class="line">
Checking language file permissions
</td>
<td class="line" align="center">
##Language##
</td>
</tr>

<tr>
<td class="line">
Checking agents file permissions
</td>
<td class="line" align="center">
##Agents##
</td>
</tr>

<tr>
<td class="line">
Checking referrers file permissions
</td>
<td class="line" align="center">
##Referrers##
</td>
</tr>

<tr>
<td class="line">
Checking scanner.cgi file permissions
</td>
<td class="line" align="center">
##Scanner##
</td>
</tr>

<tr>
<td class="line">
Checking cron.cgi file permissions
</td>
<td class="line" align="center">
##Cron##
</td>
</tr>

<tr>
<td class="line">
Checking admin directory permissions
</td>
<td class="line" align="center">
##Admin##
</td>
</tr>

<tr>
<td class="line">
Checking data directory permissions
</td>
<td class="line" align="center">
##Data##
</td>
</tr>

<tr>
<td colspan="2">
Some of the pre-installation tests did not pass.  Below are descriptions of each test and what you can do to
resolve the problems.

<br />
<br />

<b>DBI and DBD::mysql Perl module tests</b>

<br />

These two tests check to make sure the required Perl modules are installed on your server.  If either of these fail, you will need to contact
your server administrator and ask them to install those modules.  URLs where each can be found are:

<br />
<br />

http://www.cpan.org/modules/by-module/DBI/DBI-1.38.tar.gz<br />
http://www.cpan.org/modules/by-module/DBD/Msql-Mysql-modules-1.2219.tar.gz

<br />
<br />

<b>admin and data directory permissions</b>

<br />

If either of these tests fail, it indicates that the correct permissions have not been set on the specified directory.  In most cases
you will need to use 777 permissions on both of these directories.

<br />
<br />

<b>Template files permissions test</b>

<br />

If this test fails, it indicates that one or more of the files in the templates directory does not have the correct permissions.  In most
cases you will need to use 666 permissions on all files in the templates directory.  The file which has incorrect permissions will be listed
with this error.

<br />
<br />

<b>language file permissions test</b>

<br />

If this test fails, it indicates that the language file in the data directory does not have the correct permissions.  In most
cases you will need to use 666 permissions on this file.

<br />
<br />

<b>scanner.cgi and cron.cgi file permissions test</b>

<br />

If this test fails, it indicates that the file does not have the correct permissions.  In most
cases you will need to use 777 permissions on these files.

</td>
</tr>

</table>

</div>

<br />

</body>
</html>