<script language="JavaScript">

// Mouse
var mouse = new Object();
mouse.click_x = 0;
mouse.click_y = 0;
mouse.down_box = false;
mouse.down_main = false;


// Document Elements
var table_mask = null;
var table_box = null;
var img_main = null;
var div_main = null;
var img_preview = null;
var div_preview = null;
var div_thumbs = null;
var div_prog = null;
var div_bar = null;
var div_wait = null;
var div_error = null;
var text_prog = null;

// Other variables
var start_date = null;
var end_date = null;
var last_thumbs = null;
var timeout = 30000;
var poll_interval_repeat = 1500;
var poll_interval_start = 500;
var global_height = 150;
var progress_step = 0;
var final_thumb = null;
var gallery_url = null;
var thumbs = null;
var scan_complete = false;
var full_complete = false;
var thumbs_complete = false;
var total_thumbs_loaded = 0;
var animate_interval = 175;


function initializeDocument()
{
    // Get the document elements
    table_mask = document.getElementById('table_mask');
    table_box = document.getElementById('table_box');
    div_main = document.getElementById('div_main');
    div_preview = document.getElementById('div_preview');
    div_thumbs = document.getElementById('div_thumbs');
    div_prog = document.getElementById('div_prog');
    div_bar = document.getElementById('div_bar');
    div_wait = document.getElementById('div_wait');
    div_error = document.getElementById('div_error');
    text_prog = document.getElementById('text_prog');


    // Center div_wait
    if( document.all )
    {
        div_wait.style.left = parseInt((document.body.clientWidth/2) - 150);
    }
    else
    {
        div_wait.style.left = parseInt((window.outerWidth/2) - 150);
    }

    div_wait.style.top = getTop(div_thumbs) + 20;     

    // Setup the preview div
    div_preview.style.height = thumb.height;
    div_preview.style.width = thumb.width;


    // Setup the selection box cursor
    table_box.style.cursor = 'move';


    // Setup events
    document.onselectstart = selectStart;
    document.onmouseup = mouseUp;
    window.onresize = handleResize;

    beginScanGallery();
}


/*=============================================================================================
Scan gallery functions
*/

function beginScanGallery()
{
    var request = new DataRequestor();

    request.addArg('POST', 'Gallery_ID', gallery_id);

    request.onload = scanResponse;
    request.onfail = scanError;

    request.getURL(async_script_url);

    setTimeout('animateScanGallery()', animate_interval);
}


function scanResponse(data)
{
    var response_data = data.split("\n");

    thumbs = new Array();

    if( response_data[0] != 'Error' )
    {
        gallery_url = response_data[0];

        for( var i = 1; i < response_data.length; i++ )
        {
            thumbs.push(response_data[i]);
        }

        progress_step = parseInt(300/thumbs.length);
        text_prog.innerHTML = '\\ Loading Thumbnails [0%] \\';
        beginLoadThumbs();
    }
    else
    {
        hideWait(true);
        generalError(response_data[1]);
    }

    scan_complete = true;
}


function scanError(status)
{
    generalError('scanError(): ' + status);
    scan_complete = true;
}


function animateScanGallery()
{
    if( !scan_complete )
    {
        text_prog.innerHTML = updateProgAnimation(text_prog.innerHTML);

        setTimeout('animateScanGallery()', animate_interval);
    }
}


/*=============================================================================================
Load preview thumbnails functions
*/

// Start the process of loading the thumbnails
function beginLoadThumbs()
{
    var request = new DataRequestor();

    request.addArg('POST', 'Gallery_URL', gallery_url);
    request.addArg('POST', 'Prefix', prefix);

    for( var i in thumbs )
    {
        request.addArg('POST', 'Thumbs', thumbs[i]);
    }

    request.onload = downloadResponse;
    request.onfail = downloadError;

    start_date = new Date();
    last_thumbs = 0;

    request.getURL(async_script_url);

    setTimeout('animateLoadThumbs()', animate_interval);
}


// Thumbnail loading process has started, begin the polling process
function downloadResponse(data)
{
    setTimeout('pollThumbnails()', poll_interval_start);
}


// Thumbnail loading process error
function downloadError(status)
{
    generalError('downloadError(): ' + status);
}


function animateLoadThumbs()
{
    if( !thumbs_complete )
    {
        text_prog.innerHTML = updateProgAnimation(text_prog.innerHTML);        
        setTimeout('animateLoadThumbs()', animate_interval);
    }
}


// Poll to see how many thumbs are available, and display new thumbs
function pollThumbnails()
{
    var request = new DataRequestor();

    request.addArg('GET', 'Poll', Math.random());

    request.onload = pollResponse;
    request.onfail = pollError;

    request.getURL(thumb_cache_url + '/' + prefix + '.txt');
}


// Handle each response from the poll process
function pollResponse(data)
{
    var poll_data = data.split("\n");
    var total_thumbs = parseInt(poll_data[0]);
    var loaded_thumbs = poll_data.length - 2;

    // New thumbs available
    if( loaded_thumbs > last_thumbs )
    {
        for( var i = last_thumbs + 1; i <= loaded_thumbs; i++ )
        {
            var thumb_data = poll_data[i].split('|');

            if( thumb_data[1] == '1' )
            {
                var img = document.createElement('img');
                var rand = Math.random();

                img.style.visibility = 'hidden';
                img.src = thumb_data[0] + (thumb_data[4] == '0' ? '?' + rand : '');
                img.className = 'thumb'
                img.id = thumb_data[2];
                img.setAttribute('title', 'thumb');
                img.setAttribute('alt', thumb_data[3]);
                img.onclick = loadFullImage;
                img.onload = thumbLoaded;
                img.onerror = thumbError;
                
                div_thumbs.appendChild(img);

                if( i == total_thumbs )
                {                    
                    final_thumb = thumb_data[2];
                }

                total_thumbs_loaded++;
            }
        }

        last_thumbs = loaded_thumbs;
    }

    end_date = new Date();

    // Poll again unless this is the last thumb
    if( loaded_thumbs < total_thumbs && (end_date - start_date) < timeout )
    {
        setTimeout('pollThumbnails()', poll_interval_repeat);
    }

    if( (end_date - start_date) >= timeout )
    {
        if( total_thumbs_loaded < 1 )
        {
            generalError('Remote thumbnails could not be downloaded, most likely due to internet traffic congestion.  Please try again later');
            hideWait(true);
        }
        else
        {
            hideWait(false);
        }

        thumbs_complete = true;
    }
}


// Handle error in polling process
function pollError(status)
{
    generalError('pollError(): ' + status);
}


function resizeThumbs()
{
    var all_images = document.getElementsByTagName('img');

    for( var i = 0; i < all_images.length; i++ )
    {
        if( all_images[i].getAttribute('title') == 'thumb' )
        {
            all_images[i].height = global_height;
        }
    }

    div_thumbs.style.height = global_height;
}


function progressStep()
{
    var new_width;
    var percent;

    if( div_bar.style.width )
    {
        new_width = progress_step + parseInt(div_bar.style.width);
    }
    else
    {
        new_width = progress_step;
    }

    div_bar.style.width = new_width;
    percent = parseInt((new_width/300) * 100);

    text_prog.innerHTML = text_prog.innerHTML.replace(/\[(\d+)%\]/, '[' + percent + '%]');
}


// Event called when there has been an error loading a thumbnail
function thumbError()
{
    // Remove the broken image from the list
    this.parentNode.removeChild(this);

    if( this.id == final_thumb )
    {
        hideWait(false);
        thumbs_complete = true;
    }
}


// Event called when a thumbnail has been successully loaded
function thumbLoaded()
{
    var loaded_thumb = this;

    if( loaded_thumb.height < global_height )
    {
        global_height = loaded_thumb.height;
        resizeThumbs();
    }
    else
    {
        loaded_thumb.height = global_height;
    }

    loaded_thumb.style.visibility = 'visible';

    progressStep();

    if( loaded_thumb.id == final_thumb )
    {
        hideWait(false);
        thumbs_complete = true;
    }
}




/*=============================================================================================
Load new full sized image for cropping functions
*/

function loadFullImage()
{
    table_box.style.visibility = 'hidden';
    div_main.innerHTML = '\\ Loading New Image...Please Wait \\';
    div_preview.innerHTML = '';

    var full_image_url = this.getAttribute('alt');
    var request = new DataRequestor();

    request.addArg('POST', 'Gallery_URL', gallery_url);
    request.addArg('POST', 'Full', full_image_url);
    request.addArg('POST', 'Prefix', prefix);

    request.onload = loadFullResponse;
    request.onfail = loadFullError;

    request.getURL(async_script_url);

    full_complete = false;
    setTimeout('animateLoadImage()', animate_interval);
}



function loadFullResponse(data)
{
    var results = data.split('|');

    if( results[0] == 'Success' )
    {
        full_complete = true;
        updateImage(results[1]);
        document.form.Image_Name.value = results[2];
    }
    else
    {
        div_main.innerHTML = 'Image could not be loaded: ' + results[1];
    }
}



function loadFullError(status)
{
    generalError('loadFullError(): ' + status);
}



function animateLoadImage()
{
    if( !full_complete )
    {
        div_main.innerHTML = updateProgAnimation(div_main.innerHTML);
        setTimeout('animateLoadImage()', animate_interval);
    }
}


function updateImage(image_url)
{
    if( table_box )
    {
        changeImage(image_url + '?' + Math.random());
    }
}



function changeImage(source)
{
    // Hide the box
    table_box.style.visibility = 'hidden';

    // Load the new image
    div_main.innerHTML    = '<img id="img_main" src="' + source + '" onError="imageError()" onLoad="imageLoaded()" border="0">';
    div_preview.innerHTML = '<img id="img_preview" src="' + source + '" onError="previewError()" onLoad="previewLoaded()" class="img_preview">';
}



function previewLoaded()
{
    img_preview = document.getElementById('img_preview');
}



function previewError()
{
    div_preview.innerHTML = '';
}



function imageError()
{
    div_main.innerHTML = 'Image could not be loaded, please try again';
}



function imageLoaded()
{
    img_main = document.getElementById('img_main');

    // Get the image position on the page
    img_main.top  = getTop(img_main);
    img_main.left = getLeft(img_main);


    // Place the mask over the image
    table_mask.style.top    = img_main.top;
    table_mask.style.left   = img_main.left;
    table_mask.style.width  = img_main.width;
    table_mask.style.height = img_main.height;


    // Initialize the box
    initializeBox();
}



/*=============================================================================================
Selection of cropping area functions
*/

function selectStart(e)
{
    if( event )
    {
        event.cancelBubble = true;
    }

    return false;
}



function initializeBox()
{
    table_box.style.top    = 0;
    table_box.style.left   = 0;
    table_box.style.width  = 5;
    table_box.style.height = 5;
    table_box.style.cursor = 'move';
}



function setThumbSize()
{
    if( !img_main )
    {
        alert('An image must be loaded before you can set the thumbnail size');
        return;
    }

    if( parseInt(document.form.thumb_width.value) > img_main.width )
    {
        alert('Thumbnail preview width is too large');
        return;
    }

    if( parseInt(document.form.thumb_height.value) > img_main.height )
    {
        alert('Thumbnail preview height is too large');
        return;
    }

    thumb.height = parseInt(document.form.thumb_height.value);
    thumb.width  = parseInt(document.form.thumb_width.value);
    thumb.prop   = thumb.height/thumb.width;

    div_preview.style.height = document.form.thumb_height.value;
    div_preview.style.width  = document.form.thumb_width.value;

    handleResize();

    resizeBox(thumb.width, thumb.height);
}



function moveBox(x, y)
{
    // Adjust x position
    if( x < img_main.left )
    {
        x = img_main.left;
    }
    else if( x + parseInt(table_box.style.width) - img_main.left > img_main.width )
    {
        x = img_main.width - parseInt(table_box.style.width) + img_main.left;
    }


    // Adjust y position
    if( y < img_main.top )
    {
        y = img_main.top;
    }
    else if( y + parseInt(table_box.style.height) - img_main.top > img_main.height )
    {
        y = img_main.height - parseInt(table_box.style.height) + img_main.top;
    }

    table_box.style.left = parseInt(x);
    table_box.style.top  = parseInt(y);

    img_preview.style.top  = (-y + img_main.top)  * (thumb.height/parseInt(table_box.style.height));
    img_preview.style.left = (-x + img_main.left) * (thumb.width/parseInt(table_box.style.width));
}



function resizeBox(width, height)
{
    if( height < 5 || width < 5 )
    {
        return;
    }


    if( height/width != thumb.prop )
    {
        width = height/thumb.prop;
    }


    if( (parseInt(table_box.style.top) - img_main.top) + height <= img_main.height && (parseInt(table_box.style.left) - img_main.left) + width <= img_main.width )
    {
        table_box.style.height   = height;
        table_box.style.width    = width;
        img_preview.style.height = img_main.height * (thumb.height/parseInt(table_box.style.height));
        img_preview.style.width  = img_main.width * (thumb.width/parseInt(table_box.style.width));
    }

    moveBox(parseInt(table_box.style.left), parseInt(table_box.style.top));
}



function handleResize()
{
    if( img_main )
    {
        // Get the image position on the page
        img_main.top  = getTop(img_main);
        img_main.left = getLeft(img_main);


        // Place the mask over the image
        table_mask.style.top    = img_main.top;
        table_mask.style.left   = img_main.left;
        table_mask.style.width  = img_main.width;
        table_mask.style.height = img_main.height;
    }
}



function mouseUp()
{
    mouse.down_main = false;
    mouse.down_box  = false;

    table_box.style.cursor = 'move';
}



function mouseDownMain(e)
{
    if( !img_preview.complete || !img_main.complete )
    {
        alert('Please wait for the image to load completely');
        return;
    }


    if( !mouse.down_main )
    {
        handleResize();

        mouse.down_main = true;
        mouse.click_x   = e.pageX ? e.pageX : e.offsetX + img_main.left;
        mouse.click_y   = e.pageY ? e.pageY : e.offsetY + img_main.top;
      
        resizeBox(5, 5);
        moveBox(mouse.click_x, mouse.click_y);

        table_box.style.visibility = 'visible';
        table_box.style.cursor     = 'default';
    }
}



function mouseMoveMain(e)
{
    if( mouse.down_main )
    {
        var new_x = e.pageX ? e.pageX : e.offsetX + img_main.left;
        var new_y = e.pageY ? e.pageY : e.offsetY + img_main.top;

        if( new_x > mouse.click_x && new_y > mouse.click_y )
        {
            resizeBox(new_x - mouse.click_x, new_y - mouse.click_y);
        }
    }
}



function mouseDownBox(e)
{
    mouse.down_box = true;
    mouse.click_x  = e.pageX ? e.pageX : e.x;
    mouse.click_y  = e.pageY ? e.pageY : e.y;

    mouse.click_x -= parseInt(table_box.style.left);
    mouse.click_y -= parseInt(table_box.style.top);
}



function mouseMoveBox(e)
{
    if( mouse.down_main )
    {
        if( table_mask.fireEvent )
        {
            table_mask.fireEvent('onmousemove', e);
        }
    }
    else if( mouse.down_box )
    {
        var new_x = e.pageX ? e.pageX : e.x;
        var new_y = e.pageY ? e.pageY : e.y;

        new_x -= mouse.click_x;
        new_y -= mouse.click_y;

        moveBox(new_x, new_y);
    }
}



/*=============================================================================================
Misc functions
*/


function updateProgAnimation(input_string)
{
    var prog_char = getNextProgChar(input_string.charAt(0));    

    return input_string.replace(/[\\|\/-]/g, prog_char);
}


function getNextProgChar(input_char)
{
    var prog_char = '|';

    switch(input_char)
    {
        case '\\':
            prog_char = '|';
            break;
        case '|':
            prog_char = '/';
            break;
        case '/':
            prog_char = '-';
            break;
        case '-':
            prog_char = '\\';
            break;
    }

    return prog_char;
}


function hideWait(hide_thumbs)
{
    div_wait.style.visibility = 'hidden';
    div_wait.style.position = 'absolute';

    if( hide_thumbs )
    {
        div_thumbs.style.height = 0;
    }
}


function generalError(message)
{
    div_error.innerHTML = message;
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


function fillForm()
{
    document.form.x.value      = parseInt(table_box.style.left) - img_main.left;
    document.form.y.value      = parseInt(table_box.style.top) - img_main.top;
    document.form.width.value  = parseInt(table_box.style.width);
    document.form.height.value = parseInt(table_box.style.height);

    document.form.submit();
}

</script>
<style>
td { font-family: Verdana; font-size: 11px; }
div { font-family: Verdana; font-size: 11px; }
form { padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; }
a { text-decoration: none; color: #00008B; }
a:hover { text-decoration: none; color: Red; border-bottom: 1px solid #000000; }
.thumb { cursor: pointer; visibility: hidden; }
.div_preview { width: 0px; height: 0px; overflow: hidden; border: 1px solid black; }
.img_preview { position: relative; left: 0px; top: 0px; }
.table_box { visibility: hidden; border: 2px solid red; position: absolute; z-index: 2; }
.table_mask { position: absolute; z-index: 1; }
.div_prog { width: 300px; height: 20px; border: 1px solid #333333; background-color: #EEEEEE; }
.div_bar { background-color: #3CDA3F; width: 0px; height: 20px; } 
.div_thumbs { width: 90%; height: 150px; overflow: auto; }
.div_wait { position: absolute; filter: alpha(opacity: 70); -moz-opacity: 0.70; opacity: 0.70; }
.text_prog { position: absolute; text-align: center; width: 300px; top: 4px; }
.div_error { color: #FF0000; font-weight: bold; }
</style>
