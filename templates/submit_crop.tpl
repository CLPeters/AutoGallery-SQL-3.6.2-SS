<html>
<head>
<title>Crop Image</title>
<script language="JavaScript">

// Local information for this file
var image_url   = '##Image_URL##';
var thumb_url   = '##Thumb_URL##';
var gallery_url = '##Encode_URL##';
var smallest    = 999999;
var thumbs      = new Array();
var thumbs_html = '';
var thumb_ns    = 'thumb.cgi';

var thumb           = new Object();
    thumb.height    = ##Thumb_Height##;
    thumb.width     = ##Thumb_Width##;
    thumb.prop      = thumb.height/thumb.width;

<!--[Loop Start Thumbs]-->
thumbs.push('##Image_URL##|##Thumbnail_URL##');
<!--[Loop End]-->

</script>
<!--[Include File ./templates/crop.js]-->
</head>

<body onLoad="initializeDocument()">


<div align="center">


<!--[If Start Thumbs]-->
<!-- Only show this if selecting an image from the gallery-->
<div id="div_wait" align="center">
Loading Thumbnails...Please Wait

<br /><br />

<div align="left" id="div_prog" class="div_prog">
<div id="div_bar" class="div_bar">
</div>
</div>
</div>

<div id="div_thumbs" align="center" class="div_thumbs">
</div>

<br />
<!--[If End]-->




<!-- MAIN TABLE START -->
<table>
  <tr>
    <td valign="top" width="150">
      <b>Instructions</b>
      
      <br />

<!--[If Start Thumbs]-->
      From the images above, select the one you want to crop
      your preview thumbnail from.
<!--[If End]-->
      Once the image has loaded,
      click and drag your mouse over the image to create a
      selection box.  You can move the selection box around the
      image by clicking inside the box, holding the mouse button
      down, and moving your mouse.  Once you have a selection that
      you like, double click inside the selection box to crop
      your thumbnail.

      <br />
      <br />

      <b>Preview</b>

      <br />

      <div id="div_preview" class="div_preview">
      </div>

      <form name="form" action="submit.cgi" method="POST">
      <input type="hidden" name="Run" value="C">
      <input type="hidden" name="Gallery_ID" value="##Gallery_ID##">
      <input type="hidden" name="Image_Name" value="##Image_Name##">
      <input type="hidden" name="x">
      <input type="hidden" name="y">
      <input type="hidden" name="width">
      <input type="hidden" name="height">
      </form>
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


<iframe id="iframe" src="" height="0" width="0" style="visibility: hidden;" onLoad="updateImage()"></iframe>

</div>

</body>
</html>
