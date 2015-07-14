<script language="JavaScript">

var g_max_height = 150;
var g_max_width = 110;
var g_input = null;
var g_selected_image = null;
var g_filters_visible = false;
var g_image_id = null;
var g_icon_id = null;
var g_gallery_id = null;


function newSearch(form)
{
    form.Run.value  = 'DisplayGalleries';
    form.Page.value = 0;
}


function submitForm(page)
{
    document.form.Page.value = parseInt(document.form.Page.value) + parseInt(page);
    document.form.Run.value  = 'DisplayGalleries';
    document.form.submit();

    return false;
}


function jumpPage()
{
    document.form.Page.value = document.form.Page_Jump.options[document.form.Page_Jump.selectedIndex].value;
    document.form.Run.value  = 'DisplayGalleries';
    document.form.submit();
}


function allCategories()
{
    var cats = document.form.Category;

    for( var i = cats.length - 1; i >= 0; i-- )
    {
        cats[i].selected = true;
    }

    return false;
}


function openWindow(input, what)
{
    var actions = new Array();
    var file    = file_name + input + '.jpg';

    // Do not allow clicks if the filters interface is visible
    if( g_filters_visible )
    {
        return false;
    }

    if( tgp_cropper && what == 'CropThumbnail' )
    {
        var gallery_url = document.getElementById(input+'_Gallery_URL').value;
        actions['CropThumbnail'] = new Array(cropper_url+'&Gallery_URL='+ escape(gallery_url) +'&Gallery_ID=', 'menubar=no,height=0,width=0,scrollbars=yes,resizable=yes');
    }
    else if( have_magick )
    {
        actions['CropThumbnail'] = new Array('main.cgi?Run=DisplayCrop&Gallery_ID=', 'menubar=no,height=768,width=1024,scrollbars=yes,resizable=yes');
    }
    else
    {
        actions['CropThumbnail'] = new Array('main.cgi?Run=DisplayUpload&Gallery_ID=', 'menubar=no,height=175,width=650,scrollbars=yes,top=300,left=300');
    }
    actions['Blacklist'] = new Array('main.cgi?Run=DisplayQuickBan&Gallery_ID=', 'menubar=no,height=300,width=650,scrollbars=yes,top=300,left=300');
      
    actions['ScanGallery'] = new Array('main.cgi?Run=DisplayScanGallery&Gallery_ID=', 'menubar=no,height=290,width=550,scrollbars=yes,top=300,left=300');
    actions['QuickTasks'] = new Array('main.cgi?Run=DisplayQuickTasks', 'menubar=no,height=500,width=560,scrollbars=yes,top=200,left=200,resizable=yes');
    actions['ResolveIP'] = new Array('main.cgi?Run=DisplayResolveIP&IP=', 'menubar=no,height=150,width=450,scrollbars=yes,top=300,left=300');

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



function deleteGallery(id)
{
    if( confirm('Are you sure you want to delete this gallery?') )
    {
        var request = new DataRequestor();

        request.addArg('POST', 'Run', 'DeleteGallery');
        request.addArg('POST', 'Gallery_ID', id);

        request.onload = deleteGalleryResponse;

        request.getURL(g_admin_url);
    }

    return false;
}


function deleteGalleryResponse(data)
{
    var info = data.split('|');

    if( info[0] == 'Success' )
    {
        var row = null;

        while( row = document.getElementById(info[1]) )
        {
            row.parentNode.removeChild(row);
        }
    }
    else
    {
        checkForError(data);
    }
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


function showIcons(e, id)
{
    g_icon_id = id;

    var icons = document.getElementById(id + '_Icons').value.split(',');
    var icon_select = document.getElementById('icon_select');

    uncheckIcons();

    for(var i = 0; i < icons.length; i++)
    {
        checkIcon(icons[i]);
    }

    icon_select.style.top = e.pageY ? e.pageY : e.y + document.body.scrollTop;
    icon_select.style.left = (e.pageX ? e.pageX : e.x) - 150;
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
    var element = document.getElementById(g_icon_id + '_Icons');

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
        hasChanged(g_icon_id);
    }

    return false;
}


function updateIconsAll()
{
    updateIcons();
    setAll('Icons', g_icon_id);
}


function hideFullImage()
{
    var img = document.getElementById('floater');

    if( !g_filters_visible )
    {
        img.style.visibility = 'hidden';
        img.style.position = 'absolute';

        g_image_id = null;
    }
}


function showFullImage(image, image_id)
{
    var img = document.getElementById('floater');
    var td = image.parentNode.parentNode;

    if( td.getAttribute('title') == 'Resized' )
    {
        img.style.top = getTop(image);
        img.style.left = getLeft(image);
        img.style.visibility = 'visible';
        img.src = image.src;

        g_image_id = image_id;
    }   
}


function showImageFilters(e, image, id)
{
    if( e.button != 1 && e.button != 0 )
    {
        return;
    }

    if( g_image_id != null )
    {
        id = g_image_id;
    }

    if( have_magick && !g_filters_visible )
    {
        var filters = document.getElementById('filters');

        g_selected_image = id;

        filters.style.top = getTop(image);
        filters.style.left = getLeft(image) + parseInt(image.width);
        filters.style.visibility = 'visible';

        document.getElementById('undo').disabled = true;
        document.getElementById('save').disabled = true;
        document.getElementById('reset').disabled = true;

        g_filters_visible = true;
    }
}


function closeImageFilters()
{
    var filters = document.getElementById('filters');

    g_selected_image = null;

    filters.style.visibility = 'hidden';

    g_filters_visible = false;

    hideFullImage();
}


function doneEditing(image_id)
{
    document.getElementById(image_id).setAttribute('title', '');
}


function setThumbSize(image)
{
    var td = image.parentNode.parentNode;
    var height = parseInt(image.style.height);
    var width = parseInt(image.style.width);
    var max_height = g_max_height;
    var max_width = g_max_width;

    td.width = max_width + 10;

    if( image.getAttribute('title') != 'Editing' )
    {
        if( height > max_height || width > max_width )
        {
            td.setAttribute('title', 'Resized');
            td.style.backgroundColor = '#FAFAD2';

            if( height > width )
            {
                image.style.height = max_height;
                image.style.width  = width*(max_height/height);
            }
            
            if( width > max_width )
            {
                image.style.width  = max_width;
                image.style.height = height*(max_width/width);
            }
        }
        else
        {
            td.setAttribute('title', '')
            td.style.backgroundColor = '#FFFFFF';
        }
    }
}


function hasChanged(id)
{
    if( !document.form.Changed.value )
    {
        document.form.Changed.value = id;
    }
    else
    {
        var temp = ',' + document.form.Changed.value + ',';
        var re   = new RegExp(',' + id + ',');

        if( !temp.match(re) )
        {
            document.form.Changed.value += ',' + id;
        }
    }
}


function setAll(item, id)
{
    if( item == 'Icons' )
    {
        id = g_icon_id;
    }

    var key   = id + '_' + item;
    var form  = document.form;
    var value = document.all ? form.namedItem(key).value : form.elements[key].value;
    var re    = new RegExp('([0-9]+)_' + item);
    var found = null;

    for( var i = 0; i < form.elements.length; i++ )
    {
        if( found = form.elements[i].name.match(re) )
        {
            form.elements[i].value = value;

            hasChanged(found[1]);
        }
    }

    return false;
}


function checkForm(form)
{
    if( form.Run.value == 'ProcessGalleries' && !form.Changed.value )
    {
        alert('No Changes Have Been Made!');
        return false;
    }

    return true;
}


function showSelect(input, type, gallery_id)
{
    var select = document.getElementById(type);

    if( g_input )
    {
        g_input.style.visibility = 'visible';
        g_input = null;
    }

    for( var i = 0; i < select.length; i++ )
    {
        if( select.options[i].value == input.value )
        {
            select.selectedIndex = i;
            break;
        }
    }

    select.style.top = getTop(input);
    select.style.left = getLeft(input);
    select.style.width = input.style.width;
    select.style.visibility = 'visible';

    input.style.visibility = 'hidden';

    input.blur();
    select.focus();

    g_input = input;
    g_gallery_id = gallery_id;
}


function changeSelectField(select, field_id)
{
    g_input.value = select.options[select.selectedIndex].value;

    select.style.visibility  = 'hidden';
    g_input.style.visibility = 'visible';

    hasChanged(g_gallery_id);

    select.blur();
    g_input.blur();
    
    if( document.all )
    {
        document.body.focus();
    }

    return false;
}


function closeSelect(select)
{
    select.style.visibility  = 'hidden';   

    if( g_input )
    {
        g_input.style.visibility = 'visible';
    }

    select.blur();
    g_input.blur();

    if( document.all )
    {
        document.body.focus();
    }

    return false;
}


function changeFormat(id, field)
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

    hasChanged(id);
}


function changeType(id, field)
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

    hasChanged(id);
}



function selectAll(form)
{
    var value = null;

    if( form.Select_All.value == 'Select All' )
    {
        form.Select_All.value = 'Deselect All';
        value = true;   
    }
    else
    {
        form.Select_All.value = 'Select All';
        value = false;
    }


    for( var i = 0; i < form.elements.length; i++ )
    {
        if( form.elements[i].type == 'checkbox' && form.elements[i].name == 'Gallery_ID' )
        {
            form.elements[i].checked = value;
        }
    }
}



function applyCommand(command)
{
    var form = document.xml;
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
    request.addArg('POST', 'Gallery_ID', g_selected_image);
    request.addArg('POST', 'Command', command);

    request.onload = filterResponse;
    request.onfail = filterError;

    request.getURL(g_xml_url);
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
        var prev = document.getElementById('prev_'+g_selected_image);
        var floater = document.getElementById('floater');
        var src = prev.getAttribute('src');

        src = src.replace(/\?.*/, '');

        prev.setAttribute('title', 'Editing');
        prev.setAttribute('src', src + '?' + Math.random());
        floater.setAttribute('src', src + '?' + Math.random());

        if( type == 'Level' )
        {
            if( parseInt(result) > 0 )
            {
                document.getElementById('undo').disabled = false;
                document.getElementById('save').disabled = false;
                document.getElementById('reset').disabled = false;
            }
            else
            {
                document.getElementById('undo').disabled = true;
                document.getElementById('save').disabled = true;
                document.getElementById('reset').disabled = true;
            }
        }
        else if( type == 'Done' )
        {
            setTimeout('closeImageFilters()', 10);
            setTimeout('doneEditing("prev_' + g_selected_image + '")', 3000);
        }
        else if( type == 'Error' )
        {
            alert("Error: " + result);
        }
        else if( type == 'ErrorClose' )
        {
            alert("Error: " + result);
            setTimeout('closeImageFilters()', 10);
            setTimeout('doneEditing("prev_' + g_selected_image + '")', 3000);
        }
    }
    else
    {
        alert("Error: " + data);
    }
}


function expand(field, size)
{
    var top = getTop(field);
    var left = getLeft(field);
    var current_y = window.scrollY;

    field.style.top = top;
    field.style.left = left;
    field.style.position = 'absolute';
    
    field.setAttribute('size', size);

    if( !document.all )
    {
        window.scrollTo(0, current_y);
    }
}


function shrink(field, size)
{
    field.setAttribute('size', size);
    field.style.position = 'static';
}

</script>