<html>
<head>
<script language="JavaScript">

var g_admin_url = '##Script_URL##/admin/main.cgi';

function expand(field, size)
{
    var top = getTop(field);
    var left = getLeft(field);
    var current_y = window.scrollY;

    field.style.top = top;
    field.style.left = left;
    field.style.position = 'absolute';
    
    field.setAttribute('size', size);
}


function shrink(field, size)
{
    field.setAttribute('size', size);
    field.style.position = 'static';
}


function changeFormat(field)
{
    if( field.value == 'Pictures' )
    {
        field.value = 'Movies';
    }
    else
    {
        field.value = 'Pictures';
    }

    field.blur();
}


function changeType(field)
{
    if( field.value == 'Submitted' )
    {
        field.value = 'Permanent';
    }
    else
    {
        field.value = 'Submitted';
    }

    field.blur();
}


function showIcons(e)
{
    var icons = document.getElementById('Icons').value.split(',');
    var icon_select = document.getElementById('icon_select');

    uncheckIcons();

    for(var i = 0; i < icons.length; i++)
    {
        checkIcon(icons[i]);
    }

    icon_select.style.top = e.pageY ? e.pageY - 100 : e.y + document.body.scrollTop - 100;
    icon_select.style.left = (e.pageX ? e.pageX : e.x) - 200;
    icon_select.style.visibility = 'visible';

    return false;
}


function uncheckIcons()
{
    var form = document.icon_form;

    for(var i = 0; i < form.elements.length; i++)
    {
        form.elements[i].checked = false;
    }
}


function checkIcon(icon)
{
    var form = document.icon_form;

    for(var i = 0; i < form.elements.length; i++)
    {
        if( form.elements[i].value == icon )
        {
            form.elements[i].checked = true;
        }
    }
}


function updateIcons()
{
    var icons = document.icon_form.Icons;
    var new_icons = Array();
    var element = document.getElementById('Icons');

    hide('icon_select');

    if( !icons )
    {
        return false;
    }

    if( icons.length )
    {
        for(var i = 0; i < icons.length; i++)
        {
            if( icons[i].checked == true )
            {
                new_icons.push(icons[i].value);
            }
        }

        icons = new_icons.join(',');
    }
    else
    {
        if( icons.checked == true )
        {
            icons = icons.value;
        }
        else
        {
            icons = '';
        }
    }

    if( element.value != icons )
    {
        element.value = icons;
    }

    return false;
}



function updateFrame()
{
    var url = '##Gallery_URL##';
    var parent = window.parent.document;
    var frame = parent.getElementById('main');
    var form = document.review;

    frame.src = url;

    // Update options
    setSelect(form.O_Type, '##O_Type##');
    setSelect(form.O_Category, '##O_Category##');
    setSelect(form.O_Format, '##O_Format##');
    setSelect(form.O_Sort, '##O_Sort##');
    setSelect(form.O_SortDir, '##O_SortDir##');    
}


function setSelect(field, value)
{
    for( var i = 0; i < field.options.length; i++ )
    {
        if( field.options[i].value == value )
        {
            field.selectedIndex = i;
            return;
        }
    }
}


function clearFrame()
{
    var parent = window.parent.document;
    var frame  = parent.getElementById('main');

    frame.src = '';
}



function doIt(input, what)
{
    var actions = new Array();
    var file    = '##File_Name##_' + input + '.jpg';

<!--[If Start TGP_Cropper]-->
    if( what == 'CropThumbnail' )
    {
        var gallery_url = document.getElementById('Gallery_URL').value;
        actions['CropThumbnail']   = new Array('##TGP_Cropper##&Gallery_URL='+ escape(gallery_url) +'&Gallery_ID=', 'menubar=no,height=0,width=0,scrollbars=yes,resizable=yes');
    }
<!--[If Elsif Code {$HAVE_MAGICK}]-->
    actions['CropThumbnail']   = new Array('main.cgi?Run=DisplayCrop&Gallery_ID=', 'menubar=no,height=768,width=1024,scrollbars=yes,resizable=yes');
<!--[If Else]-->
    actions['CropThumbnail']   = new Array('main.cgi?Run=DisplayUpload&Gallery_ID=', 'menubar=no,height=175,width=650,scrollbars=yes,top=300,left=300');
<!--[If End]-->

    if( actions[what] )
    {
        newWindow = window.open(actions[what][0] + '' + input, '_blank', actions[what][1]);

        if( actions[what][0].search(/tgpcropper/) != -1 )
        {
            newWindow.close();
        }
    }   

    return false;
}


function deleteThumb(id)
{
    if( confirm('Are you sure you want to delete this thumbnail?') )
    {
        var request = new DataRequestor();

        request.addArg('POST', 'Run', 'DeleteThumbnail');
        request.addArg('POST', 'Gallery_ID', id);

        request.onload = deleteThumbResponse;

        request.getURL(g_admin_url);
    }

    return false;
}


function deleteThumbResponse(data)
{
    var info = data.split('|');

    if( info[0] == 'Success' )
    {
        var thumb = document.getElementById('thumb_' + info[1]);
        var nothumb = document.getElementById('nothumb_' + info[1]);

        thumb.style.visibility = 'hidden';
        thumb.style.position = 'absolute';

        nothumb.style.visibility = 'visible';
        nothumb.style.position = 'static';

        if( nothumb.parentNode.style.backgroundColor == 'rgb(250, 250, 210)' || nothumb.parentNode.style.backgroundColor == '#fafad2' )
        {
            nothumb.parentNode.style.backgroundColor = '#FFFFFF';
        }
    }
    else
    {
        checkForError(data);
    }
}


function checkForError(data)
{
    var result;

    if( result = data.match(/<span id="Error">\s+(.*?)\s+<\/span>/mi) )
    {
        alert('Error: ' + result[1]);
    }
}


function showOptions()
{
    var element = document.getElementById('options');
    var width = 0;

    if( document.layers )
        width = window.innerWidth;
    else
        width = document.body.offsetWidth;

    element.style.top = 10;
    element.style.left = (width / 2) - 375;
    element.style.visibility = 'visible';

    document.getElementById('reject_select').style.visibility = 'hidden';
    document.getElementById('cat_select').style.visibility = 'hidden';

    return false;
}



function hideOptions()
{
    var element = document.getElementById('options');
    element.style.visibility = 'hidden';
    document.getElementById('reject_select').style.visibility = 'visible';
    document.getElementById('cat_select').style.visibility = 'visible';
    return false;
}


function resetLimit()
{
    document.review.Limit.value = 0;
}

<!--[Include File ./templates/ajax.js]-->
</script>
<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body onLoad="updateFrame()">

<form name="review" action="review.cgi" method="POST" onSubmit="clearFrame()">

<table align="center" width="750" border="0" cellspacing="0" cellpadding="3">
<tr>
<td width="160" align="center">

<input type="button" onclick="showOptions()" value="Options">

&nbsp;&nbsp;&nbsp;

<input type="Submit" name="Run" value="Skip">
</td>
<td width="460" align="center">

<!--[If Start Account_ID]-->
<span class="partner">##Account_ID##</span>
&nbsp;
&nbsp;
<!--[If End]-->

<input type="Submit" name="Run" value="Approve">

<span style="margin-left: 50px"></span>

<select name="Reject" id="reject_select">
  <option value="None">None</option>
<!--[Loop Start Reasons]-->
  <option value="##Reason##"##Selected##>##Reason##</option>
<!--[Loop End]-->
</select>
<input type="Submit" name="Run" value="Reject">
</td>

<td width="130" align="center">
<input type="Submit" name="Run" value="Blacklist">
</td>


</td>
</tr>
<tr>
<td width="160" height="140" align="center" valign="top">
<!--[If Start Has_Thumb]-->
<div id="thumb_##Gallery_ID##" style="width: 155px; overflow: hidden;">
<!--[If Else]-->
<div id="thumb_##Gallery_ID##" style="visibility: hidden; position: absolute;">
<!--[If End]-->
<a href="" onClick="return doIt('##Gallery_ID##', 'CropThumbnail');" class="link">[Edit]</a>
&nbsp;
<a href="" onClick="return deleteThumb('##Gallery_ID##');" class="link">[Delete]</a>
<img id="prev_##Gallery_ID##" src="##Thumbnail_URL##"><br />
</div>


<!--[If Start Has_Thumb]-->
<span id="nothumb_##Gallery_ID##" style="visibility: hidden; position: absolute;">
<!--[If Else]-->
<span id="nothumb_##Gallery_ID##">
<!--[If End]-->
<a href="" onClick="return doIt('##Gallery_ID##', 'CropThumbnail');" class="link">[No Thumb]</a>
</span>
</td>
<td width="460" valign="top">

<table border="0" cellspacing="0" cellpadding="3">
<tr>
<td align="right">
<b>URL</b>
</td>
<td>
<input type="text" name="Gallery_URL" id="Gallery_URL" value="##Gallery_URL##" size="20" onFocus="expand(this, 60, true)" onBlur="shrink(this, 20, true)" class="##URL_Class##">
<span style="padding-left: 20px;">
<b>Format</b>
<input type="text" name="Format" value="##Format##" size="10" onFocus="changeFormat(this)">
</span>

<input type="checkbox" name="Allow_Scan" value="1" class="nomargin" checked> <b>S</b>
&nbsp;
<input type="checkbox" name="Allow_Thumb" value="1" class="nomargin" checked> <b>T</b>

</td>
</tr>
<tr>
<td align="right">
<b>Desc</b>
</td>
<td>
<input type="text" name="Description" value="##Description##" size="20" onFocus="expand(this, 60)" onBlur="shrink(this, 20)">

<span style="padding-left: 4px;">
<b>Keywords</b>
<input type="text" name="Keywords" value="##Keywords##" size="20">
</span>

</td>
</tr>
<tr>
<td align="right">
<b>Name</b>
</td>
<td>
<input type="text" name="Nickname" value="##Nickname##" size="20">

<span style="padding-left: 14px;">
<b>Sponsor</b>
<input type="text" name="Sponsor" value="##Sponsor##" size="20">
</span>
</td>
</tr>

<tr>
<td align="right">
<b>Thumbs</b>
</td>
<td>
<input type="text" name="Thumbnails" value="##Thumbnails##" size="5">

&nbsp;
&nbsp;

<b>Weight</b>
<input type="text" size="4" value="##Weight##" name="Weight">

&nbsp;
&nbsp;

<b>Type</b>
<input type="text" size="10" value="##Type##" name="Type" onFocus="changeType(this)">
</td>
</tr>


<tr>
<td align="right">
<b>Cat</b>
</td>
<td>
<select name="Category" id="cat_select">
  <option value="##Category##">##Category##</option>
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>

&nbsp;
&nbsp;

[##Added_Date##]

&nbsp;
&nbsp;
<a href="" onClick="return showIcons(event)" class="link">[Icons]</a>
<input type="hidden" name="Icons" id="Icons" value="##Icons##">

</td>
</tr>

<tr>
<td align="right">
<b>Sched</b>
</td>
<td>
<input type="text" size="10" name="Scheduled_Date">


&nbsp;
&nbsp;

<b>Del</b>
<input type="text" size="10" name="Delete_Date">

&nbsp;
&nbsp;

<a href="mailto:##Email##" class="link" title="##Email##">##ChoppedEmail##</a>
</td>
</tr>
</table>

</td>





<td width="130" valign="top">
<div align="left" style="padding-top: 5px;">
<input type="checkbox" name="submit_ip" value="1"> IP Address<br />
<input type="checkbox" name="gallery_ip" value="1"> Gallery IP<br />
<input type="checkbox" name="hostname" value="1"> Hostname<br />
<input type="checkbox" name="dns" value="1"> DNS Server<br />
<input type="checkbox" name="email" value="1"> E-mail<br />
<input type="checkbox" name="email_host" value="1"> E-mail Host<br />
</div>

</td>
</tr>
</table>

<input type="hidden" name="Gallery_ID" value="##Gallery_ID##">
<input type="hidden" name="Limit" value="##Limit##">


<!-- FLOATING OPTIONS -->
<table width="750" cellspacing="0" cellpadding="3" style="visibility: hidden; position: absolute; z-index: 20" class="outlined" id="options">
<tr>
<td colspan="4" align="center" class="tablehead">
Options
</td>
</tr>

<tr>
<td align="right">
<b>Type:</b>
</td>
<td>
<select name="O_Type">
  <option value="0">All</option>
  <option value="Submitted">Submitted</option>
  <option value="Permanent">Permanent</option>
</select>
</td>
<td align="right">
<b>Category:</b>
</td>
<td>
<select name="O_Category">
  <option value="0">All</option>
<!--[Loop Start Categories]-->
  <option value="##Name##">##Name##</option>
<!--[Loop End]-->
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Format:</b>
</td>
<td>
<select name="O_Format">
  <option value="0">All</option>
  <option value="Pictures">Pictures</option>
  <option value="Movies">Movies</option>
</select>
</td>
<td align="right">
<b>Sort:</b>
</td>
<td>
<select name="O_Sort">
  <option value="Added_Stamp">Added Time</option>
  <option value="Gallery_ID">Gallery ID</option>
  <option value="RAND()">Random</option>
</select>
<select name="O_SortDir">
  <option value="DESC">Descending</option>
  <option value="ASC">Ascending</option>
</select>
</td>
</tr>

<tr>
<td align="center" colspan="4">
<input type="submit" name="Run" value="Save" onClick="resetLimit()">
&nbsp;&nbsp;&nbsp;
<input type="button" value="Cancel" onclick="hideOptions()">
</td>
</tr>
</table>
<!-- END FLOATING OPTIONS -->

</form>


<!-- FLOATING ICON SELECTION -->
<form name="icon_form">
<table width="500" cellspacing="0" cellpadding="3" style="visibility: hidden; position: absolute; border: 1px solid black;" id="icon_select" class="outlined">
<tr>
<td colspan="3" align="center" class="tablehead" style="background-color: black;">
Icons
</td>
</tr>
<tr>
<!--[Loop Start IconSelect]-->
<td style="padding-left: 20px;">
<input type="checkbox" name="Icons" value="##Identifier##"> ##HTML##<br />
</td>
<!--[If Start Code {($i + 1) % 3 == 0}]-->
</tr>
<tr>
<!--[If End]-->
<!--[Loop End]-->
</tr>
<tr>
<td align="center" colspan="3">
<input type="button" value="Done" onClick="updateIcons()">
</td>
</tr>
</table>
</form>
<!-- END FLOATING ICON SELECTION -->


</body>
</html>