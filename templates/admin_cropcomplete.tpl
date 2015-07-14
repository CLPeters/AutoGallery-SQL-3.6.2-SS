<html>
<head>
  <title>Thumbnail</title>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
<script language="JavaScript">

var gallery_id = parseInt('##Gallery_ID##');
var thumb_url = '##Thumbnail_URL##';

function applyCommand(command)
{
    var form = document.form;
    var commands = new Array();
    var post_data = null;
    var request = new DataRequestor();

    switch(command)
    {
        case 'sharpen':
            request.addArg('POST', 'sSigma', form.sSigma.value);
            break;

        case 'brightness':
            request.addArg('POST', 'bAmount', form.bAmount.value);
            break;

        case 'annotation':
            {
                if( form.Annotation.options.length > 0 )
                {
                    request.addArg('POST', 'Annotation', form.Annotation.options[form.Annotation.selectedIndex].value);
                }
            }
            break;
    }


    request.addArg('POST', 'Run', 'ThumbnailFilter');
    request.addArg('POST', 'Gallery_ID', gallery_id);
    request.addArg('POST', 'Command', command);

    request.onload = filterResponse;
    request.onfail = filterError;

    request.getURL('xml.cgi');
}



function filterError(status)
{
    alert("xml.cgi caused a server error: " + status + "\r\nMake sure permissions are 755 on the xml.cgi file");
}


function filterResponse(data) 
{
    var response = data;
 
    if( response.indexOf('|') != -1 )
    {
        var response_data = response.split('|');
        var type = response_data[0];
        var result = response_data[1];

        document.getElementById('thumb').setAttribute('src', thumb_url + '?' + Math.random());

        updateParent();

        if( type == 'Level' )
        {
            if( parseInt(result) > 0 )
            {
                document.getElementById('undo').disabled = false;
            }
            else
            {
                document.getElementById('undo').disabled = true;
            }
        }
        else if( type == 'Done' )
        {
            setTimeout('window.close()', 100);
        }
        else if( type == 'Error' )
        {
            alert("Error: " + result);
        }
    }
    else
    {
        alert("Error: " + data);
    }
}



function updateParent()
{
    var parent = window.opener.document;
    var thumb = parent.getElementById('thumb_##Gallery_ID##');
    var nothumb = parent.getElementById('nothumb_##Gallery_ID##');
    var prev = parent.getElementById('prev_##Gallery_ID##');

    if( thumb )
    {
        thumb.style.visibility = 'visible';
        thumb.style.position = 'static';

        nothumb.style.visibility = 'hidden';
        nothumb.style.position = 'absolute';

        prev.style.height = parseInt('##Thumb_Height##');
        prev.style.width = parseInt('##Thumb_Width##');
        prev.src = thumb_url + '?' + Math.random();
    }
}

<!--[Include File ./templates/ajax.js]-->
</script>
</head>
<body onLoad="updateParent()">

<div align="center">
Thumbnail<br />
<script language="JavaScript">
document.write('<img src="' + thumb_url + '?' + Math.random() + '" id="thumb">');
</script>

<br />
<br />

<!--[If Start Custom_Filters]-->
<form name="form">
<table width="100%">
<tr>
<td align="center">
<b>Sharpen</b>
</td>
<td align="center">
<b>Brightness</b>
</td>
<td align="center">
<b>Contrast</b>
</td>
<td align="center">
<b>Normalize</b>
</td>
<!--[If Start Annotations]-->
<td align="center">
<b>Annotation</b>
</td>
<!--[If End]-->
<td align="center">
<b>Undo</b>
</td>
</tr>

<tr>
<td valign="top" align="center">
<!-- Sharpen -->
Amount <input type="text" name="sSigma" size="3" value="0.6"><br />
<input type="button" value="Apply" class="spacedbutton" onClick="applyCommand('sharpen')">
</td>
<td valign="top" align="center">
<!-- Brightness -->
Amount <input type="text" name="bAmount" size="3" value="1.2"><br />
<input type="button" value="Apply" class="spacedbutton" onClick="applyCommand('brightness')">
</td>
<td valign="top" align="center">
<!-- Contrast -->
<input type="button" value="Increase" onClick="applyCommand('contrastup')"><br />
<input type="button" value="Decrease" class="spacedbutton" onClick="applyCommand('contrastdown')">
</td>

<td valign="top" align="center">
<!-- Contrast -->
<input type="button" value="Normalize" onClick="applyCommand('normalize')">
</td>

<!--[If Start Annotations]-->
<td valign="top" align="center">
<!-- Annotation -->
<select name="Annotation">
<!--[Loop Start Annotations]-->
  <option value="##Unique_ID##">##Identifier##</option>
<!--[Loop End]-->
</select>
<br />
<input type="button" value="Apply" class="spacedbutton" onClick="applyCommand('annotation')">
</td>
<!--[If End]-->

<td valign="top" align="center">
<!-- Undo -->
<input type="button" value="Undo" disabled onClick="applyCommand('undo')" id="undo"><br />
<input type="button" value="Reset" class="spacedbutton" onClick="applyCommand('reset')">
</td>
</tr>
</table>

<br />

<input type="button" value="Done" onClick="applyCommand('done')" style="font-size: 10pt; font-weight: bold; font-family: Verdana;">

</form>

<!--[If End]-->

<br />
<br />

<a href="" onclick="window.close(); return false;" class="link">Close Window</a>
</div>

</body>
</html>
