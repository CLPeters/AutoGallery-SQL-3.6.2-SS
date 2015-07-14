<html>
<head>
<script language="JavaScript">
function checkForm(form)
{
    if( !form.Identifier.value )
    {
        alert('Please supply an identifier for this icon');
        return false;
    }


    if( form.Run.value == 'AddIcon' && !form.HTML.value )
    {
        alert('Please supply some HTML for this icon');
        return false;
    }


    if( form.Run.value == 'DeleteIcon' )
    {
        return confirm('Are you sure you want to delete this icon?');
    }
}


function loadIcon(select)
{
    var html = null;

    if( !select.options[select.selectedIndex].value )
    {
        document.form.Identifier.value = '';
        document.form.HTML.value       = '';
        return;
    }

    var div = document.getElementById(select.options[select.selectedIndex].value);

    document.form.Identifier.value = select.options[select.selectedIndex].value;

    html = div.innerHTML;
    html = html.replace(/&gt;/g, '>');
    html = html.replace(/&lt;/g, '<');

    document.form.HTML.value = html;
}


function preview()
{
    var preview = document.getElementById('preview');

    preview.innerHTML = document.form.HTML.value;

    return false;
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

<!--[If Start Icons]-->
<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" width="350">

<b>Existing Icons:</b>
<select name="Load_ID" onChange="loadIcon(this)" onFocus="loadIcon(this)">
<option value="">Select...</option>
<!--[Loop Start Icons]-->
  <option value="##Identifier##">##Identifier##</option>
<!--[Loop End]-->
</select>

</td>
</tr>
</table>

<br />
<!--[If End]-->


<table class="outlined" width="700" cellspacing="0" cellpadding="3">

<tr>
<td align="center" class="menuhead">
Manage Icons
</td>
</tr>

<tr>
<td class="subhead">
Identifier<br />
</td>
</tr>
<tr>
<td>
<input type="text" name="Identifier" size="30" style="margin-left: 20px;">
</td>
</tr>

<tr>
<td class="subhead">
HTML
<span style="font-weight: normal; padding-left: 590px;">
<a href="" onClick="return preview()">[Preview]</a>
</span>
</td>
</tr>
<tr>
<td>
<textarea name="HTML" rows="10" cols="105" wrap="off" style="margin-left: 20px;">##HTML##</textarea>
</td>
</tr>

</table>

<br />


<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" width="350">
<input type="submit" onClick="setRun('AddIcon');" value="Add/Update">
</td>
<td align="center" width="350">
<input type="submit" onClick="setRun('DeleteIcon');" value="Delete">
</td>
</tr>
</table>

<input type="hidden" name="Run">

<br />
<br />

<table class="outlined" width="300" cellspacing="0" cellpadding="3" style="margin-left: 200px;">
<tr>
<td align="center" class="menuhead">
Preview
</td>
</tr>
<tr>
<td id="preview" align="center">
</td>
</tr>
</table>

</form>


<!--[Loop Start Icons]-->
<div id="##Identifier##" style="position: absolute; visibility: hidden;">##HTML##</div>
<!--[Loop End Icons]-->


</body>
</html>