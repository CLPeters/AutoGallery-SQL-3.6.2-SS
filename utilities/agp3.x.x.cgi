#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
###########################################################################
##  agp3.x.x.cgi - Utility to export data from AutoGallery Pro 3.x.x     ##
###########################################################################

$|++;

eval
{
    require 'common.pl';
    require 'agp.pl';
    Header("Content-type: text/html\n\n");
    main();
};


err("$@", 'agp3.x.x.cgi') if( $@ );


sub main
{
    my $data = {};

    print "<pre>";

    if( $VERSION !~ /^3\.\d\.\d+/ )
    {
        print "Could not locate a 3.x.x installation of AutoGallery Pro";
        exit;
    }

    print "Exporting AutoGallery Pro v$VERSION data\n\n\n";


    ## Export all of the datafiles
    print "  Exporting datafiles....................";
    $data->{'data'} = _ExportDatafiles();
    print "done\n";


    ## Export the data for the MySQL database
    print "  Exporting galleries and partners.......";

    GetCategoryList();

    my @dbs = ('unconfirmed', 'pending', 'approved', 'archived', map(PlainString($_), @CATEGORIES));

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
                $g->{'Gallery_ID'} = undef if( $g->{'Gallery_ID'} < 1 );


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


    ## Export partner accounts
    open(PARTNERS, "$DDIR/dbs/accounts");
    for( <PARTNERS> )
    {
        my $line = $_;
        my $g    = {};

        chomp($line);

        @$g{@{$DB_FORMAT{'accounts'}}} = split(/\|/, $line);

        $g->{'Weight'} = 1.000;
        $g->{'Submitted'} = 0;
        $g->{'Removed'} = 0;
        $g->{'Check_Recip'} = $g->{'Recip'};
        $g->{'Check_Black'} = !$g->{'Blacklist'};
        $g->{'Check_HTML'} = !$g->{'HTML'};
        $g->{'Confirm'} = 0;

        $data->{'sql'} .= "INSERT INTO ags_Accounts VALUES (" .
                  MakeList([$g->{'Account_ID'},
                  $g->{'Password'},
                  $g->{'Email'},
                  $g->{'Weight'},
                  $g->{'Allowed'},
                  $g->{'Submitted'},
                  $g->{'Removed'},
                  $g->{'Auto_Approve'},
                  $g->{'Check_Recip'},
                  $g->{'Check_Black'},
                  $g->{'Check_HTML'},
                  $g->{'Confirm'},
                  $g->{'Icons'},
                  undef,
                  undef]) .
                  ");\n"; 

    }
    close(PARTNERS);



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


    ## Export permanent galleries
    open(PERM, "$DDIR/dbs/permanent");
    for( <PERM> )
    {
        my $line = $_;
        my $g    = {};

        chomp($line);

        @$g{@{$DB_FORMAT{'permanent'}}} = split(/\|/, $line);

        $g->{'Gallery_ID'} = undef;
        $g->{'Email'} = $ADMIN_EMAIL;
        $g->{'Sponsor'} = '';
        $g->{'Has_Thumb'} = $g->{'Thumbnail_URL'} ? 1 : 0;
        $g->{'Thumb_Width'} = $g->{'Thumbnail_URL'} ? $THUMB_WIDTH : undef;
        $g->{'Thumb_Height'} = $g->{'Thumbnail_URL'} ? $THUMB_HEIGHT : undef;
        $g->{'Weight'} = 1.000;
        $g->{'Clicks'} = 0;
        $g->{'Type'} = 'Permanent';
        $g->{'Format'} = 'Pictures';
        $g->{'Status'} = 'Approved';
        $g->{'Confirm_ID'} = $g->{'Confirm_ID'};
        $g->{'Added_Date'} = $DB_DATE;
        $g->{'Added_Stamp'} = time;
        $g->{'Approve_Date'} = $DB_DATE;
        $g->{'Approve_Stamp'} = time;
        $g->{'Scheduled_Date'} = $g->{'Start_Date'};
        $g->{'Display_Date'} = undef;
        $g->{'Delete_Date'} = $g->{'Expire_Date'};
        $g->{'Account_ID'} = '';
        $g->{'Moderator'} = 'Upgrade';
        $g->{'Submit_IP'} = $ENV{'REMOTE_ADDR'} || '';
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
    close(PERM);


    open(DATA, ">$DDIR/upgrade.dat") || Error("$!", "$DDIR/upgrade.dat");
    syswrite(DATA, pack("i", length('__SQL__')) . '__SQL__' .  pack("i", length($data->{'sql'})) . $data->{'sql'});    
    syswrite(DATA, $data->{'data'});
    close(DATA);

    Mode(0666, "$DDIR/upgrade.dat");

    print "done\n";

    print "\n\nData export is complete, continue with\n" .
          "the next step in the upgrade process\n</pre>";
}



sub _ExportDatafiles
{
    my @directories = qw(blacklist reject);
    my @files = qw(emails generalrecips icons trustedrecips);
    my $export = undef;


    for( @files )
    {
        my $file = $_;
        my $data = FileReadScalar("$DDIR/$file");

        UnixFormat($data);

        $export .= pack("i", length("__DDIR__/$file")) .
                   "__DDIR__/$file" .
                   pack("i", length($$data)) .
                   $$data;
    }

    for( @directories )
    {
        my $dir = $_;

        for( @{DirRead("$DDIR/$dir", '^[^.]')} )
        {
            my $file = $_;

            if( -f "$DDIR/$dir/$file" )
            {
                my $data = FileReadScalar("$DDIR/$dir/$file");

                UnixFormat($data);

                $export .= pack("i", length("__DDIR__/$dir/$file")) .
                           "__DDIR__/$dir/$file" .
                           pack("i", length($$data)) .
                           $$data;
            }
        }
    }

    return $export;
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

