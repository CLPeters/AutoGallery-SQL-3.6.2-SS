<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<script language="JavaScript">

function updateFrame()
{
    var parent = window.parent.document;
    var frame = parent.getElementById('main');
    var form = document.review;

    frame.src = '';

    // Update options
    setSelect(form.O_Type, '##O_Type##');
    setSelect(form.O_Category, '##O_Category##');
    setSelect(form.O_Format, '##O_Format##');
    setSelect(form.O_Sort, '##O_Sort##');
    setSelect(form.O_SortDir, '##O_SortDir##');
}



function setSelect(field, value)
{
    for( var i = 0; i < field.options.length; i++ )
    {
        if( field.options[i].value == value )
        {
            field.selectedIndex = i;
            return;
        }
    }
}



function showOptions()
{
    var element = document.getElementById('options');
    var width = 0;

    if( document.layers )
        width = window.innerWidth;
    else
        width = document.body.offsetWidth;

    element.style.top = 10;
    element.style.left = (width / 2) - 375;
    element.style.visibility = 'visible';

    return false;
}



function hideOptions()
{
    var element = document.getElementById('options');
    element.style.visibility = 'hidden';
    return false;
}

function submitForm()
{
    document.review.submit();
    return false;
}

</script>

<!--[Include File ./templates/admin.css]-->

<style>
.big
{
    font-family: Arial;
    font-size:   14px;
    font-weight: bold;
}
</style>
</head>
<body onLoad="updateFrame()">

<div align="center" class="big">
There are no more galleries that need to be reviewed.

<br /><br />

<!--[If Start Limit]-->
<a href="" onclick="return submitForm()" class="link" target="_parent">Review the galleries you skipped</a>
<!--[If End]-->
</div>

<br /><br />

<center>
<input type="button" onclick="showOptions()" value="Options">
</center>

<form name="review" action="review.cgi" method="POST">
<!-- FLOATING OPTIONS -->
<table width="750" cellspacing="0" cellpadding="3" style="visibility: hidden; position: absolute;" class="outlined" id="options">
<tr>
<td colspan="4" align="center" class="tablehead">
Options
</td>
</tr>

<tr>
<td align="right">
<b>Type:</b>
</td>
<td>
<select name="O_Type">
  <option value="0">All</option>
  <option value="Submitted">Submitted</option>
  <option value="Permanent">Permanent</option>
</select>
</td>
<td align="right">
<b>Category:</b>
</td>
<td>
<select name="O_Category">
  <option value="0">All</option>
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Format:</b>
</td>
<td>
<select name="O_Format">
  <option value="0">All</option>
  <option value="Pictures">Pictures</option>
  <option value="Movies">Movies</option>
</select>
</td>
<td align="right">
<b>Sort:</b>
</td>
<td>
<select name="O_Sort">
  <option value="Added_Stamp">Added Time</option>
  <option value="Gallery_ID">Gallery ID</option>
</select>
<select name="O_SortDir">
  <option value="DESC">Descending</option>
  <option value="ASC">Ascending</option>
</select>
</td>
</tr>

<tr>
<td align="center" colspan="4">
<input type="submit" value="Save">
<input type="hidden" name="Run" value="Save">
&nbsp;&nbsp;&nbsp;
<input type="button" value="Cancel" onclick="hideOptions()">
</td>
</tr>
</table>
<!-- END FLOATING OPTIONS -->

</form>

</body>
</html>