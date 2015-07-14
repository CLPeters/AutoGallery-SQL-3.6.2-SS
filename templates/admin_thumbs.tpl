<html>
<head>
<title>Thumbnail Management</title>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
<style>
.spaced { padding-bottom: 5px; }
</style>
<script language="JavaScript">
function checkForm(form)
{
    if( form.Run.value == 'DeleteThumbs' )
    {
        return confirm('Are you sure you want to do this?');
    }
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
Thumbnail Management
</td>
</tr>

<tr>
<td class="subhead">
Delete Thumbnails
</td>
</tr>
<tr>
<td style="padding-left: 20px; padding-bottom: 5px;">

    <table width="100%">
    <tr>
    <td width="50%" valign="top">
    <input type="checkbox" name="Status" value="Unconfirmed"> Unconfirmed<br />
    <input type="checkbox" name="Status" value="Pending"> Pending<br />
    <input type="checkbox" name="Status" value="Approved"> Approved<br />
    <input type="checkbox" name="Status" value="Used"> Used<br />
    <input type="checkbox" name="Status" value="Holding"> Holding<br />
    <input type="checkbox" name="Status" value="Disabled"> Disabled
    </td>
    <td width="50%" valign="top">
    <input type="checkbox" name="Format" value="Pictures"> Pictures<br />
    <input type="checkbox" name="Format" value="Movies"> Movies    

    <br />
    <br />

    <input type="checkbox" name="Type" value="Submitted"> Submitted<br />
    <input type="checkbox" name="Type" value="Permanent"> Permanent
    </td>
    </tr>
    </table>

    <br />

    <center>
    <select name="Field">
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

    <select name="Match">
      <option value="=">Equals</option>
      <option value="c">Contains</option>
    </select>

    <input type="text" name="Search" size="20">

    <br />
    <br />

    <input type="submit" value="Delete Matching Thumbs" onClick="setRun('DeleteThumbs')">

    </center>

</td>
</tr>


<tr>
<td class="subhead">
Cleanup Thumbnails
</td>
</tr>

<tr>
<td align="center" style="padding-left: 20px; padding-bottom: 5px;">
<input type="submit" value="Cleanup Broken Thumbs" onClick="setRun('ManualThumbCleanup')">
</td>
</tr>

</table>

</form>

</body>
</html>