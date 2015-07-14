<html>
<head>
  <title>Partner Account Request</title>
<!--[Include File ./templates/submit.css]-->
</head>
<body>

<form name="form" action="partner.cgi" method="POST">

<div align="center">

<h2>Partner Account Request</h2>

<table border="0" cellpadding="2" width="850">

<tr>
<td colspan="2" align="center">
<span style="font-weight: normal">
To request a partner account for gallery submissions, please fill out<br />
the form below.  You will be contacted after your request is reviewed.
<br /><br />
</span>
</td>
</tr>

<tr>
<td align="right">
E-mail Address
</td>
<td>
<input type="text" name="Email" size="30">
</td>
</tr>

<tr>
<td align="right">
Your Name
</td>
<td>
<input type="text" name="Name" size="40">
</td>
</tr>

<tr>
<td align="right">
Requested Username
</td>
<td>
<input type="text" name="Account_ID" size="20">
</td>
</tr>

<tr>
<td align="right">
Requested Password
</td>
<td>
<input type="text" name="Password" size="20">
</td>
</tr>

<tr>
<td align="right">
Sample URL 1
</td>
<td>
<input type="text" name="Gallery_1" size="50">
</td>
</tr>

<tr>
<td align="right">
Sample URL 2
</td>
<td>
<input type="text" name="Gallery_2" size="50">
</td>
</tr>

<tr>
<td align="right">
Sample URL 3
</td>
<td>
<input type="text" name="Gallery_3" size="50">
</td>
</tr>

<!--[If Start Code {$O_REQ_HOST}]-->
<!-- Only show this if we are requiring that the hosting company be submitted -->
<tr>
<td align="right">
Hosting Company
</td>
<td>
<input type="text" name="Host" size="30">
</td>
</tr>
<!--[If End]-->

<!--[If Start Code {$O_REQ_PROVIDER}]-->
<!-- Only show this if we are requiring that the content provider be submitted -->
<tr>
<td align="right">
Main Content Provider
</td>
<td>
<input type="text" name="Provider" size="30">
</td>
</tr>
<!--[If End]-->

<tr>
<td colspan="2" align="center">
<br />
<input type="submit" value="Submit Request">
<input type="hidden" name="r" value="request">
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
