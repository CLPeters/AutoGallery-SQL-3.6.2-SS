<html>
<head>
<title>Gallery Deleted</title>
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
function updateParent()
{
    window.opener.deleteGalleryResponse('Success|##Gallery_ID##');
    setTimeout("window.close()", 3000);
}
</script>
</head>
<body onLoad="updateParent()">

<div align="center">
Gallery ##Gallery_ID## has been ##More## deleted

<br />
<br />

<a href="" onClick="window.close(); return false;" class="link">Close Window</a>
<br />
<br />
<i class="tiny">Window will automatically close in 3 seconds</i>
</div>


</body>
</html>