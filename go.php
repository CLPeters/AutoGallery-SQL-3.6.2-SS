<?PHP

// These settings must match the database settings used for AutoGallery SQL

$USERNAME = 'username';          // The username to access your MySQL database
$PASSWORD = 'password';          // The password to access your MySQL database
$DATABASE = 'database';          // The name of your MySQL database
$HOSTNAME = 'localhost';         // The hostname of your MySQL database server



// Would you like to use the IP log to track unique clicks?
// Change this to TRUE if you want to use the IP log
$USE_IPLOG = FALSE;


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
    $value      = NULL;
    $cookie_set = FALSE;
    $ip_logged  = FALSE;

    if( $USE_COOKIES && isset($_COOKIE['autogallery_sql']) )
    {
        $ids = explode(',', $_COOKIE['autogallery_sql']);

        if( in_array($_GET['ID'], $ids) )
        {
            $cookie_set = TRUE;
        }
        else
        {
            $ids[] = $_GET['ID'];
            $value = join(',', $ids);
        }
    }
    else
    {
        $value = $_GET['ID'];
    }

    
    if( !$cookie_set )
    {
        mysql_connect($HOSTNAME, $USERNAME, $PASSWORD);
        mysql_select_db($DATABASE);
        $safe_id = mysql_real_escape_string($_GET['ID']);
        $safe_ip = mysql_real_escape_string($_SERVER['REMOTE_ADDR']);

        if( $USE_IPLOG )
        {
            $result = mysql_query("SELECT COUNT(*) FROM ags_Addresses WHERE Gallery_ID='$safe_id' AND IP_Address='$safe_ip'");
            $row = mysql_fetch_row($result);

            if( $row[0] > 0 )
            {
                $ip_logged = TRUE;
            }
        }

        if( !$ip_logged )
        {
            mysql_query("UPDATE ags_Galleries SET Clicks=Clicks+1 WHERE Gallery_ID='$safe_id'");

            if( $USE_IPLOG )
            {
                mysql_query("INSERT INTO ags_Addresses VALUES ('$safe_id', '$safe_ip', " . time() . ")");
            }
        }

        if( $USE_COOKIES )
        {
            setcookie('autogallery_sql', $value, time()+$EXPIRE, '/');
        }
        
        mysql_close();
    }
}


header("Location: $TEMPLATE");

?>