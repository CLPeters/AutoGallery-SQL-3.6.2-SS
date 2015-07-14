<html>
<head>
<script language="JavaScript">
function checkForm(form)
{
    if( !form.Identifier.value )
    {
        alert('Please supply an identifier for this reciprocal link');
        return false;
    }


    if( form.Run.value == 'AddReciprocal' && !form.HTML.value )
    {
        alert('Please supply some HTML for this reciprocal link');
        return false;
    }


    if( form.Run.value == 'DeleteReciprocal' )
    {
        return confirm('Are you sure you want to delete this reciprocal link?');
    }
}


function loadRecip(select)
{
    var html = null;

    if( !select.options[select.selectedIndex].value )
    {
        document.form.Identifier.value = '';
        document.form.HTML.value       = '';
        return;
    }

    var type = select.name;
    var div  = document.getElementById(type + '_' + select.options[select.selectedIndex].value);

    document.form.Identifier.value = select.options[select.selectedIndex].value;

    html = div.innerHTML;
    html = html.replace(/&gt;/g, '>');
    html = html.replace(/&lt;/g, '<');

    document.form.HTML.value = html;

    if( type == 'General' )
    {
        document.form.Type.options[0].selected = true;
    }
    else
    {
        document.form.Type.options[1].selected = true;
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


<form name="load" action="main.cgi" target="main" method="POST">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" width="350">
<!--[If Start General]-->
<b>General:</b>
<select name="General" onChange="loadRecip(this)" onFocus="loadRecip(this)">
<option value="">Select...</option>
<!--[Loop Start General]-->
  <option value="##Identifier##">##Identifier##</option>
<!--[Loop End]-->
</select>
<!--[If Else]-->
&nbsp;
<!--[If End]-->
</td>
<td align="center" width="350">
<!--[If Start Trusted]-->
<b>Partner:</b>
<select name="Trusted" onChange="loadRecip(this)" onFocus="loadRecip(this)">
<option value="">Select...</option>
<!--[Loop Start Trusted]-->
  <option value="##Identifier##">##Identifier##</option>
<!--[Loop End]-->
</select>
<!--[If Else]-->
&nbsp;
<!--[If End]-->
</td>
</tr>
</table>

</form>

<br />


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Manage Reciprocal Links
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
Type<br />
</td>
</tr>
<tr>
<td>
<select name="Type" style="margin-left: 20px;">
  <option value="generalrecips">General</option>
  <option value="trustedrecips">Partner</option>
  <option value="generalrecips,trustedrecips">Both</option>
</select>
</td>
</tr>


<tr>
<td class="subhead">
HTML<br />
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
<input type="submit" onClick="setRun('AddReciprocal');" value="Add/Update">
</td>
<td align="center" width="350">
<input type="submit" onClick="setRun('DeleteReciprocal');" value="Delete">
</td>
</tr>
</table>

<input type="hidden" name="Run">

</form>


<!--[Loop Start General]-->
<div id="General_##Identifier##" style="position: absolute; visibility: hidden;">##HTML##</div>
<!--[Loop End General]-->

<!--[Loop Start Trusted]-->
<div id="Trusted_##Identifier##" style="position: absolute; visibility: hidden;">##HTML##</div>
<!--[Loop End Trusted]-->

</body>
</html>