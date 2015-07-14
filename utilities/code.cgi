#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
######################################################
##  code.cgi - Display JPEG image with submit code  ##
######################################################

use GD;

require 'common.pl';
require 'mysql.pl';

## The density of the dots displayed on the image
## Larger number means more dots
my $dot_density = 1;


## The minimum and maximum sizes to use for each rendered TTF font
my $min_font_size = 14;
my $max_font_size = 28;


## The size of the drop shadow behind each character
my $shadow_size = 2;


## The characters that will be selected from for the code
my @allowed_chars = qw(A B C D E F H J K M N P Q R T U V W X Y 3 4 6 7 8 9);


##############################
##  DO NOT EDIT BELOW HERE  ##
##############################


## See if we are running in test mode
if( $ENV{'QUERY_STRING'} )
{
    DisplayTest();
}


my $image = undef;
my $hex_ip = IP2Hex($ENV{'REMOTE_ADDR'});
my $padding_x = 12;
my $padding_y = 12;
my $padding_chars = 5;
my $fonts = DirRead($FONT_DIR, '\.ttf$');
my $code = GenerateCode();
my ($image_width, $image_height) = CalculateImageDimensions($code);


## Force GD into true color mode
GD::Image->trueColor(1);


## Create the image
my $image = new GD::Image($image_width, $image_height);


## Fill the background with a gradient
my($bg_dark, $bg_light) = FillBackground($image);

AddDots($image);
AddText($image, $code);


## Insert code into database
$DB->Connect();
$DB->Insert("REPLACE INTO ags_Codes VALUES (?, ?, UNIX_TIMESTAMP())", [$hex_ip, join('', map($_->{'Character'}, @$code))]);
$DB->Disconnect();


## Ouput the image
if( $ENV{'REQUEST_METHOD'} )
{
    print "Content-type: image/png\n\n";
    print $image->png;
}





sub AddText
{
    my $image = shift;
    my $code = shift;
    my $start_x = int($padding_x / 2);
    my $current_x = $start_x;
    my $i;
    my $b;

    for($i = 0; $i < scalar(@$code); $i++)
    {
        my $character = $code->[$i];
        my $x = $character->{'X'} + $current_x;
        my $y = $character->{'Y'} + int($padding_y / 2);

        ## Draw the shadow
        for($b = 0; $b <= $shadow_size; $b++)
        {
            $image->stringFT($bg_dark, $character->{'Font'}, $character->{'FontSize'}, $character->{'Angle'}, $x++, $y++, $character->{'Character'});
        }
        
        ## Draw the text on top of the shadow
        $image->stringFT($bg_light, $character->{'Font'}, $character->{'FontSize'}, $character->{'Angle'}, $x++, $y++, $character->{'Character'});

        $current_x += $character->{'Width'} + $padding_chars;
    }
}



## Fill the background of the image with a gradient
sub FillBackground
{
    my $image = shift;

    ## Determine the starting color
    my $red = RandRange(50, 150);
    my $green = RandRange(50, 150); 
    my $blue = RandRange(50, 150);

    ## Determine the dimensions of the image
    my ($width, $height) = $image->getBounds();

    ## Get the total number of different colored lines
    my $lines = int($height / 2) + 1;

    ## Find the lowest starting color value from RGB
    my $smallest_rgb = GetSmallest([$red, $green, $blue]);

    ## Divide that by the number of lines to figure the deviation on each line change
    my $color_deviation = int(($smallest_rgb / $lines) * 2) || 4;

    ## Calculate the largest RGB value allowed
    my $max_color = 256 - $color_deviation;

    ## Keep track of the darkest and lightest colors
    my $darkest = undef;
    my $lightest = undef;

    for($i = 0; $i < $lines; $i++)
    {
        my $line_color = $image->colorAllocate($red, $green, $blue);

        ## Draw line at the top of the image
        $image->line(0, $i, $width, $i, $line_color);

        ## Draw line at the bottom of the image
        $image->line(0, $height - $i, $width, $height - $i, $line_color);

        ## Modify the color values
        if( $red < $max_color && $green < $max_color && $blue < $max_color )
        {
            $red += $color_deviation;
            $green += $color_deviation;
            $blue += $color_deviation;
        }

        $darkest = $line_color if( !$darkest );
        $lightest = $line_color;
    }

    return ($darkest, $lightest);
}




## Determine the image dimensions to use based on the selected fonts
sub CalculateImageDimensions
{
    my $code = shift;
    my $required_width = $padding_x;
    my $required_height = undef;

    for( @$code )
    {
        my $character = $_;

        $required_width += $character->{'Width'} + $padding_chars;
        $required_height = $character->{'Height'} + $padding_y if( $character->{'Height'} + $padding_y > $required_height );
    }

    return ($required_width, $required_height);
}



## Add random dots to the image
sub AddDots
{
    my $image = shift;
    my $i = 0;

    for($i = 0; $i < $image_width * $dot_density; $i++)
    {
        my $color = int(rand(2)) ? $bg_dark : $bg_light;

        $image->setPixel(rand($image_width), rand($image_height), $color);
    }
}



## Generate the code to display on the image
sub GenerateCode
{
    my $code = [];

    if( $O_USE_WORDS )
    {
        my $words = FileReadArray("$DDIR/words");
        my $word = @$words[rand @$words];

        $word =~ s/[\r\n]//g;

        for( split(//, $word) )
        {
            push(@$code, GetCharacter($_));
        }
    }
    else
    {        
        my $length = RandRange($MIN_CODE_LENGTH, $MAX_CODE_LENGTH);    

        for( 1..$length )
        {
            push(@$code, GetCharacter());
        }        
    }

    return $code;
}



## Select the next character to use in the code
sub GetCharacter
{
    my $angle = RandomAngle();
    my $selected = shift || $allowed_chars[rand @allowed_chars];
    my $font_size = RandRange($min_font_size, $max_font_size);
    my $font = $fonts->[rand @$fonts];
    my @bounds = GD::Image->stringFT(undef, "$FONT_DIR/$font", $font_size, $angle, 0, 0, $selected);
    my $hash = {};

    # @bounds[0,1] Lower left corner (x,y) 
    # @bounds[2,3] Lower right corner (x,y) 
    # @bounds[4,5] Upper right corner (x,y) 
    # @bounds[6,7] Upper left corner (x,y)

    $hash->{'Character'} = $selected;
    $hash->{'Angle'} = $angle;
    $hash->{'Font'} = "$FONT_DIR/$font";
    $hash->{'FontSize'} = $font_size;

    if( $angle > 0 )
    {
        $hash->{'Height'} = abs($bounds[5]);
        $hash->{'Width'} = abs($bounds[6]) + $bounds[2];
        $hash->{'X'} = abs($bounds[6]);
        $hash->{'Y'} = $hash->{'Height'};
    }
    else
    {
        $hash->{'Height'} = abs($bounds[7]) + $bounds[3];
        $hash->{'Width'} = $bounds[4];
        $hash->{'X'} = 0;
        $hash->{'Y'} = $hash->{'Height'} - $bounds[3];
    }

    return $hash;
}



## Generate a random number from a defined range
sub RandRange
{
    my $lower_limit = shift;
    my $upper_limit = shift;
    my $rand_input = $upper_limit - $lower_limit + 1;

    return int(rand($rand_input)) + $lower_limit;
}



## Get the smallest value from an array
sub GetSmallest
{
    my $array = shift;
    my $smallest = $array->[0];

    for( @$array )
    {
        if( $_ < $smallest )
        {
            $smallest = $_;
        }
    }

    return $smallest;
}



## Generate a random angle in radians
sub RandomAngle
{
    if( int(rand(2)) )
    {
        return rand(0.375);
    }
    else
    {
        return -rand(0.375);
    }
}



## Display test output to make sure font files are valid
sub DisplayTest
{
    my $font_file = "$FONT_DIR/$ENV{'QUERY_STRING'}";
    my $font_size = 24;
    my $code = join(' ', @allowed_chars);

    FileTaint($font_file);

    ## Make sure the font file exists
    if( !-f $font_file )
    {
        Header("Content-type: text/html\n\n");
        print "The font file '$ENV{'QUERY_STRING'}' does not exist";
        exit;
    }


    my @bounds = GD::Image->stringFT(undef, $font_file, $font_size, 0, 0, 0, $code);

    my $image_height = $bounds[1] - $bounds[7] + 10;
    my $image_width  = $bounds[2] + 10;

    ## Create a new image
    $image = new GD::Image($image_width, $image_height);

    ## Allocate the colors for the image
    my $bg_color = $image->colorAllocate(240, 240, 220);
    my $font_color = $image->colorAllocate(0, 0, 0);


    ## Fill the image with the background color
    $image->fill(0, 0, $bg_color);


    ## Write the submit code onto the image
    $image->stringFT($font_color, $font_file, $font_size, 0, 5+$bounds[6], $image_height-$bounds[1]-5, $code);

    ## Display the image
    Header("Content-type: image/png\n\n");
    print $image->png;
}

