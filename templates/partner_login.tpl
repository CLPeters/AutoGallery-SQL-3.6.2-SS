<html>
<head>
  <title>Partner Account Maintenance</title>
<!--[Include File ./templates/partner.css]-->
</head>
<body>

<form name="form" action="partner.cgi" method="POST">

<div align="center">

<h2>Partner Account Maintenance</h2>

<table border="0" cellpadding="2" width="600">

<tr>
<td align="center" colspan="2">
<span style="font-weight: normal">
Through this interface you can view and manage your current galleries, update<br />
your e-mail address and change the password for your partner account.
</span>
<br />
<br />
</td>

</tr>

<tr>
<td align="right" width="45%">
Username
</td>
<td width="55%">
<input type="text" name="Account_ID" size="15">
</td>
</tr>

<tr>
<td align="right">
Password
</td>
<td>
<input type="password" name="Password" size="15">
&nbsp;<a href="remind.cgi" class="smalllink">Forgot your password?</a>
</td>
</tr>

<tr>
<td colspan="2" align="center">
<br />
<input type="submit" value="Submit">
<input type="hidden" name="r" value="overview">
</td>
</td>
</tr>

</table>


<br />
<br />

</div>

</form>

</body>
</html>
