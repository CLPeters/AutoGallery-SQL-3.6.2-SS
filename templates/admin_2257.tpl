<html>
<head>
<script language="JavaScript">
function checkForm(form)
{

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

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Manage 2257 Search Code
</td>
</tr>

<tr>
<td class="subhead">
2257 Code to Search For <span style="font-weight: normal;">(one per line)</span>
</td>
</tr>
<tr>
<td>
<textarea name="Links" rows="10" cols="105" wrap="off" style="margin-left: 20px;">##Links##</textarea>
</td>
</tr>

<tr>
<td align="center">
<input type="submit" value="Save 2257 Code">
</td>
</tr>

</table>


<input type="hidden" name="Run" value="Update2257">

</form>

</body>
</html>