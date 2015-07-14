#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
######################################################
##  code.cgi - Display JPEG image with submit code  ##
######################################################

require 'common.pl';
require 'mysql.pl';

eval("use GD;");

$HEADER = 0;

## Display the GD Not Available image
if( $@ )
{
    my @png =  (
                 0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 
                 0x00, 0x00, 0x00, 0x6a, 0x00, 0x00, 0x00, 0x17, 0x01, 0x03, 0x00, 0x00, 0x00, 0xd9, 0x53, 0x48, 
                 0xcb, 0x00, 0x00, 0x00, 0x06, 0x50, 0x4c, 0x54, 0x45, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x55, 
                 0xc2, 0xd3, 0x7e, 0x00, 0x00, 0x00, 0x72, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x60, 0x18, 
                 0x20, 0xc0, 0x3c, 0x8f, 0x51, 0x80, 0x83, 0xc1, 0x81, 0x41, 0xe0, 0x80, 0x80, 0x01, 0x90, 0xcb, 
                 0x12, 0xc8, 0x38, 0x81, 0x83, 0x61, 0x01, 0x03, 0x83, 0x83, 0x80, 0x00, 0x88, 0x2b, 0xc8, 0x38, 
                 0x79, 0x1e, 0xa3, 0x88, 0x9f, 0x81, 0xf3, 0x34, 0x81, 0x07, 0x60, 0x6e, 0x88, 0x07, 0xa3, 0x88, 
                 0xa3, 0x80, 0x43, 0xa4, 0x20, 0x50, 0x9a, 0xe5, 0x22, 0x88, 0xfb, 0xc5, 0x5f, 0xc0, 0xf9, 0xa2, 
                 0xe0, 0x07, 0xb0, 0x5e, 0x13, 0x0f, 0x46, 0xa1, 0x89, 0x02, 0x2e, 0x81, 0x82, 0x10, 0xa3, 0x4c, 
                 0x3c, 0x19, 0x85, 0x26, 0x0b, 0xb8, 0xdc, 0x14, 0x84, 0x58, 0x24, 0xdc, 0xc6, 0x28, 0xc8, 0x6b, 
                 0xf1, 0x38, 0xcc, 0xe2, 0x01, 0xfd, 0xfc, 0x07, 0x00, 0x62, 0x9a, 0x17, 0x0f, 0x03, 0x46, 0x42, 
                 0xa5, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82
               );


    Header("Content-type: image/png\n\n");

    for( @png )
    {
        print chr($_);
    }

    exit;
}

$fonts = DirRead("$DDIR/fonts", 'ttf$');

## The characters that will be selected from for the code
my @allowed_chars = qw(A B C D E F H J K M N P Q R T U V W X Y 3 4 7 8 9);

## Image details
$image        = undef;
$have_ttf     = undef;
$image_width  = undef;
$image_height = undef;
$font_size    = 20;
$font_file    = $FONT_DIR . '/' . $fonts->[rand(@$fonts)];
$hex_ip       = IP2Hex($ENV{'REMOTE_ADDR'});
$angle        = 0;
$code         = GenerateCode();

## See if we are running in test mode
if( $ENV{'QUERY_STRING'} )
{
    $code = join('', @allowed_chars);
    $font_file = $FONT_DIR . '/' . $ENV{'QUERY_STRING'};
    DisplayTest();
    exit;
}

## Insert code into database
$DB->Connect();
$DB->Insert("REPLACE INTO ags_Codes VALUES (?, ?, UNIX_TIMESTAMP())", [$hex_ip, $code]);
$DB->Disconnect();

## See if FreeType is available, and get code size
eval
{
    @bounds = GD::Image->stringFT(undef, $font_file, $font_size, $angle, 0, 0, $code);
};


## Set the image size
if( scalar(@bounds) )
{
    $have_ttf     = 1;   
    $image_height = $bounds[1] - $bounds[7] + 10;
    $image_width  = $bounds[2] + 10;
}
else
{
    $image_height = GD::Font->Giant->height + 10;
    $image_width  = GD::Font->Giant->width * length($code) + 10;
}

## Create a new image
$image = new GD::Image($image_width, $image_height);

## Allocate the colors for the image
$bg_color   = $image->colorAllocate(240, 240, 220);
$font_color = $image->colorAllocate(0, 0, 0);

## Fill the image with the background color
$image->fill(0, 0, $bg_color);

for( my $i = 4; $i < $image_height; $i += 15 )
{
    $image->line(0, $i, $image_width, $i, $font_color);
}

for( my $i = 2; $i < $image_width; $i += 15 )
{
    $image->line($i, 0, $i, $image_height, $font_color);
}

## Write the submit code onto the image
if( $have_ttf )
{
    $image->stringFT($font_color, $font_file, $font_size, $angle, 5-$bounds[6], $image_height-$bounds[1]-5, $code);
}
else
{
    $image->string(GD::Font->Giant,5,5,$code,$font_color);
}

## Display the image
Header("Content-type: image/jpeg\n\n");
print $image->jpeg;

sub DisplayTest
{
    ## Make sure the font file exists
    if( !-f $font_file )
    {
        Header("Content-type: text/html\n\n");
        print "The font file '$ENV{'QUERY_STRING'}' does not exist";
        return;
    }

    ## See if FreeType is available, and get code size
    eval
    {
        @bounds = GD::Image->stringFT(undef, $font_file, $font_size, $angle, 0, 0, $code);
    };

    ## Set the image size
    if( scalar(@bounds) )
    {
        $have_ttf     = 1;   
        $image_height = $bounds[1] - $bounds[7] + 10;
        $image_width  = $bounds[2] + 10;
    }
    else
    {
        Header("Content-type: text/html\n\n");
        print "GD was not compiled with FreeType support, and therefore cannot use true-type fonts";
        return;
    }

    ## Create a new image
    $image = new GD::Image($image_width, $image_height);

    ## Allocate the colors for the image
    $bg_color   = $image->colorAllocate(240, 240, 220);
    $font_color = $image->colorAllocate(0, 0, 0);

    ## Fill the image with the background color
    $image->fill(0, 0, $bg_color);

    ## Write the submit code onto the image
    $image->stringFT($font_color, $font_file, $font_size, $angle, 5-$bounds[6], $image_height-$bounds[1]-5, $code);

    ## Display the image
    Header("Content-type: image/jpeg\n\n");
    print $image->jpeg;
}

## Generate the code to display on the image
sub GenerateCode
{
    if( $O_USE_WORDS )
    {
        my $words = FileReadArray("$DDIR/words");
        my $word = @$words[rand @$words];

        $word =~ s/[\r\n]//g;

        return $word;
    }
    else
    {
        my $code = undef;
        my $length = RandRange($MIN_CODE_LENGTH, $MAX_CODE_LENGTH);

        for( 1..$length )
        {
            $code .= $allowed_chars[rand @allowed_chars];
        }

        return $code;
    }
}


## Generate a random number from a defined range
sub RandRange
{
    my $lower_limit = shift;
    my $upper_limit = shift;
    my $rand_input = $upper_limit - $lower_limit + 1;

    return int(rand($rand_input)) + $lower_limit;
}
