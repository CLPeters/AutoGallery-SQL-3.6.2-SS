<html>
<head>
<script language="JavaScript">

function checkForm(form)
{
    if( !form.Subject.value )
    {
        alert('The subject must be filled in');
        return false;
    }

    if( !form.Text.value && !form.HTML.value )
    {
        alert('You must fill in either the Text or HTML field');
        return false;
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
<!--[If End]-->


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Send E-mail
</td>
</tr>

<tr>
<td class="subhead">
<b>To</b><br />
</td>
</tr>
<tr>
<td>
<span style="margin-left: 20px;">
##To##
</span>
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
<input type="submit" value="Send E-mail">
<input type="hidden" name="ID" value="##ID##">
<input type="hidden" name="Run" value="##Run##">
</td>

</tr>
</table>

</form>

</body>
</html>