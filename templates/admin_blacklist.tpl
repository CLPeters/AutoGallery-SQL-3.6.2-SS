<html>
<head>
<script language="JavaScript">
function checkForm(form)
{
    if( !form.Items.value )
    {
        alert('Please enter one or more items to blacklist');
        return false;
    }

    return true;
}

function fixDelete(item)
{
    if( item.value.match(/\s+\[Delete\]/) )
    {
        item.value = item.value.replace(/\s+\[Delete\]/g, "");
    }
}
</script>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">
<input type="hidden" name="Run">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="menuhead">
Manage Blacklist/Whitelist
</td>
</tr>

<tr>
<td class="subhead">
Type<br />
</td>
</tr>
<tr>
<td>
<select name="Type" style="margin-left: 20px;">
  <option value="html">HTML</option>
  <option value="domain">URL</option>
  <option value="domainip">Domain IP</option>
  <option value="dns">DNS Server</option>
  <option value="email">E-mail</option>
  <option value="submitip">Submitter IP</option>
  <option value="word">Word</option>
  <option value="whitelist">Whitelist</option>
  <option value="headers">HTTP Headers</option>
</select>
</td>
</tr>

<tr>
<td class="subhead">
Items To Blacklist/Whitelist <span style="font-weight: normal">(one per line)</span><br />
</td>
</tr>
<tr>
<td>
<textarea name="Items" rows="10" cols="105" wrap="off" style="margin-left: 20px;" onChange="fixPerLine(this)" onKeyUp="fixDelete(this)"></textarea>
</td>
</tr>

</table>

<br />


<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" width="350">
<input type="submit" onClick="setRun('AddBlacklist');" value="Add">
</td>
<td align="center" width="350">
<input type="submit" onClick="setRun('DeleteBlacklist');" value="Remove">
</td>
</tr>
</table>

</form>

<br />

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<form name="current" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">
<tr>
<td align="center" class="menuhead">
Current Blacklist
</td>
</tr>
<tr>
<td align="center">
<a href="main.cgi?Run=PrintBlacklist&Type=html" target="iframe">[HTML]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=domain" target="iframe">[URL]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=domainip" target="iframe">[Domain IP]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=dns" target="iframe">[DNS Server]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=email" target="iframe">[E-mail]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=submitip" target="iframe">[Submitter IP]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=word" target="iframe">[Word]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=whitelist" target="iframe">[Whitelist]</a> &nbsp;&nbsp;&nbsp;
<a href="main.cgi?Run=PrintBlacklist&Type=headers" target="iframe">[Headers]</a>

<br /><br />

<script language="JavaScript">

var view = '##View##';

if( view == '' )
{
    document.write('<iframe name="iframe" src="" width="95%" height="250"></iframe>');
}
else
{
    document.write('<iframe name="iframe" src="main.cgi?Run=PrintBlacklist&Type=' + view + '" width="95%" height="250"></iframe>');
}
</script>
</td>
</tr>
</table>

</form>

</body>
</html>