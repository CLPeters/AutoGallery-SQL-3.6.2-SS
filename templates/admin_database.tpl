<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">
<!--[Include File ./templates/ajax.js]-->
function checkForm(form)
{
    if( form.Run.value == 'BackupDatabase' )
    {
        if( !form.Backup_File.value )
        {
            alert('Please enter a filename');
            return false;
        }

        beginBackup(form);
    }
    else if( form.Run.value == 'RestoreDatabase' )
    {
        if( !form.Backup_File.value )
        {
            alert('Please enter a filename');
            return false;
        }

        if( confirm('Are you sure you want to restore the database?') )
        {
            beginRestore(form);
        }
    }
    else if ( form.Run.value == 'OptimizeDatabase' )
    {
        beginOptimize(form);
    }
    else if( form.Run.value == 'ExportDatabase' )
    {
        if( !form.File.value )
        {
            alert('Please enter a filename');
            return false;
        }

        beginExport(form);
    }
    else if( form.Run.value == 'ImportDatabase' )
    {
        if( !form.File.value )
        {
            alert('Please enter a filename');
            return false;
        }

        beginImport(form);
    }
    else if( form.Run.value == 'RawSQL' )
    {
        if( !form.SQL.value )
        {
            alert('Please enter a SQL command to execute');
            return false;
        }

        return true;
    }

    return false;
}


function beginExport(form)
{
    var request = new DataRequestor();

    updateButton('export', true, 'Working...');
    updateButton('import', true, 'Working...');

    request.addArg('POST', 'Export', 'true');
    request.addArg('POST', 'File', form.File.value);
    request.onload = backupResponse;
    request.getURL('xml.cgi');
}


function beginImport(form)
{
    var request = new DataRequestor();

    updateButton('export', true, 'Working...');
    updateButton('import', true, 'Working...');

    request.addArg('POST', 'Import', 'true');
    request.addArg('POST', 'File', form.File.value);
    request.onload = backupResponse;
    request.getURL('xml.cgi');
}


function beginBackup(form)
{
    var request = new DataRequestor();

    updateButton('backup', true, 'Working...');
    updateButton('restore', true, 'Working...');

    request.addArg('POST', 'Backup', 'true');
    request.addArg('POST', 'Backup_File', form.Backup_File.value);
    request.addArg('POST', 'Thumbs', form.Thumbs.checked ? 1 : 0);
    request.addArg('POST', 'Annotations', form.Annotations.checked ? 1 : 0);
    request.onload = backupResponse;
    request.getURL('xml.cgi');
}


function beginRestore(form)
{
    var request = new DataRequestor();

    updateButton('backup', true, 'Working...');
    updateButton('restore', true, 'Working...');

    request.addArg('POST', 'Restore', 'true');
    request.addArg('POST', 'Backup_File', form.Backup_File.value);
    request.onload = backupResponse;
    request.getURL('xml.cgi');
}


function backupResponse(data)
{
    if( data == 'Success' )
    {
        alert('Database function is in progress, please allow 60 seconds to complete');
    }
    else
    {
        checkForError(data);
    }

    updateButton('backup', false, 'Backup');
    updateButton('restore', false, 'Restore');
    updateButton('export', false, 'Export');
    updateButton('import', false, 'Import');
}


function beginOptimize()
{
    var request = new DataRequestor();

    request.addArg('POST', 'Optimize', 'true');
    request.onload = optimizeResponse;
    request.getURL('xml.cgi');

    updateButton('optimize', true, 'Working...');
}


function optimizeResponse(data)
{
    if( data == 'Success' )
    {
        alert('Database has been repaired and optimized');
    }
    else
    {
        checkForError(data);
    }

    updateButton('optimize', false, 'Run Optimize/Repair Function');
}
</script>

</head>
<body class="mainbody">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->

<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this);">

<table class="outlined" width="500" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Database Backup/Restore
</td>
</tr>

<tr>
<td align="right">
<b>Backup Filename</b>
</td>
<td>
<input type="text" name="Backup_File" value="backup.dat" size="20">
</td>
</tr>

<tr>
<td colspan="2" style="padding-left: 125px;">
<div style="padding-bottom: 5px;">
<input type="checkbox" name="Thumbs" value="1" class="nomargin"> Include thumbnails in backup
</div>
<input type="checkbox" name="Annotations" value="1" class="nomargin"> Include annotation files in backup
</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" onClick="setRun('BackupDatabase')" value="Backup" id="backup">
<input type="submit" onClick="setRun('RestoreDatabase')" value="Restore" id="restore" style="margin-left: 150px;">
</td>
</tr>
</table>

<br />

<table class="outlined" width="500" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Database Export/Import
</td>
</tr>

<tr>
<td align="right" width="45%">
<b>Export Filename</b>
</td>
<td>
<input type="text" name="File" value="export.dat" size="20">
</td>
</tr>

<tr>
<td align="center" colspan="2">
<input type="submit" onClick="setRun('ExportDatabase')" value="Export" id="export">
<input type="submit" onClick="setRun('ImportDatabase')" value="Import" id="import" style="margin-left: 150px;">
</td>
</tr>
</table>

<br />

<table class="outlined" width="500" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Optimize/Repair Database
</td>
</tr>

<tr>
<td align="center">
<input type="submit" onClick="setRun('OptimizeDatabase')" value="Run Optimize/Repair Function" id="optimize">
</td>
</tr>
</table>

<br />

<table class="outlined" width="500" cellspacing="0" cellpadding="3">
<tr>
<td colspan="2" align="center" class="menuhead">
Raw SQL Query
</td>
</tr>

<tr>
<td align="center">
<input type="text" name="SQL" size="70"><br />
<input type="submit" onClick="setRun('RawSQL')" value="Execute Query">
</td>
</tr>
</table>


<input type="hidden" name="Run">
</form>

</body>
</html>