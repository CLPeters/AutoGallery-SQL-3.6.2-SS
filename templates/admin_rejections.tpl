<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'SaveReject' )
    {
        if( !form.Template.value )
        {
            alert("Identifier is Required");
            return false;
        }

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
    else if( form.Run.value == 'DeleteReject' )
    {
        return confirm('Are you sure you want to delete this e-mail?');
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


<!--[If Start Template_Options]-->
<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td width="350" align="center">
<select name="Load">
##Template_Options##
</select>

<input type="submit" onClick="setRun('LoadReject')" value="Load E-mail">

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<input type="submit" onClick="setRun('DeleteReject')" value="Delete E-mail">
</td>
</table>

<br />
<!--[If End]-->



<input type="hidden" name="Run" value="">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Edit Rejection E-mails
</td>
</tr>


<tr>
<td class="subhead">
<b>Identifier</b><br />
</td>
</tr>
<tr>
<td>
<input style="margin-left: 20px;" type="text" name="Template" value="##Template##" onChange="fixID(this)" size="15" maxlength="15">
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
<input type="submit" value="Save E-mail" onClick="setRun('SaveReject')">
</td>
</tr>
</table>

</form>




</body>
</html>