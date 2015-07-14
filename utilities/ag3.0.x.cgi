#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#######################################################################
##  agp3.0.x.cgi - Utility to export data from AutoGallery 3.0.x     ##
#######################################################################

$|++;

eval
{
    require 'common.pl';
    require 'ag.pl';
    Header("Content-type: text/html\n\n");
    main();
};


err("$@", 'ag3.0.x.cgi') if( $@ );


sub main
{
    my $data = {};

    if( $VERSION !~ /^3\.0\.\d+/ )
    {
        print "Could not locate a 3.0.x installation of AutoGallery";
        exit;
    }

    print "<pre>Exporting AutoGallery v$VERSION data\n\n\n";

    ## Export the data for the MySQL database
    print "  Exporting galleries.......";

    GetCategoryList();

    my @dbs = ('pending', 'approved', 'archived');

    for( @dbs )
    {
        my $db = $_;
   
        if( -f "$DDIR/dbs/$db" )
        {
            open(GALLERIES, "$DDIR/dbs/$db");
            for( <GALLERIES> )
            {
                my $line = $_;
                my $g    = {};

                chomp($line);

                @$g{@{$DB_FORMAT{'galleries'}}} = split(/\|/, $line);

                $g->{'Sponsor'} = '';
                $g->{'Has_Thumb'} = 0;
                $g->{'Thumbnail_URL'} = undef;
                $g->{'Thumb_Width'} = undef;
                $g->{'Thumb_Height'} = undef;
                $g->{'Weight'} = 1.000;
                $g->{'Clicks'} = 0;
                $g->{'Type'} = 'Submitted';
                $g->{'Format'} = 'Pictures';
                $g->{'Status'} = 'Approved';
                $g->{'Confirm_ID'} = $g->{'Confirm_ID'};
                $g->{'Added_Date'} = $g->{'Submit_Date'};
                $g->{'Added_Stamp'} = time;
                $g->{'Approve_Date'} = $g->{'Approve_Date'};
                $g->{'Approve_Stamp'} = $g->{'Display_Stamp'};
                $g->{'Scheduled_Date'} = undef;
                $g->{'Display_Date'} = undef;
                $g->{'Delete_Date'} = undef;
                $g->{'Account_ID'} = '';
                $g->{'Moderator'} = $g->{'CPanel_ID'};
                $g->{'Submit_IP'} = $g->{'Submit_IP'};
                $g->{'Gallery_IP'} = $g->{'Gallery_IP'};
                $g->{'Scanned'} = $g->{'Scanned'};
                $g->{'Links'} = $g->{'Links'};
                $g->{'Has_Recip'} = $g->{'Has_Recip'};
                $g->{'Page_Bytes'} = $g->{'Page_Bytes'};
                $g->{'Page_ID'} = '';
                $g->{'Speed'} = 0.0;
                $g->{'Icons'} = $g->{'Icons'};
                $g->{'Allow_Scan'} = 1;
                $g->{'Allow_Thumb'} = 1;
                $g->{'Times_Selected'} = 0;
                $g->{'Used_Counter'} = 1;
                $g->{'Build_Counter'} = 1;
                $g->{'Keywords'} = '';
                $g->{'Comments'} = undef;
                $g->{'Tag'} = undef;


                if( $db eq 'unconfirmed' )
                {
                    $g->{'Status'} = 'Unconfirmed';
                }
                if( $db eq 'pending' )
                {
                    $g->{'Status'} = 'Pending';
                }
                elsif( $db eq 'approved' )
                {
                    $g->{'Status'} = 'Approved';
                }
                else
                {
                    $g->{'Status'} = 'Used';
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



    ## Export categories
    open(CATS, "$DDIR/dbs/categories");
    for( <CATS> )
    {
        my $line = $_;
        my $g    = {};

        chomp($line);

        @$g{@{$DB_FORMAT{'categories'}}} = split(/\|/, $line);

        $g->{'Per_Day'} = -1;
        $g->{'Ann_Pictures'} = 0;
        $g->{'Ann_Movies'} = 0;
        $g->{'Hidden'} = 0;
        $g->{'Ext_Pictures'} = 'jpg,gif,jpeg,bmp,png' if( !$g->{'Ext_Pictures'} );
        $g->{'Ext_Movies'} = 'avi,mpg,mpeg,rm,wmv,mov,asf' if( !$g->{'Ext_Movies'} );
        $g->{'Min_Pictures'} = 10 if( !$g->{'Min_Pictures'} );
        $g->{'Min_Movies'} = 3 if( !$g->{'Min_Movies'} );
        $g->{'Max_Pictures'} = 25 if( !$g->{'Max_Pictures'} );
        $g->{'Max_Movies'} = 25 if( !$g->{'Max_Movies'} );
        $g->{'Size_Pictures'} = 12288 if( !$g->{'Size_Pictures'} );
        $g->{'Size_Movies'} = 102400 if( !$g->{'Size_Movies'} );

        $data->{'sql'} .= "INSERT INTO ags_Categories VALUES (" .
                  MakeList([$g->{'Name'},
                  $g->{'Ext_Pictures'},
                  $g->{'Ext_Movies'},
                  $g->{'Min_Pictures'},
                  $g->{'Min_Movies'},
                  $g->{'Max_Pictures'},
                  $g->{'Max_Movies'},
                  $g->{'Size_Pictures'},
                  $g->{'Size_Movies'},
                  $g->{'Per_Day'},
                  $g->{'Ann_Pictures'},
                  $g->{'Ann_Movies'},
                  $g->{'Hidden'}]) .
                  ");\n";
    }
    close(CATS);

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
            _AddSlashes(\$_);

            $_ = "'$_'";
        }
    }

    return join(',', @$items);
}



sub _AddSlashes
{
    my $string = shift;

    $$string =~ s/'/\\'/g;
}

