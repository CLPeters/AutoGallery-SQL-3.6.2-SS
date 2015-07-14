<html>
<head>
  <title>Report a Broken Link or Cheater</title>
<!--[Include File ./templates/submit.css]-->
</head>
<body>

<form action="report.cgi" method="POST">

<div align="center">

<h2>Report a Broken Link or Cheater</h2>

<table width="600">
<tr>
<td style="font-weight: normal">
Use the form below to report a broken link or a site that is breaking our rules.  You do
not need to tell us the URL, just give a short description of what the site is doing to
break the rules, or simply enter 'This is a broken link' if the link no longer works.

<br />
<br />
<i>Insert Your Rules Here</i>
<br />
<br />

If we determine that your report is correct, we will remove the offending gallery and possibly
ban it from our TGP.  Thank you for helping to keep our TGP top quality!

<br />
<br />

<b>Gallery URL:</b> <a href="##Gallery_URL##" target="_blank">##Gallery_URL##</a><br />
<b>Description:</b> ##Description##<br>
<b>Category:</b> ##Category##

<br />
<br />

<div align="center">
<textarea name="Report" cols="60" rows="5" wrap="off"></textarea>
<input type="hidden" name="Gallery_ID" value="##Gallery_ID##">
<input type="submit" name="submit" value="Send Report">
</div>
</form>

</td>
</tr>
</table>

</div>

</body>
</html>