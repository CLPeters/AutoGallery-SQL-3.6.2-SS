<html>
<head>
<script language="JavaScript">
function resolve(ip)
{
     window.open('main.cgi?Run=DisplayResolveIP&IP=' + ip, '_blank', 'menubar=no,height=100,width=350,scrollbars=yes,top=300,left=300');

     return false;
}
</script>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST">

<table class="outlined" width="700" cellspacing="0" cellpadding="3" border="0">
<tr>
<td colspan="5" align="center" class="menuhead">
Partner Account Requests
</td>
</tr>

<!--[If Start Requests]-->
<!--[Loop Start Requests]-->
<tr class="subhead">
<td style="padding-left: 5px;" colspan="2">
<input type="checkbox" name="Approved" value="##Unique_ID##" class="nopadmargin"> Approve

&nbsp;&nbsp;

<input type="checkbox" name="Rejected" value="##Unique_ID##" class="nopadmargin"> Reject

&nbsp;&nbsp;

<select name="Reject_##Unique_ID##" class="nopadmargin" style="font-weight: normal">
  <option value="None">None</option>
##Reject_Options##
</select>

</td>
</tr>

<tr>
<td width="85" align="right">
<b>Username:</b>
</td>
<td width="615">
<input type="text" name="Account_ID_##Unique_ID##" size="15" value="##Account_ID##">
&nbsp;&nbsp;&nbsp;&nbsp;
##Name##
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Password</b>
</td>
<td width="615">
<input type="text" name="Password_##Unique_ID##" size="15" value="##Password##">
</td>
</tr>

<tr>
<td width="85" align="right">
<b>E-mail:</b>
</td>
<td>
<a href="mailto:##Email##">##Email##</a>
</td>
</tr>

<tr>
<td width="85" align="right" valign="top">
<b>Galleries:</b>
</td>
<td>
<a href="##Gallery_1##" target="_blank">##Gallery_1##</a><br />
<a href="##Gallery_2##" target="_blank">##Gallery_2##</a><br />
<a href="##Gallery_3##" target="_blank">##Gallery_3##</a>
</td>
</tr>

<!--[If Start Host]-->
<tr>
<td width="85" align="right">
<b>Host:</b>
</td>
<td>
##Host##
</td>
</tr>
<!--[If End]-->

<!--[If Start Provider]-->
<tr>
<td width="85" align="right">
<b>Content:</b>
</td>
<td>
##Provider##
</td>
</tr>
<!--[If End]-->

<tr>
<td width="85" align="right">
<b>IP:</b>
</td>
<td>
<a href="" onClick="return resolve('##IP_Address##');">##IP_Address##</a>
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Added:</b>
</td>
<td>
##Added##
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Start</b>
</td>
<td>
<input type="text" name="Start_Date_##Unique_ID##" size="10"> &nbsp; YYYY-MM-DD
</td>
</tr>

<tr>
<td width="85" align="right">
<b>End</b>
</td>
<td>
<input type="text" name="End_Date_##Unique_ID##" size="10"> &nbsp; YYYY-MM-DD
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Weight:</b>
</td>
<td>
<input type="text" name="Weight_##Unique_ID##" size="4" value="2">
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Per Day:</b>
</td>
<td>
<input type="text" name="Allowed_##Unique_ID##" size="4" value="3">
</td>
</tr>

<tr>
<td align="right" valign="top">
<b>Options:</b>
</td>
<td>
<input type="checkbox" name="Auto_Approve_##Unique_ID##" value="1" class="nopadmargin"> Auto Approve<br />
<input type="checkbox" name="Check_Recip_##Unique_ID##" value="1" class="nopadmargin"> Recip Required<br />
<input type="checkbox" name="Check_Black_##Unique_ID##" value="1" class="nopadmargin"> Check Blacklist<br />
<input type="checkbox" name="Check_HTML_##Unique_ID##" value="1" class="nopadmargin"> Check Banned HTML<br />
<input type="checkbox" name="Confirm_##Unique_ID##" value="1" class="nopadmargin"> Confirm by E-mail
</td>
</tr>

<!--[If Start Icons]-->
<tr>
<td align="right" valign="top">
<b>Icons:</b>
</td>
<td>
<span style="padding-left: 4px;">
##Icons##
</span>
</td>
</tr>
<!--[If End]-->

<!--[Loop End]-->
<!--[If Else]-->
<tr>
<td colspan="5" align="center">
<span class="errormessage">There are currently no partner account requests to process</span>
</td>
</tr>
<!--[If End]-->

</table>

<br />

<!--[If Start Requests]-->

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>

<td align="center">
<input type="hidden" name="Run" value="ProcessAccountRequests">
<input type="submit" value="Process Requests">
</td>

</tr>
</table>

<!--[If End]-->

</form>

</body>
</html>