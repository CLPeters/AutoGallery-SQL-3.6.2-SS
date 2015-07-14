<html>
<head>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'SaveScriptTemplate' && !form.Contents.value )
    {
        return confirm('Are you sure you want to delete the contents of this file?');
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
<input type="hidden" name="Run" value="">


<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<select name="Load">
##Template_Options##
</select>

<input type="submit" value="Load Template" onClick="setRun('LoadScriptTemplate')">
</td>


<!--[If Start Template]-->
<td width="350" align="center">
<input type="submit" value="Save ##Template##" onClick="setRun('SaveScriptTemplate')">
</td>
<!--[If End]-->

</tr>
</table>


<br />

<!--[If Start Template]-->
<input type="hidden" name="Template" value="##Template##">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">

<tr>
<td align="center" class="menuhead" colspan="2">
##Template##
</td>
</tr>

<tr>
<td align="center">
<textarea name="Contents" cols="100" rows="50" wrap="off">##Contents##</textarea>
</td>
</tr>

</table>

<br />

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="submit" value="Save ##Template##" onClick="setRun('SaveScriptTemplate')">
</td>
</tr>
</table>

</form>

<!--[If End]-->



</body>
</html>