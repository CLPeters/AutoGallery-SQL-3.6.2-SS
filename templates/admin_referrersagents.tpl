<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">
function checkForm(form)
{

}
</script>

</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this);">

<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Update User Agents and Referrers
</td>
</tr>

<tr>
<td class="subhead">
User Agents
</td>
</tr>

<tr>
<td align="center">
<textarea name="Agents" rows="15" cols="100" wrap="off">##Agents##</textarea>
</td>
</tr>

<tr>
<td  class="subhead">
Referring URLs
</td>
</tr>

<tr>
<td align="center">
<textarea name="Referrers" rows="15" cols="100" wrap="off">##Referrers##</textarea>
</td>
</tr>

<tr>
<td align="center">
<input type="submit" value="Save Settings">
</td>
</tr>
</table>

<input type="hidden" name="Run" value="UpdateReferrersAndAgents">

</form>

</body>
</html>