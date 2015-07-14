<html>
<head>
<title>Software Initialization</title>
<!--[Include File ./templates/admin.css]-->
</head>
<body>

<br />

<div align="center">

<!--[If Start Error]-->
<span style="color: red; font-weight: bold'">Connection error: ##Error##</span><br />
Please double check your MySQL information and try again.
<br />
<br />
<!--[If End]-->

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
AutoGallery SQL Initialization
</td>
</tr>
<tr>
<td colspan="2">
To begin the initialization process, please enter your MySQL database information below.  A brief description of each value is also listed below.
Once you enter and submit this information, the software will attempt a connection to the MySQL database.  If the connection is successful, 
it will setup the database and prepare the control panel so you can login.

<br />
<br />

<b>Username</b> - This is the username you use to access the MySQL database server.  If you do not know your MySQL username, contact
your server administrator to get that information.

<br />
<br />

<b>Password</b> - This is the password you use to access the MySQL database server.  If you do not know your MySQL password, contact
your server administrator to get that information.

<br />
<br />

<b>Database</b> - This is the name of the database that you want the software to use.  Note that this name cannot just be made up.  A
database with this name must exist, and the username and password you enter must be allowed to access it.  If you do not know the name
of a database you can use, contact your server administrator and have them create one for you.

<br />
<br />

<b>Hostname</b> - This is the hostname of the server where the MySQL database server is running.  In most cases you do not need to change 
this from localhost.  If you are not sure what server is hosting your MySQL database, contact your server administrator to get that information.

<br />
<br />
</td>
</tr>
<tr>
<td width="275" align="right">
<b>Username</b>
</td>
<td width="325">
<form action="init.cgi" method="POST">
<input type="text" size="20" name="Username" value="##Username##">
</td>
</tr>

<tr>
<td align="right">
<b>Password</b>
</td>
<td>
<input type="text" size="20" name="Password" value="##Password##">
</td>
</tr>

<tr>
<td align="right">
<b>Database</b>
</td>
<td>
<input type="text" size="20" name="Database" value="##Database##">
</td>
</tr>

<tr>
<td align="right">
<b>Hostname</b>
</td>
<td>
<input type="text" size="20" name="Hostname" value="##Hostname##">
</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" value="Submit" size="20">
</td>
</tr>
</table>

</div>

<br />

</body>
</html>