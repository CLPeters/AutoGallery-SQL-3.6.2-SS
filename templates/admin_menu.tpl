<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">

var confirm_build = true;

function errorLogCheck()
{
    var request = new DataRequestor();

    request.addArg('POST', 'ErrorLog', 1);
    request.onload = errorResponse;   
    request.getURL('xml.cgi');
}


function errorResponse(data)
{
    if( data == 'New' )
    {
        alert("A new error log entry has been added.\r\n" +
              "Please view the error log for additional information.");
    }

    setTimeout('errorLogCheck()', 30000);
}


function buildPages(url, height, width, bool)
{
    if( confirm_build )
    {
        if( confirm('Are you sure you want to run this page building function?') )
        {
            popupWindow(url, height, width, bool);
        }
    }
    else
    {
        popupWindow(url, height, width, bool);
    }

    return false;
}

<!--[Include File ./templates/ajax.js]-->
</script>
</head>
<body class="mainbody" onLoad="errorLogCheck()">

<noscript>
This software requires a JavaScript enabled browser.  Please update
your browser to a more recent version that supports JavaScript.  If
you have a modern browser, make sure JavaScript is enabled.
<div style="visibility: hidden;">
</noscript>

<div class="menuhead">
Manage Galleries<br />
</div>

<div class="menubox">
<a href="main.cgi?Run=DisplayGalleries" target="main">Display Galleries</a><br />
<a href="review.cgi" target="_blank">Review Galleries</a><br />
<a href="main.cgi?Run=DisplayScanner" target="main">Gallery Scanner</a><br />
<a href="main.cgi?Run=DisplaySubmit" target="main">Submit a Gallery</a><br />
<a href="main.cgi?Run=DisplayImport" target="main">Import Galleries</a><br />
<a href="main.cgi?Run=DisplayBreakdown" target="main">Gallery Breakdown</a>
</div>


<div class="menuhead">
TGP Pages<br />
</div>

<div class="menubox">
<a href="" onClick="return buildPages('main.cgi?Run=BuildAllPages&Which=BuildAllReorder', 300, 450, false)">Build Pages</a><br />
<a href="" onClick="return buildPages('main.cgi?Run=BuildAllPages&Which=BuildAllNew', 300, 450, false)">Build Pages With New</a><br />
<a href="main.cgi?Run=DisplayPageURLs" target="main">Show TGP Page URLs</a><br />
<a href="main.cgi?Run=DisplayManagePages" target="main">Manage Pages</a><br />
<a href="main.cgi?Run=DisplayPageTemplates" target="main">Edit Templates</a>
</div>

<div class="menuhead">
Templates<br />
</div>

<div class="menubox">
<a href="main.cgi?Run=DisplayScriptTemplates" target="main">Script Pages</a><br />
<a href="main.cgi?Run=DisplayEmailEditor" target="main">E-mail Messages</a><br />
<a href="main.cgi?Run=DisplayLangEditor" target="main">Language File</a><br />
<a href="main.cgi?Run=DisplayIcons" target="main">Manage Icons</a>
</div>

<div class="menuhead">
Gallery Control<br />
</div>

<div class="menubox">
<a href="main.cgi?Run=DisplayBlacklist" target="main">Blacklist/Whitelist</a><br />
<a href="main.cgi?Run=DisplayReciprocals" target="main">Reciprocal Links</a><br />
<a href="main.cgi?Run=Display2257" target="main">2257 Search Code</a><br />
<a href="main.cgi?Run=DisplayRejectEditor" target="main">Rejection E-mails</a><br />
<a href="main.cgi?Run=DisplayCheats" target="main">Cheat Reports</a>
</div>

<div class="menuhead">
Partner Accounts<br />
</div>

<div class="menubox">
<a href="main.cgi?Run=DisplayAddAccount" target="main">Add Account</a><br />
<a href="main.cgi?Run=DisplayAccounts" target="main">Manage Accounts</a><br />
<a href="main.cgi?Run=DisplayAccountRequests" target="main">Account Requests</a>
</div>

<div class="menuhead">
Control Panel Accounts<br />
</div>

<div class="menubox">
<a href="main.cgi?Run=DisplayAddModerator" target="main">Add Account</a><br />
<a href="main.cgi?Run=DisplayModerators" target="main">Manage Accounts</a>
</div>

<div class="menuhead">
Setup<br />
</div>

<div class="menubox">
<a href="main.cgi?Run=DisplayOptions" target="main">Edit Options</a><br />
<a href="main.cgi?Run=DisplayManageCategories" target="main">Manage Categories</a><br />
<a href="main.cgi?Run=DisplayManageAnnotations" target="main">Manage Annotations</a><br />
<a href="main.cgi?Run=DisplayReferrersAndAgents" target="main">Referrers and Agents</a><br />
<a href="main.cgi?Run=DisplayDatabaseTools" target="main">Database Tools</a><br />
<a href="" onClick="return popupWindow('main.cgi?Run=RecompileTemplates', 300, 450, true)">Recompile TGP Templates</a><br />
<a href="main.cgi?Run=DisplayErrorLog" target="main">View Error Log</a><br />
</div>

<br />


<noscript>
</div>
</noscript>

</body>
</html>