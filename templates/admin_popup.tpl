<html>
<head>
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
function beginCloseTimer()
{
<!--[If Start NoClose]-->
<!--[If Else]-->
    setTimeout("window.close()", 3000);
<!--[If End]-->
}
</script>
</head>
<body onLoad="beginCloseTimer()">

<div align="center">
##Message##

<br />
<br />

<a href="" onClick="window.close(); return false;">Close Window</a>

<!--[If Start NoClose]-->
<!--[If Else]-->
<br />
<br />
<i class="tiny">Window will automatically close in 3 seconds</i>
<!--[If End]-->
</div>


</body>
</html>