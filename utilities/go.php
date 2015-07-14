<?PHP
// http://www.jmbsoft.com/license.php


// Enter the full path to the data directory of your AutoGallery SQL installation
$DDIR = '/home/soft/cgi-bin/ags/data';


// Would you like to use the IP log to track unique clicks?
// Change this to FALSE if you do not want to use the IP log
$USE_IPLOG = TRUE;


// Would you like to use cookies to track unique clicks?
// Change this to FALSE if you do not want to use cookies
$USE_COOKIES = TRUE;


// The length of time (in seconds) before this script's cookie expires
// Cookies are used to track unique clicks
$EXPIRE = 86400;


// The template for your traffic trading script URL
// If you are not using a traffic trading script, do not change this value
$TEMPLATE = '##Gallery_URL##';


// If your traffic trading script supports encoded URLs set this value to TRUE.
// This will allow you to send traffic to URLs that contain query strings without a problem.
// If you are not using a traffic trading script, do not change this value
$ENCODE = FALSE;


###########################################################################################################
##              DONE EDITING THIS FILE.  YOU DO NOT NEED TO EDIT THIS FILE ANY FURTHER                   ##
###########################################################################################################

if( $ENCODE )
{
    $_GET['URL'] = urlencode($_GET['URL']);
}

$TEMPLATE = str_replace('##Skim##', $_GET['P'], $TEMPLATE);
$TEMPLATE = str_replace('##Gallery_URL##', $_GET['URL'], $TEMPLATE);

foreach( $_GET as $key => $value )
{
    $TEMPLATE = str_replace("##$key##", $value, $TEMPLATE);
}


if( $_GET['ID'] )
{
    $value = $_GET['ID'];
    $cookie_set = FALSE;    

    if( $USE_COOKIES && isset($_COOKIE['autogallery_sql']) )
    {
        if( strstr(",{$_COOKIE['autogallery_sql']},", ",{$_GET['ID']},") )
        {
            $cookie_set = TRUE;
        }
        else
        {
            $value = "{$_COOKIE['autogallery_sql']},{$_GET['ID']}";
        }
    }

    if( !$USE_IPLOG )
    {
        $_SERVER['REMOTE_ADDR'] = '';
    }

    if( !$cookie_set )
    {
        $fd = fopen("$DDIR/clicklog", 'a');
        flock($fd, LOCK_EX);
        fwrite($fd, "{$_GET['ID']}|{$_SERVER['REMOTE_ADDR']}\n");
        flock($fd, LOCK_UN);
        fclose($fd);

        if( $USE_COOKIES )
        {
            setcookie('autogallery_sql', $value, time() + $EXPIRE, '/');
        }
    }    
}


header("Location: $TEMPLATE");

?>
