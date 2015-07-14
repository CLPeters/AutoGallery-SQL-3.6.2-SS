<html>
<head>
<script language="JavaScript">
function showCrop()
{
<!--[If Start Crop]-->
<!--[If Start TGP_Cropper]-->
    openTGPCropper();
<!--[If Elsif Code {$HAVE_MAGICK}]-->
    openWebCropper();
<!--[If Else]-->
    return true;
<!--[If End]-->
<!--[If End]-->
}


function openTGPCropper()
{
    newWindow = window.open('##TGP_Cropper##&Gallery_URL='+ escape(gallery_url) +'&Gallery_ID=##Gallery_ID##', 'menubar=no,height=0,width=0,scrollbars=yes,resizable=yes');
    newWindow.close();
    return false;
}


function openWebCropper()
{
    window.open('main.cgi?Run=DisplayCrop&Gallery_ID=##Gallery_ID##', '_blank', 'menubar=no,height=768,width=1024,scrollbars=yes,resizable=yes');
    return false;
}


function checkForm(form)
{   
    if( form.Email.value.search(/^[\w\d][\w\d\,\.\-]*\@([\w\d\-]+\.)+([a-zA-Z]+)$/) == -1 )
    {
        alert("Invalid E-mail Address");
        return false;
    }


    if( form.Gallery_URL.value.search(/^http:\/\/[\w\d\-\.]+\.[\w\d\-\.]+/) == -1 )
    {
        alert("Invalid Gallery URL");
        return false;
    }

    if( !form.Thumbnails.value )
    {
        alert("Please enter the number of thumbnails on this gallery");
        return false;
    }
}
</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody" onLoad="showCrop();">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<!--[If Start WarnURL]-->
<div class="errormessage">
The gallery URL you supplied produced the following<br />
error message when it was scanned: ##WarnURL##<br />
You may want to check that the URL is valid and working.
</div>
<br />
<!--[If End]-->

<!--[If Start WarnNoThumbs]-->
<div class="errormessage">
The gallery URL you supplied was scanned and no thumbnails<br />
could be found.  You may want to check that the URL is<br />
pointing to a valid gallery.
</div>
<br />
<!--[If End]-->


<!--[If Start Crop]-->
<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center">
If the cropping window does not appear because you<br />
are using a pop-up blocker, 
<!--[If Start TGP_Cropper]-->
<a href="#" onClick="return openTGPCropper()">click here</a>
<!--[If Elsif Code {$HAVE_MAGICK}]-->
<a href="#" onClick="return openWebCropper()">click here</a>
<!--[If End]-->
to open open it.
</td>
</tr>
</table>

<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST" enctype="multipart/form-data" onSubmit="return checkForm(this)">

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Gallery Details
</td>
</tr>

<tr>
<td align="right">
<b>E-mail</b>
</td>
<td>
<input type="text" name="Email" size="30">
</td>
</tr>

<tr>
<td align="right">
<b>Name</b>
</td>
<td>
<input type="text" name="Nickname" size="20">
</td>
</tr>

<tr>
<td align="right">
<b>Gallery URL</b>
</td>
<td>
<input type="text" name="Gallery_URL" size="60">
</td>
</tr>

<tr>
<td align="right">
<b>Description</b>
</td>
<td>
<input type="text" name="Description" size="60">
</td>
</tr>

<tr>
<td align="right">
<b>Keywords</b>
</td>
<td>
<input type="text" name="Keywords" size="60">
</td>
</tr>

<tr>
<td align="right">
<b>Category</b>
</td>
<td>
<select name="Category">
<!--[Loop Start Categories]-->
  <option value="##Category##">##Category##</option>
<!--[Loop End]-->
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Sponsor</b>
</td>
<td>
<input type="text" name="Sponsor" size="40">
</td>
</tr>

<tr>
<td align="right">
<b>Thumbnails</b>
</td>
<td>
<input type="text" name="Thumbnails" size="10">
</td>
</tr>

<tr>
<td align="right">
<b>Weight</b>
</td>
<td>
<input type="text" name="Weight" size="10" value="1.000">
</td>
</tr>

<tr>
<td align="right">
<b>Type</b>
</td>
<td>
<select name="Type">
  <option value="Submitted">Submitted</option>
  <option value="Permanent">Permanent</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Format</b>
</td>
<td>
<select name="Format">
  <option value="Pictures">Pictures</option>
  <option value="Movies">Movies</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Status</b>
</td>
<td>
<select name="Status">
  <option value="Pending">Pending</option>
  <option value="Approved">Approved</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Scheduled Date</b>
</td>
<td>
<input type="text" name="Scheduled_Date" size="20"> YYYY-MM-DD
</td>
</tr>

<tr>
<td align="right">
<b>Delete Date</b>
</td>
<td>
<input type="text" name="Delete_Date" size="20"> YYYY-MM-DD
</td>
</tr>

<tr>
<td align="right" valign="top">
<b>Options</b>
</td>
<td valign="top">
<input type="checkbox" name="Allow_Scan" value="1" checked> Allow the gallery scanner to scan this gallery<br />
<input type="checkbox" name="Allow_Thumb" value="1" checked> Allow the gallery scanner to create a thumbnail for this gallery
</td>
</tr>
</table>

<br />

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Preview Thumbnail
</td>
</tr>

<tr>
<td class="subhead">
<input type="radio" name="Preview" value="None" checked> No thumbnail for this gallery
</td>
</tr>


<!--[If Start Code {$HAVE_MAGICK}]-->
<tr>
<td class="subhead">
<input type="radio" name="Preview" value="Crop"> Crop thumbnail after gallery is submitted
</td>
</tr>
<!--[If End]-->

<tr>
<td class="subhead">
<input type="radio" name="Preview" value="Upload"> Upload from hard drive
</td>
</tr>

<tr>
<td style="padding-left: 20px;">
<input type="file" name="Upload" size="35">
<!--[If Start Code {$HAVE_MAGICK}]-->
<br />
<div style="padding-top: 10px;">
<input type="checkbox" name="Crop" value="1" class="nomargin"> 
Crop and resize this image to <input type="text" name="Width" size="3" value="##Width##"> width x <input type="text" name="Height" size="3" value="##Height##"> height
</div>
<!--[If End]-->

</td>
</tr>

<tr>
<td class="subhead">
<input type="radio" name="Preview" value="Specify"> Enter Thumbnail Information
</td>
</tr>

<tr>
<td style="padding-left: 20px;">

<table width="100%" cellspacing="0" cellpadding="3">
<tr>
<td align="right">
<b>Thumbnail URL</b>
</td>
<td>
<input type="text" name="Thumbnail_URL" size="60">
</td>
</tr>
<tr>
<td align="right">
<b>Thumb Width</b>
</td>
<td>
<input type="text" name="Thumb_Width" size="10" value="##Width##">
</td>
</tr>
<tr>
<td align="right">
<b>Thumb Height</b>
</td>
<td>
<input type="text" name="Thumb_Height" size="10" value="##Height##">
</td>
</tr>
</table>

</td> 
</tr>


</table>

<br />

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="submit" value="Add Gallery">
<input type="hidden" name="Run" value="SubmitGallery">
</td>
</tr>
</table>

</form>

<br />
<br />

</body>
</html>