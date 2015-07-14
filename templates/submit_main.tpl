<html>
<head>
  <title>Submit A Gallery</title>
<script language="JavaScript">

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

    if( form.Thumbnails && !form.Thumbnails.value )
    {
        alert("Please enter the number of thumbnails on your gallery");
        return false;
    }
}


</script>
<!--[Include File ./templates/submit.css]-->
</head>
<body>

<form name="form" action="submit.cgi" method="POST" enctype="multipart/form-data" onSubmit="return checkForm(this)">

<div align="center">

<h2>Submit A Gallery</h2>

<table border="0" cellpadding="2" width="600">

<!--[If Start Submit_Status {eq 'Password'}]-->
<!-- Display this message if the submission form is in password only mode -->
<tr>
<td colspan="2" align="center">
<span style="color: blue">
We are currently only accepting galleries from partners.<br />
You will not be able to submit a gallery unless you have a partner account.
</span>

<br /><br />
</td>
</tr>
<!--[If End]-->

<tr>
<td colspan="2" class="small" align="center">
If you have a partner account, please fill in the username and password fields.
</td>
</tr>

<tr>
<td align="right">
Username
</td>
<td>
<input type="text" name="Username" size="20">
</td>
</tr>

<tr>
<td align="right">
Password
</td>
<td>
<input type="password" name="Password" size="20">
&nbsp;<a href="remind.cgi" class="smalllink">Forgot your password?</a>
</td>
</tr>

<tr>
<td colspan="2">
&nbsp;
</td>
</tr>

<tr>
<td align="right">
E-mail
</td>
<td>
<input type="text" name="Email" size="30">
</td>
</tr>

<tr>
<td align="right">
Name/Nickname
</td>
<td>
<input type="text" name="Nickname" size="20">
</td>
</tr>

<tr>
<td align="right">
Gallery URL
</td>
<td>
<input type="text" name="Gallery_URL" size="60">
</td>
</tr>

<tr>
<td align="right">
Description 
</td>
<td>
<input type="text" name="Description" size="60">
</td>
</tr>

<!--[If Start Code {$O_ALLOW_KEYWORDS}]-->
<tr>
<td align="right" valign="top">
Keywords 
</td>
<td>
<input type="text" name="Keywords" size="40"><br />
<span style="font-size: 8pt; font-weight: normal;">Separate keywords by spaces (not commas)</span>
</td>
</tr>
<!--[If End]-->

<tr>
<td align="right">
Category
</td>
<td>
<select name="Category">
<!--[Loop Start Categories]-->
  <option value="##Category##">##Category##</option>
<!--[Loop End]-->
</select>
</td>
</tr>

<!--[If Start Code {!$O_COUNT_THUMBS}]-->
<tr>
<td align="right">
Number of Thumbs 
</td>
<td>
<input type="text" name="Thumbnails" size="10">
</td>
</tr>
<!--[If End]-->


<!--[If Start Code {$O_ALLOW_THUMB}]-->
<tr>
<td valign="top" align="right">
Preview Thumb<br />
<span class="small">
##Width##x##Height## Max
</span>
</td>
<td class="small">
<!--[If Start Code {$HAVE_MAGICK}]-->
<!-- Show these options if ImageMagick is available -->
<input type="radio" name="Thumb_Source" value="Upload" checked> Upload <input type="file" name="Preview" size="35"><br />
<input type="radio" name="Thumb_Source" value="Select"> Let the script select an image from your gallery<br />

<script language="JavaScript">
var browser = navigator.userAgent;

// Only show this option to compatible browsers
if( browser.search(/Opera/) == -1 && (browser.search(/MSIE (6|7).0/) != -1 || browser.search(/Gecko/) != -1) )
    document.write('<input type="radio" name="Thumb_Source" value="Crop"> Select and crop an image from your gallery<br />');
</script>

<!--[If Else]-->
<!-- Show these options if ImageMagick is NOT available -->
<input type="hidden" name="Thumb_Source" value="Upload">
<input type="file" name="Preview" size="35">
<!--[If End]-->
</td>
</tr>
<!--[If End]-->




<!--[If Start Code {$HAVE_GD && ($O_TRUST_STRING || $O_GEN_STRING)}]-->
<!-- Only show this if the GD module is available and 
     either general or partners need to provide
     a submit code -->
<tr>
<td align="right">
Submit Code
</td>
<td valign="middle">

<table>
<tr>
<td>
<img src="code.cgi">
</td>
<td>
<input type="text" name="Code" size="15">
</td>
</table>

<span class="small">Copy the letters and numbers from the image into the text box</span>

</td>
</tr>
<!--[If End]-->


<tr>
<td colspan="2" align="center">
<br />
<input type="submit" value="Submit Gallery">
</td>
</td>
</tr>

</table>


<br />
<br />

</div>

</form>

</body>
</html>
