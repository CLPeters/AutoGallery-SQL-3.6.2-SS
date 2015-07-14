<html>
<head>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
function checkForm(form)
{
    for( var i = 0; i < form.elements.length; i++ )
    {
        if( !form.elements[i].value )
        {
            alert('Please fill in all of the form fields');
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

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this);">


<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Language Settings
</td>
</tr>

<!--[Loop Start Text]-->
<tr>
<td align="right">
<b>##Identifier##</b><br />
</td>
<td>
<input type="text" name="##Identifier##" value="##Value##" size="80">
</td>
</tr>
<!--[Loop End]-->

</table>

<br />


<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="submit" value="Save Settings">
<input type="hidden" name="Run" value="SaveLanguage">
</td>
</tr>
</table>

</form>

<br />
<br />


</body>
</html>