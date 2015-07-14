<html>
<head>
<script language="JavaScript">
function resolve(ip)
{
     window.open('main.cgi?Run=DisplayResolveIP&IP=' + ip, '_blank', 'menubar=no,height=100,width=350,scrollbars=yes,top=300,left=300');
}
</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST">


<table class="outlined" width="700" cellspacing="0" cellpadding="3" border="0">
<tr>
<td colspan="2" align="center" class="menuhead">
Cheat/Broken Link Reports
</td>
</tr>

<!--[If Start Reports]-->
<!--[Loop Start Reports]-->
<tr class="subhead">
<td style="padding-left: 5px;" colspan="2">
<input type="checkbox" name="Report_ID" value="##Report_ID##" style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
&nbsp;##Report_ID##
<span style="margin-left: 10px; font-weight: normal;">
<a href="##Gallery_URL##" class="link" target="_blank">##Gallery_URL##</a> (##Gallery_ID##)
</span>
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Message:</b>
</td>
<td width="615" class="nopad">
##Report##
</td>
</tr>

<!--[If Start Description]-->
<tr>
<td width="85" align="right">
<b>Description:</b>
</td>
<td class="nopad">
##Description##
</td>
</tr>
<!--[If End]-->

<tr>
<td width="85" align="right">
<b>E-mail:</b>
</td>
<td class="nopad">
<a href="mailto:##Email##" class="link">##Email##</a>
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Submit IP:</b>
</td>
<td class="nopad">
<a href="" onClick="return resolve('##Submit_IP##');" class="link">##Submit_IP##</a>
</td>
</tr>

<tr>
<td width="85" align="right">
<b>Report IP:</b>
</td>
<td class="nopad">
<a href="" onClick="return resolve('##Report_IP##');" class="link">##Report_IP##</a>
</td>
</tr>
<!--[Loop End]-->
<!--[If Else]-->
<tr>
<td colspan="2" align="center" class="errormessage">
There are currently no cheat reports to process
</td>
</tr>
<!--[If End]-->

</table>

<br />

<!--[If Start Reports]-->

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>

<td align="center">
<select name="Run">
  <option value="ReportRemove">Remove Report</option>
  <option value="ReportDelete">Delete Gallery</option>
  <option value="ReportBan">Delete &amp; Ban Gallery</option>
  <option value="ReportRemoveAll">Remove All Reports</option>
</select>
<input type="submit" value="Process Reports">
</td>

</tr>
</table>

<!--[If End]-->

</form>

</body>
</html>