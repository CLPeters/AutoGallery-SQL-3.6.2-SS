<html>
<head>
  <title>Account Overview</title>
<!--[Include File ./templates/partner.css]-->
<script language="JavaScript">

function doAction(the_action)
{
    document.action.r.value = the_action;
    document.action.submit();

    return false;
}

function setDisable(gallery_id, reason)
{
    document.disable.Reason.value = reason.value;
    document.disable.Gallery_ID.value = gallery_id;
    document.disable.submit();
}

function jumpPage(page)
{
    var form = document.action;

    form.r.value = 'overview';
    form.Sort.value = document.getElementById('SortSelect').value;
    form.Page.value = page;
    form.submit();

    return false;
}

</script>
</head>
<body>

<div align="center">

<b><a href="" onClick="return doAction('edit');">Edit Account</a> : <a href="submit.cgi">Submit Galleries</a> : <a href="mailto:##Admin_Email##">E-mail Administrator</a></b>

<h2>Account Overview</h2>


<table width="300" cellpadding="4" cellspacing="0">

<tr>
<td class="line-bottom">
<b>Galleries Allowed Per Day</b>
</td>
<td class="line-bottom">
##Allowed##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Account Active On</b>
</td>
<td class="line-bottom">
##Start_Date##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Account Expires On</b>
</td>
<td class="line-bottom">
##End_Date##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Galleries In Database</b>
</td>
<td class="line-bottom">
##Total##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Clicks on Galleries</b>
</td>
<td class="line-bottom">
##Clicks##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Unconfirmed Galleries</b>
</td>
<td class="line-bottom">
##Unconfirmed##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Pending Galleries</b>
</td>
<td class="line-bottom">
##Pending##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Approved Galleries</b>
</td>
<td class="line-bottom">
##Approved##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Used Galleries</b>
</td>
<td class="line-bottom">
##Used##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Held Galleries</b>
</td>
<td class="line-bottom">
##Holding##
</td>
</tr>

<tr>
<td class="line-bottom">
<b>Disabled Galleries</b>
</td>
<td class="line-bottom">
##Disabled##
</td>
</tr>

</table>

<br />
<br />

<!--[If Start Error]-->
<div style="color: #FF0000; font-weight: bold;">
##Error##
<br />
<br />
</div>
<!--[If End]-->

<!--[If Start Gallery_URL]-->
<div style="color: #0000FF; font-weight: bold;">
Your gallery with URL <a href="##Gallery_URL##" target="_blank">##Gallery_URL##</a> has been disabled.
<br />
<br />
</div>
<!--[If End]-->

<form name="disable" action="partner.cgi" method="POST">

<!--[If Start Galleries]-->
<table width="900" cellpadding="4" cellspacing="0" border="0">

<tr>
<td width="150">
<!--[If Start Previous]-->
<a href="" onClick="return jumpPage(##Previous##)">&lt;&lt; Previous</a>
<!--[If End]-->
<!--[If Start Code {$T{'Previous'} && $T{'Next'}}]-->
 | 
<!--[If End]-->
<!--[If Start Next]-->
<a href="" onClick="return jumpPage(##Next##)">Next &gt;&gt;</a>
<!--[If End]-->
</td>

<td align="center">
<span style="font-size: 16pt; font-weight: bold;">Galleries ##Start##-##End## of ##Total##</span>
</td>

<td align="right" width="250">
Sort By:
<select name="Sort" id="SortSelect">
  <option value="Clicks">Clicks</option>
  <option value="Added">Date Added</option>
  <option value="Approved">Date Approved</option>
  <option value="Status">Status</option>
</select>
<input type="button" value="Go" onClick="jumpPage(1)">
<script language="JavaScript">
var ss = document.getElementById('SortSelect');
for( var i = 0; i < ss.options.length; i++ )
{
    if( ss.options[i].value == '##Sort##' )
    {
        ss.options[i].selected = true;
        break;
    }
}
</script>
</td>
</tr>
<tr>
<td>
&nbsp;
</td>
</tr>

<!--[Loop Start Galleries]-->
<tr>
<td class="line-bottom" align="center" valign="middle">

<!--[If Start Has_Thumb]-->
<img src="##Thumbnail_URL##" border="1">
<!--[If Else]-->
<div style="height: 100px;">
</div>
<!--[If End]-->
</td>
<td class="line-bottom" valign="top" colspan="2">
<b>URL:</b> <a href="##Gallery_URL##" target="_blank">##Gallery_URL##</a><br />
<b>Description:</b> ##Description##<br />
<b>Status:</b> ##Status##<br />
<b>Submitted:</b> ##Submitted##<br />
<b>Category:</b> ##Category##<br />
<b>Clicks:</b> ##Clicks##<br />
<!--[If Start Enabled]-->
<b>Disable:</b> <input type="text" name="Reason_##Gallery_ID##" size="40"> <input type="submit" value="Disable" onClick="setDisable('##Gallery_ID##', document.disable.Reason_##Gallery_ID##)">
<!--[If End]-->
</td>
</tr>
<tr>
<td>
&nbsp;
</td>
</tr>
<!--[Loop End]-->

</table>
<!--[If End]-->

<input type="hidden" name="r" value="disable">
<input type="hidden" name="Gallery_ID" value="">
<input type="hidden" name="Reason" value="">
<input type="hidden" name="Account_ID" value="##Account_ID##">
<input type="hidden" name="Password" value="##Password##">
</form>

<form name="action" action="partner.cgi" method="POST">
<input type="hidden" name="r">
<input type="hidden" name="Account_ID" value="##Account_ID##">
<input type="hidden" name="Password" value="##Password##">
<input type="hidden" name="Page">
<input type="hidden" name="Sort">
</form>

</body>
</html>
