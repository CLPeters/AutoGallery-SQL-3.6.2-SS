<html>
<head>
<script language="JavaScript">

function showIframe()
{
    show('breakdown_id');
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


<table width="400" cellpadding="3" cellspacing="0" class="outlined">
<tr>
<td colspan="3" align="center" class="menuhead">
Gallery Breakdown
</td>
</tr>

<tr>
<td colspan="3" class="subhead">
Submitted Galleries
</td>
</tr>

<!--[If Start Submitted]-->
<!--[Loop Start Submitted]-->
<tr>
<td style="padding-left: 20px">
##Status##
</td>
<td align="center">
##Total##
</td>
<td align="center">
<a href="main.cgi?Run=Breakdown&Status=##Status##&Type=Submitted&Method=Date" target="breakdown">[By Date]</a>
&nbsp;
<a href="main.cgi?Run=Breakdown&Status=##Status##&Type=Submitted&Method=Category" target="breakdown">[By Category]</a>
</td>
</tr>
<!--[Loop End]-->
<!--[If Else]-->
<tr>
<td colspan="3">
There are currently no submitted galleries
</td>
</td>
<!--[If End]-->


<tr>
<td colspan="3" class="subhead">
Permanent Galleries
</td>
</tr>

<!--[If Start Permanent]-->
<!--[Loop Start Permanent]-->
<tr>
<td style="padding-left: 20px">
##Status##
</td>
<td align="center">
##Total##
</td>
<td align="center">
<a href="main.cgi?Run=Breakdown&Status=##Status##&Type=Permanent&Method=Date" target="breakdown">[By Date]</a>
&nbsp;
<a href="main.cgi?Run=Breakdown&Status=##Status##&Type=Permanent&Method=Category" target="breakdown">[By Category]</a>
</td>
</tr>
<!--[Loop End]-->
<!--[If Else]-->
<tr>
<td colspan="3">
There are currently no permanent galleries
</td>
</td>
<!--[If End]-->


</table>

<br />

<iframe name="breakdown" id="breakdown_id" src="main.cgi?Run=Breakdown&Status=Approved&Type=Submitted&Method=Date" frameborder="0" width="400" height="400"></iframe>

</body>
</html>