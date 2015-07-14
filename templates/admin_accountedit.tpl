<html>
<head>
<title>Edit Partner Account</title>
<script language="JavaScript">

function setupPage()
{
    var auto = parseInt('##Auto_Approve##');
    var recip = parseInt('##Check_Recip##');
    var black = parseInt('##Check_Black##');
    var html = parseInt('##Check_HTML##');
    var confirm = parseInt('##Confirm##');

    document.form.Auto_Approve.options[auto].selected = true;
    document.form.Check_Recip.options[recip].selected = true;
    document.form.Check_Black.options[black].selected = true;
    document.form.Check_HTML.options[html].selected = true;

    if( !isNaN(confirm) )
    {
        document.form.Confirm.options[confirm].selected = true;
    }
}



function checkForm(form)
{
    var parent = window.opener.document;
    var id     = form.Account_ID.value;
    var name   = new Array('Password', 'Email', 'Weight', 'Allowed');
    var value  = new Array('Password', 'E-mail', 'Weight', 'Galleries Per Day');

    for( var i = 0; i < name.length; i++ )
    {
        if( form.elements[name[i]] && !form.elements[name[i]].value )
        {
            alert(value[i] + ' Must Be Filled In');
            return false;
        }
    }

    parent.getElementById(id+'_submitted').innerHTML = form.Submitted.value;
    parent.getElementById(id+'_removed').innerHTML   = form.Removed.value;
    parent.getElementById(id+'_allowed').innerHTML   = (form.Allowed.value == -1 ? 'NL' : form.Allowed.value);
    parent.getElementById(id+'_weight').innerHTML    = form.Weight.value;
    
    parent.getElementById(id+'_ahref').setAttribute('href', 'mailto:' + form.Email.value);

    if( form.Start_Date.value && form.End_Date.value )
    {
        parent.getElementById(id+'_dates').innerHTML = form.Start_Date.value + ' to ' + form.End_Date.value;
    }
    else
    {
        parent.getElementById(id+'_dates').innerHTML = 'No Date Limit';
    }

    return true;
}


</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody" onLoad="setupPage()">


<div align="center">

<!-- ACCOUNT EDITING TABLE -->
<form name="form" action="main.cgi" method="POST" onSubmit="return checkForm(this)">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td colspan="3" align="center" class="menuhead">
Edit Partner Account
</td>
</tr>

<tr>
<td width="300" align="right">
<b>Account ID</b>
</td>
<td width="400">
##Account_ID##
</td>
</tr>

<tr>
<td align="right">
<b>Password</b>
</td>
<td>
<input type="text" name="Password" size="20" value="##Password##">
</td>
</tr>

<tr>
<td align="right">
<b>E-mail</b>
</td>
<td>
<input type="text" name="Email" size="40" value="##Email##"> 
</td>
</tr>

<tr>
<td align="right">
<b>Weight</b>
</td>
<td>
<input type="text" name="Weight" size="5" onChange="fixNumber(this)" value="##Weight##">
</td>
</tr>

<tr>
<td align="right">
<b>Galleries Per Day</b>
</td>
<td>
<input type="text" name="Allowed" size="5" onChange="fixNumber(this)" value="##Allowed##">  -1 for no limit
</td>
</tr>

<tr>
<td align="right">
<b>Galleries Submitted</b>
</td>
<td>
<input type="text" name="Submitted" size="5" onChange="fixNumber(this)" value="##Submitted##">
</td>
</tr>

<tr>
<td align="right">
<b>Galleries Removed</b>
</td>
<td>
<input type="text" name="Removed" size="5" onChange="fixNumber(this)" value="##Removed##">
</td>
</tr>

<tr>
<td align="right">
<b>Start Date</b>
</td>
<td>
<input type="text" name="Start_Date" size="10" value="##Start_Date##"> &nbsp; YYYY-MM-DD
</td>
</tr>

<tr>
<td align="right">
<b>End Date</b>
</td>
<td>
<input type="text" name="End_Date" size="10" value="##End_Date##"> &nbsp; YYYY-MM-DD
</td>
</tr>

<tr>
<td align="right">
<b>Auto-Approve</b>
</td>
<td>
<select name="Auto_Approve">
  <option value="0">No</option>
  <option value="1">Yes</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Recip Required</b>
</td>
<td>
<select name="Check_Recip">
  <option value="0">No</option>
  <option value="1">Yes</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Check Blacklist</b>
</td>
<td>
<select name="Check_Black">
  <option value="0">No</option>
  <option value="1">Yes</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Check Banned HTML</b>
</td>
<td>
<select name="Check_HTML">
  <option value="0">No</option>
  <option value="1">Yes</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Confirm by E-mail</b>
</td>
<td>
<select name="Confirm">
  <option value="0">No</option>
  <option value="1">Yes</option>
</select>
</td>
</tr>

<!--[If Start Icon]-->
<tr>
<td align="right">
<b>Icons</b>
</td>
<td>
<!--[Loop Start Icon]-->
<input type="checkbox" name="Icons" value="##Identifier##" style="margin: 0px 0px 0px 0px;"##Checked##> ##HTML## &nbsp;&nbsp;
<!--[Loop End]-->
</td>
</tr>
<!--[If End]-->

<tr>
<td colspan="2" align="center">
<input type="submit" value="Update Account">
<input type="hidden" name="Account_ID" value="##Account_ID##">
<input type="hidden" name="Run" value="UpdateAccount"> 
</td>
</tr>

</table>

</form>
<!-- END ACCOUNT EDITING TABLE -->


</div>

</body>
</html>