<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">

function checkForm(form)
{
    var cb = null;

    for( var i = 0; i < form.Type.length; i++ )
    {
        if( form.Type[i].checked == true )
        {
            cb = form.Type[i];
        }
    }

    if( form.Run.value == 'DeleteAnnotation' )
    {
        if( !confirm("Are you sure you want to delete the annotation '" + form.Load_ID.options[form.Load_ID.selectedIndex].text + "'?") )
        {
            return false;
        }
    }
    if( form.Run.value == 'AddAnnotation' || form.Run.value == 'UpdateAnnotation' )
    {
        if( !form.Identifier.value )
        {
            alert('Identifier Must Be Filled In');
            return false;
        }

        if( cb.value == 'Text' )
        {
            fields = new Array('String', 'Font_File', 'Size', 'Color', 'Shadow');
            names = new Array('String', 'Font File', 'Font Size', 'Text Color', 'Shadow Color');
            
            for( i = 0; i < fields.length; i++ )
            {
                if( !form.elements[fields[i]].value )
                {
                    alert('The ' + names[i] + ' field must be filled in');
                    return false;
                }
            }
        }
        else
        {
            if( !form.Image_File.value )
            {
                alert('Image file must be filled in');
                return false;
            }
        }
    }

    return true;
}


function handleLoaded()
{
    var form = document.form;

    for( var i = 0; i < form.Type.length; i++ )
    {
        if( form.Type[i].value == '##Type##' )
        {
            form.Type[i].checked = true;
            handleCheckbox(form.Type[i]);
        }
    }
}


function handleCheckbox(cb)
{
    var form = document.form;
    var othercb = null;
    var loc = '##Location##';

    if( loc )
    {
        for( var i = 0; i < form.Location.length; i++ )
        {
            if( form.Location.options[i].value == loc )
            {
                form.Location.options[i].selected = true;
                break;
            }
        }
    }

    for( var i = 0; i < form.Type.length; i++ )
    {
        if( form.Type[i].value != cb.value )
        {
            othercb = form.Type[i];
            break;
        }
    }

    othercb.checked = false;
    cb.checked = true;

    if( cb.value == 'Text' )
    {
        form.Font_File.disabled = false;
        form.String.disabled = false;
        form.Size.disabled = false;
        form.Color.disabled = false;
        form.Shadow.disabled = false;

        form.Image_File.disabled = true;
        form.Transparency.disabled = true;
    }
    else
    {
        form.Font_File.disabled = true;
        form.String.disabled = true;
        form.Size.disabled = true;
        form.Color.disabled = true;
        form.Shadow.disabled = true;

        form.Image_File.disabled = false;
        form.Transparency.disabled = false;
    }
}
</script>
</head>
<body class="mainbody" onLoad="handleLoaded()">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<!--[If Start Annotations]-->
<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<b>Annotations:</b>
<select name="Load_ID">
<!--[Loop Start Annotations]-->
  <option value="##Unique_ID##"##Selected##>##Identifier##</option>
<!--[Loop End]-->
</select>

&nbsp;

<input type="submit" onClick="setRun('LoadAnnotation');" value="Load">

&nbsp;&nbsp;

<input type="submit" onClick="setRun('DeleteAnnotation');" value="Delete">

</td>
</tr>
</table>

<br />
<!--[If End]-->

<table class="outlined" width="700" cellspacing="0" cellpadding="3" border="0">
<tr>
<td align="center" class="tablehead" colspan="4">
<!--[If Start Loaded]-->
Update Annotation '##Identifier##'
<!--[If Else]-->
Add an Annotation
<!--[If End]-->
</td>
</tr>

<tr>
<td width="100" align="right">
<b>Identifier</b>
</td>
<td width="250">
<input type="text" name="Identifier" size="30" value="##Identifier##">
<input type="hidden" name="Unique_ID" value="##Unique_ID##">
</td>
</tr>

<tr>
<td align="right">
<b>Location</b>
</td>
<td>
<select name="Location">
  <option value="NorthWest">Top Left</option>
  <option value="North">Top Center</option>
  <option value="NorthEast">Top Right</option>
  <option value="SouthWest">Bottom Left</option>
  <option value="South">Bottom Center</option>
  <option value="SouthEast">Bottom Right</option>
</select>
</td>
</tr>

<tr class="subhead">
<td width="350" colspan="2">
&nbsp; <input type="checkbox" name="Type" value="Text" class="nomargin" onClick="handleCheckbox(this)" checked> Text String
</td>
<td width="350" colspan="2">
<input type="checkbox" name="Type" value="Image" class="nomargin" onClick="handleCheckbox(this)"> Image Overlay
</td>
</tr>

<tr>
<td align="right" width="100">
<b>String</b>
</td>
<td width="250">
<input type="text" name="String" size="25" value="##String##">
</td>
<td align="right" width="100">
<b>Image File</b>
</td>
<td width="250">
<input type="text" name="Image_File" size="25" value="##Image_File##" disabled>
</td>
</tr>

<tr>
<td align="right">
<b>Font File</b>
</td>
<td>
<input type="text" name="Font_File" size="15" value="##Font_File##">
</td>
<td align="right">
<b>Transparency</b>
</td>
<td>
<input type="text" name="Transparency" size="15" value="##Transparency##" disabled>
</td>
</tr>

<tr>
<td align="right">
<b>Font Size</b>
</td>
<td>
<input type="text" name="Size" size="15" value="##Size##">
</td>
</tr>

<tr>
<td align="right">
<b>Text Color</b>
</td>
<td>
<input type="text" name="Color" size="15" value="##Color##">
</td>
</tr>

<tr>
<td align="right">
<b>Shadow Color</b>
</td>
<td>
<input type="text" name="Shadow" size="15" value="##Shadow##">
</td>
</tr>

</table>

<br />


<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>

<!--[If Start Loaded]-->
<td align="center" width="50%">
<input type="submit" onClick="setRun('UpdateAnnotation');" value="Update Annotation">
</td>
<td align="center" width="50%">
<input type="submit" onClick="setRun('DisplayManageAnnotations');" value="New Annotation">
</td>
<!--[If Else]-->
<td align="center">
<input type="submit" onClick="setRun('AddAnnotation');" value="Add Annotation">
</td>
<!--[If End]-->

</tr>
</table>

<input type="hidden" name="Run" value="AddAnnotation">

</form>

</body>
</html>