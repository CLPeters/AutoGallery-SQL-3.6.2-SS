<html>
<head>
  <title>Submission Confirmed</title>
<!--[Include File ./templates/submit.css]-->
</head>
<body>

<form name="form" action="submit.cgi" method="POST" enctype="multipart/form-data" onSubmit="return checkForm(this)">

<div align="center">

<h2>Submission Confirmed</h2>

<table border="0" cellpadding="2" width="700">
<tr>
<td colspan="2">
<span style="font-weight: normal">
<!-- This is shown to everyone -->
Your gallery submission has been confirmed.



<!--[If Start Status {eq 'Approved'}]-->
<!-- This text will be shown if the gallery was auto-approved -->
Your gallery will be displayed on our TGP in the next few days.


<!--[If Else]-->
<!-- This text will be shown if the gallery needs to be approved -->
We will examine your gallery shortly and determine if it is acceptable for our TGP.
If your gallery is accepted, it will be displayed on our TGP in the next few days.

<!--[If End]-->

</span>

<br /><br />

</td>
</tr>


<tr>
<td align="right">
E-mail
</td>
<td>
<span style="font-weight: normal">
##Email##
</span>
</td>
</tr>


<tr>
<td align="right">
Name
</td>
<td>
<span style="font-weight: normal">
##Nickname##
</span>
</td>
</tr>


<tr>
<td align="right">
Gallery URL
</td>
<td>
<span style="font-weight: normal">
##Gallery_URL##
</span>
</td>
</tr>


<tr>
<td align="right">
Description 
</td>
<td>
<span style="font-weight: normal">
##Description##
</span>
</td>
</tr>


<tr>
<td align="right">
Category
</td>
<td>
<span style="font-weight: normal">
##Category##
</span>
</td>
</tr>


<tr>
<td align="right">
Thumbnails
</td>
<td>
<span style="font-weight: normal">
##Thumbnails##
</span>
</td>
</tr>


<!--[If Start Has_Thumb]-->
<!-- Display the preview thumbnail, only if there is one -->
<tr>
<td valign="top" align="right">
Preview
</td>
<td>
<img src="##Thumbnail_URL##">
</td>
</tr>
<!--[If End]-->

</table>


<br />
<br />

</div>

</form>

</body>
</html>
