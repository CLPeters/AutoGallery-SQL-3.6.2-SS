<html>
<head>
<script language="JavaScript">

function checkForm(form)
{
    if( form.Template.selectedIndex == -1 )
    {
        alert('Please select at least one page!');
        return false;
    }

    if( !form.Find.value )
    {
        alert('Please enter text to search for');
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
<br />
<!--[If End]-->


<form name="form" action="main.cgi" target="main" method="POST" OnSubmit="return checkForm(this);">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">

<tr>
<td colspan="2" align="center" class="menuhead">
Find and Replace
</td>
</tr>

<tr>
<td valign="top" align="right">
<b>Pages</b>
</td>
<td>
<select name="Template" size="10" multiple>
<!--[Loop Start Pages]-->
  <option value="##Page_ID##">/##Filename##</option>
<!--[Loop End]-->
</select>
</td>
</tr>


<tr>
<td valign="top" align="right">
<b>Find</b>
</td>
<td>
<textarea name="Find" rows="6" cols="80" wrap="off"></textarea>
</td>
</tr>

<tr>
<td valign="top" align="right">
<b>Replace</b>
</td>
<td>
<textarea name="Replace" rows="6" cols="80" wrap="off"></textarea>
</td>
</tr>

<tr>
<td colspan="2" align="center">
<input type="submit" value="Find and Replace">
</td>
</tr>

</table>

<input type="hidden" name="Run" value="PageReplace">

</form>

<br />
<br />


</body>
</html>