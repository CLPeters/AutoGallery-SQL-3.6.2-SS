#!/usr/bin/perl

require 'http.pl';

%F = ();

_ProcessURLEncoded(\$ENV{'QUERY_STRING'});

my $url = $F{'image'};
my $http = new Http();

$http->Get(URL => $url, Referrer => $F{'gallery'}, AllowRedirect => 1);

if( $F{'id'} )
{
    require "./data/variables";

    if( $F{'id'} =~ /^t[^\.]+\.jpg$/i )
    {
        FileWrite("$THUMB_DIR/$F{'id'}", $http->{'Body'});
    }
      
    print "Content-type: image/jpeg\n\n";
    print $http->{'Body'};
}
else
{
    print "Cache-control: private\n";
    print "Expires: " . Expires() . "\n";
    print "Content-type: image/jpeg\n\n";
    print $http->{'Body'};
}




sub Expires
{
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @days   = qw(Sun Mon Tue Wed Thu Fri Sat);
    my @date   = gmtime(time + 300);

    ## set year
    $date[5] += 1900;

    ## setup hour
    $date[2] = '0' . $date[2] if( length($date[2]) == 1 );

    ## setup minute
    $date[1] = '0' . $date[1] if( length($date[1]) == 1 );

    ## setup second
    $date[0] = '0' . $date[0] if( length($date[0]) == 1 );

    return "$days[$date[6]], $date[3] $months[$date[4]] $date[5] $date[2]:$date[1]:$date[0] GMT";
}



sub FileWrite
{
    my $file = shift;
    my $data = shift;

    open(FILE, ">$file") || die "$!";
    print FILE $data;
    close(FILE);

    chmod(0666, $file);
}



sub _ProcessURLEncoded
{
    my $buffer = shift;
    my $name   = undef;
    my $value  = undef;
    my @pairs  = ();

    @pairs = split(/&/, $$buffer);
	
    for (@pairs)
    {
        ($name, $value) = split(/=/, $_);
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $F{$name} =  (exists $F{$name}) ? join(',', $F{$name}, $value) : $value;
    }
}
