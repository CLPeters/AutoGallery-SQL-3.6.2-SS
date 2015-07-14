<script language="JavaScript">

function updateButton(id, disabled, text)
{
    var element = document.getElementById(id);
    element.value = text;
    element.disabled = disabled;
}


function checkForError(data)
{
    var result;

    if( result = data.match(/<span id="Error">\s*(.*?)\s*<\/span>/mi) )
    {
        alert('Error: ' + result[1]);
    }
    else
    {
        alert('Error: ' + data);
    }
}


// Hide a DOM element
function show(id)
{
    var item  = document.getElementById(id);

    if( item.style.visibility == 'hidden' )
    {
        item.style.position   = 'static';
        item.style.visibility = 'visible';
        
    }

    return false;
}



// Show a previously hidden DOM element
function hide(id)
{
    var item  = document.getElementById(id);

    if( item && item.style.visibility == 'visible' )
    {
        item.style.visibility = 'hidden';
        item.style.position   = 'absolute';
    }

    return false;
}



// Set the function to be executed on a form
function setRun(value)
{
    document.form.Run.value = value;
}



// Display a popup window
function popupWindow(url, height, width, user_confirm)
{
    var top = 300;
    var left = 300;

    if( top + height > window.screen.height )
    {
        top = 100
    }

    if( left + width > window.screen.width )
    {
        left = 100;
    }

    if( (user_confirm && confirm('Are you sure you want to do this?')) || !user_confirm )
    {
        window.open(url, '_blank', 'menubar=no,height='+height+',width='+width+',scrollbars=yes,top='+top+',left='+left+',resizable=yes');
    }

    return false;
}



// Fix number fields
function fixNumber(item)
{
    item.value = item.value.replace(/[^0-9\-\.]/gi, '');    
}



// Fix comma separated data fields
function fixCommas(item)
{
    item.value = item.value.replace(/\s*,\s*/g, ',');
    item.value = item.value.replace(/^\s*|\s*$/g, '');
    item.value = item.value.replace(/^,*|,*$/g, '');
    item.value = item.value.replace(/,+/g, ',');
}



// Fix one per line fields
function fixPerLine(item)
{
    if( item.value.match(/\r\n/) )
    {
        var strings = item.value.split("\r\n");

        item.value = '';

        for( var i = 0; i < strings.length; i++ )
        {
            if( strings[i] != '' )
            {
                strings[i] = strings[i].replace(/^\s+|\s+$/, '');

                item.value += strings[i] + "\r\n";
            }
        }
        
        item.value = item.value.replace(/(\r\n)+$/g, '');
    }
    else if( item.value.match(/[^\r]\n/) )
    {
        item.value = item.value.replace(/\n\n+/g, "\n");

        RegExp.multiline = true;
        item.value = item.value.replace(/^\s+|\s+$/g, '');
    }
}



// Remove trailing slash from a string
function removeTrailingSlash(item)
{
    item.value = item.value.replace(/\/+$/, '');
}



// Remove all period characters from a string
function removePeriod(item)
{
    item.value = item.value.replace(/\./, '');
}



// Remove all non alphanumeric values from an identifier
function fixID(field)
{
    field.value = field.value.replace(/[^0-9A-Z_]/gi, '');
}


function getLeft(obj)
{
	var curleft = 0;

    while(obj.offsetParent)
    {
        curleft += obj.offsetLeft;
        obj = obj.offsetParent;
    }

	return curleft;
}


function getTop(obj)
{
	var curtop = 0;

    while(obj.offsetParent)
    {
        curtop += obj.offsetTop;
        obj = obj.offsetParent;
    }

	return curtop;
}
</script>
