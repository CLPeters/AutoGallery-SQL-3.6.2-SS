<html>
<head>
<title>Quick Tasks</title>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
<style>
.spaced { padding-bottom: 5px; }
</style>
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'SearchAndReplace' )
    {
        if( !form.SRFind.value )
        {
            alert('All form fields must be filled in');
            return false;
        }
    }
    else if( form.Run.value == 'SearchAndDelete' )
    {
        if( !form.SDFind.value )
        {
            alert('All form fields must be filled in');
            return false;
        }
    }
    else if( form.Run.value == 'SearchAndSet' )
    {
        if( !form.SSFind.value )
        {
            alert('All form fields must be filled in');
            return false;
        }
    }

    return confirm('Are you sure you want to do this?');
}

function submitForm(func)
{
    if( confirm('Are you sure you want to do this?') )
    {
        setRun(func);
        document.form.submit();
    }

    return false;
}


function displayDuplicates()
{
    window.open('main.cgi?Run=DisplayDuplicates', '_blank', 'menubar=no,height=768,width=1024,scrollbars=yes,resizable=yes');
    return false;
}
</script>
</head>
<body>

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" method="POST" onSubmit="return checkForm(this)">
<input type="hidden" name="Run" value="">

<table class="outlined" width="515" cellspacing="0" cellpadding="3" align="center">
<tr>
<td colspan="2" align="center" class="menuhead">
Quick Tasks
</td>
</tr>

<tr>
<td colspan="2" class="subhead">
Search and Replace
</td>
</tr>

<tr>
<td align="right">
<b>Find</b>
</td>
<td>
<input type="text" name="SRFind" size="30">

<b>in</b>

<select name="SRFindIn">
  <option value="Email">Email</option>
  <option value="Gallery_URL">Gallery URL</option>
  <option value="Thumbnail_URL">Thumbnail URL</option>
  <option value="Description">Description</option>
  <option value="Thumbnails">Thumbnails</option>
  <option value="Category">Category</option>
  <option value="Sponsor">Sponsor</option>
  <option value="Thumb_Width">Thumb Width</option>
  <option value="Thumb_Height">Thumb Height</option>
  <option value="Weight">Weight</option>
  <option value="Nickname">Nickname</option>
  <option value="Clicks">Clicks</option>
  <option value="Keywords">Keywords</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Replace With</b>
</td>
<td>
<input type="text" name="SRReplace" size="30">

</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" value="Replace" onClick="setRun('SearchAndReplace')">
</td>
</tr>

<tr>
<td colspan="2" class="subhead">
Search and Set
</td>
</tr>

<tr>
<td align="right">
<b>Find</b>
</td>
<td colspan="2">
<input type="text" name="SSFind" size="30">

<b>in</b>

<select name="SSFindIn">
  <option value="Email">Email</option>
  <option value="Gallery_URL">Gallery URL</option>
  <option value="Thumbnail_URL">Thumbnail URL</option>
  <option value="Description">Description</option>
  <option value="Thumbnails">Thumbnails</option>
  <option value="Category">Category</option>
  <option value="Sponsor">Sponsor</option>
  <option value="Thumb_Width">Thumb Width</option>
  <option value="Thumb_Height">Thumb Height</option>
  <option value="Weight">Weight</option>
  <option value="Nickname">Nickname</option>
  <option value="Clicks">Clicks</option>
  <option value="Type">Type</option>
  <option value="Format">Format</option>
  <option value="Added_Date">Added Date</option>
  <option value="Approve_Date">Approve Date</option>
  <option value="Scheduled_Date">Scheduled Date</option>
  <option value="Display_Date">Display Date</option>
  <option value="Delete_Date">Delete Date</option>
  <option value="Account_ID">Partner</option>
  <option value="Moderator">Moderator</option>
  <option value="Submit_IP">Submit IP</option>
  <option value="Gallery_IP">Gallery IP</option>
  <option value="Keywords">Keywords</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Set</b>
</td>
<td>
<select name="SSSetIn">
  <option value="Email">Email</option>
  <option value="Gallery_URL">Gallery URL</option>
  <option value="Thumbnail_URL">Thumbnail URL</option>
  <option value="Description">Description</option>
  <option value="Thumbnails">Thumbnails</option>
  <option value="Category">Category</option>
  <option value="Sponsor">Sponsor</option>
  <option value="Thumb_Width">Thumb Width</option>
  <option value="Thumb_Height">Thumb Height</option>
  <option value="Weight">Weight</option>
  <option value="Nickname">Nickname</option>
  <option value="Clicks">Clicks</option>
  <option value="Type">Type</option>
  <option value="Format">Format</option>
  <option value="Scheduled_Date">Scheduled Date</option>
  <option value="Delete_Date">Delete Date</option>
  <option value="Keywords">Keywords</option>
</select>

<b>to</b>

<input type="text" name="SSSet" size="30">
</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" value="Set" onClick="setRun('SearchAndSet')">
</td>
</tr>


<tr>
<td class="subhead" colspan="2">
Search and Delete
</td>
</tr>

<tr>
<td align="center" colspan="2">
<b>Find</b>

<input type="text" name="SDFind" size="30">

<b>in</b>

<select name="SDFindIn">
  <option value="Email">Email</option>
  <option value="Gallery_URL">Gallery URL</option>
  <option value="Thumbnail_URL">Thumbnail URL</option>
  <option value="Description">Description</option>
  <option value="Thumbnails">Thumbnails</option>
  <option value="Category">Category</option>
  <option value="Sponsor">Sponsor</option>
  <option value="Thumb_Width">Thumb Width</option>
  <option value="Thumb_Height">Thumb Height</option>
  <option value="Weight">Weight</option>
  <option value="Nickname">Nickname</option>
  <option value="Clicks">Clicks</option>
  <option value="Type">Type</option>
  <option value="Status">Status</option>
  <option value="Format">Format</option>
  <option value="Added_Date">Added Date</option>
  <option value="Approve_Date">Approve Date</option>
  <option value="Scheduled_Date">Scheduled Date</option>
  <option value="Display_Date">Display Date</option>
  <option value="Delete_Date">Delete Date</option>
  <option value="Account_ID">Partner</option>
  <option value="Moderator">Moderator</option>
  <option value="Submit_IP">Submit IP</option>
  <option value="Gallery_IP">Gallery IP</option>
  <option value="Keywords">Keywords</option>
</select>
</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" value="Delete" onClick="setRun('SearchAndDelete')">
</td>
</tr>


<tr>
<td class="subhead" colspan="2">
Other Functions
</td>
</tr>

<tr>
<td colspan="2" style="padding-left: 20px;">

<div class="spaced"><a href="" onClick="return submitForm('ResetSubmittedClicks')">Reset the click count for all submitted galleries back to zero</a></div>
<div class="spaced"><a href="" onClick="return submitForm('ResetPermanentClicks')">Reset the click count for all permanent galleries back to zero</a></div>
<div class="spaced"><a href="" onClick="return submitForm('DecrementCounters')">Decrement the used and build counters by one</a></div>
<div class="spaced"><a href="" onClick="return submitForm('RemoveUnconfirmed')">Remove unconfirmed galleries that are more than 48 hours old</a></div>
<div class="spaced"><a href="" onClick="return displayDuplicates()">Display duplicate galleries</a></div>
<div class="spaced"><a href="main.cgi?Run=DisplayThumbManager">Display thumbnail management interface</a></div>

</td>
</tr>

</table>

</form>

</body>
</html>