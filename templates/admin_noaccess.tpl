<html>
<head>
<title>Access Denied by IP Address</title>
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody">

<script language="JavaScript">
var width = 0;

if( window.outerWidth > 500 )
    width = 500;
else
    width = window.outerWidth - 30;

document.write('<table id="error" class="outlined" width="' + width + '" cellspacing="0" cellpadding="3">');
</script>
<tr>
<td align="center" class="tablehead">
Access Denied by IP Address
</td>
</tr>
<td>
<span id="Error">
The IP address ##IP## that you are connecting from is not allowed to access this script function.  To access this function, you will need to add your IP address to the access list.  This process is outlined in the 'Setting up an Access List' section of the software manual.
</span>
<br />
</td>
</tr>
</table>

</td>
</tr>
</table>

</body>
</html>