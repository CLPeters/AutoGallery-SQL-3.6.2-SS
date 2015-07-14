<html>
<head>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">
<!--[Include File ./templates/ajax.js]-->

var interval;

function setupForm()
{
    var form   = document.form;
    var fields = new Array();

    fields['connection']    = '##connection##';
    fields['broken_url']    = '##broken_url##';
    fields['redirect']      = '##redirect##';
    fields['links']         = '##links##';
    fields['page_change']   = '##page_change##';
    fields['blacklist']     = '##blacklist##';
    fields['thumb_change']  = '##thumb_change##';
    fields['banned_html']   = '##banned_html##';
    fields['no_recip']      = '##no_recip##';
    fields['create_thumbs'] = '##create_thumbs##';
    fields['new_thumbs']    = '##new_thumbs##';
    fields['build_pages']   = '##build_pages##';
    fields['send_email']    = '##send_email##';
    fields['no_thumb']      = '##no_thumb##';
    fields['no_2257']       = '##no_2257##';
    fields['download_thumb'] = '##download_thumb##';
    fields['download_resize'] = '##download_resize##';
    fields['new_size'] = '##new_size##';

    fields['only_partner']  = '##only_partner##';
    fields['only_status']   = '##only_status##';
    fields['only_type']     = '##only_type##';
    fields['only_sponsor']  = '##only_sponsor##';
    fields['only_category'] = '##only_category##';
    fields['only_format']   = '##only_format##';
    fields['id_range']      = '##id_range##';
    fields['zero_thumbs']   = '##zero_thumbs##';
    fields['update_count']  = '##update_count##';
    fields['update_format'] = '##update_format##';


    for( var i = 0; i < form.elements.length; i++ )
    {
        if( fields[form.elements[i].name] )
        {
            var select = form.elements[i];

            if( select.options )
            {
                for( var j = 0; j < select.options.length; j++ )
                {
                    if( select.options[j].value == fields[form.elements[i].name] )
                    {
                        select.selectedIndex = j;
                        break;
                    }
                }
            }
            else
            {
                if( fields[form.elements[i].name] == 1 )
                {
                    form.elements[i].checked = true;
                }
            }
        }
    }

    queryScanner();
    interval = setInterval('queryScanner()', 7000);
}


function checkForm(form)
{
    if( form.Run.value == 'SaveScannerConfig' && !form.Identifier.value )
    {
        alert('Please enter an identifier');
        return false;
    }

    return true;
}


function fixID(field)
{
    field.value = field.value.replace(/[^0-9A-Z_]/gi, '');
}


function startScanner(config)
{
    var request = new DataRequestor();

    request.addArg('POST', 'StartScanner', 'true');
    request.addArg('POST', 'Config', config);
    request.onload = startScannerResponse;
    request.getURL('xml.cgi');

    clearInterval(interval);
    interval = setInterval('queryScanner()', 7000);

    document.getElementById(config).innerHTML = 'Starting...';


    return false;
}


function startScannerResponse(data)
{
    var info = data.split('|');
    
    if( info[0] == 'Success' )
    {
        var span = document.getElementById(info[2]);

        if( span )
        {
            span.innerHTML = 'Started';
        }
    }
    else
    {
        checkForError(data);
    }    
}


function queryScanner()
{
    var request = new DataRequestor();

    setStatusColor('#FF0000');

    request.addArg('POST', 'QueryScanner', 'true');
    request.onload = queryScannerResponse;
    request.getURL('xml.cgi');
}


function queryScannerResponse(data)
{
    var lines = data.split("\n");

    if( lines[0] == 'Success' )
    {
        for( var i = 1; i < lines.length; i++ )
        {
            var info = lines[i].split('|');
            var span = document.getElementById(info[1]);

            if( span )
            {
                span.innerHTML = info[0];
            }
        }
    }
    else
    {
        checkForError(data);
    }

    setStatusColor('#000000');
}


function stopScanner(config)
{
    var request = new DataRequestor();

    request.addArg('POST', 'StopScanner', 'true');
    request.addArg('POST', 'Config', config);
    request.onload = stopScannerResponse;
    request.getURL('xml.cgi');

    return false;
}


function stopScannerResponse(data)
{
    var info = data.split('|');

    if( info[0] == 'Success' )
    {
        var span = document.getElementById(info[1]);

        if( span )
        {
            clearInterval(interval);
            interval = setInterval('queryScanner()', 7000);
            span.innerHTML = 'Stopping...';
        }
    }
    else
    {
        checkForError(data);
    }  
}

function setStatusColor(color)
{
    document.getElementById('status').style.color = color;
}

</script>
</head>
<body class="mainbody" onLoad="setupForm()">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="tablehead" colspan="2">
Gallery Scanner Configuration
</td>
</tr>

<tr>
<td class="subhead" colspan="2">
Identifier<br />
</td>
</tr>
<tr>
<td colspan="2">
<input type="text" name="Identifier" size="30" style="margin-left: 20px;" onChange="fixID(this)" value="##Identifier##">
</td>
</tr>

<tr>
<td class="subhead" colspan="2">
Limit Gallery Scan to Specific Galleries<br />
</td>
</tr>
<tr>
<td colspan="2">
<input type="checkbox" name="zero_thumbs" value="1"style="margin-left: 20px;"> Only galleries that have a zero thumbnail count<br />
<input type="checkbox" name="no_thumb" value="1"style="margin-left: 20px;"> Only galleries that do not have a preview thumbnail<br />
<input type="checkbox" name="only_partner" value="1"style="margin-left: 20px;"> Only galleries submitted by partner accounts<br />
<input type="checkbox" name="only_type" value="1"style="margin-left: 20px;"> Galleries of type
<select name="type">
<!--[Loop Start Types]-->
  <option value="##Type##"##Selected##>##Type##</option>
<!--[Loop End]-->
</select>
<br />

<input type="checkbox" name="only_format" value="1"style="margin-left: 20px;"> Galleries of format
<select name="format">
  <option value="Pictures"##FormatPictures##>Pictures</option>
  <option value="Movies"##FormatMovies##>Movies</option>
</select>
<br />

<input type="checkbox" name="only_status" value="1"style="margin-left: 20px;"> Galleries with status
<select name="status">
<!--[Loop Start Statuses]-->
  <option value="##Status##"##Selected##>##Status##</option>
<!--[Loop End]-->
</select>
<br />

<!--[If Start Sponsors]-->
<input type="checkbox" name="only_sponsor" value="1"style="margin-left: 20px;"> Galleries from sponsor
<select name="sponsor_name">
<!--[Loop Start Sponsors]-->
  <option value="##Sponsor##"##Selected##>##Sponsor##</option>
<!--[Loop End]-->
</select>
<br />
<!--[If End]-->
<input type="checkbox" name="only_category" value="1"style="margin-left: 20px;"> Galleries in category 
<select name="category_name">
<!--[Loop Start Categories]-->
  <option value="##Name##"##Selected##>##Name##</option>
<!--[Loop End]-->
</select>
<br />
<input type="checkbox" name="id_range" value="1"style="margin-left: 20px;"> Galleries with ID number between <input type="text" name="start" size="9" value="##start##"> and <input type="text" name="end" size="9" value="##end##">
</td>
</tr>

<tr>
<td class="subhead" colspan="2">
Options<br />
</td>
</tr>
<tr>
<td colspan="2">
<!--[If Start Code ($HAVE_MAGICK)]-->
<input type="checkbox" name="create_thumbs" value="1" style="margin-left: 20px;"> Create a preview thumbnail for galleries that do not have one<br />
<div style="margin-left: 40px; padding-top: 10px; padding-bottom: 10px;">
Thumb Height: <input type="text" name="height" size="3" value="##height##">
Thumb Width: <input type="text" name="width" size="3" value="##width##">
</div>
<input type="checkbox" name="new_thumbs" value="1" style="margin-left: 20px;"> Create new preview thumbnails for all galleries that already have one<br />
<input type="checkbox" name="new_size" value="1" style="margin-left: 20px;"> Use height and width above for galleries that already have a thumbnail<br />
<!--[If End]-->

<input type="checkbox" name="download_thumb" value="1" style="margin-left: 20px;"> Download thumbnails located on remote servers<br />
<!--[If Start Code ($HAVE_MAGICK)]-->
<input type="checkbox" name="download_resize" value="1" style="margin-left: 20px;"> Resize downloaded thumbnails to dimensions entered above<br />
<!--[If End]-->
<input type="checkbox" name="update_count" value="1" style="margin-left: 20px;"> Update the thumbnail count for scanned galleries<br />
<input type="checkbox" name="update_format" value="1" style="margin-left: 20px;"> Update the gallery format for scanned galleries<br />
<input type="checkbox" name="build_pages" value="1" style="margin-left: 20px;"> Rebuild the TGP pages when the scanner is completed<br />
<input type="checkbox" name="send_email" value="1" style="margin-left: 20px;"> Send an e-mail to the administrator when the scanner is completed<br />
</td>
</tr>


<tr>
<td class="subhead" colspan="2">
Actions
</td>
</tr>

<tr>
<td colspan="2">
<select name="connection" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with connection errors<br />

<select name="broken_url" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with broken URLs<br />

<select name="redirect" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries that forward<br />

<select name="blacklist" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with blacklisted data<br />

<select name="banned_html" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with blacklisted HTML<br />

<select name="no_2257" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with no 2257 code<br />


<select name="no_recip" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with no reciprocal link<br />


<select name="thumb_change" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with a change in the thumbnail count<br />


<select name="links" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries with too many links<br />


<select name="page_change" style="margin-left: 20px;">
  <option value="0x00000000">Ignore</option>
  <option value="0x00000001">Display In Report Only</option>
  <option value="0x00000002">Place in Disabled Gallery Queue</option>
  <option value="0x00000004">Delete Gallery From Database</option>
  <option value="0x00000008">Delete Gallery And Blacklist It</option>
</select>
Galleries where the page has changed since submission<br />
</td>
</tr>

<tr>
<td class="subhead" colspan="2">
Save/Load
</td>
</tr>
<tr>
<td align="center">
<input type="hidden" name="Run">
<input type="submit" value="Save" onClick="setRun('SaveScannerConfig')">
</td>

<!--[If Start Configurations]-->
<td align="center" width="50%">
<select name="Config">
<!--[Loop Start Configurations]-->
  <option value="##Identifier##">##Identifier##</option>
<!--[Loop End]-->
</select>
<input type="submit" value="Load" onClick="setRun('LoadScannerConfig')">
&nbsp;
<input type="submit" value="Delete" onClick="setRun('DeleteScannerConfig')">
</td>
<!--[If End]-->

</tr>
</table>

</form>

<br />



<!--[If Start Configurations]-->
<table class="outlined" width="700" cellspacing="0" cellpadding="3">
<tr>
<td align="center" class="tablehead" colspan="3">
Gallery Scanner Status
</td>
</tr>

<tr class="subhead">
<td align="center" width="250">
Identifier
</td>
<td>
<span id="status">Status</span>
</td>
<td align="center" width="150">
Actions
</td>
</tr>

<!--[Loop Start Configurations]-->
<tr>
<td align="center">
<a href="main.cgi?Run=DisplayReport&Page=report-##Identifier##.html"  target="_blank">##Identifier##</a>
</td>
<td>
<span id="##Identifier##">Checking...</span>
</td>
<td align="center">
<a href="" onClick="return startScanner('##Identifier##')">[Start]</a>
&nbsp;
<a href="" onClick="return stopScanner('##Identifier##')">[Stop]</a>
</td>
</tr>
<!--[Loop End]-->
</table>

<br />
<!--[If End]-->


</body>
</html>
