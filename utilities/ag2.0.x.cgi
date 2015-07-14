#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
######################################################################
##  ag2.0.x.cgi - Utility to export data from AutoGallery 2.0.x     ##
######################################################################

$|++;

print "Content-type: text/html\n\n<pre>\n";


eval
{
    require 'ag.pl';
    $HEADER = 1;
    main();
};


err("$@", 'ag2.0.x.cgi') if( $@ );


sub main
{
    my $data = {};

    if( $VERSION !~ /^2\.0\.\d+/ )
    {
        print "Could not locate a 2.0.x installation of AutoGallery";
        exit;
    }

    print "Exporting AutoGallery v$VERSION data\n\n\n";


    ## Export the MySQL database
    print "  Exporting galleries.......";

    my @dbs = ('queue', 'current');

    for( @dbs )
    {
        my $db = $_;
   
        if( -f "$DDIR/dbs/$db" )
        {
            open(GALLERIES, "$DDIR/dbs/$db");
            for( <GALLERIES> )
            {
                my $line = $_;

                chomp($line);

                ($g->{'Gallery_ID'},
                 $g->{'Email'},
                 $g->{'Gallery_URL'},
                 $g->{'Description'},
                 $junk,
                 $junk,
                 $g->{'Thumbnails'},
                 $g->{'Category'},
                 $g->{'Added_Date'},
                 $g->{'Added_Stamp'},
                 $g->{'Approve_Stamp'},
                 $junk,
                 $g->{'Account_ID'},
                 $g->{'Moderator'},
                 $junk,
                 $g->{'Submit_IP'},
                 $g->{'Scanned'},
                 $g->{'Has_Recip'}) = split(/\|/, $line);

                $g->{'Sponsor'} = '';
                $g->{'Has_Thumb'} = 0;
                $g->{'Thumbnail_URL'} = undef;
                $g->{'Thumb_Width'} = undef;
                $g->{'Thumb_Height'} = undef;
                $g->{'Weight'} = 1.000;
                $g->{'Nickname'} = '';
                $g->{'Clicks'} = 0;
                $g->{'Type'} = 'Submitted';
                $g->{'Format'} = 'Pictures';
                $g->{'Status'} = 'Approved';
                $g->{'Confirm_ID'} = undef;
                $g->{'Added_Date'} = fdate('%Y-%m-%d', $g->{'Added_Stamp'} + 3600 * $TIME_ZONE);
                $g->{'Scheduled_Date'} = undef;
                $g->{'Display_Date'} = undef;
                $g->{'Delete_Date'} = undef;
                $g->{'Account_ID'} = $g->{'Account_ID'} eq '-' ? '' : $g->{'Account_ID'};
                $g->{'Moderator'} = $g->{'Moderator'} eq '-' ? undef : $g->{'Moderator'};
                $g->{'Gallery_IP'} = '';
                $g->{'Scanned'} = 0;
                $g->{'Links'} = 0;
                $g->{'Has_Recip'} = 0;
                $g->{'Page_Bytes'} = 0;
                $g->{'Page_ID'} = '';
                $g->{'Speed'} = 0.0;
                $g->{'Icons'} = '';
                $g->{'Allow_Scan'} = 1;
                $g->{'Allow_Thumb'} = 1;
                $g->{'Times_Selected'} = 0;
                $g->{'Used_Counter'} = 1;
                $g->{'Build_Counter'} = 1;
                $g->{'Keywords'} = '';
                $g->{'Comments'} = undef;
                $g->{'Tag'} = undef;

                if( $db eq 'queue' )
                {
                    $g->{'Status'} = 'Pending';
                    $g->{'Approve_Date'} = undef;
                    $g->{'Approve_Stamp'} = undef;
                }
                else
                {
                    $g->{'Status'} = 'Approved';
                    $g->{'Approve_Date'} = fdate('%Y-%m-%d', $g->{'Approve_Stamp'} + 3600 * $TIME_ZONE);
                }

                $data->{'sql'} .= "INSERT INTO ags_Galleries VALUES (" .
                          MakeList([$g->{'Gallery_ID'},
                          $g->{'Email'},
                          $g->{'Gallery_URL'},
                          $g->{'Description'},
                          $g->{'Thumbnails'},
                          $g->{'Category'},
                          $g->{'Sponsor'},
                          $g->{'Has_Thumb'},
                          $g->{'Thumbnail_URL'},
                          $g->{'Thumb_Width'},
                          $g->{'Thumb_Height'},
                          $g->{'Weight'},
                          $g->{'Nickname'},
                          $g->{'Clicks'},
                          $g->{'Type'},
                          $g->{'Format'},
                          $g->{'Status'},
                          $g->{'Confirm_ID'},
                          $g->{'Added_Date'},
                          $g->{'Added_Stamp'},
                          $g->{'Approve_Date'},
                          $g->{'Approve_Stamp'},
                          $g->{'Scheduled_Date'},
                          $g->{'Display_Date'},
                          $g->{'Delete_Date'},
                          $g->{'Account_ID'},
                          $g->{'Moderator'},
                          $g->{'Submit_IP'},
                          $g->{'Gallery_IP'},
                          $g->{'Scanned'},
                          $g->{'Links'},
                          $g->{'Has_Recip'},
                          $g->{'Page_Bytes'},
                          $g->{'Page_ID'},
                          $g->{'Speed'},
                          $g->{'Icons'},
                          $g->{'Allow_Scan'},
                          $g->{'Allow_Thumb'},
                          $g->{'Times_Selected'},
                          $g->{'Used_Counter'},
                          $g->{'Build_Counter'},
                          $g->{'Keywords'},
                          $g->{'Comments'},
                          $g->{'Tag'}]) . ");\n";
            }

            close(GALLERIES);
        }
    }


    close(SQL);

    print "done\n";

    open(DATA, ">$DDIR/upgrade.dat") || Error("$!", "$DDIR/upgrade.dat");
    syswrite(DATA, pack("i", length('__SQL__')) . '__SQL__' .  pack("i", length($data->{'sql'})) . $data->{'sql'});    
    close(DATA);

    print "\n\nData export is complete, continue with\n" .
          "the next step in the upgrade process";
}



sub MakeList
{
    my $items = shift;

    for( @$items )
    {
        if( !defined $_ )
        {
            $_ = 'NULL';
        }
        else
        {
            AddSlashes(\$_);

            $_ = "'$_'";
        }
    }

    return join(',', @$items);
}



sub AddSlashes
{
    my $string = shift;

    $$string =~ s/'/\\'/g;
}
