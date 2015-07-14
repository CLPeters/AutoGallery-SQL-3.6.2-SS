<html>
<head>
<title>Upload Preview Thumbnail</title>
<script language="JavaScript">
function checkForm(form)
{
    if( !form.Preview.value )
    {
        alert('Please select a thumbnail to upload');
        return false;
    }

    return true;
}
</script>
<!--[Include File ./templates/admin.css]-->
</head>
<body>

<div align="center">

<form name="form" action="main.cgi" method="POST" enctype="multipart/form-data" onSubmit="return checkForm(this)">

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="tablehead">
Upload Preview Thumbnail
</td>
</tr>

<tr>
<td align="center">
<input type="file" name="Preview" size="35">

<!--[If Start Code {$HAVE_MAGICK}]-->
<div style="padding-top: 10px;">
<input type="checkbox" name="Crop" value="1" class="nomargin"> 
Crop and resize this image to <input type="text" name="Width" size="3" value="##Width##"> width x <input type="text" name="Height" size="3" value="##Height##"> height
</div>
<!--[If End]-->
</td>
</tr>
</table>

<br />

<table class="outlined" width="600" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="hidden" name="Gallery_ID" value="##Gallery_ID##">
<input type="hidden" name="Run" value="UploadThumbnail">
<input type="submit" value="Upload">
</td>
</tr>
</table>

</div>

</body>
</html>