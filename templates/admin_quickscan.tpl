<html>
<head>
<title>Gallery Scan</title>
<script language="JavaScript">
function openSource(url, height, width)
{
    window.open(url, '_blank', 'menubar=no,height='+height+',width='+width+',scrollbars=yes,top=100,left=100,resizable=yes');

    window.close();

    return false;
}
</script>
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<table class="outlined" width="100%" cellspacing="0" cellpadding="3" align="center">
<tr>
<td colspan="2" align="center" class="menuhead">
Gallery Scan
</td>
</tr>

<!--[If Start Error]-->
<tr>
<td align="right">
<b>Error</b>
</td>
<td>
<font color="red">
##Error##
</font>
</td>
</tr>
<!--[If Else]-->

<tr>
<td align="right">
<b>Format</b>
</td>
<td>
##Format##
<!--[If Start Format_Changed]-->
<font color="red">
(changed)
</font>
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Thumbnails</b>
</td>
<td>
##Thumbnails##
<!--[If Start Thumbnails_Changed]-->
<font color="red">
(changed)
</font>
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Links</b>
</td>
<td>
##Links##
<!--[If Start Links_Changed]-->
<font color="red">
(changed)
</font>
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Page Size</b>
</td>
<td>
##Bytes## bytes
</td>
</tr>

<tr>
<td align="right">
<b>Download</b>
</td>
<td>
##Speed## KB/sec
</td>
</tr>

<tr>
<td align="right">
<b>Banned HTML</b>
</td>
<td>
<!--[If Start Has_Banned]-->
Found
<!--[If Else]-->
Not Found
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Blacklisted</b>
</td>
<td>
<!--[If Start Blacklisted]-->
<font color="red">Yes</font> (##Blacklisted##)
<!--[If Else]-->
No
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Reciprocal Link</b>
</td>
<td>
<!--[If Start Has_Recip]-->
Found
<!--[If Else]-->
Not Found
<!--[If End]-->
<!--[If Start Has_Recip_Changed]-->
<font color="red">
(changed)
</font>
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>2257 Code</b>
</td>
<td>
<!--[If Start Has_2257]-->
Found
<!--[If Else]-->
<font color="red">
Not Found
</font>
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Domain IP</b>
</td>
<td>
##Gallery_IP##
<!--[If Start Gallery_IP_Changed]-->
<font color="red">
(changed)
</font>
<!--[If End]-->
</td>
</tr>

<tr>
<td align="right">
<b>Page Content</b>
</td>
<td>
<!--[If Start Page_ID_Changed]-->
<font color="red">
Has Changed
</font>
<!--[If Else]-->
Unchanged
<!--[If End]-->
</td>
</tr>
<!--[If End]-->


<tr>
<td align="center" colspan="2">
<a href="" onClick="return openSource('main.cgi?Run=DisplayRaw&Gallery_ID=##Gallery_ID##', 650, 800)">Display HTML Source and HTTP Headers</a>
</td>
</tr>

</table>

</body>
</html>