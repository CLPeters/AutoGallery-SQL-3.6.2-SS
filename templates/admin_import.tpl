<html>
<head>
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'AnalyzeInput' && !form.Input.value )
    {
        alert('Please supply some galleries to be analyzed');
        return false;
    }

    return true;
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


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<input type="hidden" name="Run">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Import Galleries
</td>
</tr>
<tr>
<td>
<b>From A File</b><br />
Upload your file named import.txt to the data directory of your installation, then press the Analyze File button.

<br />
<br />

<b>From The Input Box</b><br />
Copy and paste your galleries into the text box below, then press the Analyze Input button.
</td>
</tr>
</table>

<br />

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="submit" onClick="setRun('AnalyzeInput');" value="Analyze Input">
</td>
<td align="center">
<input type="submit" onClick="setRun('AnalyzeFile');" value="Analyze File">
</td>
</tr>
</table>

<br />

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Input Box
</td>
</tr>
<tr>
<td align="center">
<textarea name="Input" rows="20" cols="105" wrap="off"></textarea>
</td>
</tr>
</table>

</form>

</body>
</html>
