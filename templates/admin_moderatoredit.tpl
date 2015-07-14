<html>
<head>
<title>Edit Control Panel Account</title>
<script language="JavaScript">

function setupPage()
{
    var edit   = document.form;
    var rights = ##Rights##;

    // Setup privileges checkboxes
    for( var i = 0; i < edit.elements.length; i++ )
    {
        if( edit.elements[i].type == 'checkbox' )
        {
            edit.elements[i].checked = false;

            if( edit.elements[i].value & rights )
            {
                edit.elements[i].checked = true;
            }
        }
    }
}



function checkForm(form)
{
    var parent = window.opener.document;
    var id = form.Username.value;

    var name  = new Array(
                       'Email',
                       'Approved',
                       'Declined',
                       'Banned'
                     );

    var value = new Array(
                       'E-mail',
                       'Approved',
                       'Declined',
                       'Banned'
                     );

    for( var i = 0; i < name.length; i++ )
    {
        if( form.elements[name[i]] && !form.elements[name[i]].value )
        {
            alert(value[i] + ' Must Be Filled In');
            return false;
        }
    }
    
    parent.getElementById(id+'_approved').innerHTML = form.Approved.value;
    parent.getElementById(id+'_declined').innerHTML = form.Declined.value;
    parent.getElementById(id+'_banned').innerHTML   = form.Banned.value;
   
    parent.getElementById(id+'_ahref').setAttribute('href', 'mailto:' + form.Email.value);


    return true;
}


function setAll(form, value)
{
    for( var i = 0; i < form.elements.length; i++ )
    {
        if( form.elements[i].type == 'checkbox' )
        {
            form.elements[i].checked = value;
        }
    }
}


function setChecked(checkbox)
{
    if( document.form.P_ALL.checked == true )
    {
        checkbox.checked = true;
    }
}


</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody" onLoad="setupPage()">


<div align="center">

<form name="form" action="main.cgi" method="POST" onSubmit="return checkForm(this)">

<!-- ACCOUNT EDITING TABLE -->
<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Edit Control Panel Account
</td>
</tr>

<tr>
<td width="200" align="right">
<b>Username</b>
</td>
<td width="500">
##Username##
</td>
</tr>

<tr>
<td align="right" valign="top" style="padding-top: 6px;">
<b>New Password</b>
</td>
<td>
<input type="text" name="Password" size="20"><br />
Only fill this in if you want to change the account password
</td>
</tr>

<tr>
<td align="right">
<b>E-mail</b>
</td>
<td>
<input type="text" name="Email" size="40" value="##Email##"> 
</td>
</tr>

<tr>
<td align="right">
<b>Approved</b>
</td>
<td>
<input type="text" name="Approved" size="5" onChange="fixNumber(this)" value="##Approved##">
</td>
</tr>

<tr>
<td align="right">
<b>Declined</b>
</td>
<td>
<input type="text" name="Declined" size="5" onChange="fixNumber(this)" value="##Declined##">
</td>
</tr>

<tr>
<td align="right">
<b>Banned</b>
</td>
<td>
<input type="text" name="Banned" size="5" onChange="fixNumber(this)" value="##Banned##">
</td>
</tr>

<tr>
<td colspan="2" align="center" class="menuhead">
Access Privileges
</td>
</tr>

<tr>
<td colspan="2">
<input type="checkbox" name="P_ALL" value="0x00000001" onClick="setAll(document.form, this.checked)"> <b>All privileges</b><br />
<input type="checkbox" name="P_GALLERIES" value="0x00000002" onClick="setChecked(this)"> <b>Process galleries in the database</b><br />
<input type="checkbox" name="P_IMPORT" value="0x00000004" onClick="setChecked(this)"> <b>Import galleries</b><br />
<input type="checkbox" name="P_SCANNER" value="0x00000010" onClick="setChecked(this)"> <b>Configure and run gallery scanner</b><br />
<input type="checkbox" name="P_REBUILD" value="0x00000020" onClick="setChecked(this)"> <b>Rebuild TGP pages</b><br />
<input type="checkbox" name="P_OPTIONS" value="0x00000040" onClick="setChecked(this)"> <b>Edit software options</b><br />
<input type="checkbox" name="P_PATCH" value="0x00000008" onClick="setChecked(this)"> <b>Run the patch.cgi script</b><br />
<input type="checkbox" name="P_CATEGORIES" value="0x00000080" onClick="setChecked(this)"> <b>Manage categories and annotations</b><br />
<input type="checkbox" name="P_BACKUP" value="0x00000100" onClick="setChecked(this)"> <b>Use database tools</b><br />
<input type="checkbox" name="P_MODERATORS" value="0x00000200" onClick="setChecked(this)"> <b>Manage control panel accounts</b><br />
<input type="checkbox" name="P_ACCOUNTS" value="0x00000400" onClick="setChecked(this)"> <b>Manage partner accounts</b><br />
<input type="checkbox" name="P_BLACKLIST" value="0x00000800" onClick="setChecked(this)"> <b>Manage blacklist/whitelist</b><br />
<input type="checkbox" name="P_TEMPLATES" value="0x00001000" onClick="setChecked(this)"> <b>Edit script page, tgp page, and e-mail templates</b><br />
<input type="checkbox" name="P_EMAIL" value="0x00002000" onClick="setChecked(this)"> <b>Send e-mails from the software</b><br />
<input type="checkbox" name="P_RECIP" value="0x00004000" onClick="setChecked(this)"> <b>Manage reciprocal links</b><br />
<input type="checkbox" name="P_PAGES" value="0x00008000" onClick="setChecked(this)"> <b>Manage TGP pages</b><br />
<input type="checkbox" name="P_CHEATS" value="0x00010000" onClick="setChecked(this)"> <b>Manage cheat reports</b><br />
<input type="checkbox" name="P_2257" value="0x00020000" onClick="setChecked(this)"> <b>Manage 2257 links</b>
</td>
</tr>

<tr>
<td colspan="2" align="center">
<input type="submit" value="Update Account">
<input type="hidden" name="Username" value="##Username##">
<input type="hidden" name="Run" value="UpdateModerator"> 
</td>
</tr>

</table>
</div>
<!-- END ACCOUNT EDITING TABLE -->