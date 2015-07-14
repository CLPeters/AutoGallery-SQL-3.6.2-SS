use Socket;
use Fcntl qw(:DEFAULT :flock);

$|++;

## Globals
$ADIR = './admin';
$DDIR = './data';
$TDIR = './templates';
$CRLF = "\r\n";
$CR = "\r";
$LF = "\n";
$DEL = '|';
$HEADER = 1;
$TIME = time;
$MYSQL_DATE = undef;
$MYSQL_TIME = undef;
$ERROR_LOG  = 0;
$CGI_INPUT = undef;
$NO_ACCESS_LIST = 0;
%T = ();
%F = ();

## Load variables, if they exist
if( -e "$DDIR/variables" )
{
    require "$DDIR/variables";

    $TIME += 3600 * $TIME_ZONE;
}

## Setup MySQL compatible date and time values
$MYSQL_TIME = Date('%H:%i:%s', $TIME);
$MYSQL_DATE = Date('%Y-%m-%d', $TIME);

1;

## Print HTTP header
sub Header
{
    if( !$HEADER && $ENV{'REQUEST_METHOD'} )
    {
        print shift;
        $HEADER = 1;
    }
}

## Output data for Ajax requests
sub OutputAjax
{
    print join('|', @_);
}

## Determine if a string contains nothing but whitespace
sub IsEmptyString
{
    my $string = shift;

    if( $string =~ /^\s*$/s )
    {
        return 1;
    }

    return 0;
}

## Remove leading and trailing whitespace from all strings in an arry
sub TrimArray
{
    my $array = shift;

    for( @$array )
    {
        $_ =~ s/^\s+//gi;
        $_ =~ s/\s+$//gi;
    }
}

## Remove leading and trailing whitespace from a string
sub Trim
{
    my $string = shift;

    $$string =~ s/^\s+//gi;
    $$string =~ s/\s+$//gi;
}

## Shorten a string to a specific length
sub TrimString
{
    my $string = shift;
    my $length = shift;

    if( length($string) > $length )
    {
        $string = substr($string, 0, $length);

        Trim(\$string);

        $string = "$string...";
    }

    return $string;
}

## Generate a random password
sub RandomPassword
{
    my @letters = ('a','b','c','d','e','f','g','h','j','k','m','n','p','q','r','s','t','u','v','w','x','y','z');
    my @numbers = ('2','3','4','5','6','8','9');
    my @password_chars = ();
    my $num_letters = 6;
    my $num_numbers = 2;
    my $i;

    ## Select random letters
    for( 1..$num_letters )
    {
        if( int(rand(2)) )
        {
            push(@password_chars, uc($letters[rand @letters]));
        }
        else
        {
            push(@password_chars, $letters[rand @letters]);
        }
    }

    ## Select random numbers
    for( 1..$num_numbers )
    {
        push(@password_chars, $numbers[rand @numbers]);    
    }

    ## Randomize the selected characters
    for( $i = @password_chars; --$i; )
    {
        my $j = int(rand($i+1));
        next if( $i == $j );
        @password_chars[$i,$j] = @password_chars[$j,$i]
    }

    return join('', @password_chars);
}

## Set permissions on a file
sub Mode
{
    my $mode = shift;
    my $file = shift;

    if( -o $file )
    {
        chmod($mode, $file) || Error("$!", $file);
    }
}

## Locate an executable file on the server
sub LocateBinary
{
    my $bin = shift;

    @bin_directories = ('/bin', '/usr/bin', '/usr/local/bin', '/usr/local/mysql/bin', '/sbin', '/usr/sbin', '/usr/lib', '/usr/local/ImageMagick/bin', '/usr/X11R6/bin');

    for( @bin_directories )
    {
        if( -x "$_/$bin" )
        {
            return "$_/$bin";
        }
    }

    return undef;
}

## Get the base URL where the software is installed
sub GetScriptURL
{
    my $url = "http://$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'}";

    $url =~ s/\/admin\/.*//i;

    return $url;
}

## Get the base install directory
sub GetCwd
{
    my $cwd = `pwd`;

    if( IsEmptyString($cwd) )
    {
        $cwd = $ENV{'SCRIPT_FILENAME'};

        do
        {
            $cwd = LevelUpPath($cwd);
        }
        while( !IsEmptyString($cwd) && !-e "$cwd/common.pl" );
    }

    $cwd =~ s/\r|\n//gi;

    return $cwd;
}

## Go up one level on a directory path
sub LevelUpPath
{
    my $path  = shift;
    my $slash = rindex($path, '/');

    return substr($path, 0, $slash);
}

## Encode a URL
sub URLEncode
{
    my $url = shift;
    $url =~ s/([^\w\.\-])/sprintf("%s%x", '%', ord($1))/eg;
    return $url;
}

sub HashToTemplate
{
    my $hash = shift;

    for( keys %$hash )
    {
        StripHTML(\$hash->{$_});
        $T{$_} = $hash->{$_};
    }
}

sub InArray
{
    my $value = shift;
    my $array = shift;

    for( @$array )
    {
        return 1 if( $_ eq $value );
    }

    return 0;
}

## Add slashes to all values in a hash or array reference
sub AddSlashes
{
    my $hash = shift;

    if( ref($hash) eq 'HASH' )
    {
        for( keys %$hash )
        {
            $hash->{$_} =~ s/'/\\'/g;
        }
    }
    else
    {
        for( @$hash )
        {
            $_ =~ s/'/\\'/g;
        }
    }
}



## Remove slashes from all values in a hash or array reference
sub StripSlashes
{
    my $hash = shift;

    if( ref($hash) eq 'HASH' )
    {
        for( keys %$hash )
        {
            $hash->{$_} =~ s/\\//g;
        }
    }
    else
    {
        for( @$hash )
        {
            $_ =~ s/\\//g;
        }
    }
}



## Remove all non-alphanumeric characters from a string
sub PlainString
{
    my $string = shift;

    $string =~ s/[^a-z0-9]//gi;

    return lc($string);
}



## Check if the user's browser is supported
sub BadBrowser
{
    my $agent = $ENV{'HTTP_USER_AGENT'};

    return ($agent =~ /Opera/ || ($agent !~ /MSIE (6|7)\.\d/ && $agent !~ /Gecko/));
}



sub MakeBindList
{
    my $number = shift;
    my @qmarks = ();

    for( 1..$number )
    {
        push(@qmarks, '?');
    }

    return join(',', @qmarks);
}



sub MakeList
{
    my $string = shift;

    if( ref $string )
    {
        return "'" . join("','", @$string) . "'";
    }
    else
    {
        return "'" . join("','", split(/,/, $string)) . "'";
    }
}



## Convert an IP address to a hex value
sub IP2Hex
{
    return uc(join('', map(sprintf("%02x", $_), split(/\./, shift))));
}



## Convert a hex value to an IP address
sub Hex2IP
{
    return join('.', map(hex($_), shift =~ /(.{2})/g));
}



## Check if an encrypted password matches a submitted password
sub ValidPassword
{
    my $crypted = shift;
    my $pass = shift;
    my $salt = substr($crypted, 0, 2);

    $salt = substr($crypted, 3, 2) if( $crypted =~ /^\$/ );

    return crypt($pass, $salt) eq $crypted;
}



## Generate a random salt value for the crypt function
sub Salt
{
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9', '.', '/');
    return $chars[rand(@chars)] . $chars[rand(@chars)];
}



## Generate a random 32 character string
sub GenerateUniqueValue
{
    my @chars  = ('a'..'z', 'A'..'Z', '0'..'9');
    my $string = undef;

    for( 1..32 )
    {
        $string .= $chars[rand(@chars)];
    }

    return $string;
}



## Base 64 encode a buffer
sub Base64Encode
{
    my $buffer = undef;
    my $padding = undef;
    my $data = shift;
    my $eol = shift || $CRLF;

    while( $$data =~ /(.{1,45})/gs )
    {
	    $buffer .= substr(pack('u', $1), 1);
	    chop($buffer);
    }

    $buffer =~ tr|` -_|AA-Za-z0-9+/|;

    $padding = (3 - length($$data) % 3) % 3;

    $buffer =~ s/.{$padding}$/'=' x $padding/e if $padding;

    if( length($eol) )
    {
	    $buffer =~ s/(.{1,76})/$1$eol/g;
    }

    return $buffer;
}



## Base 64 decode a buffer
sub Base64Decode
{
    my $data = shift;
    my $buffer = undef;
    my $length = undef;

    $$data =~ tr|A-Za-z0-9+=/||cd;
    $$data =~ s/=+$//;
    $$data =~ tr|A-Za-z0-9+/| -_|;

    while( $$data =~ /(.{1,60})/gs )
    {
	    $length  = chr(32 + length($1)*3/4);
	    $buffer .= unpack("u", $length . $1 );
    }

    return $buffer;
}



## Get the filename from a directory path
sub BaseName
{
    my $filename = shift;

    if( index($filename, '/') == -1 )
    {
        return $filename;
    }
    else
    {
        return substr($filename, rindex($filename, '/') + 1);
    }
}



## Change the text case of a string
sub ChangeCase
{
    my $string = shift;
    my $case = shift || $TEXT_CASE;

    if( $case eq 'FirstUpper' )
    {
        $$string = ucfirst(lc($$string));
    }
    elsif( $case eq 'WordsUpper' )
    {
        $$string = ucfirst(lc($$string));

        $$string =~ s/\s(\w)/" " . uc($1)/gie;
    }
    elsif( $case eq 'AllUpper' )
    {
        $$string = uc($$string);
    }
    elsif( $case eq 'AllLower' )
    {
        $$string = lc($$string);
    }
}



## Convert text to Unix style end-of-line format
sub UnixFormat
{
    my $string = shift;

    $$string =~ s/$CRLF/$LF/g;
    $$string =~ s/$CR/$LF/g;
}



## Convert text to PC style end-of-line format
sub PCFormat
{
    my $string = shift;

    UnixFormat($string);

    $$string =~ s/$LF/$CRLF/g;
}



## Remove all carriage returns and newlines from a string
sub StripReturns
{
    my $string = shift;

    $$string =~ s/[$LF$CR]//g;
}



## Convert HTML characters into their HTML entities
sub StripHTMLHash
{
    my $hash = shift;

    for( keys %$hash )
    {
        $hash->{$_} =~ s/"/&quot;/g;
        $hash->{$_} =~ s/</&lt;/g;
        $hash->{$_} =~ s/>/&gt;/g;
    }
}



## Convert HTML characters into their HTML entities
sub StripHTML
{
    my $string = shift;

    $$string =~ s/"/&quot;/g;
    $$string =~ s/</&lt;/g;
    $$string =~ s/>/&gt;/g;
}


## Convert HTML characters into their HTML entities
sub StripHTMLAll
{
    my $string = shift;

    $string =~ s/&/&amp;/g;
    $string =~ s/"/&quot;/g;
    $string =~ s/</&lt;/g;
    $string =~ s/>/&gt;/g;

    return $string;
}



## Display an error message and exit
sub Error
{
    my $cause = shift;
    my $file = shift;
    my @user = getpwuid($<);
    my @group = getgrgid($));

    chomp($cause);

    if( $ERROR_LOG )
    {
        $ERROR_LOG = 0;
        FileAppend("$DDIR/error_log", scalar(localtime()) . "\n\tError: $cause\n\tFile: $file\n\n");
    }

    Header("Content-type: text/html\n\n");

    if( $ENV{'REQUEST_METHOD'} )
    {
        print <<"        HTML";
        <div align="center">
        <font face='Arial' size='2'>
        <h2>Critical Error</h2>
        </font>

        <table width="500" cellspacing="2">
        <tr>
        <td valign="top">
        <font face='Arial' size='2'>
        <b>Error</b><br />
        </font>
        </td>
        <td>
        <font face='Arial' size='2'>
        <span id="Error">
        $cause
        </span>
        <br />
        </font>
        </td>
        </tr>
        <tr>
        <td>
        <font face='Arial' size='2'>
        <b>File</b><br />
        </font>
        </td>
        <td>
        <font face='Arial' size='2'>
        $file<br />
        </font>
        </td>
        </tr>
        <tr>
        <td>
        <font face='Arial' size='2'>
        <b>As</b><br />
        </font>
        </td>
        <td>
        <font face='Arial' size='2'>
        $user[0]/$group[0]<br />
        </font>
        </td>
        </tr>
        </table>

        </div>
        HTML
    }
    else
    {
        print "\n\tError : $cause\n";
        print "\tFile  : $file\n\n";
    }


    exit;
}



sub AdminError
{
    my $error = shift;
    my $more = shift;
    my $lang = IniParse("$DDIR/language");

    if( $lang->{$error} )
    {
        $T{'Error'} = $lang->{$error} . ($lang->{$more} ? ": $lang->{$more}" : ($more ? ": $more" : ''));
    }
    else
    {
        $T{'Error'} = $error;
    }

    ParseTemplate('admin_error.tpl');

    exit;
}



##############################################################
##               File Manipulation Functions                ##
##############################################################


sub IsFile
{
    my $file = shift;

    if( !-e $file )
    {
        return 1;
    }
    else
    {
        return -f $file;
    }
}



sub FileCopy
{
    my $input = shift;
    my $output = shift;

    FileWrite($output, ${FileReadScalar($input)});
}



sub FileWrite
{
    my $file = shift;
    my $data = shift;

    FileTaint($file);

    if( !-e $file )
    {
        open(FILE, ">$file") || Error("$!", $file);
    }
    else
    {
        open(FILE, "+<$file") || Error("$!", $file);
    }

    flock(FILE, LOCK_EX);
    seek(FILE, 0, 0);
    print FILE $data;
    truncate(FILE, tell(FILE));
    flock(FILE, LOCK_UN);
    close(FILE);

    Mode(0666, $file);
}



sub FileWriteNew
{
    my $file = shift;
    my $data = shift;

    if( !-e $file )
    {
        FileWrite($file, $data);
    }
}



sub FileAppend
{
    my $file = shift;
    my $data = shift;

    FileTaint($file);

    open(FILE, ">>$file") || Error("$!", $file);
    flock(FILE, LOCK_EX);
    print FILE $data;
    flock(FILE, LOCK_UN);
    close(FILE);

    Mode(0666, $file);
}



sub FileRemove
{
    my $file = shift;

    FileTaint($file);

    unlink($file) || Error("$!", $file);
}



sub FileCreate
{
    my $file = shift;

    if( !-e $file )
    {
        FileWrite($file, '');
    }
}



sub FileReadScalar
{
    my $file = shift;
    my $line = undef;

    FileTaint($file);

    open(FILE, $file) || Error("$!", $file);
    flock(FILE, LOCK_SH);
    while( <FILE> )
    {
        $line .= $_;
    }
    flock(FILE, LOCK_UN);
    close(FILE);

    return \$line;
}



sub FileReadArray
{
    my $file = shift;

    FileTaint($file);

    open(FILE, $file) || Error("$!", $file);
    flock(FILE, LOCK_SH);
    my @lines = <FILE>;
    close(FILE);
    flock(FILE, LOCK_UN);

    return \@lines;
}



sub FileReadLine
{
    my $file = shift;

    FileTaint($file);

    open(FILE, $file) || Error("$!", $file);
    flock(FILE, LOCK_SH);
    my $line = <FILE>;
    close(FILE);
    flock(FILE, LOCK_UN);
    chomp($line);

    return $line;
}



sub FileReadSplit
{
    my $file = shift;

    my @data = split(/\|/, FileReadLine($file));

    return \@data;
}



sub FileWriteJoin
{
    my $file = shift;
    my @data = @_;

    FileWrite($file, join('|', @data));
}



sub FileTaint
{
    my $file = shift;

    Error('Not A File', $file) if( !IsFile($file) );
    Error('Security Violation', $file) if( index($file, '..') != -1 );
    Error('Security Violation', $file) if( index($file, '|') != -1 );
    Error('Security Violation', $file) if( index($file, ';') != -1 );
}



##############################################################
##            Directory Manipulation Functions              ##
##############################################################


sub IsDirectory
{
    my $dir = shift;

    if( !-e $dir )
    {
        return 1;
    }
    else
    {
        return -d $dir;
    }
}



sub DirCreate
{
    my $dir  = shift;
    my $mode = shift || 0777;

    DirTaint($dir);

    if( !-e $dir )
    {
        mkdir($dir, $mode) || Error("$!", $dir);
        Mode($mode, $dir);
    }
}



sub DirRead
{
    my $dir  = shift;
    my $patt = shift;

    DirTaint($dir);

    opendir(DIR, $dir) || Error("$!", $dir);
    my @files = grep { /$patt/ && -f "$dir/$_" } readdir(DIR);
    closedir(DIR);

    return \@files;
}



sub DirTaint
{
    my $dir = shift;

    Error('Not A Directory', $dir) if( !IsDirectory($dir) );
    Error('Security Violation', $dir) if( index($dir, '..') != -1 );
    Error('Security Violation', $dir) if( index($dir, '|') != -1 );
    Error('Security Violation', $dir) if( index($dir, ';') != -1 );
}



##############################################################
##               POST & GET Parsing Functions               ##
##############################################################


sub ParseRequest
{
    my $strip  = shift;
    my $buffer = '';
    my $clength = $ENV{'CONTENT_LENGTH'} || 0;
    my $bytes  = read(STDIN, $buffer, $clength);

    $CGI_INPUT = $buffer;

    ## Process POST request
    if( $bytes )
    {
        if( $ENV{'CONTENT_TYPE'} =~ /multipart\/form-data/gi )
        {
            ProcessMultipart(\$buffer, $strip);            
        }
        else
        {
            ProcessURLEncoded(\$buffer, $strip);   
        }
    }


    ## Process GET request
    if( $ENV{'QUERY_STRING'} )
    {
        ProcessURLEncoded(\$ENV{'QUERY_STRING'}, $strip);
    }
}



sub ParseMulti
{
    my $field = shift;
    my $items = [];
    my $name   = undef;
    my $value  = undef;
    my @pairs  = ();

    $CGI_INPUT =~ s/\%00//gi;

    @pairs = split(/&/, $CGI_INPUT);

    for (@pairs)
    {
        ($name, $value) = split(/=/, $_);
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

        if( $name eq $field )
        {
            push(@$items, $value);
        }
    }

    return $items;
}



sub ProcessURLEncoded
{
    my $buffer = shift;
    my $strip  = shift;
    my $name   = undef;
    my $value  = undef;
    my @pairs  = ();

    $$buffer =~ s/\%00//gi;

    @pairs = split(/&/, $$buffer);
	
    for (@pairs)
    {
        ($name, $value) = split(/=/, $_);
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

        if( $strip )
        {
            $value =~ s/</&lt;/g;
            $value =~ s/>/&gt;/g;
        }

        $F{$name} = (exists $F{$name}) ? join(',', $F{$name}, $value) : $value;
    }
}



sub ProcessMultipart
{
    my $buffer   = shift;
    my $strip    = shift;
    my $boundary = undef;

    if( $ENV{'CONTENT_TYPE'} =~ /^.*boundary="?(.*)"?$/ )
    {
        $boundary = $1;

        for( split(/--$boundary/, $$buffer) )
        {
            my $data = $_;

            if( $data =~ /Content-Disposition: form-data; name="([^"]+)"/m )
            {
                my $name = $1;

                if( $data =~ /$CRLF$CRLF(.*)$CRLF/s )
                {
                    $F{$name} = $1;

                    if( $strip && $data !~ /filename=/ )
                    {
                        $F{$name} =~ s/</&lt;/g;
                        $F{$name} =~ s/>/&gt;/g;
                    }
                }
            }
        }
    }
}

#REPLACE


##############################################################
##                  Time & Date Functions                   ##
##############################################################


sub AgeString
{
    my $time   = shift;
    my $days   = int($time / (60*60*24));
    my $string = '';

    $string .= $days > 0 ? $days . ' Days ' : '';
    $time -= $days * 60*60*24;
    my $hours = int($time / (60*60));
    $string .= $hours > 0 ? sprintf("%02d:", $hours) : "00:";
    $time -= $hours *60*60;
    my $minutes = int($time / 60);
    $string .= $minutes > 0 ? sprintf("%02d:", $minutes) : "00:";
    $time -= $minutes * 60;
    my $seconds = sprintf("%02d", $time);
    $string .= $seconds;

    return $string;
}



sub Age
{
    return $TIME - shift;
}



sub FileAge
{
    return $TIME - FileReadLine(shift);
}



sub Date
{
    $LANG = IniParse("$DDIR/language") if( !ref($LANG) );
    my @months = ($LANG->{'JANUARY'},$LANG->{'FEBRUARY'},$LANG->{'MARCH'},$LANG->{'APRIL'},$LANG->{'MAY'},$LANG->{'JUNE'},$LANG->{'JULY'},$LANG->{'AUGUST'},$LANG->{'SEPTEMBER'},$LANG->{'OCTOBER'},$LANG->{'NOVEMBER'},$LANG->{'DECEMBER'});
    my @days = ($LANG->{'SUNDAY'},$LANG->{'MONDAY'},$LANG->{'TUESDAY'},$LANG->{'WEDNESDAY'},$LANG->{'THURSDAY'},$LANG->{'FRIDAY'},$LANG->{'SATURDAY'});
    my %fmt = ();

    ## Find out if it is daylight savings time
    my $isdst = (localtime())[8];

    my $format = shift || '%M %e, %Y %h:%i%p';
    my $time = shift || $TIME;

    ## If it is daylight savings, add one hour
    if( $isdst )
    {
        $time += 3600;
    }

    my @date = gmtime($time);    
    my $month  = $date[4] + 1;

    ## Date values
    $fmt{'d'} = length($date[3]) < 2 ? "0" . $date[3] : $date[3];               ## Day of the month, numeric (00..31)
    $fmt{'e'} = $date[3];                                                       ## Day of the month, numeric (0..31)
    $fmt{'a'} = substr($days[$date[6]], 0, 3);                                  ## Abbreviated weekday name (Sun..Sat)
    $fmt{'W'} = $days[$date[6]];                                                ## Weekday name (Sunday..Saturday)
    $fmt{'b'} = substr($months[$date[4]], 0, 3);                                ## Abbreviated month name (Jan..Dec)
    $fmt{'M'} = $months[$date[4]];                                              ## Month name (January..December)
    $fmt{'m'} = length($month) < 2 ? "0" . $month : $month;                     ## Month, numeric (00..12)
    $fmt{'c'} = $date[4] + 1;                                                   ## Month, numeric (0..12)
    $fmt{'Y'} = $date[5] + 1900;                                                ## Year, numeric, 4 digits
    $fmt{'y'} = substr($date[5] + 1900, 2, 2);                                  ## Year, numeric, 2 digits

    my @day_suffix = qw(0th 1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th 11th 12th 13th 14th 15th 16th 17th 18th 19th 20th 21st 22nd 23rd 24th 25th 26th 27th 28th 29th 30th 31st);
    $fmt{'S'} = $day_suffix[$fmt{'e'}];

    ## Time values
    $fmt{'p'} = $date[2] < 12 ? "AM" : "PM";                                    ## AM or PM
    $fmt{'h'} = $date[2] > 12 ? $date[2] - 12 : $date[2];                       ## Hour (01..12)
    $fmt{'h'} = 12 if( $fmt{'h'} == 0 );
    $fmt{'h'} = length( $fmt{'h'} ) < 2 ? "0" . $fmt{'h'} : $fmt{'h'};
    $fmt{'H'} = length($date[2]) < 2 ? "0" . $date[2] : $date[2];               ## Hour (00..23)
    $fmt{'l'} = $date[2] > 12 ? $date[2] - 12 : $date[2];                       ## Hour (1..12)
    $fmt{'l'} = 12 if( $fmt{'l'} == 0 );
    $fmt{'k'} = $date[2];                                                       ## Hour (0..23)
    $fmt{'i'} = length($date[1]) < 2 ? "0" . $date[1] : $date[1];               ## Minutes, numeric (00..59)
    $fmt{'s'} = length($date[0]) < 2 ? "0" . $date[0] : $date[0];               ## Seconds (00..59)

    for( keys %fmt )
    {
        $format =~ s/%([a-zA-Z])/$fmt{$1}/gise;
    }

    $format =~ s/\s+$//g;

    return $format;
}



sub i{
$HEADER = 0;
}


##############################################################
##                    E-mail Functions                      ##
##############################################################


sub Mail
{
    my $file    = shift;
    my $mailer  = $SENDMAIL || shift;
    my $message = undef;

    if( !$mailer )
    {
        Error('Sendmail/SMTP Not Provided', 'Mail');
    }

    Error('Security Violation', $mailer) if( index($mailer, '|') != -1 );
    Error('Security Violation', $mailer) if( index($mailer, ';') != -1 );

    if( !ref($file) )
    {
        $file = FileReadScalar($file);
    }

    StringParseRet($file);

    $message = _GenerateEmail(IniParse($file));

    if( index($mailer, '/') == -1 )
    {
        _SMTPMail($message, $mailer);
    }
    else
    {
        _ShellMail($message, $mailer);
    }
}



sub _SMTPMail
{
    my $message  = shift;
    my $mailer   = shift;
    my $response = undef;

    my $ip   = inet_aton($mailer);
    my $padd = sockaddr_in(25, $ip);
    socket(SMTP, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
    connect(SMTP, $padd) || Error("$!", "SMTP Socket");

    _SMTPRead(SMTP);
    _SMTPSend(SMTP, "HELO localhost$CRLF");
    _SMTPSend(SMTP, "RSET$CRLF");
    _SMTPSend(SMTP, "MAIL FROM: <$T{'From'}>$CRLF");
    _SMTPSend(SMTP, "RCPT TO: <$T{'To'}>$CRLF");
    _SMTPSend(SMTP, "DATA$CRLF");
    _SMTPSend(SMTP, "$$message$CRLF.$CRLF");
    _SMTPSend(SMTP, "QUIT$CRLF");

    shutdown(SMTP, 1);
    close(SMTP);
}



sub _SMTPSend
{
    my $sock     = shift;
    my $data     = shift;
    my $response = undef;

    send($sock, $data, 0);
    $response = _SMTPRead($sock);

    if( int(substr($response, 0, 3)) > 400 )
    {
        FileAppend("$DDIR/maillog", $response);
    }
}



sub _SMTPRead
{
    my $sock     = shift;
    my $buffer   = undef;
    my $response = undef;

    sysread($sock, $response, 4096);

    return $response;
}



sub _ShellMail
{
    my $message = shift;
    my $mailer  = shift;

    FileCreate("$DDIR/maillog");

    open(MAIL, "|$mailer -t >>$DDIR/maillog") || Error("$!", $mailer);
    print MAIL $$message;
    close(MAIL);
}



sub _GenerateEmail
{
    my $ini             = shift;
    my $message         = undef;
    my $file            = undef;
    my $basename        = undef;
    my $contentType     = undef;
    my $plainText       = undef;
    my $multipartText   = undef;
    my $multipartHTML   = undef;
    my $multipartAttach = undef;
    my $boundary        = _GenerateBoundary();
    my $endBoundary     = "--$boundary--";


    if( $ini->{'Text'} )
    {
        $contentType   = 'text/plain';
        $plainText     = "$ini->{'Text'}$CRLF";
        $multipartText = "--$boundary$CRLF" .
                         "Content-Type: text/plain; charset=iso-8859-1$CRLF" .
                         "Content-Transfer-Encoding: 7bit$CRLF$CRLF" .
                         "$plainText$CRLF";
    }

    if( $ini->{'HTML'} )
    {
        $plainText     = undef;
        $contentType   = 'multipart/alternative; boundary=' . $boundary;
        $multipartHTML = "--$boundary$CRLF" .
                         "Content-Type: text/html$CRLF" .
                         "Content-Transfer-Encoding: 7bit$CRLF$CRLF" .
                         "$ini->{'HTML'}$CRLF";
    }

    if( $ini->{'Attach'} )
    {
        $plainText       = undef;
        $contentType     = 'multipart/mixed; boundary=' . $boundary;
        $multipartAttach = join('', map(_AttachFile($_, $boundary),  split(/$LF/, $ini->{'Attach'})));
    }


    if( $contentType eq 'text/plain' )
    {
        $multipartText = undef;
        $endBoundary   = undef;
    }


    if( $ini->{'Text'} && $ini->{'HTML'} && $ini->{'Attach'} )
    {
        my $subBound    = _GenerateBoundary();
        my $subBoundEnd = "--$subBound--";


        $multipartText  =~ s/$boundary/$subBound/;

        $multipartText  = "--$boundary$CRLF" .
                          'Content-Type: multipart/alternative; boundary=' . $subBound . $CRLF .
                          "Content-Transfer-Encoding: 7bit$CRLF$CRLF" .
                          $multipartText;

        $multipartHTML  =~ s/$boundary/$subBound/;
        $multipartHTML  .= $subBoundEnd . $CRLF;
    }


    $message = "To: $T{'To'}$CRLF" .
               "From: $T{'From'}$CRLF" .
               "Subject: $ini->{'Subject'}$CRLF" .
               "Mime-Version: 1.0$CRLF" .
               "Content-Type: $contentType$CRLF" .
               "Content-Transfer-Encoding: 7bit$CRLF$CRLF" .
               $plainText .
               $multipartText .
               $multipartHTML .
               $multipartAttach .
               $endBoundary;


    UnixFormat(\$message);
    #PCFormat(\$message);  this caused problems when using qmail

    return \$message;
}



sub _AttachFile
{
    my $file     = shift;
    my $boundary = shift;
    my $basename = BaseName($file);

    return "--$boundary$CRLF" .
           "Content-Type: unknown/file; name=$basename$CRLF" .
           "Content-Transfer-Encoding: base64$CRLF" .
           "Content-Disposition: attachment; filename=$basename$CRLF$CRLF" .
           Base64Encode(FileReadScalar($file));
}



sub _GenerateBoundary
{
    my @chars  = ('a'..'z', 'A'..'Z', '0'..'9');
    my $string = '--';

    for( 1..32 )
    {
        $string .= $chars[rand(@chars)];
    }

    return $string;
}


##############################################################
##                Text Database Functions                   ##
##############################################################



sub DBSize
{
    my $file  = shift;
    my $count = 0;

    FileTaint($file);

    open(DB, $file) || Error("$!", $file);
    flock(DB, LOCK_SH);
    while( <DB> )
    {
        $count++ if( $_ !~ /^\s*$/ );
    }
    flock(DB, LOCK_UN);
    close(DB);

    return $count;
}



sub DBInsert
{
    my $file = shift;
    my @data = @_; 
    my $line = undef;

    FileTaint($file);

    if( !-e $file )
    {
        open(DB, ">$file") || Error("$!", $file);
    }
    else
    {
        open(DB, "+<$file") || Error("$!", $file);
    }

    flock(DB, LOCK_EX);
    seek(DB, 0, 0);

    while( $line = <DB> )
    {
        if( index($line, "$data[0]$DEL") == 0 )
        {
            flock(DB, LOCK_UN);
            close(DB);

            return 0;
        }
    }

    print DB join($DEL, @data) . $LF;
    flock(DB, LOCK_UN);
    close(DB);

    Mode(0666, $file);

    return 1;
}



sub DBDelete
{
    my $file = shift;
    my $key  = shift;
    my $del  = shift || $DEL;
    my $line = undef;
    my @old  = ();

    FileTaint($file);

    if( !-e $file )
    {
        open(DB, ">$file") || Error("$!", $file);
    }
    else
    {
        open(DB, "+<$file") || Error("$!", $file);
    }


    flock(DB, LOCK_EX);
    seek(DB, 0, 0);

    @old = <DB>;
    seek(DB, 0, 0);

    foreach $line ( @old )
    {
        if( index($line, "$key$del") == 0 )
        {
            next;
        }
        else
        {
            print DB $line if( $line !~ /^\s*$/ );
        }
    }

    truncate(DB, tell(DB));
    flock(DB, LOCK_UN);
    close(DB);

    Mode(0666, $file);

    return;
}



sub DBSelect
{
    my $file = shift;
    my $key  = shift;
    my $line = undef;

    FileTaint($file);

    open(DB, $file) || Error("$!", $file);
    flock(DB, LOCK_SH);

    while( $line = <DB> )
    {
        if( index($line, "$key$DEL") == 0 )
        {
            flock(DB, LOCK_UN);
            close(DB);

            Mode(0666, $file);

            chomp($line);

            my @data = split(/\Q$DEL\E/, $line);

            return \@data;
        }
    }

    flock(DB, LOCK_UN);
    close(DB);

    Mode(0666, $file);

    return undef;
}



sub DBUpdate
{
    my $file = shift;
    my $key  = shift;
    my @data = @_;
    my $line = undef;
    my @old  = ();

    FileTaint($file);

    if( !-e $file )
    {
        open(DB, ">$file") || Error("$!", $file);
    }
    else
    {
        open(DB, "+<$file") || Error("$!", $file);
    }

    flock(DB, LOCK_EX);
    seek(DB, 0, 0);

    @old = <DB>;
    seek(DB, 0, 0);

    foreach $line ( @old )
    {
        if( index($line, "$key$DEL") == 0 )
        {
            print DB join($DEL, @data) . $LF;
        }
        else
        {
            print DB $line if( $line !~ /^\s*$/ );
        }
    }

    truncate(DB, tell(DB));
    flock(DB, LOCK_UN);
    close(DB);

    Mode(0666, $file);
}



##############################################################
##                     DNS Functions                        ##
##############################################################


sub ExtractDomain
{
    my $url     = shift;
    my $host    = undef;
    my @domains = ();
    my $dot     = 0;
    my $dots    = 0;

    if( $url =~ m|http://(www\.)?([^:/]+):?(\d+)*(/?.*)|i )
    {
        $host = $2;

        while( ($dot = index($host, '.')) != -1 )
        {
            $dots = $host =~ tr/././;

            if( $dots <= 2 )
            {
                unshift(@domains, $host);
            }

            $host = substr($host, $dot+1);
        }

        @domains = reverse(@domains);

    }
    else
    {
        return 0;
    }

    return \@domains;
}



sub GetNS
{
    my $domains = ExtractDomain(shift);
    my $record  = undef;
    my @ns      = ();

    Error('Security Violation', $NSLOOKUP) if( index($NSLOOKUP, '|') != -1 );
    Error('Security Violation', $NSLOOKUP) if( index($NSLOOKUP, ';') != -1 );

    if( $NSLOOKUP =~ /nslookup$/ )
    {
        for( @$domains )
        {
            $record = `$NSLOOKUP -timeout=15 -type=NS $_ 2>&1`;

            while( $record =~ /nameserver\s\=\s(.*)$/mgi )
            {
                my $host = $1;

                $host =~ s/\.$//g;

                push(@ns, lc($host));
            }

            last if scalar(@ns);
        }
    }
    else
    {
        for( @$domains )
        {
            $record = `$NSLOOKUP -t ns $_ 2>&1`;

            while( $record =~ /name\sserver\s(.*)$/mgi )
            {
                my $host = $1;

                $host =~ s/\.$//g;

                push(@ns, lc($host));
            }

            last if scalar(@ns);
        }
    }

    return \@ns;
}



##############################################################
##                   Template Functions                     ##
##############################################################


sub ParseTemplate
{
    my $file   = shift;
    my $handle = shift;

    #print "<xmp>" . ${CompileTemplate($file, $handle)} . "</xmp>";
    eval ${CompileTemplate($file, $handle)};


    if( $@ )
    {
        Error("$@", 'ParseTemplate');
    }
}



sub TemplateAdd
{
    my $key      = shift;
    my $values   = shift;
    my $position = shift;

    if( $position != undef )
    {
        --$position;

        if( !$T{$key}[$position] )
        {
            $T{$key}[$position] = $values;
        }
        else
        {
            ## If the gallery in this position is a random gallery
            ## replace it with the new gallery that has this position
            ## defined and move the random gallery to the end
            if( $T{$key}[$position]{'Position'} == 999999 )
            {
                my $temp = $T{$key}[$position];

                $T{$key}[$position] = $values;

                push(@{$T{$key}}, $temp);
            }
        }

        return $position;
    }
    elsif( !exists($T{$key}) )
    {
        $T{$key}[0] = $values;
        return 0;
    }
    else
    {
        return push(@{$T{$key}}, $values) - 1;
    }
}



sub CompileTemplate
{
    my $contents  = shift;
    my $handle    = shift;
    my $line      = undef;
    my $elements  = undef;
    my $temp      = undef;
    my $compiled  = undef;
    my $buffer    = undef;
    my $namespace = '$T';
    my @scope     = ();

    if( !ref($contents) )
    {
        $contents = FileReadScalar("$TDIR/$contents");
    }

    UnixFormat($contents);

    for( split(/\n/, $$contents) )
    {
        $line = $_;

        ## skip blank lines
        next if( !$line );

        if( index($line, '<!--[') == 0 )
        {
            $line = substr($line, 5, (rindex($line, ']-->')-5));

            $elements = ParseCommand(\$line);


            ## Process Loop commands
            if( $elements->[0] eq 'Loop' )
            {
                if( $elements->[1] eq 'Start' )
                {
                    my $limit  = ref($T{$elements->[2]}) ? $#{$T{$elements->[2]}} : -1;
                    $namespace = "\$T{'$elements->[2]'}[\$i]";
                    $compiled .= "for( my \$i = 0; \$i <= $limit; \$i++ )\n{\n";
                    unshift(@scope, 'Loop');
                }
                elsif( $elements->[1] eq 'End' )
                {
                    $namespace = '$T';
                    $compiled .= "}\n";
                    shift(@scope);
                }
            }


            ## Process If commands
            elsif( $elements->[0] eq 'If' )
            {
                if( $elements->[1] eq 'Start' )
                {
                    if( $elements->[2] eq 'Code' )
                    {
                        $compiled .= "if( $elements->[3] )\n{\n";
                    }
                    else
                    {
                        $compiled .= "if($namespace\{'$elements->[2]'\} $elements->[3])\n{\n";
                    }

                    unshift(@scope, 'If');
                }
                elsif( $elements->[1] eq 'Elsif' )
                {
                    if( $elements->[2] eq 'Code' )
                    {
                        $compiled .= "}\nelsif( $elements->[3] )\n{\n";
                    }
                    else
                    {
                        $compiled .= "}\nelsif($namespace\{'$elements->[2]'\} $elements->[3])\n{\n";
                    }
                }
                elsif( $elements->[1] eq 'Else' )
                {
                    $compiled .= "}\nelse\n{\n";
                }
                elsif( $elements->[1] eq 'End' )
                {
                    $compiled .= "}\n";
                    shift(@scope);
                }
            }


            ## Process Include commands
            elsif( $elements->[0] eq 'Include' )
            {
                $compiled .= "print \${FileReadScalar('$elements->[2]')};\n";
            }


            ## Process all other commands
            else
            {
                Error('Unrecognized Template Command', $line);
            }
        }


        ## Process non-command lines
        else
        {
            $line =~ s/'/\\'/g;
            $line =~ s/##(.*?)##/' . $namespace\{'$1'\} . '/g;
            $compiled .= "print $handle '$line' . \"\\n\";\n";
        }
    }


    if( scalar(@scope) )
    {
        Error('Invalid Template Scoping', 'Template Compiler');
    }

    return \$compiled;
}



sub ParseCommand
{
    my $line = shift;
    my $char = undef;
    my $in = undef;
    my $buffer = undef;
    my @items = ();
    my @stack = ();

    for( unpack('C*', $$line) )
    {
        $char = chr($_);

        if( !scalar(@stack) && $char eq ' ' )
        {
            if( $buffer )
            {
                push(@items, $buffer);
                $buffer = undef;
            }
            next;
        }


        if( $char eq '{' )
        {
            push(@stack, $char);

            if( scalar(@stack) == 1 )
            {
                next;
            }
        }
        elsif( $char eq '}' )
        {
            pop(@stack);

            if( scalar(@stack) == 0 )
            {
                push(@items, $buffer);
                $buffer = undef;
                next;
            }            
        }

        $buffer .= $char;
    }

    if( $buffer )
    {
        push(@items, $buffer);
    }

    return \@items;
}



sub StringParse
{
    my $string = shift;
    my $handle = shift || STDOUT;

    $string =~ s/##(.*?)##/$T{$1}/gise;

    print $handle $string;
}



sub StringParseRet
{
    my $string = shift;

    $$string =~ s/##(.*?)##/$T{$1}/gise;
}



sub IniParse
{
    my $data  = shift;
    my $line  = undef;
    my $key   = undef;
    my $store = {};

    if( !ref($data) )
    {
        $data = FileReadScalar($data);
    }

    if( !$$data )
    {
        return $store;
    }

    UnixFormat($data);

    while( $$data =~ /^(.*$LF?)/gm )
    {
        my $line = $1;

        if( $line =~ /^=>\[(.*?)\]$LF/ )
        {
            $key = $1;
        }
        else
        {
            $store->{$key} .= $line;
        }
    }

    chomp(%$store);

    return $store;
}



sub IniWrite
{
    my $file  = shift;
    my @items = @_;
    my $text  = undef;

    for( @items )
    {
        $text .= "=>[$_]\n$F{$_}\n" if( $F{$_} );
    }

    UnixFormat(\$text);

    FileWrite($file, $text);
}
