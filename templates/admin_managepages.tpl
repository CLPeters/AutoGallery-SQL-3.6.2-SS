<html>
<head>
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'AddPage' )
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
    }
    else
    {
        return confirm('Are you sure you want to do this?');
    }
}

function editPage(id)
{
    window.open('main.cgi?Run=DisplayEditPage&Page_ID=' + id, '_blank', 'menubar=no,height=300,width=650,scrollbars=yes,top=300,left=300');

    return false;
}

function selectAll()
{
    var form = document.form;
    var value = null;

    if( form.Select_All.value == 'Select All' )
    {
        form.Select_All.value = 'Deselect All';
        value = true;   
    }
    else
    {
        form.Select_All.value = 'Select All';
        value = false;
    }


    for( var i = 0; i < form.elements.length; i++ )
    {
        if( form.elements[i].type == 'checkbox' && form.elements[i].name == 'Page_ID' )
        {
            form.elements[i].checked = value;
        }
    }
}
</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
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

<!--[If Start WarnExists]-->
<div class="message">
A file with the name ##Filename## already exists in ##Directory##<br />
<!--[If Start WarnPerms]-->
You will not be able to rebuild your pages until you either remove<br />
the existing file or change it's permissions to 666.
<!--[If Else]-->
If you rebuild your pages, the old file will be overwritten by the software<br />
It is recommended that you backup or remove the file before rebuilding your pages
<!--[If End]-->
</div>
<br />
<!--[If End]-->


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">


<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Add New TGP Page
</td>
</tr>

<tr>
<td align="right">
<b>Filename</b>
</td>
<td>
##Document_Root##/<input type="text" name="Filename" size="30">
</td>
</tr>

<tr>
<td align="right">
<b>Category</b>
</td>
<td>
<select name="Category">
  <option value="Mixed">Mixed</option>
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
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
<td align="center" colspan="2">
<input type="submit" value="Add Page" onClick="setRun('AddPage')">
<input type="hidden" name="Run" value="">
</td>
</tr>
</table>

<br />

<div align="center" style="width: 750px;">
<a href="main.cgi?Run=DisplayAddCategoryPages" target="main" style="font-size: 10pt; font-weight: bold;">Automatic Category Page Creation</a>
</div>

<br />


<!--[If Start Pages]-->
<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td colspan="5" align="center" class="menuhead">
Existing Pages
</td>
</tr>

<tr class="subhead">
<td>
ID
</td>
<td>
Page
</td>
<td align="center">
Order
</td>
<td align="center">
Category
</td>
<td align="center">
Actions
</td>
</tr>

<!--[Loop Start Pages]-->
<tr>
<td>
<input type="checkbox" name="Page_ID" value="##Page_ID##" class="normargin">
##Page_ID##
</td>
<td>
<a href="http://##Http_Host##/##Filename##" target="_blank">http://##Http_Host##/##Filename##</a>
</td>
<td align="center">
##Build_Order##
</td>
<td align="center">
##Category##
</td>
<td align="center">
<a href="" onClick="return editPage('##Page_ID##')">[Edit]</a>
&nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=DeletePage&Page_ID=##Page_ID##" onClick="return confirm('Are you sure you want to do this?')">[Delete]</a>
</td>
</tr>
<!--[Loop End]-->

</table>

<br />

<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td align="center" width="50%">
<input type="button" value="Select All" name="Select_All" onClick="selectAll()">
</td>
<td align="center" width="50%">
<input type="submit" value="Delete Selected" onClick="setRun('DeleteSelectedPages')">
</td>
</tr>
</table>
<!--[If End]-->

</form>

<br />
<br />
<br />
<br />

</body>
</html>