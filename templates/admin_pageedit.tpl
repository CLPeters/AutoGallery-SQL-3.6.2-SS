<html>
<head>
<title>Edit Page</title>
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
function checkForm(form)
{
    if( !form.Build_Order.value || !form.Filename.value )
    {
        alert('All fields must be filled in');
        return false;
    }

    var lastslash = form.Filename.value.lastIndexOf("/");
    var filename = form.Filename.value.substr(lastslash + 1);

    if( filename.match("[^a-zA-Z0-9\-\._]") )
    {
        alert('The filename may only contain letters, numbers, dots, dashes, and underscores');
        return false;
    }

    if( filename.indexOf(".") == -1 )
    {
        confirmed = confirm("WARNING\r\n" +
                            "Adding pages without a file extension may cause\r\n" +
                            "the page to display incorrectly in your browser.\r\n" +
                            "Are you sure you want to add this page without a\r\n" +
                            "file extension?");

        if( !confirmed )
        {
            return false;
        }
    }    

    return true;
}

<!--[If Start Reload]-->
window.opener.location = 'main.cgi?Run=DisplayManagePages&Rand='+Math.random();
<!--[If End]-->
</script>

</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->


<!--[If Start WarnPerms]-->
<div class="message">
The file ##Directory##/##Filename## has incorrect permissions<br />
and you will not be able to rebuild your pages until you change them to 666<br />
</div>
<br />
<!--[If End]-->


<form name="form" action="main.cgi" method="POST" onSubmit="return checkForm(this);">

<table class="outlined" width="620" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="tablehead">
Edit This Page
</td>
</tr>

<tr>
<td align="right">
<b>Filename</b>
</td>
<td>
##Document_Root##/<input type="text" name="Filename" size="30" value="##Filename##">
</td>
</tr>

<tr>
<td align="right">
<b>Category</b>
</td>
<td>
<select name="Category">
<!--[Loop Start Categories]-->
<!--[If Start Selected]-->
  <option value="##Name##" selected>##Name##</option>
<!--[If Else]-->
  <option value="##Name##">##Name##</option>
<!--[If End]-->
<!--[Loop End]-->
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Build Order</b>
</td>
<td>
<input type="text" name="Build_Order" size="10" value="##Build_Order##">
</td>
</tr>

<tr>
<td colspan="2" align="center">
<input type="hidden" name="Page_ID" value="##Page_ID##">
<input type="submit" value="Update This Page">
</td>
</tr>

</table>

<input type="hidden" name="Run" value="EditPage">

</form>

</body>
</html>
