<html>
<head>
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
function checkForm(form)
{
    form.Extension.value = form.Extension.value.replace('.', '');

    if( !form.Extension.value )
    {
        alert('The file extension field must be filled in');
        return false;
    }
    return true;
}

function morePages()
{
    var select = document.form.Pages;
    var current = select.options.length;

    current++;

    for( var i = current; i < current + 40; i++ )
    {
        select.options[i-1] = new Option(i, i);
    }

    return false;
}
</script>
</head>
<body class="mainbody">

<!--[If Start NO_ACCESS_LIST]-->
<div class="errormessage">
You have not yet setup an access list, which will add increased security to your<br />
control panel.  Please review the 'Setting up an Access List' section of the software<br />
manual and setup your access list as soon as possible to enhance your security.
</div>
<br />
<!--[If End]-->

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" method="POST" onSubmit="return checkForm(this);">

<table class="outlined" width="620" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="tablehead">
Automatic Category Page Creation
</td>
</tr>

<tr>
<td align="right">
<b>Directory</b>
</td>
<td>
##Document_Root##/<input type="text" name="Directory" size="30">
</td>
</tr>

<tr>
<td align="right">
<b>File Extension</b>
</td>
<td>
<input type="text" name="Extension" size="10" value="html">
</td>
</tr>

<tr>
<td align="right">
<b>Category</b>
</td>
<td>
<select name="Category">
    <option value="_ALL_">All Categories</option>
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Pages</b>
</td>
<td>
<select name="Pages">
    <option value="1">1</option>
    <option value="2">2</option>
    <option value="3">3</option>
    <option value="4">4</option>
    <option value="5">5</option>
    <option value="6">6</option>
    <option value="7">7</option>
    <option value="8">8</option>
    <option value="9">9</option>
    <option value="10">10</option>
    <option value="11">11</option>
    <option value="12">12</option>
    <option value="13">13</option>
    <option value="14">14</option>
    <option value="15">15</option>
    <option value="16">16</option>
    <option value="17">17</option>
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20">20</option>
</select>

<a href="javascript:void(0)" onclick="return morePages()">[More]</a>
</td>
</tr>

<tr>
<td align="right" valign="top">
<b>Conversions</b>
</td>
<td>
<select name="AlphaNum">
    <option value="">Remove all non-alphanumeric characters</option>
    <option value="-">Replace all non-alphanumeric characters with a dash</option>
    <option value="_">Replace all non-alphanumeric characters with an underscore</option>
</select>

<br />

<select name="Case" style="margin-top: 3px;">    
    <option value="AllLower">All letters lower case</option>
    <option value="">No change in text case</option>
</select>
</td>
</tr>

<tr>
<td colspan="2" align="center">
<input type="submit" value="Create Category Pages">
</td>
</tr>

</table>

<input type="hidden" name="Run" value="AddCategoryPages">

</form>

</body>
</html>
