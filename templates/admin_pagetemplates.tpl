<html>
<head>
<script language="JavaScript">

function checkForm(form)
{
    if( form.Run.value == 'LoadPageTemplate' )
    {
        if( form.Template.selectedIndex == -1 )
        {
            alert('Please select a page!');
            return false;
        }

        var index = form.Template.selectedIndex;

        for( var i = 0; i < form.Template.options.length; i++ )
        {
            form.Template.options[i].selected = false;
        }

        form.Template.options[index].selected = true;
    }
    else
    {
        if( form.Template.selectedIndex == -1 )
        {
            alert('Please select at least one page!');
            return false;
        }

        if( !form.Contents.value )
        {
            alert('Please enter some HTML to save!');
            return false;
        }
    }
}


function setTemplate()
{
    for( i = 0; i < document.form.Template.options.length; i++ )
    {
        if( document.form.Template.options[i].value == '##Template##' )
        {
            document.form.Template.options[i].selected = true;
            break;
        }
    }
}
</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody" onLoad="setTemplate();">

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


<form name="form" action="main.cgi" target="main" method="POST" OnSubmit="return checkForm(this);">
<input type="hidden" name="Run">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" valign="top">


<table>
<tr>
<td>
<select name="Template" size="5" multiple>
<!--[Loop Start Pages]-->
  <option value="##Page_ID##">/##Filename##</option>
<!--[Loop End]-->
</select>
</td>
<td valign="top">
<input type="submit" value="Load HTML" OnClick="setRun('LoadPageTemplate');" style="width: 100px;">
<!--[If Start Template]-->
<div style="margin-top: 28px;">
<input type="submit" value="Save HTML" OnClick="setRun('SavePageTemplate');" style="width: 100px;">
</div>
<!--[If End]-->
</td>
</tr>
</table>


</td>
</tr>
</table>

<br />

<div style="text-align: center; width: 700px;">
<a href="main.cgi?Run=DisplayPageReplace" target="main" style="font-size: 10pt; font-weight: bold;">Find and Replace</a>
</div>

<br />

<!--[If Start Template]-->
<table class="outlined" width="700" cellspacing="0" cellpadding="3">

<tr>
<td align="center" class="menuhead" colspan="2">
/##Filename##
</td>
</tr>

<tr>
<td align="center">
<textarea name="Contents" cols="100" rows="50" wrap="off">##Contents##</textarea>
</td>
</tr>
</table>

</form>

<!--[If End]-->


<br />
<br />


</body>
</html>