<html>
<head>
<title>Crop Image</title>
<script language="JavaScript">

// Local information for this file
var prefix = '##Prefix##';
var thumb_url = '##Thumb_URL##';
var async_script_url = 'xml.cgi';
var thumb_cache_url = '##Thumb_URL##/cache';
var gallery_id = '##Gallery_ID##';
var thumb = new Object();
thumb.height = ##Thumb_Height##;
thumb.width = ##Thumb_Width##;
thumb.prop = thumb.height/thumb.width;

<!--[Include File ./templates/ajax.js]-->

</script>
<!--[Include File ./templates/cropadmin.js]-->
<style>
body { background-color: #ececec; }
.flat { border: 1px solid #000000; padding: 1px 2px 1px 2px; margin-top: 5px; font-family: Verdana; font-size: 8pt; }
.nomargin { padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; }
</style>
</head>

<body onLoad="initializeDocument()">


<div align="center">


<div id="div_error" class="div_error">
</div>

<!--If Start Thumbs-->
<!-- Only show this if selecting an image from the gallery-->
<div id="div_wait" class="div_wait">
<div align="left" id="div_prog" class="div_prog">
<div id="text_prog" class="text_prog">\ Scanning Gallery \</div>
<div id="div_bar" class="div_bar">
</div>
</div>
</div>

<br />

<div id="div_thumbs" align="center" class="div_thumbs">
</div>
<br />
<!--If End-->




<!-- MAIN TABLE START -->
<table>
  <tr>
    <td valign="top" width="150" align="center">

      <b>Preview</b>

      <br />

      <div id="div_preview" class="div_preview">
      </div>

      <br />

      <form name="form" action="main.cgi" method="POST">
      <input type="hidden" name="Gallery_ID" value="##Gallery_ID##">
      <input type="hidden" name="Image_Name" value="">
      <input type="hidden" name="x">
      <input type="hidden" name="y">
      <input type="hidden" name="width">
      <input type="hidden" name="height">
      <input type="hidden" name="Run" value="CropThumbnail">
      <input type="checkbox" name="filter" class="nomargin"> <b>Custom Filters</b><br />
      <b>Width:</b>  <input type="text" name="thumb_width" size="5" value="##Thumb_Width##" class="flat" style="margin-left: 5px;"><br />
      <b>Height:</b> <input type="text" name="thumb_height" size="5" value="##Thumb_Height##" class="flat"><br />
      <input type="button" value="Set Size" onClick="setThumbSize()" style="margin-top: 5px; font-family: Verdana; font-size: 8pt;">
      </form>

      <br />

      <div align="center">
      <a href="main.cgi?Run=DisplayUpload&Gallery_ID=##Gallery_ID##">Upload A Thumbnail</a>
      </div>
      
    </td>
    <td valign="top" width="400">
      <div align="center" id="div_main">
      <b>No Image Loaded</b>
      </div>
    </td>
  </tr>
</table>
<!-- MAIN TABLE END   -->





<!-- IMAGE MASK START -->
<table id="table_mask" class="table_mask" cellpadding="0" cellspacing="0" onMouseMove="mouseMoveMain(event)" onMouseDown="mouseDownMain(event)">
  <tr>
    <td>
    </td>
  </tr>
</table>
<!-- IMAGE MASK END   -->





<!-- SELECTION BOX START -->
<table id="table_box" class="table_box" onDblClick="fillForm()" onMouseMove="mouseMoveBox(event)" onMouseDown="mouseDownBox(event)">
  <tr>
    <td>
    </td>
  </tr>
</table>
<!-- SELECTION BOX END   -->

</div>

</body>
</html>
