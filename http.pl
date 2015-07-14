package Http;


use Socket;


## Error messages
$L_CONNECT_TIMEOUT = 'Connection timeout.';
$L_RESOLVE_TIMEOUT = 'DNS timeout.';
$L_READ_TIMEOUT = 'Read timeout.';
$L_SEND_TIMEOUT = 'Send timeout.';
$L_REDIRECTS = 'Too many redirects.';
$L_INVALID_URL = 'Invalid URL.';
$L_READ_ERROR = 'Read error';
$L_RESOLVE = 'Could not resolve hostname';


## Timeout values
$READ_TIMEOUT = 30;
$SEND_TIMEOUT = 10;
$CONNECT_TIMEOUT = 15;
$RESOLVE_TIMEOUT = 15;


## Misc values
$CRLF = "\r\n";
$DDIR = './data';
$REFERRERS = FileReadArray("$DDIR/referrers");
$AGENTS = FileReadArray("$DDIR/agents");


## Setup SIGALRM for timeouts
$SIG{ALRM} = sub { die "timeout" };


## Setup time function based on available modules
eval("use Time::HiRes;");

if( !$@ )
{
    *Now = \&Time::HiRes::time;  
}
else
{
    *Now = sub { return time; };
}



## Constructor
sub new
{
    my $self = {};
    my $type = shift;
    my $args = {@_};

    bless($self);

    return $self;
}



## Make a HTTP GET request
sub Get
{
    my $self = shift;
    my $args = {@_};

    $self->{'Method'} = 'GET';
    $self->{'Agent'} = SelectRandom($AGENTS) || 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)' if( !$args->{'Agent'} );
    $self->{'Referrer'} = $args->{'Referrer'} ? "Referer: $args->{'Referrer'}$CRLF" : "Referer: " . SelectRandom($REFERRERS) . $CRLF;

    if( $args->{'AllowRedirect'} )
    {
        my $last_result = 0;
        $self->{'Redirects'} = -1;

        do
        {
            $self->Reset();

            $last_result = $self->Request($args);

            $self->{'Redirects'}++;

            if( $self->{'Redirects'} > 3 )
            {
                $self->{'Error'} = $L_REDIRECTS;
                return 0;
            }
        }
        while( $args->{'URL'} = $self->{'Headers'}->{'location'} );

        return $last_result;
    }
    else
    {
        $self->Reset();

        return $self->Request($args);
    }    
}



## Make a HTTP HEAD request
sub Head
{
    my $self = shift;
    my $args = {@_};

    $self->{'Method'} = 'HEAD';

    $self->Reset();

    return $self->Request($args);
}



## Perform a HTTP request
sub Request
{
    my $self = shift;
    my $args = shift;

    $self->{'URL'} = $args->{'URL'};

    ## Parse the URL
    if( !$self->ParseUrl($args->{'URL'}) )
    {
        return 0;
    }


    ## Handle proxy
    if( $args->{'Proxy'} )
    {
        $self->ProcessProxy($args->{'Proxy'}, $args->{'URL'});
    }


    # Resolve hostname
    if( !$self->Resolve() )
    {
        return 0;
    }

    
    # Attempt to connect to the server
    if( !$self->CallTimedFunction(\&Connect, $CONNECT_TIMEOUT) )
    {
        $self->{'Error'} = $L_CONNECT_TIMEOUT if( !$self->{'Error'} );
        return 0;
    }


    # Send request to the server
    if( !$self->CallTimedFunction(\&Send, $SEND_TIMEOUT) )
    {
        $self->{'Error'} = $L_SEND_TIMEOUT if( !$self->{'Error'} );
        $self->Disconnect();
        return 0;
    }


    # Read data from server
    if( !$self->CallTimedFunction(\&Read, $READ_TIMEOUT) )
    {
        $self->{'Error'} = $L_READ_TIMEOUT if( !$self->{'Error'} );
        $self->Disconnect();
        return 0;
    }

    $self->Disconnect();

    # Bad status code
    if( $self->{'Code'} >= ($self->{'AllowRedirect'} ? 400 : 300) )
    {
        $self->{'Error'} = $self->{'Status'};
        return 0;
    }

    return 1;
}



## Resolve a hostname to an IP address
sub Resolve
{
    my $self = shift;

    socket(SOCK, AF_INET, SOCK_STREAM, getprotobyname('tcp'));
    $self->{'Socket'} = SOCK;

    my $start = Now();
    $self->{'Packed'} = gethostbyname($self->{'Server'});
    my $end = Now();

    $self->{'ResolveTime'} = $end-$start;

    if( !$self->{'Packed'} )
    {
        $self->{'Error'} = "$L_RESOLVE: $self->{'Server'}";
        return 0;
    }

    $self->{'IP'} = inet_ntoa($self->{'Packed'});

    return 1;
}



## Make connection to remote server
sub Connect
{
    my $self = shift;
    my $paddr = sockaddr_in($self->{'Port'}, $self->{'Packed'});
    my $start = Now();
    my $result = connect($self->{'Socket'}, $paddr);
    my $end = Now();

    if( !$result )
    {
        $self->{'Error'} = "$!";
        return 0;
    }
    else
    {
        $self->{'ConnectTime'} = $end-$start;
        $self->{'ConnectTime'} = 0.15 if( $self->{'ConnectTime'} == 0 );
        return 1;
    }
}



## Send data to remote server
sub Send
{
    my $self = shift;
    my $request = $self->GenerateRequest();
    my $result = send($self->{'Socket'}, $request, undef);

    if( !$result )
    {
        $self->{'Error'} = "$!";
        return 0;
    }

    return 1;
}



## Read response from remote server
sub Read
{
    my $self = shift;
    my $line = undef;
    my $buffer = undef;
    my $chunk_size = 0;
    *SOCK = $self->{'Socket'};

    my $start = Now();

    ## Read status line
    $self->{'StatusLine'} = <SOCK>;
    $self->{'StatusLine'} = StripLineFeeds($self->{'StatusLine'});
    

    ## Extract information from status line
    if( $self->{'StatusLine'} =~ m|^HTTP/\d\.\d\s(([^\s]+)\s.*)$| )
    {
        $self->{'Status'} = $1;
        $self->{'Code'} = $2;        
    }


    ## Read headers
    do
    {
        $line = <SOCK>;
    }
    while( $self->ProcessHeader($line) );

    ## Read chunked body
    if( $self->{'Headers'}->{'transfer-encoding'} eq 'chunked' )
    {
        while( 1 )
        {
            if( $chunk_size == 0 )
            {
                $line = <SOCK>;

                if( $line =~ /^([0-9a-f]+)/i )
                {
                    $chunk_size = hex($1);

                    ## End reached
                    last if( $chunk_size == 0 );
                }
            }
            else
            {
                my $bytes_read = read(SOCK, $buffer, $chunk_size);

                if( $bytes_read == undef )
                {
                    $self->{'Error'} = "$L_READ_ERROR: $!";
                    return 0;
                }

                $self->{'Body'} .= $buffer;

                $chunk_size -= $bytes_read;

                ## Read end of line
                if( $chunk_size == 0 )
                {
                    my $throw_away = <SOCK>;
                }
            }
        }
    }

    ## Read normal body
    else
    {
        if( $self->{'Headers'}->{'content-length'} )
        {
            my $remaining_size = $self->{'Headers'}->{'content-length'};
            my $chunk_size = 16384; 

            do
            {
                my $bytes_read = read(SOCK, $buffer, $remaining_size < $chunk_size ? $remaining_size : $chunk_size);

                if( $bytes_read == undef )
                {
                    $self->{'Error'} = "$L_READ_ERROR: $!";
                    return 0;
                }

                $self->{'Body'} .= $buffer;

                $remaining_size -= $bytes_read;
            }
            while( $remaining_size != 0 );
        }
        else
        {
            while( <SOCK> )
            {
                $self->{'Body'} .= $_;
            }
        }
    }

    my $end = Now();

    $self->{'ReadTime'} = $end-$start;
    $self->{'ReadTime'} = 0.25 if( $self->{'ReadTime'} == 0 );

    $self->{'BodyBytes'} = length($self->{'Body'});
    $self->{'HeaderBytes'} = length($self->{'Headers'}->{'All'});
    $self->{'TotalBytes'} = $self->{'BodyBytes'} + $self->{'HeaderBytes'};
    $self->{'Throughput'} = sprintf("%.1f", ($self->{'TotalBytes'}/1024)/$self->{'ReadTime'});

    return 1;
}



## Disconnect from remote server
sub Disconnect
{
    my $self = shift;

    shutdown($self->{'Socket'}, 0);
    close($self->{'Socket'});
}



## Process response header
sub ProcessHeader
{
    my $self = shift;
    my $header = shift;

    $self->{'Headers'}->{'All'} .= $header;

    $header = StripLineFeeds($header);

    if( $header =~ /^([^:]+):\s+(.*)/i )
    {
        $self->{'Headers'}->{lc($1)} = $2;
        return 1;
    }

    return 0;
}



## Handle proxy server
sub ProcessProxy
{
    my $self = shift;
    my $proxy = shift;
    my $url = shift;

    $proxy =~ m/([^:]+):?(\d+)*/;

    $self->{'Server'} = $1;
    $self->{'Port'} = $2 ? $2 : 80;
    $self->{'URI'}  = $url;
    $self->{'Proxy'} = $proxy;
}



## Generate the full HTTP request
sub GenerateRequest
{
    my $self = shift;
    my $version = $self->{'Proxy'} ? '1.0' : '1.1';

    return "$self->{'Method'} $self->{'URI'} HTTP/$version$CRLF" .
           "Host: $self->{'Hostname'}$CRLF" .
           "User-Agent: $self->{'Agent'}$CRLF" .
           "$self->{'Referrer'}" .
           "Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/vnd.ms-excel, application/msword, application/x-shockwave-flash, */*$CRLF" .
           "Accept-Language: en-us$CRLF" .  
           "Connection: close$CRLF$CRLF";    
}



## Parse an HTTP URL into it's parts
sub ParseUrl
{
    my $self = shift;
    my $url = shift;

    if( $url =~ m|http://([^:/]+):?(\d+)*(/?.*)|i )
    {
        $self->{'Hostname'} = $self->{'Server'} = $1;
        $self->{'Port'} = $2 ? $2 : 80;
        $self->{'URI'} = $3 ? $3 : '/';

        if( $self->{'Hostname'} =~ s/([?&].*)// )
        {
            $self->{'URI'} .= $1;
        }

        return 1;
    }
    else
    {
        $self->{'Error'} = $L_INVALID_URL;
        return 0;
    }
}



## Call a function with a specified timeout
sub CallTimedFunction
{
    my $self = shift;
    *Function = shift;
    my $timeout = shift;
    my $result = undef;

    eval 
    {
        alarm($timeout);
        $result = $self->Function();
        alarm(0);
    };

    if( $@ =~ /timeout/ )
    {
        return 0;
    }
    elsif( $@ && !$self->{'Error'} )
    {
        $self->{'Error'} = "$@";
        return 0;
    }

    return $result;
}



## Reset the object to prepare for re-use
sub Reset
{
    my $self = shift;

    $self->{'Headers'} = {};
    $self->{'Body'} = undef;
    $self->{'Code'} = undef;
    $self->{'Status'} = undef;
    $self->{'StatusLine'} = undef;
    $self->{'Hostname'} = undef;
    $self->{'Server'} = undef;
    $self->{'Port'} = undef;
    $self->{'URI'} = undef;
    $self->{'Socket'} = undef;
    $self->{'Error'} = undef;
    $self->{'TotalBytes'} = 0;
    $self->{'ReadTime'} = 0;
    $self->{'ConnectTime'} = 0;
    $self->{'HeaderBytes'} = 0;
    $self->{'BodyBytes'} = 0;
    $self->{'Throughput'} = 0;
    $self->{'Proxy'} = undef;
}



## Select a random value from an array
sub SelectRandom
{
    my $array = shift;
    my $item = undef;

    $item = $array->[rand @$array];
    
    ## Remove newlines
    $item =~ s/[\r\n]//gi;
    
    return $item;
}



## Read file contents into an array
sub FileReadArray
{
    my $file = shift;
    my @lines = ();

    if( -e $file )
    {
        open(FILE, $file);
        flock(FILE, 1);
        @lines = <FILE>;
        close(FILE);
        flock(FILE, 8);
    }

    return \@lines;
}



## Strip end of line characters from a string
sub StripLineFeeds
{
    my $string = shift;

    $string =~ s/[\r\n]//g;

    return $string;
}
