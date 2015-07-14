<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'ClearErrorLog' )
    {
        return confirm('Are you sure you want to clear the error log?');
    }
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

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Error Log
</td>
</tr>

<tr>
<td align="center">
<textarea rows="50" cols="90" wrap="OFF" style="font-family: Courier New, Courier; font-size: 8pt;">##Errors##</textarea>
</td>
</tr>

<tr>
<td align="center">
<input type="submit" onClick="setRun('ClearErrorLog')" value="Clear Error Log">
</td>
</tr>

</table>

<input type="hidden" name="Run">

</form>

</body>
</html>