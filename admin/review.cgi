#!/usr/bin/perl

use Fcntl qw(:DEFAULT :flock);

chdir('..');


eval
{
    require 'common.pl';
    require 'ags.pl';
    require 'mysql.pl';
    Header("Content-type: text/html\n\n");
    main();
};


if( $@ )
{
    Error("$@", 'review.cgi');
}


sub main
{
    ParseRequest();

    CheckPrivileges($P_GALLERIES);

    $T{'O_Type'} = $F{'O_Type'} || '0';
    $T{'O_Format'} = $F{'O_Format'} || '0';
    $T{'O_Category'} = $F{'O_Category'} || '0';
    $T{'O_Sort'} = $F{'O_Sort'} || 'Added_Stamp';
    $T{'O_SortDir'} = $F{'O_SortDir'} || 'ASC'; 

    if( $ENV{'QUERY_STRING'} )
    {
        DisplayReview();
    }
    else
    {
        if( $F{'Run'} )
        {
            &{$F{'Run'}};
        }
        else
        {
            ParseTemplate('review_frameset.tpl');
        }
    }
}



sub GetQualifier
{
    my @wheres = "Status=?";
    my $binds = ['Pending'];

    if( $T{'O_Type'} )
    {
        push(@wheres, 'Type=?');
        push(@$binds, $T{'O_Type'});
    }

    if( $T{'O_Format'} )
    {
        push(@wheres, 'Format=?');
        push(@$binds, $T{'O_Format'});
    }

    if( $T{'O_Category'} )
    {
        push(@wheres, 'Category=?');
        push(@$binds, $T{'O_Category'});
    }

    if( $T{'O_Type'} )
    {
        push(@wheres, 'Type=?');
        push(@$binds, $T{'O_Type'});
    }

    return (join(' AND ', @wheres), $binds);
}


sub DisplayReview
{
    my $gallery = undef;
    my($qualifier, $binds) = GetQualifier();

    $DB->Connect();
    $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE $qualifier ORDER BY $T{'O_Sort'} $T{'O_SortDir'} LIMIT " . int($F{'Limit'}) . ",1", $binds);
    
    GetCategoryList();

    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Name'} = $_;

        TemplateAdd('Categories', $H);
    }
    
    if( !$gallery )
    {
        $T{'Limit'} = $F{'Limit'};

        ParseTemplate('review_done.tpl');
    }
    else
    {
        HashToTemplate($gallery);        

        ## Add reject reasons to the template
        for( @{DirRead("$DDIR/reject", '^[^.]')} )
        {
            my $H = {};
            $H->{'Reason'} = $_;
            $H->{'Selected'} = ' selected' if( $H->{'Reason'} eq 'RejectGallery' );
            TemplateAdd('Reasons', $H);
        }


        ## Add icons to the template
        my $icons = IniParse("$DDIR/icons");
        for( keys %$icons )
        {
            my $H = {};

            $H->{'Identifier'} = $_;
            $H->{'HTML'} = $icons->{$_};

            TemplateAdd('IconSelect', $H);
        }

        $T{'Weight'} = sprintf("%.3f", $gallery->{'Weight'});
        $T{'ChoppedEmail'} = length($T{'Email'}) > 25 ? substr($T{'Email'}, 0, 25) . "..." : $T{'Email'};
        $T{'File_Name'} = 't' . IP2Hex($ENV{'REMOTE_ADDR'});
        $T{'Limit'} = $F{'Limit'};
        $T{'URL_Class'} = ($gallery->{'Has_Recip'} ? 'normalgreen' : 'normal');
        $T{'Script_URL'} = $CGI_URL;
        
        ## Setup for TGP Cropper
        if( $O_TGP_CROPPER )
        {
            $T{'TGP_Cropper'} = "tgpcropper://Post_Back_URL=" . URLEncode("$CGI_URL/admin/main.cgi") . 
                                "&Run=UploadThumbnail" .                        
                                "&Height=$THUMB_HEIGHT" .
                                "&Width=$THUMB_WIDTH" .
                                "&Quality=$THUMB_QUALITY";
        }

        ParseTemplate('review_main.tpl');
    }
}



sub Skip
{
    $F{'Limit'}++;

    DisplayReview();
}



sub Approve
{
    $DB->Connect();

    if( $F{'Scheduled_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ )
    {
        $F{'Scheduled_Date'} = undef;
    }

    if( $F{'Delete_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ )
    {
        $F{'Delete_Date'} = undef;
    }
    
    $DB->Update("UPDATE ags_Galleries SET " .
                "Gallery_URL=?, " .
                "Description=?, " .
                "Thumbnails=?, " .
                "Category=?, " .
                "Sponsor=?, " .
                "Weight=?, " .
                "Nickname=?, " .
                "Type=?, " .
                "Format=?, " .
                "Status='Approved', " .
                "Approve_Date=?, " .
                "Approve_Stamp=?, " .
                "Scheduled_Date=?, " .
                "Delete_Date=?, " .
                "Moderator=?, " .
                "Icons=?, " .
                "Allow_Scan=?, " .
                "Allow_Thumb=?, " .
                "Keywords=? " .
                "WHERE Gallery_ID=?", 
                [$F{'Gallery_URL'},
                 $F{'Description'},
                 $F{'Thumbnails'},
                 $F{'Category'},
                 $F{'Sponsor'},
                 $F{'Weight'},
                 $F{'Nickname'},
                 $F{'Type'},
                 $F{'Format'},
                 $MYSQL_DATE,
                 time,
                 $F{'Scheduled_Date'},
                 $F{'Delete_Date'},
                 $ENV{'REMOTE_USER'},
                 $F{'Icons'},
                 int($F{'Allow_Scan'}),
                 int($F{'Allow_Thumb'}),
                 $F{'Keywords'},
                 $F{'Gallery_ID'}]);

    
    ## Send approval e-mail
    if( $O_PROCESS_EMAIL )
    {
        my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);

        ## Don't send an approval e-mail message if the e-mail address of the
        ## gallery is the same as the TGP administrator's e-mail address
        if( $gallery->{'Email'} ne $ADMIN_EMAIL )
        {
            ## Send approval e-mail
            $T{'To'} = $gallery->{'Email'}; 
            $T{'From'} = $ADMIN_EMAIL;

            map($T{$_} = $gallery->{$_}, keys %$gallery);
            
            Mail("$TDIR/email_approved.tpl");
        }
    }

    ## Update the approval count for the moderator
    $DB->Update("UPDATE ags_Moderators SET Approved=Approved+1 WHERE Username=?", [$ENV{'REMOTE_USER'}]);

    $DB->Disconnect();

    DisplayReview();   
}



sub Reject
{
    $DB->Connect();

    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);

    if( $O_PROCESS_EMAIL && $F{'Reject'} ne 'None' )
    {
        ## send rejection e-mail
        $T{'To'} = $gallery->{'Email'}; 
        $T{'From'} = $ADMIN_EMAIL;

        map($T{$_} = $gallery->{$_}, keys %$gallery);
        
        Mail("$DDIR/reject/$F{'Reject'}");
    }


    ## Update the removed count for the submitter account
    if( $gallery->{'Account_ID'} )
    {
        $DB->Update("UPDATE ags_Accounts SET Removed = Removed + 1 WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
    }


    ## Delete the gallery and it's thumbnail
    $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    FileRemove("$THUMB_DIR/$F{'Gallery_ID'}.jpg") if( -e "$THUMB_DIR/$F{'Gallery_ID'}.jpg" );


    ## Update moderator rejection count
    $DB->Update("UPDATE ags_Moderators SET Declined=Declined+1 WHERE Username=?", [$ENV{'REMOTE_USER'}]);

    $DB->Disconnect();

    DisplayReview();
}



sub Blacklist
{
    my $gallery = undef;

    $DB->Connect();

    $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);


    ## Delete the gallery and it's thumbnail
    $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    FileRemove("$THUMB_DIR/$F{'Gallery_ID'}.jpg") if( -e "$THUMB_DIR/$F{'Gallery_ID'}.jpg" );


    ## Update moderator blacklist count
    $DB->Update("UPDATE ags_Moderators SET Banned=Banned+1 WHERE Username=?", [$ENV{'REMOTE_USER'}]);

    $DB->Disconnect();

    ## Add items to the blacklist
    AddBlacklist('submitip', $gallery->{'Submit_IP'})                 if( $F{'submit_ip'} );
    AddBlacklist('domainip', GetIPFromURL($gallery->{'Gallery_URL'})) if( $F{'gallery_ip'} );
    AddBlacklist('domain', GetHost($gallery->{'Gallery_URL'}))        if( $F{'hostname'} );
    AddBlacklist('dns', @{GetNS($gallery->{'Gallery_URL'})}[0])       if( $F{'dns'} );
    AddBlacklist('email', $gallery->{'Email'})                        if( $F{'email'} );
    AddBlacklist('email', GetEmailHost($gallery->{'Email'}))          if( $F{'email_host'} );

    DisplayReview();
}



sub Save
{
    DisplayReview();
}



sub AddBlacklist
{
    my $type = shift;
    my $item = lc(shift);

    return if( $item eq '' );

    FileTaint("$DDIR/blacklist/$type");

    sysopen(DB, "$DDIR/blacklist/$type", O_RDWR|O_CREAT) || Error("$!", "$DDIR/blacklist/$type");
    flock(DB, LOCK_EX);
    seek(DB, 0, 0);

    for( <DB> )
    {
        if( $_ eq "$item\n" )
        {
            close(DB);
            return;
        }
    }

    print DB "$item\n";
    flock(DB, LOCK_UN);
    close(DB);
}



sub GetHost
{
    my $url = shift;

    $url =~ m|http://([^:/]+):?(\d+)*(/?.*)|i;

    return $1;
}



sub GetEmailHost
{
    my $email = shift;
    return substr($email, index($email, '@')+1);
}
