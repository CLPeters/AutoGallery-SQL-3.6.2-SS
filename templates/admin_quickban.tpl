<html>
<head>
<title>Blacklist</title>
<script language="JavaScript">
function clearItem(item)
{
    item.value = '';
    return false;
}

function getDomain()
{
    var url = document.form.domain.value;

    url = url.replace(/http:\/\//, '');
    url = url.replace(/\/.*/, '');
    url = url.replace(/www\./, '');

    document.form.domain.value = url;

    return false;
}
</script>
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<form name="form" action="main.cgi" method="POST">

<table class="outlined" width="600" cellspacing="0" cellpadding="3" align="center">
<tr>
<td colspan="2" align="center" class="menuhead">
Blacklist
</td>
</tr>

<tr>
<td align="right">
<b>Domain IP</b>
</td>
<td>
<input type="text" name="domainip" value="##Gallery_IP##" size="20">
<a href="" onClick="return clearItem(document.form.domainip)" class="link">[x]</a>
</td>
</tr>

<tr>
<td align="right">
<b>Submitter IP</b>
</td>
<td>
<input type="text" name="submitip" value="##Submit_IP##" size="20">
<a href="" onClick="return clearItem(document.form.submitip)" class="link">[x]</a>
</td>
</tr>

<tr>
<td align="right">
<b>DNS Server</b>
</td>
<td>
<input type="text" name="dns" value="##DNS##" size="30">
<a href="" onClick="return clearItem(document.form.dns)" class="link">[x]</a>
</td>
</tr>

<tr>
<td align="right">
<b>Gallery URL</b>
</td>
<td>
<input type="text" name="domain" value="##Gallery_URL##" size="60">
<a href="" onClick="return getDomain()" class="link">[Domain]</a>
<a href="" onClick="return clearItem(document.form.domain)" class="link">[x]</a>
</td>
</tr>

<tr>
<td align="right">
<b>E-mail Address</b>
</td>
<td>
<input type="text" name="email" value="##Email##" size="30">
<a href="" onClick="return clearItem(document.form.email)" class="link">[x]</a>
</td>
</tr>

</table>

<br />

<table class="outlined" width="600" cellspacing="0" cellpadding="3" align="center">
<tr>
<td align="center">
<input type="hidden" name="Gallery_ID" value="##Gallery_ID##">
<input type="hidden" name="Run" value="QuickBan">
<input type="submit" value="Update Blacklist">
</td>
</tr>
</table>

</form>

</body>
</html>