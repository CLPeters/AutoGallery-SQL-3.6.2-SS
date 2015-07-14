my $module = 1;
my $default_sharpen = '0.0x0.6';
my $default_compose = 'over'; 

eval('use Image::Magick;');


if( $@ )
{
    $module = 0;
}

my %offsets;


if( $MAGICK6 )
{
    %offsets = ('NorthEast' => {'Shadow' => {'x' => 2, 'y' =>  0}, 'Text' => {'x' => 3, 'y' => -1}},
                'North'     => {'Shadow' => {'x' => 3, 'y' =>  0}, 'Text' => {'x' => 2, 'y' => -1}},
                'NorthWest' => {'Shadow' => {'x' => 3, 'y' =>  0}, 'Text' => {'x' => 2, 'y' => -1}},
                'SouthEast' => {'Shadow' => {'x' => 2, 'y' => -1}, 'Text' => {'x' => 3, 'y' =>  0}},
                'South'     => {'Shadow' => {'x' => 3, 'y' => -1}, 'Text' => {'x' => 2, 'y' =>  0}},
                'SouthWest' => {'Shadow' => {'x' => 3, 'y' => -1}, 'Text' => {'x' => 2, 'y' =>  0}});
}
else
{
    %offsets = ('NorthEast' => {'Shadow' => {'x' => 1, 'y' =>  -3}, 'Text' => {'x' => 2, 'y' => -4}},
                'North'     => {'Shadow' => {'x' => 1, 'y' =>  -3}, 'Text' => {'x' => 0, 'y' => -4}},
                'NorthWest' => {'Shadow' => {'x' => 2, 'y' =>  -3}, 'Text' => {'x' => 1, 'y' => -4}},
                'SouthEast' => {'Shadow' => {'x' => 1, 'y' => 3}, 'Text' => {'x' => 2, 'y' =>  4}},
                'South'     => {'Shadow' => {'x' => 1, 'y' => 3}, 'Text' => {'x' => 0, 'y' =>  4}},
                'SouthWest' => {'Shadow' => {'x' => 2, 'y' => 3}, 'Text' => {'x' => 1, 'y' =>  4}});
}


sub ApplyFilter
{
    my $file = shift;
    my $filter = shift;
    my @input = @_;

    $module ? PMDApplyFilter($file, $filter, @input) : CLIApplyFilter($file, $filter, @input);
}


sub AutoResize
{
    $module ? PMDAutoResize(shift, shift, shift) : CLIAutoResize(shift, shift, shift);
}



sub ManualResize
{
    $module ? PMDManualResize(shift, shift) : CLIManualResize(shift, shift);
}



sub Annotate
{
    $module ? PMDAnnotate(shift, shift) : CLIAnnotate(shift, shift);
}



sub PMDApplyFilter
{
    my $file = shift;
    my $filter = shift;
    my @input = @_;
    my $image = new Image::Magick;

    my $result = $image->Read($file);    

    if( $result )
    {
        return 0;
    }   

    $image->Set('sampling-factor' => '1x1');
    $image->Set(quality => '100');

    if( $filter eq 'sharpen' )
    {
        $image->Sharpen("0.0x$input[0]");
    }
    elsif( $filter eq 'brightness' )
    {
        $image->Gamma(gamma => $input[0]);
    }
    elsif( $filter eq 'contrastup' )
    {
        $image->Contrast(sharpen => 'true');
    }
    elsif( $filter eq 'contrastdown' )
    {
        $image->Contrast(sharpen => 'false');
    }
    elsif( $filter eq 'normalize' )
    {
        $image->Normalize();
    }
    elsif( $filter eq 'annotation' )
    {
        PMDAnnotate($image, $input[0]);
    }
    elsif( $filter eq 'compress' )
    {
        $image->Set(quality => $THUMB_QUALITY);
    }
    
    $image->Write($file);
}



sub PMDAutoResize
{
    my $buffer      = shift;
    my $temp_name   = shift;
    my $annotation  = shift;
    my $width       = $THUMB_WIDTH   || 100;
    my $height      = $THUMB_HEIGHT  || 100;
    my $quality     = $THUMB_QUALITY || 80;
    my $image       = undef;
    my $result      = undef;
    my $orig_width  = 0;
    my $orig_height = 0;
    my $new_width   = 0;
    my $new_height  = 0;
    my $src_x       = 0;
    my $src_y       = 0;

    if( ref($buffer) )
    {
        FileWrite("$THUMB_DIR/$temp_name.jpg", $$buffer);
        $buffer = "$THUMB_DIR/$temp_name.jpg";
    }

    $image  = new Image::Magick;
    $result = $image->Read($buffer);

    if( $result )
    {
        FileRemove($buffer);
        return 0;
    }

    ($orig_width, $orig_height) = $image->Get('width', 'height');

    $new_width  = $width;
    $new_height = $orig_height*($width/$orig_width);
    $src_x      = 0;
    $src_y      = ($new_height-$height)/2;

    if( $new_height < $height )
    {
        $new_width  = $orig_width*($height/$orig_height);
        $new_height = $height;
        $src_x      = ($new_width-$width)/2;
        $src_y      = 0;
    }
    
    $image->Profile(name => '*');
    $image->Set(quality => $quality);
    $image->Set('sampling-factor' => '1x1');
    #$image->Set('units' => 'PixelsPerInch');
    #$image->Set('density' => '100x100');
    $image->Strip() if( $MAGICK6 );
    $image->Resize(width=>$new_width, height=>$new_height, filter=>Lanczos, blur=>1.0);
    $image->Crop(width=>$width, height=>$height, x=>$src_x, y=>$src_y);
    $image->Sharpen($default_sharpen);
    #$image->Enhance();

    PMDAnnotate($image, $annotation);

    $image->Write($buffer);
}



sub PMDAnnotate
{
    my $file = shift;
    my $annotation = shift;
    my $image = undef;
    my $result = undef;
    my $height = undef;
    my $quality = $THUMB_QUALITY || 80;

    if( !$annotation || $annotation->{'Type'} eq 'None' )
    {
        return;
    }

    
    ## Working with an existing object
    if( ref($file) )
    {
        $image = $file;
    }

    ## Need to read from file
    else
    {
        $image  = new Image::Magick;
        $result = $image->Read($file);

        if( $result )
        {
            FileRemove($file);
            return 0;
        }
    }


    if( $annotation->{'Type'} eq 'Text' && -e "$ANNOTATION_DIR/$annotation->{'Font_File'}" )
    {
        if( $MAGICK5 )
        {
            $offsets{$annotation->{'Location'}}->{'Shadow'}->{'y'} += $annotation->{'Size'};
            $offsets{$annotation->{'Location'}}->{'Text'}->{'y'} += $annotation->{'Size'};
        }

        $image->Annotate(text => $annotation->{'String'}, 
                         font => "$ANNOTATION_DIR/$annotation->{'Font_File'}", 
                         pointsize => $annotation->{'Size'},
                         fill => $annotation->{'Shadow'}, 
                         gravity => $annotation->{'Location'},
                         x => $offsets{$annotation->{'Location'}}->{'Shadow'}->{'x'}, 
                         y => $offsets{$annotation->{'Location'}}->{'Shadow'}->{'y'});

        $image->Annotate(text => $annotation->{'String'}, 
                         font => "$ANNOTATION_DIR/$annotation->{'Font_File'}", 
                         pointsize => $annotation->{'Size'},
                         fill => $annotation->{'Color'}, 
                         gravity => $annotation->{'Location'},
                         x => $offsets{$annotation->{'Location'}}->{'Text'}->{'x'}, 
                         y => $offsets{$annotation->{'Location'}}->{'Text'}->{'y'});
    }
    elsif( $annotation->{'Type'} eq 'Image' && -e "$ANNOTATION_DIR/$annotation->{'Image_File'}" )
    {
        $overlay = new Image::Magick;
        $overlay->Read("$ANNOTATION_DIR/$annotation->{'Image_File'}");

        if( $annotation->{'Transparency'} )
        {
            $overlay->Transparent(color => $annotation->{'Transparency'});
        }

        $image->Composite(image => $overlay,
                          compose => $default_compose,
                          gravity => $annotation->{'Location'},
                          x => 2,
                          y => 2);
    }

    ## Save file
    if( !ref($file) )
    {
        $image->Set('sampling-factor' => '1x1');
        $image->Strip() if( $MAGICK6 );
        $image->Profile(name => '*');
        $image->Set(quality => $quality);
        $image->Write($file);
    }
}



sub PMDManualResize
{
    my $buffer = shift;
    my $annotation = shift;
    my $width = $THUMB_WIDTH || 100;
    my $height = $THUMB_HEIGHT || 100;
    my $quality = $THUMB_QUALITY || 80;
    my $image = undef;
    my $result = undef;

    $image  = new Image::Magick;
    $result = $image->Read($buffer);

    if( $result )
    {
        Error($result, $buffer);
    }

    $image->Profile(name => '*');
    $image->Set('sampling-factor' => '1x1');
    #$image->Set('units' => 'PixelsPerInch');
    #$image->Set('density' => '100x100');
    $image->Set(quality => $quality);
    $image->Strip() if( $MAGICK6 );
    $image->Crop(width=>$F{'width'}, height=>$F{'height'}, x=>$F{'x'}, y=>$F{'y'});

    if( $F{'width'} != $width || $F{'height'} != $height )
    {
        $image->Resize(width=>$width, height=>$height, filter=>Lanczos, blur=>1.0);

        if( !$F{'filter'} )
        {
            $image->Sharpen($default_sharpen);
        }

        #$image->Enhance();
    }

    PMDAnnotate($image, $annotation);

    $image->Write($buffer);
}



sub CLIAutoResize
{
    my $buffer      = shift;
    my $temp_name   = shift;
    my $annotation  = shift;
    my $width       = $THUMB_WIDTH   || 100;
    my $height      = $THUMB_HEIGHT  || 100;
    my $quality     = $THUMB_QUALITY || 80;
    my $orig_width  = 0;
    my $orig_height = 0;
    my $new_width   = 0;
    my $new_height  = 0;
    my $src_x       = 0;
    my $src_y       = 0;
    my $resize_cmd  = undef;
    my $crop_cmd    = undef;
    my $shadow_cmd  = undef;
    my $text_cmd    = undef;
    my $overlay_cmd = undef;
    my $compress_cmd = undef;

    if( ref($buffer) )
    {
        FileWrite("$THUMB_DIR/$temp_name.jpg", $$buffer);
        $buffer = "$THUMB_DIR/$temp_name.jpg";
    }

    if( `$IDENTIFY -format %wx%h $buffer` =~ /(\d+)x(\d+)/ )
    {
        $orig_width  = $1;
        $orig_height = $2;

        $new_width  = $width;
        $new_height = int($orig_height*($width/$orig_width));
        $src_x      = 0;
        $src_y      = int(($new_height-$height)/2);

        if( $new_height < $height )
        {
            $new_width  = int($orig_width*($height/$orig_height));
            $new_height = $height;
            $src_x      = int(($new_width-$width)/2);
            $src_y      = 0;
        }

        $resize_cmd = "-compress JPEG " .
                      "-quality 100 " .
                      "-sampling-factor 1x1 " . 
                      "-filter Lanczos " .
                      "-resize $new_width" . "x$new_height " . 
                      ($MAGICK6 ? "-strip " : '') .
                      "$buffer " .
                      "$buffer";

        $crop_cmd = "+profile \"*\" " . 
                    "-compress JPEG " .
                    "-quality 100 " .  
                    "-sampling-factor 1x1 " . 
                    "-crop $width" . "x$height+$src_x+$src_y " .
                    "-sharpen $default_sharpen " .                    
                    "$buffer " .
                    "$buffer";

        $compress_cmd = "-compress JPEG " .
                        "-quality $quality " .
                        "-sampling-factor 1x1 " . 
                        "$buffer " .
                        "$buffer";

        system("$CONVERT $resize_cmd 2>&1");
        system("$CONVERT $crop_cmd 2>&1");        

        CLIAnnotate($buffer, $annotation, 1);        

        system("$CONVERT $compress_cmd 2>&1");
    }
    else
    {
        unlink("$THUMB_DIR/$temp_name.jpg");
    }
}



sub CLIAnnotate
{
    my $buffer = shift;
    my $annotation = shift;
    my $no_compress = shift;
    my $quality = $THUMB_QUALITY || 80;
    my $shadow_cmd = undef;
    my $text_cmd = undef;
    my $overlay_cmd = undef;
    my $compress_cmd = undef;
    my $shadow_off = undef;
    my $text_off = undef;

    if( !$annotation || $annotation->{'Type'} eq 'None' )
    {
        return;
    }

    if( $annotation->{'Type'} eq 'Text' )
    {
        if( $MAGICK5 )
        {
            $offsets{$annotation->{'Location'}}->{'Shadow'}->{'y'} += $annotation->{'Size'};
            $offsets{$annotation->{'Location'}}->{'Text'}->{'y'} += $annotation->{'Size'};
        }

        $shadow_off = "$offsets{$annotation->{'Location'}}->{'Shadow'}->{'x'},$offsets{$annotation->{'Location'}}->{'Shadow'}->{'y'}";
        $text_off = "$offsets{$annotation->{'Location'}}->{'Text'}->{'x'},$offsets{$annotation->{'Location'}}->{'Text'}->{'y'}";

        $shadow_cmd = "-compress JPEG " .
                      "-quality 100 " .
                      "-sampling-factor 1x1 " . 
                      "-font $ANNOTATION_DIR/$annotation->{'Font_File'} " .
                      "-pointsize $annotation->{'Size'} " .
                      "-fill '$annotation->{'Shadow'}' " .
                      "-draw 'gravity $annotation->{'Location'} text $shadow_off \"$annotation->{'String'}\"' " .
                      "$buffer " .
                      "$buffer";

        $text_cmd = "-compress JPEG " .
                    "-quality 100 " .
                    "-sampling-factor 1x1 " . 
                    "-font $ANNOTATION_DIR/$annotation->{'Font_File'} " .
                    "-pointsize $annotation->{'Size'} " .
                    "-fill '$annotation->{'Color'}' " .
                    "-draw 'gravity $annotation->{'Location'} text $text_off \"$annotation->{'String'}\"' " .
                    "$buffer " .
                    "$buffer";

        system("$CONVERT $shadow_cmd 2>&1");
        system("$CONVERT $text_cmd 2>&1");
    }
    elsif( $annotation->{'Type'} eq 'Image' && $COMPOSITE )
    {
        $overlay_cmd = "-compress JPEG " .
                       "-quality 100 " .
                       "-sampling-factor 1x1 " . 
                       "-gravity $annotation->{'Location'} " .
                       "-compose $default_compose " .
                       "-geometry +2+2 " .
                       "$ANNOTATION_DIR/$annotation->{'Image_File'} " .
                       "$buffer " .
                       "$buffer";

        system("$COMPOSITE $overlay_cmd 2>&1");
    }


    if( !$no_compress )
    {
        $compress_cmd = "-compress JPEG " .
                        "-quality $quality " .
                        "-sampling-factor 1x1 " . 
                        "$buffer " .
                        "$buffer";

        system("$CONVERT $compress_cmd 2>&1");
    }
}



sub CLIManualResize
{
    my $buffer = shift;
    my $annotation = shift;
    my $width = $THUMB_WIDTH   || 100;
    my $height = $THUMB_HEIGHT  || 100;
    my $quality = $THUMB_QUALITY || 80;
    my $sharpen = undef;

    if( !$F{'filter'} )
    {
        $sharpen = "-sharpen $default_sharpen";
    }

    $resize_cmd = "-compress JPEG " .
                  "-quality 100 " .
                  "-sampling-factor 1x1 " . 
                  "-filter Lanczos " .
                  "-resize $width" . "x$height " .                   
                  "$sharpen " .
                  ($MAGICK6 ? "-strip " : '') .
                  "$buffer " .
                  "$buffer";

    $crop_cmd = "+profile \"*\" " . 
                "-compress JPEG " .
                "-quality 100 " .
                "-sampling-factor 1x1 " .            
                "-crop $F{'width'}x$F{'height'}+$F{'x'}+$F{'y'} " .
                "$buffer " .
                "$buffer";

    $compress_cmd = "-compress JPEG " .
                    "-quality $quality " .
                    "-sampling-factor 1x1 " . 
                    "$buffer " .
                    "$buffer";

    system("$CONVERT $crop_cmd 2>&1");
    system("$CONVERT $resize_cmd 2>&1");    

    CLIAnnotate($buffer, $annotation, 1);   

    if( !$F{'filter'} )
    {
        system("$CONVERT $compress_cmd 2>&1");
    }
}



sub CLIApplyFilter
{
    my $file = shift;
    my $filter = shift;
    my @input = @_;
    my $command = undef;

    if( $filter eq 'sharpen' )
    {
        $command = "-sharpen 0.0x$input[0] " .
                   "-compress JPEG " .
                   "-quality 100 " .
                   "$file " .
                   "$file";
    }
    elsif( $filter eq 'brightness' )
    {
        $command = "-gamma $input[0] " .
                   "-compress JPEG " .
                   "-quality 100 " .
                   "$file " .
                   "$file";
    }
    elsif( $filter eq 'contrastup' )
    {
        $command = "-contrast " .
                   "-compress JPEG " .
                   "-quality 100 " .
                   "$file " .
                   "$file";
    }
    elsif( $filter eq 'contrastdown' )
    {
        $command = "+contrast " .
                   "-compress JPEG " .
                   "-quality 100 " .
                   "$file " .
                   "$file";
    }
    elsif( $filter eq 'normalize' )
    {
        $command = "-normalize " .
                   "-compress JPEG " .
                   "-quality 100 " .
                   "$file " .
                   "$file";
    }    
    elsif( $filter eq 'annotation' )
    {
        CLIAnnotate($file, $input[0]);
    }
    elsif( $filter eq 'compress' )
    {
        $command = "-compress JPEG " .
                   "-quality $THUMB_QUALITY " .
                   "$file " .
                   "$file";
    }
    
    if( $command )
    {
        system("$CONVERT $command 2>&1");
    }
}

1;
