<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'SaveEmail' )
    {
        if( !form.Subject.value )
        {
            alert("Subject is Required");
            return false;
        }

        if( !form.Text.value && !form.HTML.value )
        {
            alert("Text or HTML is Required");
            return false;
        }
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


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="checkForm(this)">

<input type="hidden" name="Run" value="">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">

<select name="Load">
##Template_Options##
</select>

<input type="submit" value="Load E-mail" onClick="setRun('LoadEmail')">
</td>

<!--[If Start Template]-->
<td width="350" align="center">
<input type="submit" value="Save ##Template##" onClick="setRun('SaveEmail')">
</td>
<!--[If End]-->

</tr>
</table>

<br />

<!--[If Start Template]-->
<input type="hidden" name="Template" value="##Template##">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
##Template##
</td>
</tr>

<tr>
<td class="subhead">
<b>Subject</b><br />
</td>
</tr>
<tr>
<td>
<input style="margin-left: 20px;" type="text" name="Subject" value="##Subject##" size="70">
</td>
</tr>

<tr>
<td class="subhead">
<b>Text</b><br />
</td>
</tr>
<tr>
<td>
<textarea style="margin-left: 20px;" name="Text" cols="100" rows="15" wrap="off">##Text##</textarea>
</td>
</tr>

<tr>
<td class="subhead">
<b>HTML</b><br />
</td>
</tr>
<tr>
<td>
<textarea style="margin-left: 20px;" name="HTML" cols="100" rows="15" wrap="off">##HTML##</textarea>
</td>
</tr>

<!--[If Start Attach_Options]-->
<tr>
<td class="subhead">
<b>Attachments</b><br />
</td>
</tr>
<tr>
<td>
<select style="margin-left: 20px;" name="Attach" size="7" multiple="true">
  ##Attach_Options##
</select>
</td>
</tr>
<!--[If End]-->

</table>

<br />

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="submit" value="Save ##Template##" onClick="setRun('SaveEmail')">
</td>
</tr>
</table>

</form>

<!--[If End]-->



</body>
</html>