<html>
<head>
<script language="JavaScript">

function checkForm(form)
{
    var name  = new Array('Account_ID', 'Password', 'Email', 'Weight', 'Allowed');
    var value = new Array('Account ID', 'Password', 'E-mail', 'Weight', 'Galleries Per Day');

    for( var i = 0; i < name.length; i++ )
    {
        if( form.elements[name[i]] && !form.elements[name[i]].value )
        {
            alert(value[i] + ' Must Be Filled In');
            return false;
        }
    }
}

</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Add Partner Account
</td>
</tr>

<tr>
<td width="200" align="right">
<b>Account ID</b>
</td>
<td width="400">
<input type="text" name="Account_ID" size="20">
</td>
</tr>

<tr>
<td align="right">
<b>Password</b>
</td>
<td>
<input type="text" name="Password" size="20">
</td>
</tr>

<tr>
<td align="right">
<b>E-mail</b>
</td>
<td>
<input type="text" name="Email" size="40"> 

<select name="Send_Email">
  <option value="1">Send E-mail</option>
  <option value="0" selected>No E-mail</option>
</select>

</td>
</tr>

<tr>
<td align="right">
<b>Weight</b>
</td>
<td>
<input type="text" name="Weight" size="5" onChange="fixNumber(this)">
</td>
</tr>

<tr>
<td align="right">
<b>Galleries Per Day</b>
</td>
<td>
<input type="text" name="Allowed" size="5" onChange="fixNumber(this)"> -1 for no limit
</td>
</tr>

<tr>
<td align="right">
<b>Start Date</b>
</td>
<td>
<input type="text" name="Start_Date" size="10"> &nbsp; YYYY-MM-DD
</td>
</tr>

<tr>
<td align="right">
<b>End Date</b>
</td>
<td>
<input type="text" name="End_Date" size="10"> &nbsp; YYYY-MM-DD
</td>
</tr>

<tr>
<td align="right">
<b>Auto-Approve</b>
</td>
<td>
<select name="Auto_Approve">
  <option value="1">Yes</option>
  <option value="0">No</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Recip Required</b>
</td>
<td>
<select name="Check_Recip">
  <option value="1">Yes</option>
  <option value="0" selected>No</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Check Blacklist</b>
</td>
<td>
<select name="Check_Black">
  <option value="1" selected>Yes</option>
  <option value="0">No</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Check Banned HTML</b>
</td>
<td>
<select name="Check_HTML">
  <option value="1" selected>Yes</option>
  <option value="0">No</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Confirm by E-mail</b>
</td>
<td>
<select name="Confirm">
  <option value="1">Yes</option>
  <option value="0" selected>No</option>
</select>
</td>
</tr>

<!--[If Start Icons]-->
<tr>
<td align="right">
<b>Icons</b>
</td>
<td>
<!--[Loop Start Icons]-->
<input type="checkbox" name="Icons_##Unique_ID##" value="##Identifier##" style="margin: 0px 0px 0px 0px;"> ##HTML## &nbsp;&nbsp;
<!--[Loop End]-->
</td>
</tr>
<!--[If End]-->

</table>

<br />


<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>

<td align="center">
<input type="submit" value="Add Account">
<input type="hidden" name="Run" value="AddAccount">
</td>

</tr>
</table>

</form>

</body>
</html>