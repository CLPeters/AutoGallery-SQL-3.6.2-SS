<html>
<head>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<form name="form" action="main.cgi" target="main" method="POST">

<input type="hidden" name="Run" value="ImportGalleries">

<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Data Analysis
</td>
</tr>
<!--[Loop Start Fields]-->
<tr>
<td align="right" style="padding-right: 10px;">
##Value##
</td>
<td>
<select name="##Position##">
  <option value="Email">E-mail</option>
  <option value="Gallery_URL">Gallery URL</option>
  <option value="Thumbnail_URL">Thumbnail URL</option>
  <option value="Thumb_Width">Thumbnail Width</option>
  <option value="Thumb_Height">Thumbnail Height</option>
  <option value="Description">Description</option>
  <option value="Thumbnails">Thumbnails</option>
  <option value="Category">Category</option>
  <option value="Weight">Weight</option>
  <option value="Nickname">Nickname</option>
  <option value="Sponsor">Sponsor</option>
  <option value="Type">Type</option>
  <option value="Format">Format</option>
  <option value="Scheduled_Date">Scheduled Date</option>
  <option value="Delete_Date">Delete Date</option>
  <option value="Keywords">Keywords</option>
  <option value="Icons">Icons</option>
  <option value="Skip">SKIP</option>
</select>
</td>
</tr>
<!--[Loop End]-->
<tr>
<td align="right" style="padding-right: 10px;">
Gallery Status
</td>
<td>
<select name="Status">
  <option value="Pending">Pending</option>
  <option value="Approved">Approved</option>
</select>
</td>
</tr>
<tr>
<td align="right" style="padding-right: 10px;">
Gallery Type
</td>
<td>
<select name="Type">
  <option value="">From File</option>
  <option value="Submitted" selected>Submitted</option>
  <option value="Permanent">Permanent</option>  
</select>
</td>
</tr>
<tr>
<td align="right" style="padding-right: 10px;">
Gallery Format
</td>
<td>
<select name="Format">
  <option value="">From File</option>
  <option value="Pictures" selected>Pictures</option>
  <option value="Movies">Movies</option>  
</select>
</td>
</tr>
</table>

<br />

<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead" colspan="2">
Options
</td>
</tr>
<tr>
<td style="padding-left: 110px;">
<input type="checkbox" name="Duplicates" value="1" class="nomargin">
<b>Check for and skip galleries with a URL that is already in the database</b>

<br />
<br />

<input type="checkbox" name="ChangeCase" value="1" class="nomargin">
<b>Convert descriptions to</b>
<select name="Case">
  <option value="FirstUpper">First letter upper case</option>
  <option value="WordsUpper">First letter of each word upper case</option>
  <option value="AllUpper">All letters upper case</option>
  <option value="AllLower">All letters lower case</option>
</select>

<br />
<br />

<input type="checkbox" name="Truncate" value="1" class="nomargin">
<select name="Method">
  <option value="Reject">Skip Over</option>
  <option value="Truncate">Truncate</option>
</select>
<b>descriptions that contain more than</b>
<input type="text" name="Length" size="5" value="100">
<b>characters</b>

<br />
<br />

<input type="checkbox" name="DefaultCat" value="1" class="nomargin">

<b>If a gallery does not match an existing category put it in</b>

<select name="Category">
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>

</td>
</tr>
</table>

<br />

<table class="outlined" width="750" cellspacing="0" cellpadding="3">
<tr>
<td align="center">
<input type="submit" value="Import Galleries">
</td>
</tr>
</table>

<input type="hidden" name="Filename" value="##Filename##">

</form>

</body>
</html>