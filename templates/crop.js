<script language="JavaScript">

// Mouse
var mouse           = new Object();
    mouse.click_x   = 0;
    mouse.click_y   = 0;
    mouse.down_box  = false;
    mouse.down_main = false;


// Document Elements
var table_mask      = null;
var table_box       = null;
var img_main        = null;
var div_main        = null;
var img_preview     = null;
var div_preview     = null;
var div_thumbs      = null;
var div_prog        = null;
var div_bar         = null;
var div_wait        = null;
var iframe          = null;


// Other variables
var test_thumb      = null;
var hotlink         = true;
var timer           = 0;
var complete_thumbs = new Array();



function initializeDocument()
{
    // Get the document elements
    iframe      = document.getElementById('iframe');
    table_mask  = document.getElementById('table_mask');
    table_box   = document.getElementById('table_box');
    div_main    = document.getElementById('div_main');
    div_preview = document.getElementById('div_preview');
    div_thumbs  = document.getElementById('div_thumbs');
    div_prog    = document.getElementById('div_prog');
    div_bar     = document.getElementById('div_bar');
    div_wait    = document.getElementById('div_wait');


    // Setup the preview div
    div_preview.style.height = thumb.height;
    div_preview.style.width  = thumb.width;


    // Setup the selection box cursor
    table_box.style.cursor = 'move';


    // Setup events
    document.onselectstart = selectStart;
    document.onmouseup     = mouseUp;
    window.onresize        = handleResize;


    // Cropping from an uploaded image
    if( thumbs.length == 0 )
    {
        changeImage(image_url);
    }


    // Cropping from the gallery images
    else
    {
        test_thumb     = new Image();
        test_thumb.src = thumbs[0].split('|').pop();

        checkThumb();
    }
}



function selectStart(e)
{
    if( event )
    {
        event.cancelBubble = true;
    }

    return false;
}



function checkThumb()
{
    if( timer > 2000 )
    {
        hotlink = false;
        loadThumbs();
        return;
    }

    if( test_thumb.complete )
    {
        if( test_thumb.height == 0 )
        {
            hotlink = false;
        }

        loadThumbs();
    }
    else
    {
        timer += 100;
        setTimeout('checkThumb()', 100);
    }
}



function loadThumbs()
{
    for( var i = 0; i < thumbs.length; i++ )
    {
        var urls = thumbs[i].split('|');
        var src  = hotlink ? urls[1] : thumb_ns + "?image=" + urls[1] + "&gallery=" + gallery_url;
       
        complete_thumbs[i] = false;

        thumbs_html += '<img src="' + src + '" name="thumbs_' + i + '" class="thumb" onError="thumbError(\'' + i + '\')" onClick="newImage(\'' + urls[0] + '\')" border="0">';
    }

    div_thumbs.innerHTML = thumbs_html;

    resizeThumbs();
}



function resizeThumbs()
{
    if( !thumbsLoaded() )
    {
        updateProgress();
        setTimeout('resizeThumbs()', 100);
        return;
    }

    for( var i = 0; i < thumbs.length; i++ )
    {
        var current = document.images['thumbs_' + i];

        current.style.height = smallest;
        current.style.width  = current.width / (parseInt(current.style.height)/smallest);
    }

    // Hide the loading message
    div_wait.style.position   = 'absolute';
    div_wait.style.visibility = 'hidden';

    if( smallest > 1000 || smallest < 50 )
    {
        smallest = 125;
    }

    // Show the thumbs
    div_thumbs.style.height     = smallest;
    div_thumbs.style.position   = 'static';
    div_thumbs.style.visibility = 'visible';
}



function updateProgress()
{
    var complete = 0;
    var percent  = 0;
    var fill     = 0;

    for( var i = 0; i < thumbs.length; i++ )
    {
        if( document.images['thumbs_' + i].complete )
        {
             complete++;
        }
    }

    percent = complete/thumbs.length;

    div_bar.style.width = parseInt(percent * 100) + '%';
}



function thumbError(id)
{
    complete_thumbs[id] = true;
}



function thumbsLoaded()
{
    for( var i = 0; i < thumbs.length; i++ )
    {
        if( document.images['thumbs_' + i].complete )
        {
            if( document.images['thumbs_' + i].height < smallest && document.images['thumbs_' + i].height > 0 )
            {
                smallest = document.images['thumbs_' + i].height;
            }
        }
        else if( complete_thumbs[i] )
        {
            continue;
        }
        else
        {
            return false;
        }
    }

    return true;
}



function newImage(url)
{
    table_box.style.visibility = 'hidden';
    div_main.innerHTML         = 'Loading New Image...Please Wait';
    div_preview.innerHTML      = '';

    iframe.src = thumb_ns + "?image=" + url  + "&gallery=" + gallery_url + "&id=" + document.form.Image_Name.value;
}



function updateImage()
{
    if( table_box )
    {
        changeImage(thumb_url + '/' + document.form.Image_Name.value + '?' + Math.random());
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



function initializeBox()
{
    table_box.style.top    = 0;
    table_box.style.left   = 0;
    table_box.style.width  = 5;
    table_box.style.height = 5;
    table_box.style.cursor = 'move';
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



function fillForm()
{
    document.form.x.value      = parseInt(table_box.style.left) - img_main.left;
    document.form.y.value      = parseInt(table_box.style.top) - img_main.top;
    document.form.width.value  = parseInt(table_box.style.width);
    document.form.height.value = parseInt(table_box.style.height);

    document.form.submit();
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
        table_mask.fireEvent('onmousemove', e)
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

</script>
<style>
td { font-family: Verdana; font-size: 11px; }
div { font-family: Verdana; font-size: 11px; }
form { padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; }
a { text-decoration: none; color: #00008B; }
a:hover { text-decoration: none; color: Red; border-bottom: 1px solid #000000; }
.thumb { cursor: pointer; }
.div_preview { width: 0px; height: 0px; overflow: hidden; border: 1px solid black; }
.img_preview { position: relative; left: 0px; top: 0px; }
.table_box { visibility: hidden; border: 2px solid red; position: absolute; z-index: 2; }
.table_mask { position: absolute; z-index: 1; }
.div_prog { width: 200px; height: 30px; border: 1px solid black; }
.div_bar { background-color: blue; width: 0px; height: 30px; }
.div_thumbs { width: 90%; height: 0px; overflow: auto; position: absolute; visibility: hidden; }
</style>