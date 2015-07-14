<html>
<head>
  <title>Submission Recorded</title>
<!--[Include File ./templates/submit.css]-->
</head>
<body>

<form name="form" action="submit.cgi" method="POST" enctype="multipart/form-data" onSubmit="return checkForm(this)">

<div align="center">

<h2>Submission Recorded</h2>

<table border="0" cellpadding="2" width="700">

<tr>
<td colspan="2">
<span style="font-weight: normal">
<!-- This is shown to everyone -->
Thank you for your submission!



<!--[If Start Status {eq 'Approved'}]-->
<!-- This text will be shown if the gallery was auto-approved -->
Your gallery has been added to our database and will be displayed the next
time our TGP pages are updated.  Your gallery has been assigned the ID number ##Gallery_ID##.



<!--[If Elsif Status {eq 'Unconfirmed'}]-->
<!-- This text will be shown if the gallery needs to be confirmed through e-mail -->
Your gallery has been added to our database.  You will receive an e-mail shortly
at ##Email##.  In that e-mail you will find a link that you need to visit in order to confirm
your gallery submission.  Your gallery has been assigned the ID number ##Gallery_ID##.



<!--[If Elsif Status {eq 'Pending'}]-->
<!-- This text will be shown if the gallery needs to be approved -->
Your gallery has been added to our database.  We will examine your gallery shortly
and determine if it is acceptable for our TGP.  If your gallery is accepted, it will be displayed
on our TGP in the next few days.  Your gallery has been assigned the ID number ##Gallery_ID##.


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

<!--[If Start Code {$O_ALLOW_KEYWORDS}]-->
<tr>
<td align="right">
Keywords
</td>
<td>
<span style="font-weight: normal">
##Keywords##
</span>
</td>
</tr>
<!--[If End]-->

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
