<html>
<head>
<script language="JavaScript">

var cats = new Array(
<!--[Loop Start Categories]-->
"##Name##|##Ext_Pictures##|##Ext_Movies##|##Min_Pictures##|##Min_Movies##|##Max_Pictures##|##Max_Movies##|##Size_Pictures##|##Size_Movies##|##Per_Day##|##Ann_Pictures##|##Ann_Movies##|##Hidden##",
<!--[Loop End Categories]-->
"");


var name  = new Array(
                       'Names',
                       'Per_Day',
                       'Min_Pictures',
                       'Min_Movies',
                       'Max_Pictures',
                       'Max_Movies',
                       'Size_Pictures',
                       'Size_Movies'
                     );

var value = new Array(
                       'Category Names',
                       'Submissions Per Day',
                       'Minimum Pictures',
                       'Minimum Movies',
                       'Maximum Pictures',
                       'Maximum Movies',
                       'Picture File Size',
                       'Movie File Size'
                     );

function checkAddForm(form)
{
    for( var i = 0; i < name.length; i++ )
    {
        if( form.elements[name[i]] && !form.elements[name[i]].value )
        {
            alert(value[i] + ' Must Be Filled In');
            return false;
        }
    }


    if( !form.Ext_Pictures.value && !form.Ext_Movies.value )
    {
        alert('You must fill in one of the Movies or Pictures file extensions fields');
        return false;
    }


    if( parseInt(form.Min_Movies.value) > parseInt(form.Max_Movies.value) )
    {
        alert('Minimum amount of movies cannot exceed maximum amount');
        return false;
    }


    if( parseInt(form.Min_Pictures.value) > parseInt(form.Max_Pictures.value) )
    {
        alert('Minimum amount of pictures cannot exceed maximum amount');
        return false;
    }
}


function checkManageForm(form)
{
    if( checkAddForm(form) == false )
    {
        return false;
    }

    if( form.Run.value == 'RenameCategory' )
    {
        if( !form.NewName.value )
        {
            alert('You must enter a new name for this category');
            return false;
        }
    }
    else if( form.Categories.selectedIndex == -1 )
    {
        alert('You must select at least one category to perform this action on');
        return false;
    }

    if( form.Run.value == 'DeleteCategories' )
    {
        return confirm('Are you sure you want to delete these categories?\r\nAll galleries in these categories will also be deleted!');
    }
}


function changeSelectedCategory(selected)
{
    var form = document.form;
    var cat = cats[form.Categories.selectedIndex].split('|');

    form.Ext_Pictures.value = cat[1];
    form.Ext_Movies.value = cat[2];
    form.Min_Pictures.value = cat[3];
    form.Min_Movies.value = cat[4];
    form.Max_Pictures.value = cat[5];
    form.Max_Movies.value = cat[6];
    form.Size_Pictures.value = cat[7];
    form.Size_Movies.value = cat[8];
    form.Per_Day.value = cat[9];
    form.Hidden.checked = (cat[12] == 1 ? true : false);

    if( form.Ann_Pictures.options )
    {
        form.Ann_Pictures.selectedIndex = 0;
        form.Ann_Movies.selectedIndex = 0;

        if( cat[10] )
        {
            for( var i = 0; i < form.Ann_Pictures.length; i++ )
            {
                if( form.Ann_Pictures.options[i].value == cat[10] )
                {
                    form.Ann_Pictures.options[i].selected = true;
                    break;
                }
            }
        }

        if( cat[11] )
        {
            for( var i = 0; i < form.Ann_Movies.length; i++ )
            {
                if( form.Ann_Movies.options[i].value == cat[11] )
                {
                    form.Ann_Movies.options[i].selected = true;
                    break;
                }
            }
        }
    }
}


function showManage()
{
    var addnew = document.getElementById('add_new');
    var manage = document.getElementById('manage');

    addnew.style.position = 'absolute';
    addnew.style.visibility = 'hidden';

    manage.style.position = 'relative';
    manage.style.visibility = 'visible';
}


function showAddNew()
{
    var addnew = document.getElementById('add_new');
    var manage = document.getElementById('manage');

    addnew.style.position = 'relative';
    addnew.style.visibility = 'visible';

    manage.style.position = 'absolute';
    manage.style.visibility = 'hidden';
}

function allCategories()
{
    var cats = document.form.Categories;

    for( var i = cats.length - 1; i >= 0; i-- )
    {
        cats[i].selected = true;
    }

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



<!--[If Start Categories]-->
<div id="manage" style="width: 800px; text-align: center">

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkManageForm(this)">

<table class="outlined" width="800" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Manage Existing Categories
</td>
</tr>

<tr>
<td class="subhead" width="325">
Existing Categories

<span style="margin-left: 160px; font-weight: normal">
<a href="" onClick="return allCategories()">[All]</a>
</span>
</td>
<td class="subhead" width="475">
File Extensions
</td>
</tr>
<tr>
<td rowspan="12" valign="top">
<div style="margin-left: 20px;">
<select name="Categories" size="18" multiple style="width: 280px;" onChange="changeSelectedCategory(this)">
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>

<br />
<br />
<input type="checkbox" name="Hidden" value="1" class="nomargin" id="make_hidden"> <b><label for="make_hidden">Make these categories hidden</label></b>
</div>
</td>
</tr>

<tr>
<td style="border-left: 2px solid #ececec">
<span id="Extensions" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixCommas(this)" name="Ext_Pictures" value="jpg,gif,jpeg,bmp,png" size="40">
<div style="margin-left: 20px; padding-top: 2px;">
Movies: <input type="text" onChange="fixCommas(this)" name="Ext_Movies" value="avi,mpg,mpeg,rm,wmv,mov,asf" size="40" style="margin-left: 6px;">
</div>
</span>
</td>
</tr>


<tr>
<td class="subhead">
<b>Minimum Amount</b><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<span id="Minimum" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixNumber(this)" name="Min_Pictures" size="15" value="10">
<span style="margin-left: 20px;">
Movies: <input type="text" onChange="fixNumber(this)" name="Min_Movies" size="15" value="3">
</span>
</span>
</td>
</tr>


<tr>
<td class="subhead">
<b>Maximum Amount</b><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<span id="Maximum" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixNumber(this)" name="Max_Pictures" size="15" value="25">
<span style="margin-left: 20px;">
Movies: <input type="text" onChange="fixNumber(this)" name="Max_Movies" size="15" value="25">
</span>
</span>
</td>
</tr>


<tr>
<td class="subhead">
<b>Minimum File Size</b> <span style="font-weight: normal">(in bytes)</span><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<span id="Size" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixNumber(this)" name="Size_Pictures" size="15" value="12288">
<span style="margin-left: 20px;">
Movies: <input type="text" onChange="fixNumber(this)" name="Size_Movies" size="15" value="102400">
</span>
</span>
</td>
</tr>

<tr>
<td class="subhead">
<b>Annotations</b>
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<!--[If Start Annotations]-->
<span style="margin-left: 20px;">
Pictures: 
<select name="Ann_Pictures">
<option value="0">None</option>
<!--[Loop Start Annotations]-->
<option value="##Unique_ID##">##Identifier##</option>
<!--[Loop End]-->
</select>
<div style="margin-left: 20px; padding-top: 2px;">
Movies: 
<select name="Ann_Movies" style="margin-left: 6px;">
<option value="0">None</option>
<!--[Loop Start Annotations]-->
<option value="##Unique_ID##">##Identifier##</option>
<!--[Loop End]-->
</select>
</div>
</span>
<!--[If Else]-->
<span style="margin-left: 20px;">
There are no annotations defined
<input type="hidden" name="Ann_Pictures" value="0">
<input type="hidden" name="Ann_Movies" value="0">
</span>
<!--[If End]-->
</td>
</tr>


<tr>
<td class="subhead">
<b>Maximum Submissions Allowed Per Day</b> <span style="font-weight: normal">(use -1 for no limit)</span><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<input style="margin-left: 20px;" type="text" name="Per_Day" value="-1" size="15" onChange="fixNumber(this)">
</td>
</tr>

<tr>
<td align="center" style="border-top: 2px solid #ececec">
<input type="submit" value="Delete Selected" onClick="setRun('DeleteCategories')">
</td>
<td align="center" style="border-top: 2px solid #ececec">
<input type="submit" value="Update Selected" onClick="setRun('UpdateCategories')">
</td>
</tr>

</table>

<br />

<table class="outlined" width="800" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Rename a Category
</td>
</tr>
<tr>
<td align="center">
<b>Category:</b>
<select name="Rename">
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>

&nbsp;&nbsp;&nbsp;&nbsp;

<b>New Name:</b> <input type="text" name="NewName" size="30">

&nbsp;&nbsp;&nbsp;&nbsp;

<input type="submit" value="Rename" onClick="setRun('RenameCategory')">

</td>
</tr>
</table>

<input type="hidden" name="Run">
<input type="hidden" name="Names" value="x">

</form>

<br />
<br />

<a href="#" onClick="showAddNew()" style="font-size: 10pt; font-weight: bold">Add New Categories</a>

<br />

</div>

<!--[If End]-->

<!--[If Start Categories]-->
<div id="add_new" style="width: 800px; text-align: center; visibility: hidden; position: absolute;">
<!--[If Else]-->
<div id="add_new" style="width: 800px; text-align: center;">
<!--[If End]-->

<form name="addform" action="main.cgi" target="main" method="POST" onSubmit="return checkAddForm(this)">

<table class="outlined" width="800" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Add New Categories
</td>
</tr>

<tr>
<td class="subhead" width="325">
Category Names <span style="font-weight: normal">(one per line)</span><br />
</td>
<td class="subhead" width="475">
File Extensions
</td>
</tr>
<tr>
<td rowspan="12" valign="top">
<div style="margin-left: 20px;">
<textarea rows="18" cols="40" name="Names" wrap="off" onChange='fixPerLine(this)'></textarea>
<br />
<br />
<input type="checkbox" name="Hidden" value="1" class="nomargin" id="make_hidden"> <b><label for="make_hidden">Make these categories hidden</label></b>
</div>
</td>
</tr>

<tr>
<td style="border-left: 2px solid #ececec">
<span id="Extensions" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixCommas(this)" name="Ext_Pictures" value="jpg,gif,jpeg,bmp,png" size="40">
<div style="margin-left: 20px; padding-top: 2px;">
Movies: <input type="text" onChange="fixCommas(this)" name="Ext_Movies" value="avi,mpg,mpeg,rm,wmv,mov,asf" size="40" style="margin-left: 6px;">
</div>
</span>
</td>
</tr>


<tr>
<td class="subhead">
<b>Minimum Amount</b><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<span id="Minimum" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixNumber(this)" name="Min_Pictures" size="15" value="10">
<span style="margin-left: 20px;">
Movies: <input type="text" onChange="fixNumber(this)" name="Min_Movies" size="15" value="3">
</span>
</span>
</td>
</tr>


<tr>
<td class="subhead">
<b>Maximum Amount</b><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<span id="Maximum" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixNumber(this)" name="Max_Pictures" size="15" value="25">
<span style="margin-left: 20px;">
Movies: <input type="text" onChange="fixNumber(this)" name="Max_Movies" size="15" value="25">
</span>
</span>
</td>
</tr>


<tr>
<td class="subhead">
<b>Minimum File Size</b> <span style="font-weight: normal">(in bytes)</span><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<span id="Size" style="margin-left: 20px;">
Pictures: <input type="text" onChange="fixNumber(this)" name="Size_Pictures" size="15" value="12288">
<span style="margin-left: 20px;">
Movies: <input type="text" onChange="fixNumber(this)" name="Size_Movies" size="15" value="102400">
</span>
</span>
</td>
</tr>

<tr>
<td class="subhead">
<b>Annotations</b>
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<!--[If Start Annotations]-->
<span style="margin-left: 20px;">
Pictures: 
<select name="Ann_Pictures">
<option value="0">None</option>
<!--[Loop Start Annotations]-->
<option value="##Unique_ID##">##Identifier##</option>
<!--[Loop End]-->
</select>
<div style="margin-left: 20px; padding-top: 2px;">
Movies: 
<select name="Ann_Movies" style="margin-left: 6px;">
<option value="0">None</option>
<!--[Loop Start Annotations]-->
<option value="##Unique_ID##">##Identifier##</option>
<!--[Loop End]-->
</select>
</div>
</span>
<!--[If Else]-->
<span style="margin-left: 20px;">
There are no annotations defined
<input type="hidden" name="Ann_Pictures" value="0">
<input type="hidden" name="Ann_Movies" value="0">
</span>
<!--[If End]-->
</td>
</tr>


<tr>
<td class="subhead">
<b>Maximum Submissions Allowed Per Day</b> <span style="font-weight: normal">(use -1 for no limit)</span><br />
</td>
</tr>
<tr>
<td style="border-left: 2px solid #ececec">
<input style="margin-left: 20px;" type="text" name="Per_Day" value="-1" size="15" onChange="fixNumber(this)">
</td>
</tr>

<tr>
<td align="center" style="border-top: 2px solid #ececec" colspan="2">
<input type="submit" value="Add Categories">
</td>
</tr>

</table>

<input type="hidden" name="Run" value="AddCategories">

</form>

<!--[If Start Categories]-->
<br />
<br />

<a href="#" onClick="showManage()" style="font-size: 10pt; font-weight: bold">Manage Existing Categories</a>
<!--[If End]-->

</div>

<br />

</body>
</html>