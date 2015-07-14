##
## Code adapted from the Image::Size Perl module (c) 2000 by Randy J. Ray
##


# Package lexicals - invisible to outside world, used only in imgsize
my %type_map = ( '^GIF8[7,9]a'              => \&gifsize,
                 "^\xFF\xD8"                => \&jpegsize,
                 "^\x89PNG\x0d\x0a\x1a\x0a" => \&pngsize,
                 '^MM\x00\x2a'              => \&tiffsize,
                 '^II\x2a\x00'              => \&tiffsize,
                 '^BM'                      => \&bmpsize,
                 );


#
# These are lexically-scoped anonymous subroutines for reading the three
# types of input streams. When the input to imgsize() is typed, then the
# lexical "read_in" is assigned one of these, thus allowing the individual
# routines to operate on these streams abstractly.
#

my $read_io = sub {
    my $handle = shift;
    my ($length, $offset) = @_;

    if (defined($offset) && ($offset != $last_pos))
    {
        $last_pos = $offset;
        return '' if (! seek($handle, $offset, 0));
    }

    my ($data, $rtn) = ('', 0);
    $rtn = read $handle, $data, $length;
    $data = '' unless ($rtn);
    $last_pos = tell $handle;

    $data;
};

my $read_buf = sub {
    my $buf = shift;
    my ($length, $offset) = @_;

    if (defined($offset) && ($offset != $last_pos))
    {
        $last_pos = $offset;
        return '' if ($last_pos > length($$buf));
    }

    my $data = substr($$buf, $last_pos, $length);
    $last_pos += length($data);

    $data;
};

sub imgsize
{
    my $stream = shift;

    my ($handle, $header);
    my ($x, $y, $id, $mtime, @list);
    # These only used if $stream is an existant open FH
    my ($save_pos, $need_restore) = (0, 0);
    # This is for when $stream is a locally-opened file
    my $need_close = 0;
    # This will contain the file name, if we got one
    my $file_name = undef;

    $header = '';
    $last_pos = 0;

    if (ref($stream) eq "SCALAR")
    {
        $handle  = $stream;
        $read_in = $read_buf;
        $header  = substr(($$handle || ''), 0, 256);
    }
    else
    {
        return (undef, undef, "Must be scalar reference");
    }

    $id = "Data stream is not a known image file format";
    $x  = undef;
    $y  = undef;


    for( keys %type_map )
    {
        if( $header =~ /$_/ )
        {
            return &{$type_map{$_}}($handle);
        }
    }


    # results:
    return (wantarray) ? ($x, $y, $id) : ();
}



# This used only in gifsize:
sub img_eof
{
    my $stream = shift;

    return ($last_pos >= length($$stream)) if (ref($stream) eq "SCALAR");

    eof $stream;
}


###########################################################################
# Subroutine gets the size of the specified GIF
###########################################################################
sub gifsize
{
    my $stream = shift;

    my ($cmapsize, $buf, $h, $w, $x, $y, $type);

    my $gif_blockskip = sub {
        my ($skip, $type) = @_;
        my ($lbuf);

        &$read_in($stream, $skip);        # Skip header (if any)
        while (1)
        {
            if (&img_eof($stream))
            {
                return (undef, undef,
                        "Invalid/Corrupted GIF (at EOF in GIF $type)");
            }
            $lbuf = &$read_in($stream, 1);        # Block size
            last if ord($lbuf) == 0;     # Block terminator
            &$read_in($stream, ord($lbuf));  # Skip data
        }
    };

    $type = &$read_in($stream, 6);
    if (length($buf = &$read_in($stream, 7)) != 7 )
    {
        return (undef, undef, "Invalid/Corrupted GIF (bad header)");
    }
    ($x) = unpack("x4 C", $buf);
    if ($x & 0x80)
    {
        $cmapsize = 3 * (2**(($x & 0x07) + 1));
        if (! &$read_in($stream, $cmapsize))
        {
            return (undef, undef,
                    "Invalid/Corrupted GIF (global color map too small?)");
        }
    }

  FINDIMAGE:
    while (1)
    {
        if (&img_eof($stream))
        {
            return (undef, undef,
                    "Invalid/Corrupted GIF (at EOF w/o Image Descriptors)");
        }
        $buf = &$read_in($stream, 1);
        ($x) = unpack("C", $buf);
        if ($x == 0x2c)
        {
            # Image Descriptor (GIF87a, GIF89a 20.c.i)
            if (length($buf = &$read_in($stream, 8)) != 8)
            {
                return (undef, undef,
                        "Invalid/Corrupted GIF (missing image header?)");
            }
            ($x, $w, $y, $h) = unpack("x4 C4", $buf);
            $x += $w * 256;
            $y += $h * 256;
            return ($x, $y, 'GIF');
        }
        if ($x == 0x21)
        {
            # Extension Introducer (GIF89a 23.c.i, could also be in GIF87a)
            $buf = &$read_in($stream, 1);
            ($x) = unpack("C", $buf);
            if ($x == 0xF9)
            {
                # Graphic Control Extension (GIF89a 23.c.ii)
                &$read_in($stream, 6);    # Skip it
                next FINDIMAGE;       # Look again for Image Descriptor
            }
            elsif ($x == 0xFE)
            {
                # Comment Extension (GIF89a 24.c.ii)
                &$gif_blockskip(0, "Comment");
                next FINDIMAGE;       # Look again for Image Descriptor
            }
            elsif ($x == 0x01)
            {
                # Plain Text Label (GIF89a 25.c.ii)
                &$gif_blockskip(13, "text data");
                next FINDIMAGE;       # Look again for Image Descriptor
            }
            elsif ($x == 0xFF)
            {
                # Application Extension Label (GIF89a 26.c.ii)
                &$gif_blockskip(12, "application data");
                next FINDIMAGE;       # Look again for Image Descriptor
            }
            else
            {
                return (undef, undef,
                        sprintf("Invalid/Corrupted GIF (Unknown " .
                                "extension %#x)", $x));
            }
        }
        else
        {
            return (undef, undef,
                    sprintf("Invalid/Corrupted GIF (Unknown code %#x)",
                            $x));
        }
    }
}



# pngsize : gets the width & height (in pixels) of a png file
# cor this program is on the cutting edge of technology! (pity it's blunt!)
#
# Re-written and tested by tmetro@vl.com
sub pngsize
{
    my $stream = shift;

    my ($x, $y, $id) = (undef, undef, "could not determine PNG size");
    my ($offset, $length);

    # Offset to first Chunk Type code = 8-byte ident + 4-byte chunk length + 1
    $offset = 12; $length = 4;
    if (&$read_in($stream, $length, $offset) eq 'IHDR')
    {
        # IHDR = Image Header
        $length = 8;
        ($x, $y) = unpack("NN", &$read_in($stream, $length));
        $id = 'PNG';
    }

    ($x, $y, $id);
}


# jpegsize: gets the width and height (in pixels) of a jpeg file
# Andrew Tong, werdna@ugcs.caltech.edu           February 14, 1995
# modified slightly by alex@ed.ac.uk
# and further still by rjray@blackperl.com
# optimization and general re-write from tmetro@vl.com
sub jpegsize
{
    my $stream = shift;

    my $MARKER      = "\xFF";       # Section marker.

    my $SIZE_FIRST  = 0xC0;         # Range of segment identifier codes
    my $SIZE_LAST   = 0xC3;         #  that hold size info.

    my ($x, $y, $id) = (undef, undef, "could not determine JPEG size");

    my ($marker, $code, $length);
    my $segheader;

    # Dummy read to skip header ID
    &$read_in($stream, 2);
    while (1)
    {
        $length = 4;
        $segheader = &$read_in($stream, $length);

        # Extract the segment header.
        ($marker, $code, $length) = unpack("a a n", $segheader);

        # Verify that it's a valid segment.
        if ($marker ne $MARKER)
        {
            # Was it there?
            $id = "JPEG marker not found";
            last;
        }
        elsif ((ord($code) >= $SIZE_FIRST) && (ord($code) <= $SIZE_LAST))
        {
            # Segments that contain size info
            $length = 5;
            ($y, $x) = unpack("xnn", &$read_in($stream, $length));
            $id = 'JPG';
            last;
        }
        else
        {
            # Dummy read to skip over data
            &$read_in($stream, ($length - 2));
        }
    }

    ($x, $y, $id);
}


# tiffsize: size a TIFF image
#
# Contributed by Cloyce Spradling <cloyce@headgear.org>
sub tiffsize {
    my $stream = shift;

    my ($x, $y, $id) = (undef, undef, "Unable to determine size of TIFF data");

    my $endian = 'n';           # Default to big-endian; I like it better
    my $header = &$read_in($stream, 4);
    $endian = 'v' if ($header =~ /II\x2a\x00/o); # little-endian

    # Set up an association between data types and their corresponding
    # pack/unpack specification.  Don't take any special pains to deal with
    # signed numbers; treat them as unsigned because none of the image
    # dimensions should ever be negative.  (I hope.)
    my @packspec = ( undef,     # nothing (shouldn't happen)
                     'C',       # BYTE (8-bit unsigned integer)
                     undef,     # ASCII
                     $endian,   # SHORT (16-bit unsigned integer)
                     uc($endian), # LONG (32-bit unsigned integer)
                     undef,     # RATIONAL
                     'c',       # SBYTE (8-bit signed integer)
                     undef,     # UNDEFINED
                     $endian,   # SSHORT (16-bit unsigned integer)
                     uc($endian), # SLONG (32-bit unsigned integer)
                     );

    my $offset = &$read_in($stream, 4, 4); # Get offset to IFD
    $offset = unpack(uc($endian), $offset); # Fix it so we can use it

    my $ifd = &$read_in($stream, 2, $offset); # Get number of directory entries
    my $num_dirent = unpack($endian, $ifd); # Make it useful
    $offset += 2;
    $num_dirent = $offset + ($num_dirent * 12); # Calc. maximum offset of IFD

    # Do all the work
    $ifd = '';
    my $tag = 0;
    my $type = 0;
    while (!defined($x) || !defined($y)) {
        $ifd = &$read_in($stream, 12, $offset); # Get first directory entry
        last if (($ifd eq '') || ($offset > $num_dirent));
        $offset += 12;
        $tag = unpack($endian, $ifd); # ...and decode its tag
        $type = unpack($endian, substr($ifd, 2, 2)); # ...and the data type
        # Check the type for sanity.
        next if (($type > @packspec+0) || (!defined($packspec[$type])));
        if ($tag == 0x0100) {   # ImageWidth (x)
            # Decode the value
            $x = unpack($packspec[$type], substr($ifd, 8, 4));
        } elsif ($tag == 0x0101) {      # ImageLength (y)
            # Decode the value
            $y = unpack($packspec[$type], substr($ifd, 8, 4));
        }
    }

    # Decide if we were successful or not
    if (defined($x) && defined($y)) {
        $id = 'TIF';
    } else {
        $id = '';
        $id = 'ImageWidth ' if (!defined($x));
        if (!defined ($y)) {
            $id .= 'and ' if ($id ne '');
            $id .= 'ImageLength ';
        }
        $id .= 'tag(s) could not be found';
    }

    ($x, $y, $id);
}

# bmpsize: size a Windows-ish BitMaP image
#
# Adapted from code contributed by Aldo Calpini <a.calpini@romagiubileo.it>
sub bmpsize
{
    my $stream = shift;

    my ($x, $y, $id) = (undef, undef, "Unable to determine size of BMP data");
    my ($buffer);

    $buffer = &$read_in($stream, 26);
    ($x, $y) = unpack("x18VV", $buffer);
    $id = 'BMP' if (defined $x and defined $y);

    ($x, $y, $id);
}



1;
