<html>
<head>
  <title>Edit Your Account</title>
<!--[Include File ./templates/partner.css]-->
</head>
<script language="JavaScript">

function doAction(the_action)
{
    document.action.r.value = the_action;
    document.action.submit();

    return false;
}

</script>
<body>

<form name="form" action="partner.cgi" method="POST">

<div align="center">

<b><a href="" onClick="return doAction('overview');">Account Overview</a> : <a href="submit.cgi">Submit Galleries</a> : <a href="mailto:##Admin_Email##">E-mail Administrator</a></b>

<h2>Edit Your Account</h2>


<table border="0" cellpadding="2" width="600">

<!--[If Start Message]-->
<!-- Display this message after the account has been updated -->
<tr>
<td colspan="2" align="center">
<span style="color: blue">
Your partner account has been updated with the new information you have
provided.  If you changed your password, be sure to make a note of it
for future reference.
</span>

<br /><br />
</td>
</tr>
<!--[If End]-->

<tr>
<td align="right" width="45%">
E-mail Address
</td>
<td width="55%">
<input type="text" name="Email" size="30" value="##Email##">
</td>
</tr>

<tr>
<td align="right" valign="top">
New Password
</td>
<td>
<input type="text" name="New_Password" size="15"><br/>
<span class="small">
Only enter a new password if you want to<br />
change your password, otherwise leave blank
</span>
</td>
</tr>

<tr>
<td colspan="2" align="center">
<br />
<input type="submit" value="Update Account">
<input type="hidden" name="r" value="update">
<input type="hidden" name="Account_ID" value="##Account_ID##">
<input type="hidden" name="Password" value="##Password##">
</td>
</td>
</tr>

</table>


<br />
<br />

</div>

</form>


<form name="action" action="partner.cgi" method="POST">
<input type="hidden" name="r">
<input type="hidden" name="Account_ID" value="##Account_ID##">
<input type="hidden" name="Password" value="##Password##">
</form>

</body>
</html>
