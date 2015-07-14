<html>
<head>
<title>Duplicate Galleries</title>
<!--[Include File ./templates/admin.css]-->
<script language="JavaScript">
</script>
</head>
<body>

<div align="center">
<a href="main.cgi?Run=RemoveDuplicates" onClick="return confirm('Are you sure you want to do this?')"><b>Remove Duplicate Galleries</b></a>
</div>

<br />

<table class="outlined" width="800" cellspacing="0" cellpadding="3" align="center">
<tr>
<td colspan="2" align="center" class="menuhead">
Duplicate Galleries
</td>
</tr>

<tr class="subhead">
<td>
Gallery URL
</td>
<td>
Number
</td>
</tr>

<!--[Loop Start Duplicates]-->
<tr onMouseOver="this.style.backgroundColor='#FAFAD2'" onMouseOut="this.style.backgroundColor='#ffffff'">
<td>
##Gallery_URL##
</td>
<td>
##Total##
</td>
</tr>
<!--[Loop End]-->
</table>

<br />
<br />

</body>
</html>