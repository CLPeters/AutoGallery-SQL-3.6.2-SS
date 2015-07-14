<html>
<head>
<script language="JavaScript">

function checkForm(form)
{
    var values = new Array(
                            'Document Root',
                            'Thumbnail URL',
                            'Sendmail/SMTP',
                            'E-mail Address',
                            'Download Speed',
                            'External Links',
                            'Minimum Description Length',
                            'Maximum Description Length',
                            'Global Submissions',
                            'Submissions Per Person',
                            'Submitted Gallery Hold Period',
                            'Permanent Gallery Hold Period',
                            'Date Format',
                            'Time Format'
                          );

    var keys   = new Array(
                           'DOCUMENT_ROOT',
                           'THUMB_URL',
                           'SENDMAIL',
                           'ADMIN_EMAIL',
                           'SPEED',
                           'LINKS',
                           'MIN_LENGTH',
                           'MAX_LENGTH',
                           'MAX_SUBMISSIONS',
                           'MAX_PERSON',
                           'HOLD_PERIOD',
                           'PERM_HOLD_PERIOD',
                           'DATE_FORMAT',
                           'TIME_FORMAT'
                          );


    for( i = 0; i < keys.length; i++ )
    {
        if( !form.elements[keys[i]].value )
        {
            alert('The ' + values[i] + ' field must be filled in');
            return false;
        }
    }
}



function setDefaults(form)
{
    var i       = 0;
    var domain  = document.domain;
    var tcase   = '##TEXT_CASE##';
    var tzone   = '##TIME_ZONE##';
    var tnmatch = '##THUMB_NO_MATCH##';
    var status  = '##SUBMIT_STATUS##';

    var values = new Array(
                             '##DOCUMENT_ROOT##',
                             'http://' + domain + '/tgp/thumbs',
                             '5',
                             '10',
                             '100',
                             '100',
                             '10240',
                             '75',
                             '10',
                             '75',
                             '-1',                             
                             '3',
                             '14',
                             '7',
                             '%c-%e-%y',
                             '%l:%i%p',
                             '4',
                             '6'
                          );

    var keys   = new Array(  
                             'DOCUMENT_ROOT',
                             'THUMB_URL',
                             'SPEED',
                             'LINKS',
                             'THUMB_WIDTH',
                             'THUMB_HEIGHT',
                             'THUMB_SIZE',
                             'THUMB_QUALITY',
                             'MIN_LENGTH',
                             'MAX_LENGTH',
                             'MAX_SUBMISSIONS',
                             'MAX_PERSON',
                             'HOLD_PERIOD',
                             'PERM_HOLD_PERIOD',
                             'DATE_FORMAT',
                             'TIME_FORMAT',
                             'MIN_CODE_LENGTH',
                             'MAX_CODE_LENGTH'
                          );

    var check  = new Array(##Checked##);


    for( i = 0; i < keys.length; i++ )
    {
        if( form.elements[keys[i]] && !form.elements[keys[i]].value )
        {
            form.elements[keys[i]].value = values[i];
        }
    }


    if( check[0] )
    {
        for( i = 0; i < check.length; i++ )
        {
            if( form.elements[check[i]] )
            {
                form.elements[check[i]].checked = true;
            }
        }
    }


    // Set selected state of text case select
    for( i = 0; i < form.TEXT_CASE.options.length; i++ )
    {
        if( form.TEXT_CASE.options[i].value == tcase )
        {
            form.TEXT_CASE.options[i].selected = true;
            break;
        }
    }


    // Set selected state of timezone select
    for( i = 0; i < form.TIME_ZONE.options.length; i++ )
    {
        if( form.TIME_ZONE.options[i].value == tzone )
        {
            form.TIME_ZONE.options[i].selected = true;
            break;
        }
    }


    // Set selected state of thumb no match select
    for( i = 0; i < form.THUMB_NO_MATCH.options.length; i++ )
    {
        if( form.THUMB_NO_MATCH.options[i].value == tnmatch )
        {
            form.THUMB_NO_MATCH.options[i].selected = true;
            break;
        }
    }


    // Set selected state of submit status select
    for( i = 0; i < form.SUBMIT_STATUS.options.length; i++ )
    {
        if( form.SUBMIT_STATUS.options[i].value == status )
        {
            form.SUBMIT_STATUS.options[i].selected = true;
            break;
        }
    }
}



function editDocRoot()
{
    document.form.DOCUMENT_ROOT.removeAttribute('readOnly');
    document.form.DOCUMENT_ROOT.style.backgroundColor = '';
    document.form.DOCUMENT_ROOT.style.color = '';
    expand('Doc_Root_Warning');

    document.getElementById("editdocroot").style.visibility = 'hidden';  

    return false;
}


function changeThumbSource(select)
{
    if( select.options[select.selectedIndex].value == 'Upload' )
    {
        show('upload');
    }
    else
    {
        hide('Thumb_No_Match_Help');
        hide('upload');
    }
}



function expand(id)
{
    var item  = document.getElementById(id);

    if( item.style.visibility == 'hidden' )
    {
        item.style.position   = 'relative';
        item.style.visibility = 'visible';
        
    }
    else
    {
        item.style.visibility = 'hidden';
        item.style.position   = 'absolute';
    }

    return false;
}



function showCropperWarning(cb)
{
    if( cb.checked )
    {
        alert("WARNING!!\r\n" +
              "Only check this box if you have installed the TGP Cropper\r\n" +
              "program on your Windows based computer.  If you have not\r\n" +
              "installed TGP Cropper, uncheck this option so that you will\r\n" +
              "be able to access the software's web-based cropping interface."
             );
    }
}

function showDocRootWarning()
{
    alert("WARNING!!\r\n" +
          "In most cases you do not need to change this setting.  If you\r\n" +
          "do need to change this setting, make sure it points to the base\r\n" +
          "directory of your website and not a sub-directory."); 
}

</script>
<!--[Include File ./templates/admin.css]-->
<!--[Include File ./templates/admin.js]-->
</head>
<body class="mainbody" onLoad="setDefaults(document.form);">


<noscript>
This software requires a JavaScript enabled browser.  Please update
your browser to a more recent version that supports JavaScript.  If
you have a modern browser, make sure JavaScript is enabled.
<div style="visibility: hidden;">
</noscript>

<!--[If Start NO_ACCESS_LIST]-->
<div class="errormessage">
You have not yet setup an access list, which will add increased security to your<br />
control panel.  Please review the 'Setting up an Access List' section of the software<br />
manual and setup your access list as soon as possible to enhance your security.
</div>
<br />
<!--[If End]-->

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->


<form name="form" action="main.cgi" target="main" method="POST" onSubmit="return checkForm(this)">

<!-- SECTION SEP -->
<div class="menuhead" align="center" style="width: 700px;">
URLs & Files<br />
</div>
<div class="menubox" style="width: 700px;">

<!-- Document Root -->
<b>Document Root:</b><br />
<input type="text" name="DOCUMENT_ROOT" value="##DOCUMENT_ROOT##" onChange="removeTrailingSlash(this)" size="70" style="background-color: #ececec; color: #afafaf;" readonly> 
<a href="" onClick="return expand('Doc_Root_Help');">[?]</a> <a href="" onClick="return editDocRoot();" id="editdocroot">[Edit]</a><br />
<div id="Doc_Root_Warning" class="popup" style="position: absolute; visibility: hidden; color: #FF0000; font-weight: bold">
WARNING!!<br />
In most cases you do not need to change this setting.  If you<br />
do need to change this setting, make sure it points to the base<br />
directory of your website and not a sub-directory.
</div>
<div id="Doc_Root_Help" class="popup" style="position: absolute; visibility: hidden;">
The base directory on your server where you place your HTML files.<br />
<b>Example:</b> /home/username/public_html<br />
</div>

<br />

<!-- Thumb URL -->
<b>Thumbnail URL:</b><br />
<input type="text" name="THUMB_URL" value="##THUMB_URL##" onChange="removeTrailingSlash(this)" size="70"> 
<a href="" onClick="return expand('Thumb_URL_Help');">[?]</a><br />
<div id="Thumb_URL_Help" class="popup" style="position: absolute; visibility: hidden;">
The URL where you want your thumbnail preview images to be stored.<br />
<b>Example:</b> http://www.yoursite.com/tgp/thumbs<br />
</div>

</div>


<!-- SECTION SEP -->
<div class="menuhead" align="center" style="width: 700px;">
E-mail Options<br />
</div>
<div class="menubox" style="width: 700px;">

<!-- Sendmail/SMTP -->
<b>Sendmail Path or SMTP Server:</b><br />
<input type="text" name="SENDMAIL" value="##SENDMAIL##" size="30"> 
<a href="" onClick="return expand('Sendmail_Help');">[?]</a><br />
<div id="Sendmail_Help" class="popup" style="position: absolute; visibility: hidden;">
The full path to sendmail or the hostname/IP of your SMTP server.<br />
<b>Example:</b> /usr/sbin/sendmail<br />
</div>

<br />

<!-- E-mail Address -->
<b>Your E-mail Address:</b><br />
<input type="text" name="ADMIN_EMAIL" value="##ADMIN_EMAIL##" size="30"> 
<a href="" onClick="return expand('Admin_Email_Help');">[?]</a><br />
<div id="Admin_Email_Help" class="popup" style="position: absolute; visibility: hidden;">
This e-mail address will appear in the from field of all e-mails sent by AutoGallery SQL.<br />
<b>Example:</b> tgp@yoursite.com<br />
</div>

<br />

<input type="checkbox" name="O_CONFIRM_EMAIL" value="1"> <b>General gallery submissions must be confirmed through e-mail?</b>
<a href="" onClick="return expand('Confirmmail_Help');">[?]</a><br />
<div id="Confirmmail_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will send an e-mail to the submitter each time a gallery is submitted.<br />
The e-mail will contain instructions on how to confirm their gallery submission.<br />
This option helps to ensure that submitters are using valid e-mail addresses.
</div>

<input type="checkbox" name="O_CONFIRM_CLICK" value="1"> <b>Allow confirmation e-mail to contain a clickable confirmation link?</b>
<a href="" onClick="return expand('Confirmclick_Help');">[?]</a><br />
<div id="Confirmclick_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will allow the confirmation e-mail that is sent to have a clickable<br />
confirmation link instead of requiring the submitter to enter their submission code on a web-based form.
</div>

<input type="checkbox" name="O_PROCESS_EMAIL" value="1"> <b>Send e-mail to submitter when their gallery has been processed?</b>
<a href="" onClick="return expand('Processmail_Help');">[?]</a><br />
<div id="Processmail_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will send an e-mail to the gallery's submitter when it is approved or rejected.<br />
</div>
</div>



<!-- SECTION SEP -->
<div class="menuhead" align="center" style="width: 700px;">
Gallery Scanner<br />
</div>
<div class="menubox" style="width: 700px;">

<input type="checkbox" name="O_COUNT_THUMBS" value="1"> <b>Have the gallery scanner's thumbnail count override the submitted thumbnail count?</b>
<a href="" onClick="return expand('Count_Help');">[?]</a><br />
<div id="Count_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will count the number of thumbnails on the gallery and<br />
use that value instead of the value provided by the gallery submitter.<br />
</div>

<input type="checkbox" name="O_NEED_RECIP" value="1"> <b>Reject the gallery if there is no reciprocal link?</b>
<a href="" onClick="return expand('Norecip_Help');">[?]</a><br />
<div id="Norecip_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check the gallery to see if it has a link to your site<br />
and reject the gallery if it does not.<br />
</div>

<input type="checkbox" name="O_BOOST_RATING" value="1"> <b>Automatically increase the weight for galleries that have a reciprocal link?</b>
<a href="" onClick="return expand('Rate_Help');">[?]</a><br />
<div id="Rate_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check the gallery to see if it has a link to your site<br />
and add one point to it's weight if it does.<br />
</div>

<input type="checkbox" name="O_CHECK_PAGEID" value="1"> <b>Reject the gallery if it is using the same HTML as an existing gallery?</b>
<a href="" onClick="return expand('Pageid_Help');">[?]</a><br />
<div id="Pageid_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check to make sure that the submitted gallery is not using<br />
the same HTML as any other gallery in your database.<br />
</div>

<input type="checkbox" name="O_CHECK_SPEED" value="1"> <b>Reject the gallery if it does not meet the minimum download speed?</b>
<a href="" onClick="return expand('Speed_Help');">[?]</a><br />
<div id="Speed_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check the download speed of the gallery page<br />
and reject the gallery if it does not meet the minimum speed you have specified.<br />
</div>

<input type="checkbox" name="O_CHECK_SIZE" value="1"> <b>Reject the gallery if it's content does not meet the minimum size requirements?</b>
<a href="" onClick="return expand('Size_Help');">[?]</a><br />
<div id="Size_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check the file size of the gallery content<br />
and reject the gallery if it does not meet the minimum file size you have specified.<br />
</div>

<input type="checkbox" name="O_CHECK_LINKS" value="1"> <b>Reject the gallery if it exceeds the maximum external link count?</b>
<a href="" onClick="return expand('Links_Help');">[?]</a><br />
<div id="Links_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will count the number of external links on the gallery<br />
and reject the gallery if it exceeds the maximum link count you have specified.<br />
</div>

<input type="checkbox" name="O_CHECK_2257" value="1"> <b>Reject the gallery if it does not have 2257 information?</b>
<a href="" onClick="return expand('2257_Help');">[?]</a><br />
<div id="2257_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check to see if the gallery has 2257<br />
information on the gallery page and reject the gallery if it does not.<br />
</div>

<input type="checkbox" name="O_TRANSPARENT" value="1"> <b>Have the blacklist be transparent to the gallery submitter?</b>
<a href="" onClick="return expand('Transparent_Help');">[?]</a><br />
<div id="Transparent_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check the gallery for any blacklisted items.<br />
If any blacklisted items are found, the gallery will be rejected. However, to the gallery<br />
submitter it will appear that their submission has gone through.
</div>

<br />

<b>Download Speed Requirement:</b><br />
<input type="text" name="SPEED" value="##SPEED##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Speed_Req_Help');">[?]</a><br />
<div id="Speed_Req_Help" class="popup" style="position: absolute; visibility: hidden;">
The minimum download speed, in kilobytes per second.<br />
<b>Example:</b> 5<br />
</div>

<br />

<b>External Links Requirement:</b><br />
<input type="text" name="LINKS" value="##LINKS##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Links_Req_Help');">[?]</a><br />
<div id="Links_Req_Help" class="popup" style="position: absolute; visibility: hidden;">
The maximum number of external links allowed on the gallery page.<br />
<b>Example:</b> 10<br />
</div>

</div>



<!-- SECTION SEP -->
<div class="menuhead" align="center" style="width: 700px;">
Thumbnail Preview Options<br />
</div>
<div class="menubox" style="width: 700px;">

<!--[If Start Code {!$HAVE_MAGICK}]-->
<div style="padding-left: 10px;">
<span style="font-weight: bold; color: red;">
ImageMagick is not available on this server.<br />
</span>
You will be unable to use the thumbnail resizing and cropping features.
</div>
<br />
<!--[If End]-->


<input type="checkbox" name="O_ALLOW_THUMB" value="1"> <b>Allow submitters to provide a thumbnail preview with their gallery?</b>
<a href="" onClick="return expand('Allow_Help');">[?]</a><br />
<div id="Allow_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will allow submitters to provide a thumbnail preview image with their gallery.
</div>

<input type="checkbox" name="O_PARTNER_THUMB" value="1"> <b>Only allow partners to submit a preview thumbnail with their gallery?</b>
<a href="" onClick="return expand('Partner_Thumb_Help');">[?]</a><br />
<div id="Partner_Thumb_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will only allow partners to submit a thumbnail preview image with their gallery.
</div>

<input type="checkbox" name="O_NEED_THUMB" value="1"> <b>All submissions must include a thumbnail?</b>
<a href="" onClick="return expand('Thumb_Help');">[?]</a><br />
<div id="Thumb_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will reject any galleries for which a thumbnail is not provided.
</div>

<!--[If Start Code {$HAVE_MAGICK}]-->
<input type="checkbox" name="O_SELECT_THUMB" value="1"> <b>Automatically select a thumbnail if one is not provided by the submitter?</b>
<a href="" onClick="return expand('Select_Help');">[?]</a><br />
<div id="Select_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will automatically select a thumbnail from the submitter's gallery.
</div>
<!--[If End]-->

<input type="checkbox" name="O_FORCE_DIMS" value="1"> <b>Require that all thumbs be exactly the height and width entered below?</b>
<a href="" onClick="return expand('Force_Help');">[?]</a><br />
<div id="Force_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check the thumbnail dimensions to make sure they match<br />
the dimensions you have provided.  If they do not, the gallery will be rejected.
</div>

<input type="checkbox" name="O_TGP_CROPPER" value="1" onClick="showCropperWarning(this)"> <b>Use TGP Cropper as the thumbnail cropping tool for control panel users?</b>
<a href="" onClick="return expand('TGP_Cropper_Help');">[?]</a><br />
<div id="TGP_Cropper_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will use TGP Cropper as the thumbnail cropping tool instead<br />
of it's web-based cropping interface.
</div>

<br />

<b>Default Thumbnail Width:</b><br />
<input type="text" name="THUMB_WIDTH" value="##THUMB_WIDTH##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Thumb_Width_Help');">[?]</a><br />
<div id="Thumb_Width_Help" class="popup" style="position: absolute; visibility: hidden;">
The default width of preview thumbnails, in pixels.<br />
All thumbnails submitted by outside webmasters will be this width.<br />
<b>Example:</b> 100<br />
</div>

<br />

<b>Default Thumbnail Height:</b><br />
<input type="text" name="THUMB_HEIGHT" value="##THUMB_HEIGHT##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Thumb_Height_Help');">[?]</a><br />
<div id="Thumb_Height_Help" class="popup" style="position: absolute; visibility: hidden;">
The default height of preview thumbnails, in pixels.<br />
All thumbnails submitted by outside webmasters will be this height.<br />
<b>Example:</b> 100<br />
</div>

<br />

<b>Maximum Thumbnail File Size:</b><br />
<input type="text" name="THUMB_SIZE" value="##THUMB_SIZE##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Thumb_Size_Help');">[?]</a><br />
<div id="Thumb_Size_Help" class="popup" style="position: absolute; visibility: hidden;">
The maximum allowed file size of uploaded preview thumbnails, in bytes.<br />
<b>Example:</b> 10240<br />
</div>


<br />

<b>If Thumbnail Exceeds Dimensions:</b><br />
<select name="THUMB_NO_MATCH">
  <option value="Reject">Reject Gallery</option>
<!--[If Start Code {$HAVE_MAGICK}]-->
  <option value="AutoCrop">Automatically Crop</option>
  <option value="ManualCrop">Manually Crop</option>
<!--[If End]-->
</select>
<a href="" onClick="return expand('Thumb_No_Match_Help');">[?]</a><br />
<div id="Thumb_No_Match_Help" class="popup" style="position: absolute; visibility: hidden;">
Reject Gallery: The gallery will be rejected.<br />
<!--[If Start Code {$HAVE_MAGICK}]-->
Automatically Crop: Have the software automatically crop and resize the thumbnail<br />
Manually Crop: Have the gallery submitter crop the thumbnail through a web-based interface
<!--[If End]-->
</div>

<!--[If Start Code {$HAVE_MAGICK}]-->
<br />

<b>Thumbnail Quality:</b><br />
<input type="text" name="THUMB_QUALITY" value="##THUMB_QUALITY##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Thumb_Quality_Help');">[?]</a><br />
<div id="Thumb_Quality_Help" class="popup" style="position: absolute; visibility: hidden;">
If the thumbnail is cropped or resized, this will be the quality<br />
of the resulting thumbnail. The number should range from 1 to 100, with higher<br />
numbers corresponding to better quality but larger filesize thumbnails.<br />
<b>Example:</b> 75<br />
</div>

<!--[If End]-->

</div>


<!-- SECTION SEP -->
<div class="menuhead" align="center" style="width: 700px;">
Other Options<br />
</div>
<div class="menubox" style="width: 700px;">
<!--[If Start Code {$HAVE_GD}]-->
<input type="checkbox" name="O_GEN_STRING" value="1"> <b>Require general submitters to enter a submit code for gallery submission?</b>
<a href="" onClick="return expand('Gen_String_Help');">[?]</a><br />
<div id="Gen_String_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will require that any general submitters copy<br />
a string from an image into a form input field in order to submit
</div>

<input type="checkbox" name="O_TRUST_STRING" value="1"> <b>Require partners to enter a submit code for gallery submission?</b>
<a href="" onClick="return expand('Trust_String_Help');">[?]</a><br />
<div id="Trust_String_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will require that any partners copy<br />
a string from an image into a form input field in order to submit
</div>

<input type="checkbox" name="O_USE_WORDS" value="1"> <b>Use dictionary words for the submit code instead of random characters?</b>
<a href="" onClick="return expand('Use_Words_Help');">[?]</a><br />
<div id="Use_Words_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will use words from a file you supply<br />
as the submit code instead of randomly generated characters
</div>
<!--[If Else]-->
<div style="padding-left: 10px;">
<span style="font-weight: bold; color: red;">
The GD module is not available on this server.<br />
</span>
You will be unable to use the submit code feature of the software.
</div>
<br />
<!--[If End]-->

<input type="checkbox" name="O_REQ_HOST" value="1"> <b>Partner account requests must include hosting company?</b>
<a href="" onClick="return expand('Req_Host_Help');">[?]</a><br />
<div id="Req_Host_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will require all partner account<br />
requests to include the hosting company they use to host their galleries
</div>

<input type="checkbox" name="O_REQ_PROVIDER" value="1"> <b>Partner account requests must include main content provider?</b>
<a href="" onClick="return expand('Req_Provider_Help');">[?]</a><br />
<div id="Req_Provider_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will require all partner account<br />
requests to include the content provider that supplies them with images<br />
and movies for their galleries
</div>

<input type="checkbox" name="O_NO_RESET_ON_ROTATE" value="1"> <b>Do not reset click counts and counters on permanent galleries when rotated from holding?</b>
<a href="" onClick="return expand('Ror_Help');">[?]</a><br />
<div id="Ror_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will not reset the click count, used counter, and build counter for
permanent galleries when they are rotated from the holding queue to the approved queue.
</div>

<input type="checkbox" name="O_CHECK_DUPS" value="1"> <b>Make sure no duplicate gallery URLs are submitted?</b>
<a href="" onClick="return expand('Dups_Help');">[?]</a><br />
<div id="Dups_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check to make sure that the same<br />
gallery URL does not appear in the database twice.
</div>

<input type="checkbox" name="O_PREFIX" value="1"> <b>Prefix single digit thumbnail count values with a zero?</b>
<a href="" onClick="return expand('Prefix_Help');">[?]</a><br />
<div id="Prefix_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will display the gallery's thumbnail count<br />
with a zero in front of it if it is a single digit number.
</div>

<input type="checkbox" name="O_NEED_DESC" value="1"> <b>Submitters must provide a text description of their gallery?</b>
<a href="" onClick="return expand('Description_Help');">[?]</a><br />
<div id="Description_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check to make sure that a gallery description<br />
has been provided by the gallery submitter.
</div>

<input type="checkbox" name="O_NEED_NAME" value="1"> <b>Submitters must provide their name/nickname?</b>
<a href="" onClick="return expand('Name_Help');">[?]</a><br />
<div id="Name_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will check to make sure that a name or nickname<br />
has been provided by the gallery submitter.
</div>

<input type="checkbox" name="O_ALLOW_KEYWORDS" value="1"> <b>Submitters are allowed to submit keywords with their galleries?</b>
<a href="" onClick="return expand('Keywords_Help');">[?]</a><br />
<div id="Keywords_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will allow submitters to include a list of keywords<br />
with their gallery submissions.
</div>

<input type="checkbox" name="O_EMAIL_LOG" value="1"> <b>Keep a log of all e-mail addresses used for submissions?</b>
<a href="" onClick="return expand('Log_Help');">[?]</a><br />
<div id="Log_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will keep a log of all e-mail addresses<br />
used during gallery submissions.
</div>

<input type="checkbox" name="O_AUTO_APPROVE" value="1"> <b>Automatically approve galleries after being scanned and confirmed?</b>
<a href="" onClick="return expand('Auto_Help');">[?]</a><br />
<div id="Auto_Help" class="popup" style="position: absolute; visibility: hidden; margin-left: 25px;">
If this box is checked, AutoGallery SQL will automatically approve galleries once they<br />
have been submitted.  You will not have a chance to review them before they are approved.
</div>

<br />

<b>Submit Code Length Range:</b><br />
<input type="text" name="MIN_CODE_LENGTH" value="##MIN_CODE_LENGTH##" onChange="fixNumber(this)" size="5"> 
to
<input type="text" name="MAX_CODE_LENGTH" value="##MAX_CODE_LENGTH##" onChange="fixNumber(this)" size="5">
<a href="" onClick="return expand('Code_Length_Help');">[?]</a><br />
<div id="Code_Length_Help" class="popup" style="position: absolute; visibility: hidden;">
A range that limits the number of characters in the submit codes.<br />
The first box is the minimum number of characters that a submit code can have.<br />
The second box is the maximum number of characters that a submit code can have.<br />
This will only be used if you are not using the dictionary word option.<br />
<b>Example:</b> 4 to 6<br />
</div>

<br />

<b>Description Text Case:</b><br />
<select name="TEXT_CASE">
  <option value="NoChange">No Change</option>
  <option value="FirstUpper">First letter upper case</option>
  <option value="WordsUpper">First letter of each word upper case</option>
  <option value="AllUpper">All letters upper case</option>
  <option value="AllLower">All letters lower case</option>
</select>
<a href="" onClick="return expand('Text_Case_Help');">[?]</a><br />
<div id="Text_Case_Help" class="popup" style="position: absolute; visibility: hidden;">
When a gallery is submitted with a text description, this option will determine<br />
how the description is displayed.
</div>

<br />

<b>Minimum Description Length:</b><br />
<input type="text" name="MIN_LENGTH" value="##MIN_LENGTH##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Min_Help');">[?]</a><br />
<div id="Min_Help" class="popup" style="position: absolute; visibility: hidden;">
The minimum number of characters allowed on in the gallery's text description.<br />
<b>Example:</b> 10<br />
</div>

<br />

<b>Maximum Description Length:</b><br />
<input type="text" name="MAX_LENGTH" value="##MAX_LENGTH##" onChange="fixNumber(this)" size="30"> 
<a href="" onClick="return expand('Desc_Help');">[?]</a><br />
<div id="Desc_Help" class="popup" style="position: absolute; visibility: hidden;">
The maximum number of characters allowed on in the gallery's text description.<br />
<b>Example:</b> 75<br />
</div>

<br />

<b>Submission Status:</b><br />
<select name="SUBMIT_STATUS">
  <option value="All">Open To All</option>
  <option value="Password">Open Only To Partners</option>
  <option value="0">Closed To All</option>
</select>
<a href="" onClick="return expand('Submit_Status_Help');">[?]</a><br />
<div id="Submit_Status_Help" class="popup" style="position: absolute; visibility: hidden;">
All: The submission form can be used by anyone.<br />
Passwords: The submission form can only be used by webmasters with passwords.<br />
Closed: The submission form is closed.  No galleries can be submitted.
</div>

<br />

<b>Global Submissions Per Day:</b><br />
<input type="text" name="MAX_SUBMISSIONS" value="##MAX_SUBMISSIONS##" size="30">
<a href="" onClick="return expand('Max_Submit_Help');">[?]</a><br />
<div id="Max_Submit_Help" class="popup" style="position: absolute; visibility: hidden;">
The global limit on the number of galleries that can be submitted each day.<br />
Once this number has been reached, gallery submissions will be disabled until the next day.<br />
If you do not want to place a limit on the number of submissions, enter -1 in this field.<br />
<b>Example:</b> 300<br />
</div>

<br />

<b>Submissions Per Person:</b><br />
<input type="text" name="MAX_PERSON" value="##MAX_PERSON##" size="30">
<a href="" onClick="return expand('Max_Person_Help');">[?]</a><br />
<div id="Max_Person_Help" class="popup" style="position: absolute; visibility: hidden;">
The maximum number of galleries that a general submitter can submit per day.<br />
If you do not want to place a limit on the number of submissions per person, enter -1 in this field.<br />
<b>Example:</b> 3<br />
</div>

<br />

<b>Submitted Holding Period:</b><br />
<input type="text" name="HOLD_PERIOD" value="##HOLD_PERIOD##" size="30">
<a href="" onClick="return expand('Hold_Period_Help');">[?]</a><br />
<div id="Hold_Period_Help" class="popup" style="position: absolute; visibility: hidden;">
The number of days that a submitted gallery should be held in the database after it is no<br />
longer being displayed on one of your pages.  Once this time has elapsed, the gallery will<br />
be permanently deleted from the database.<br />
<b>Example:</b> 14<br />
</div>

<br />

<b>Permanent Holding Period:</b><br />
<input type="text" name="PERM_HOLD_PERIOD" value="##PERM_HOLD_PERIOD##" size="30">
<a href="" onClick="return expand('Perm_Hold_Period_Help');">[?]</a><br />
<div id="Perm_Hold_Period_Help" class="popup" style="position: absolute; visibility: hidden;">
The number of days that a permanent gallery should be held in the database after it is no<br />
longer being displayed on one of your pages.  Once this time has elapsed, the gallery will<br />
be rotated back into the pool of available galleries.<br />
<b>Example:</b> 7<br />
</div>

<br />

<b>Date Format:</b><br />
<input type="text" name="DATE_FORMAT" value="##DATE_FORMAT##" size="30">
<a href="" onClick="return expand('Date_Format_Help');">[?]</a><br />
<div id="Date_Format_Help" class="popup" style="position: absolute; visibility: hidden;">
The format string to specify how you want your dates to appear.<br />
<b>Example:</b> %c-%e-%y<br />
</div>

<br />

<b>Time Format:</b><br />
<input type="text" name="TIME_FORMAT" value="##TIME_FORMAT##" size="30">
<a href="" onClick="return expand('Time_Format_Help');">[?]</a><br />
<div id="Time_Format_Help" class="popup" style="position: absolute; visibility: hidden;">
The format string to specify how you want your times to appear.<br />
<b>Example:</b> %l:%i%p<br />
</div>

<br />

<b>Time Zone:</b><br />
<select name="TIME_ZONE">
  <option value="-12">GMT - 12 Hours</option>
  <option value="-11">GMT - 11 Hours</option>
  <option value="-10">GMT - 10 Hours</option>
  <option value="-9">GMT - 9 Hours</option>
  <option value="-8">GMT - 8 Hours</option>
  <option value="-7">GMT - 7 Hours</option>
  <option value="-6">GMT - 6 Hours</option>
  <option value="-5">GMT - 5 Hours</option>
  <option value="-4">GMT - 4 Hours</option>
  <option value="-3.5">GMT - 3.5 Hours</option>
  <option value="-3">GMT - 3 Hours</option>
  <option value="-2">GMT - 2 Hours</option>
  <option value="-1">GMT - 1 Hours</option>
  <option value="0" selected="selected">GMT</option>
  <option value="1">GMT + 1 Hour</option>
  <option value="2">GMT + 2 Hours</option>
  <option value="3">GMT + 3 Hours</option>
  <option value="3.5">GMT + 3.5 Hours</option>
  <option value="4">GMT + 4 Hours</option>
  <option value="4.5">GMT + 4.5 Hours</option>
  <option value="5">GMT + 5 Hours</option>
  <option value="5.5">GMT + 5.5 Hours</option>
  <option value="6">GMT + 6 Hours</option>
  <option value="6.5">GMT + 6.5 Hours</option>
  <option value="7">GMT + 7 Hours</option>
  <option value="8">GMT + 8 Hours</option>
  <option value="9">GMT + 9 Hours</option>
  <option value="9.5">GMT + 9.5 Hours</option>
  <option value="10">GMT + 10 Hours</option>
  <option value="11">GMT + 11 Hours</option>
  <option value="12">GMT + 12 Hours</option>
</select>
<a href="" onClick="return expand('Time_Zone_Help');">[?]</a><br />
<div id="Time_Zone_Help" class="popup" style="position: absolute; visibility: hidden;">
Select the timezone you are located in.
</div>

</div>


<br />


<div align="center" class="menubox" style="width: 700px; border-top-width: 1px;">
<input type="hidden" name="Run" value="SaveOptions">
<input type="submit" value="Save Options">
</div>

</form>

<br />
<br />

<noscript>
</div>
</noscript>

</body>
</html>