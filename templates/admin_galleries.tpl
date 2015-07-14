<html>
<head>
<script language="JavaScript">
<!--[If Start Code {$O_TGP_CROPPER}]-->
var tgp_cropper = true;
var cropper_url = '##TGP_Cropper##';
<!--[If Else]-->
var tgp_cropper = false;
<!--[If End]-->

<!--[If Start Code {$HAVE_MAGICK}]-->
var have_magick = true;
<!--[If Else]-->
var have_magick = false;
<!--[If End]-->
var file_name = '##File_Name##_';
var g_xml_url = 'xml.cgi';
var g_admin_url = '##Script_URL##/admin/main.cgi';
var g_unique = '##Unique##';

<!--[Include File ./templates/ajax.js]-->
</script>
<!--[Include File ./templates/admin_galleries.js]-->
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<!--[If End]-->


<div align="center">


<!-- BEGIN SEARCH TABLE -->

<form name="form" action="main.cgi" method="POST" onSubmit="return checkForm(this);">

<table class="outlined" width="700" cellspacing="0" cellpadding="3" border="0">
<tr>
<td colspan="3" align="center" class="tablehead">
Display Galleries
</td>
</tr>

<tr>
<td class="subhead" width="385">
Select which galleries to display<br />
</td>
<td class="subhead" width="315">
Select which categories to display
<span style="margin-left: 50px; font-weight: normal">
<a href="" onClick="return allCategories()">[All]</a>
</span>
</td>
</tr>

<tr>
<td>


<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
<td valign="top">


<script language="JavaScript">
{
var keys = new Array("Unconfirmed","Pending","Approved","Used","Holding","Disabled");
for( var i = 0; i < keys.length; i++ )
{
    document.write('<input type="checkbox" name="Status" value="' + keys[i] + '" style="margin-left: 20px;"');
    document.write(("##Status##".indexOf(keys[i]) == -1 ? '' : ' checked') + '> ' + keys[i] + '<br />');
}
}
</script>

<br />

<script language="JavaScript">
document.write('<input type="checkbox" name="Has_Thumb" value="1" style="margin-left: 20px;"' + ("##Has_Thumb##".indexOf('1') == -1 ? '' : ' checked') + '> Has thumbnail preview<br />');
document.write('<input type="checkbox" name="Has_Thumb" value="0" style="margin-left: 20px;"' + ("##Has_Thumb##".indexOf('0') == -1 ? '' : ' checked') + '> No thumbnail preview<br />');
</script>

</td>
<td valign="top">

<script language="JavaScript">
{
var keys = new Array("Pictures","Movies");
for( var i = 0; i < keys.length; i++ )
{
    document.write('<input type="checkbox" name="Format" value="' + keys[i] + '" style="margin-left: 20px;"');
    document.write(("##Format##".indexOf(keys[i]) == -1 ? '' : ' checked') + '> ' + keys[i] + '<br />');
}
}
</script>

<br />
<br />

<script language="JavaScript">
{
var keys = new Array("Submitted","Permanent");
for( var i = 0; i < keys.length; i++ )
{
    document.write('<input type="checkbox" name="Type" value="' + keys[i] + '" style="margin-left: 20px;"');
    document.write(("##Type##".indexOf(keys[i]) == -1 ? '' : ' checked') + '> ' + keys[i] + '<br />');
}
}
</script>

<br />
<br />

<script language="JavaScript">
document.write('<input type="checkbox" name="Partner" value="1" style="margin-left: 20px;"' + (parseInt('##Partner##') == 1 ? "checked" : "") + '> Partners<br />');
</script>

</td>
</tr>
</table>


</td>
<td align="left" valign="top" rowspan="7">
<select name="Category" size="23" style="margin-left: 10px; width: 200px;" multiple>
##Category_Options##
</select>
</td>
</tr>


<tr>
<td class="subhead">
Search and Sorting Options

<span style="margin-left: 100px; font-weight: normal;">
<a href="" onClick="return openWindow('', 'QuickTasks');">[Quick Tasks]</a>
</span>
</td>
</tr>

<tr>
<td>
<span style="margin-left: 20px;">
Search In
</span>
<select name="Search_Field" style="margin-left: 18px;">
<script language="JavaScript">
{
var keys = new Array("Gallery_ID","Gallery_URL","Email","Description","Sponsor","Nickname","Thumb_Width","Thumb_Height","Weight","Display_Date","Scheduled_Date","Delete_Date","Keywords","Account_ID","Submit_IP","Gallery_IP","Confirm_ID");
var vals = new Array("Gallery ID","Gallery URL","E-mail Address","Description","Sponsor","Name","Thumb Width","Thumb Height","Weight","Display Date","Scheduled Date","Delete Date","Keywords","Partner Account","Submitter IP","Gallery IP","Confirm ID");

for( var i = 0; i < keys.length; i++ )
{
    document.write('<option value="' + keys[i] + '"' + (keys[i] == '##Search_Field##' ? ' selected' : '') + '>' + vals[i] + '</option>');
}
}
</script>
</select>
</td>
</tr>

<tr>
<td>
<span style="margin-left: 20px;">
Search Term
</span>
<select name="Match">
<script language="JavaScript">
{
var keys = new Array("Contains","Matches");

for( var i = 0; i < keys.length; i++ )
{
    document.write('<option value="' + keys[i] + '"' + (keys[i] == '##Match##' ? ' selected' : '') + '>' + keys[i] + '</option>');
}
}
</script>
</select>
<input type="text" name="Search_Value" size="30" value="##Search_Value##">
</td>
</tr>

<tr>
<td>
<span style="margin-left: 20px;">
Sort 1st
</span>
<select name="Order_Field" style="margin-left: 29px;">
<script language="JavaScript">
{
var keys = new Array("Gallery_ID","Thumbnails","Category","Clicks","Weight","Thumb_Width","Thumb_Height","Added_Date","Times_Selected","Display_Date","Scheduled_Date","Submit_IP","Gallery_IP","Nickname","Email","Account_ID","Moderator","Approve_Stamp","(Clicks/Build_Counter)","RAND()","Description");
var vals = new Array("Gallery ID","Thumbnails","Category","Clicks","Weight","Thumb Width","Thumb Height","Date Added","Times Selected","Display Date","Scheduled Date","Submitter IP","Gallery IP","Name","E-mail","Partner Account","Moderator","Approval Date","Productivity","Random","Description");

for( var i = 0; i < keys.length; i++ )
{
    document.write('<option value="' + keys[i] + '"' + (keys[i] == '##Order_Field##' ? ' selected' : '') + '>' + vals[i] + '</option>');
}
}
</script>
</select>
<select name="Direction">
<script language="JavaScript">
{
var keys = new Array("DESC","ASC");
var vals = new Array("Descending","Ascending");
for( var i = 0; i < keys.length; i++ )
{
    document.write('<option value="' + keys[i] + '"' + (keys[i] == '##Direction##' ? ' selected' : '') + '>' + vals[i] + '</option>');
}
}
</script>
</select>
</td>
</tr>

<tr>
<td>
<span style="margin-left: 20px;">
Sort 2nd
</span>
<select name="Order_Field2" style="margin-left: 25px;">
<script language="JavaScript">
{
var keys = new Array("Gallery_ID","Thumbnails","Category","Clicks","Weight","Thumb_Width","Thumb_Height","Added_Date","Times_Selected","Display_Date","Scheduled_Date","Submit_IP","Gallery_IP","Nickname","Email","Account_ID","Moderator","Approve_Stamp","(Clicks/Build_Counter)","RAND()","Description");
var vals = new Array("Gallery ID","Thumbnails","Category","Clicks","Weight","Thumb Width","Thumb Height","Date Added","Times Selected","Display Date","Scheduled Date","Submitter IP","Gallery IP","Name","E-mail","Partner Account","Moderator","Approval Date","Productivity","Random","Description");

for( var i = 0; i < keys.length; i++ )
{
    document.write('<option value="' + keys[i] + '"' + (keys[i] == '##Order_Field2##' ? ' selected' : '') + '>' + vals[i] + '</option>');
}
}
</script>
</select>
<select name="Direction2">
<script language="JavaScript">
{
var keys = new Array("", "DESC","ASC");
var vals = new Array("", "Descending","Ascending");
for( var i = 0; i < keys.length; i++ )
{
    document.write('<option value="' + keys[i] + '"' + (keys[i] == '##Direction2##' ? ' selected' : '') + '>' + vals[i] + '</option>');
}
}
</script>
</select>
</td>
</tr>

<tr>
<td>
<span style="margin-left: 20px;">
Per Page
</span>
<input type="text" name="Per_Page" size="10" value="##Per_Page##" style="margin-left: 23px;">
</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" value="Display Galleries" onClick="newSearch(document.form);">
</td>
</tr>
</table>

<input type="hidden" name="Page" value="##Page##">
<input type="hidden" name="Changed" value="">
<input type="hidden" name="Run" value="ProcessGalleries">
<!-- END SEARCH TABLE -->

</div>

<br />

<!-- BEGIN RESULTS TABLE -->
<!--[If Start Galleries]-->
<table align="center" class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td width="100">
<script language="JavaScript">
if( ##Page## != 0 )
document.write('<a href="" onClick="return submitForm(-1);">&lt;&lt; Prev</a>');
</script>
</td>
<td align="center">
<input type="submit" value="Process Changes">

<script language="JavaScript">
var pages = Math.ceil(##Total##/##Per_Page##);
var this_page = ##Page## + 1;

if( pages )
{
    document.write('<input type="button" value="Jump To Page" onClick="jumpPage()" style="margin-left: 40px;">&nbsp;<select name="Page_Jump">');

    for( var i = 0; i < pages; i++ )
    {
        document.write('<option value="' + i + '"');

        if( i+1 == this_page )
        {
            document.write(' selected');
        }

        document.write('>#' + (i+1) + '</option>');
    }

    document.write('</select>');
}
</script>

</td>
<td width="100" align="right">
<script language="JavaScript">
if( ##Total## != ##End## )
document.write('<a href="" onClick="return submitForm(1);">Next &gt;&gt;</a>');
</script>
</td>
</tr>
</table>

<br />


<table class="outlined" width="100%" cellspacing="0" cellpadding="3" border="0">
<tr>
<td colspan="5" align="center" class="tablehead">
Galleries ##Start## - ##End## of ##Total##
<span style="padding-left: 20px;">
<script language="JavaScript">
document.write('Page ' + this_page + ' of ' + pages + '');
</script>
</span>
</td>
</tr>



<!--[Loop Start Galleries]-->
<tr class="subhead" id="##Gallery_ID##">
<td style="padding-left: 5px;">
<input type="checkbox" name="Gallery_ID" value="##Gallery_ID##" class="nomargin"> ##Gallery_ID##
<input type="hidden" name="##Gallery_ID##_Icons" id="##Gallery_ID##_Icons" value="##Icons##">
</td>
<td colspan="2" align="right" style="font-weight: normal">
<!--[If Start Productivity]-->
<b>Productivity:</b> ##Productivity##
&nbsp;
<!--[If End]-->

<!--[If Start Account_ID]-->
<span class="partner">##Account_ID##</span>
&nbsp;
<!--[If End]-->

<a href="##Gallery_URL##" target="_blank">[Visit]</a>
&nbsp;

<!--[If Start Email]-->
<a href="mailto:##Email##" target="_blank">[E-mail]</a>
&nbsp;
<!--[If End]-->

<a href="" onClick="return openWindow('##Gallery_ID##', 'ScanGallery');">[Scan]</a>
&nbsp;
<a href="" onClick="return showIcons(event, '##Gallery_ID##')">[Icons]</a>
&nbsp;
<a href="" onClick="return deleteGallery('##Gallery_ID##');">[Delete]</a>
&nbsp;
<a href="" onClick="return openWindow('##Gallery_ID##', 'Blacklist');">[Blacklist]</a>
</span>
</td>
</tr>

<tr id="##Gallery_ID##">
<td style="border-right: 1px solid black;" align="center" valign="center" width="120">

<!--[If Start Has_Thumb]-->
<span id="thumb_##Gallery_ID##">
<img id="prev_##Gallery_ID##" src="##Thumbnail_URL##" onLoad="setThumbSize(this)" style="width: ##Thumb_Width##px; height: ##Thumb_Height##px;" onMouseOver="showFullImage(this, '##Gallery_ID##')" onMouseDown="showImageFilters(event, this, '##Gallery_ID##')"><br />
<!--[If Else]-->
<span id="thumb_##Gallery_ID##" style="visibility: hidden; position: absolute;">
<img id="prev_##Gallery_ID##" onLoad="setThumbSize(this)" onMouseOver="showFullImage(this, '##Gallery_ID##')" onMouseDown="showImageFilters(event, this, '##Gallery_ID##')"><br />
<!--[If End]-->
<a href="" onClick="return openWindow('##Gallery_ID##', 'CropThumbnail');">[Edit]</a>
&nbsp;
<a href="" onClick="return deleteThumb('##Gallery_ID##');">[Delete]</a>
</span>


<!--[If Start Has_Thumb]-->
<span id="nothumb_##Gallery_ID##" style="visibility: hidden; position: absolute;">
<!--[If Else]-->
<span id="nothumb_##Gallery_ID##">
<!--[If End]-->
<a href="" onClick="return openWindow('##Gallery_ID##', 'CropThumbnail');">[No Thumb]</a>
</span>

</td>
<td>


<table cellpadding="0" cellspacing="0" border="0">
<tr>
<td width="85" align="right" class="nopad">
<b>URL:</b>
</td>
<td class="nopad">
<input type="text" size="40" class="##URL_Class##" name="##Gallery_ID##_Gallery_URL" id="##Gallery_ID##_Gallery_URL" value="##Gallery_URL##" onChange="hasChanged('##Gallery_ID##')" onFocus="expand(this, 80)" onBlur="shrink(this, 40)">
</td>
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Thumbnails', '##Gallery_ID##')" class="green">Thumbs</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" size="10" name="##Gallery_ID##_Thumbnails" value="##Thumbnails##" onChange="hasChanged('##Gallery_ID##')">
</td>
</tr>

<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b>Description:</b>
</td>
<td class="nopad">
<input type="text" size="40" class="flat" name="##Gallery_ID##_Description" value="##Description##" onChange="hasChanged('##Gallery_ID##')" onFocus="expand(this, 80)" onBlur="shrink(this, 40)">
</td>
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Scheduled_Date', '##Gallery_ID##')" class="green">Scheduled</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" size="10" name="##Gallery_ID##_Scheduled_Date" value="##Scheduled_Date##" onChange="hasChanged('##Gallery_ID##')">
</td>
</tr>

<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b>Keywords:</b>
</td>
<td class="nopad">
<input type="text" size="40" class="flat" name="##Gallery_ID##_Keywords" value="##Keywords##" onChange="hasChanged('##Gallery_ID##')" onFocus="expand(this, 80)" onBlur="shrink(this, 40)">
</td>
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Delete_Date', '##Gallery_ID##')" class="green">Delete</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" size="10" name="##Gallery_ID##_Delete_Date" value="##Delete_Date##" onChange="hasChanged('##Gallery_ID##')">
</td>
</tr>

<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b>Name:</b>
</td>
<td class="nopad">
<input type="text" size="20" class="flat" name="##Gallery_ID##_Nickname" value="##Nickname##" onChange="hasChanged('##Gallery_ID##')">
<!--[If Start Gallery_IP]-->
&nbsp;&nbsp;
<a href="" onClick="return openWindow('##Gallery_IP##', 'ResolveIP');">[##Gallery_IP##]</a>
<!--[If End]-->
</td>
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Weight', '##Gallery_ID##')" class="green">Weight</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" size="10" name="##Gallery_ID##_Weight" value="##Weight##" onChange="hasChanged('##Gallery_ID##')">
</td>
</tr>



<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Sponsor', '##Gallery_ID##')" class="green">Sponsor</a>:</b>
</td>
<td class="nopad">
<input type="text" size="20" class="flat" name="##Gallery_ID##_Sponsor" value="##Sponsor##" onChange="hasChanged('##Gallery_ID##')">
&nbsp;&nbsp;
<a href="" onClick="return openWindow('##Submit_IP##', 'ResolveIP');">[##Submit_IP##]</a>
</td>
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Type', '##Gallery_ID##')" class="green">Type</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" size="10" name="##Gallery_ID##_Type" value="##Type##" onChange="hasChanged('##Gallery_ID##')" onFocus="changeType('##Gallery_ID##', this)" style="cursor: pointer">
</td>
</tr>


<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Format', '##Gallery_ID##')" class="green">Format</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" style="cursor: pointer" size="10" name="##Gallery_ID##_Format" value="##Format##" onFocus="changeFormat('##Gallery_ID##', this)">

<span style="padding-left: 44px;">
<b><a href="" onClick="return setAll('Display_Date', '##Gallery_ID##')" class="green">Display</a>:</b>
<input type="text" class="flat" size="10" name="##Gallery_ID##_Display_Date" value="##Display_Date##" onChange="hasChanged('##Gallery_ID##')">
</span>
</td>
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Clicks', '##Gallery_ID##')" class="green">Clicks</a>:</b>
</td>
<td class="nopad">
<input type="text" class="flat" size="10" name="##Gallery_ID##_Clicks" value="##Clicks##" onChange="hasChanged('##Gallery_ID##')">
</td>
</tr>

<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Category', '##Gallery_ID##')" class="green">Category</a>:</b>
</td>
<td class="nopad">
<input type="text" name="##Gallery_ID##_Category" value="##Category##" size="15" class="flat" onFocus="showSelect(this, 'CatSelect', '##Gallery_ID##')">

<!--<span style="padding-left: 38px;">
<b><a href="" onClick="return setAll('Tag', '##Gallery_ID##')" class="green">Tag</a>:</b>
<input type="text" class="flat" size="10" name="##Gallery_ID##_Tag" value="##Tag##">
</span>-->
</td>
<td colspan="2" class="nopad" align="center">
<input type="checkbox" class="nomargin" name="##Gallery_ID##_Allow_Scan" value="1" onClick="hasChanged('##Gallery_ID##')"##AS_Checked##> <b>Scan</b> 

<span style="margin-left: 20px;">
<input type="checkbox" class="nomargin" name="##Gallery_ID##_Allow_Thumb" value="1" onClick="hasChanged('##Gallery_ID##')"##AT_Checked##> <b>Thumb</b> 
</span>
</td>
</tr>

<tr id="##Gallery_ID##">
<td width="85" align="right" class="nopad">
<b><a href="" onClick="return setAll('Status', '##Gallery_ID##')" class="green">Status</a>:</b>
</td>
<td class="nopad" colspan="3">
<input type="text" name="##Gallery_ID##_Status" value="##Status##" size="12" class="flat" onFocus="showSelect(this, 'StatusSelect', '##Gallery_ID##')">

&nbsp;
&nbsp;

<!--[If Start Code {!$T{'Galleries'}[$i]{'Moderator'}}]-->
<b><a href="" onClick="return setAll('Reject', '##Gallery_ID##')" class="green">Reject</a>:</b>
<input type="text" name="##Gallery_ID##_Reject" value="##Default_Reject##" size="14" class="flat" onFocus="showSelect(this, 'RejectSelect', '##Gallery_ID##')">
<!--[If Else]-->
[##Moderator## on ##Approve_Date##]
<!--[If End]-->

&nbsp;
&nbsp;
[##Added_Date##]
</td>
<td width="85" align="right" class="nopad">
</td>
<td class="nopad">
</td>
</tr>

<tr id="##Gallery_ID##">
<!--[If Start Comments]-->
<td width="85" align="right" class="nopad">
<b>Notes:</b>
</td>
<td class="nopad" colspan="3">
##Comments##
</td>
<!--[If Else]-->
<td colspan="3" class="nopad" height="0"></td>
<!--[If End]-->
</tr>


</table>


</td>
</tr>
<!--[Loop End]-->





</table>

<br />

<table align="center" class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td width="100">
<script language="JavaScript">
if( ##Page## != 0 )
document.write('<a href="" onClick="return submitForm(-1);">&lt;&lt; Prev</a>');
</script>
</td>
<td align="center">
<input type="button" name="Select_All" value="Select All" onClick="selectAll(document.form);">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" value="Delete Selected" onClick="setRun('DeleteSelectedGalleries');">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" value="Process Changes" onClick="setRun('ProcessGalleries');">
</td>
<td width="100" align="right">
<script language="JavaScript">
if( ##Total## != ##End## )
document.write('<a href="" onClick="return submitForm(1);">Next &gt;&gt;</a>');
</script>
</td>
</tr>
</table>

</form>

<!--[If Else]-->
<div align="center" style="color: red;">
<b>No Galleries Matched Your Search Criteria</b>
</div>
<br />
<!--[If End]-->
<!-- END RESULTS TABLE -->




<!-- STATUS SELECTION -->
<select id="StatusSelect" onChange="changeSelectField(this, 'Status')" onBlur="closeSelect(this)" style="visibility: hidden; position: absolute;">
  <option value="Unconfirmed">Unconfirmed</option>
  <option value="Pending">Pending</option>
  <option value="Approved">Approved</option>
  <option value="Used">Used</option>
  <option value="Disabled">Disabled</option>
  <option value="Reject">Reject</option>
</select>
<!-- END STATUS SELECTION -->


<!-- REJECTION SELECTION -->
<select id="RejectSelect" onChange="changeSelectField(this, 'Reject')" onBlur="closeSelect(this)" style="visibility: hidden; position: absolute;">
  <option value="None">None</option>
<!--[Loop Start Reasons]-->
  <option value="##Reason##"##Selected##>##Reason##</option>
<!--[Loop End]-->
</select>
<!-- END REJECTION SELECTION -->


<!-- CATEGORY SELECTION -->
<select id="CatSelect" onChange="changeSelectField(this, 'Category')" onBlur="closeSelect(this)" style="visibility: hidden; position: absolute;">
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>
<!-- END CATEGORY SELECTION -->


<!-- FLOATING IMAGE -->
<img id="floater" style="visibility: hidden; position: absolute; border: 1px solid black;" onMouseOut="hideFullImage()" onMouseDown="showImageFilters(event, this, null)">
<!-- END FLOATING IMAGE -->


<!-- FLOATING ICON SELECTION -->
<form name="icon_form">
<table width="150" cellspacing="0" cellpadding="3" style="visibility: hidden; position: absolute; border: 1px solid black;" id="icon_select" class="outlined">
<tr>
<td colspan="2" align="center" class="tablehead" style="background-color: black;">
Icons
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
<!--[Loop Start Icons]-->
<input type="checkbox" name="Icons" value="##Identifier##"> ##HTML##<br />
<!--[Loop End]-->
</td>
</tr>
<tr>
<td align="center">
<input type="button" value="Done" onClick="updateIcons()">
<input type="button" value="All" onClick="updateIconsAll()">
</td>
</tr>
</table>
</form>
<!-- END FLOATING ICON SELECTION -->


<!-- FLOATING IMAGE FILTERS -->
<form name="xml">
<table width="300" cellspacing="0" cellpadding="3" style="visibility: hidden; position: absolute; border: 1px solid black;" id="filters" class="outlined">
<tr>
<td colspan="2" align="center" class="tablehead" style="background-color: black;">
Image Filters
</td>
</tr>

<tr class="subhead">
<td>
Sharpen
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
Amount <input type="text" name="sSigma" size="3" value="0.6"> <input type="button" value="Apply" onClick="applyCommand('sharpen')">
</td>
</tr>

<tr class="subhead">
<td>
Brightness
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
Amount <input type="text" name="bAmount" size="3" value="1.2"> <input type="button" value="Apply" onClick="applyCommand('brightness')">
</td>
</tr>

<tr class="subhead">
<td>
Contrast
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
<input type="button" value="Increase" onClick="applyCommand('contrastup')"> <input type="button" value="Decrease" onClick="applyCommand('contrastdown')">
</td>
</tr>

<tr class="subhead">
<td>
Normalize
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
<input type="button" value="Normalize" onClick="applyCommand('normalize')">
</td>
</tr>

<!--[If Start Annotations]-->
<tr class="subhead">
<td>
Annotation
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
<select name="Annotation">
<!--[Loop Start Annotations]-->
  <option value="##Unique_ID##">##Identifier##</option>
<!--[Loop End]-->
</select>
<input type="button" value="Apply" onClick="applyCommand('annotation')">
</td>
</tr>
<!--[If End]-->

<tr class="subhead">
<td>
Undo
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
<input type="button" value="Undo" onClick="applyCommand('undo')" id="undo" disabled> <input type="button" value="Reset" onClick="applyCommand('reset')" id="reset" disabled>
</td>
</tr>

<tr class="subhead">
<td>
Save
</td>
</tr>
<tr>
<td style="padding-left: 20px;">
<input type="button" value="Save Changes" onClick="applyCommand('done')" id="save" disabled>
<input type="button" value="Cancel" onClick="applyCommand('cancel')">
</td>
</tr>

</table>
</form>
<!-- END FLOATING IMAGE FILTERS -->


<br />
<br />
<br />
<br />
<br />
<br />


</body>
</html>

