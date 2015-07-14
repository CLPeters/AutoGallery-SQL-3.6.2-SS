#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#######################################################################
##  submit.cgi - Handle general gallery submissions from webmasters  ##
#######################################################################

eval
{
    require 'common.pl';
    require 'ags.pl';
    require 'mysql.pl';
    require 'http.pl';
    Header("Content-type: text/html\n\n");
    main();
};


if( $@ )
{
    Error("$@", 'submit.cgi');
}



sub main
{
    ParseRequest(1);


    ## Display the submissions closed page
    if( !$SUBMIT_STATUS )
    {
        ParseTemplate('submit_closed.tpl');
        exit;
    }


    if( $ENV{'REQUEST_METHOD'} eq 'GET' )
    {
        DisplaySubmit();
    }
    else
    {
        ProcessPost();
    }
}



## Display the gallery submission page
sub DisplaySubmit
{
    ## Add categories to the template
    GetCategoryList(1);

    if( !scalar(@CATEGORIES) )
    {
        SubmitError('E_NO_CATEGORIES');
    }

    for( @CATEGORIES )
    {
        my $H = {};
        $H->{'Category'} = $_;
        StripHTML(\$H->{'Category'});
        TemplateAdd('Categories', $H);
    }

    $T{'Submit_Status'} = $SUBMIT_STATUS;
    $T{'Width'} = $THUMB_WIDTH;
    $T{'Height'} = $THUMB_HEIGHT;

    ParseTemplate('submit_main.tpl');
}



## Display the thumbnail cropping page
sub DisplayCrop
{
    my $results = shift;

    $T{'Image_URL'} = "$THUMB_URL/$T{'Image_Name'}";
    $T{'Thumb_URL'} = $THUMB_URL;
    $T{'Thumb_Height'} = $THUMB_HEIGHT;
    $T{'Thumb_Width'} = $THUMB_WIDTH;
    $T{'Encode_URL'} = URLEncode($F{'End_URL'});

    if( !$F{'Preview'} )
    {
        for( my $i = 0; $i < scalar(@{$results->{'Thumbs'}}); $i++ )
        {
            my $H = {};

            $H->{'Thumbnail_URL'} = URLEncode($results->{'Thumbs'}[$i]);
            $H->{'Image_URL'} = $results->{'Format'} eq 'Pictures' ? URLEncode($results->{'Content'}[$i]) : $H->{'Thumbnail_URL'};

            TemplateAdd('Thumbs', $H);
        }
    }   

    ParseTemplate('submit_crop.tpl');
}




## Crop the thumbnail
sub CropThumbnail
{
    my $thumb_file = "$F{'Gallery_ID'}.jpg";

    ## Gallery already has a thumbnail
    if( -e "$THUMB_DIR/$thumb_file" )
    {
        unlink("$THUMB_DIR/$F{'Image_Name'}") if( -e "$THUMB_DIR/$F{'Image_Name'}" );
        SubmitError('E_HAS_THUMB');
    }

    require 'image.pl';

    $DB->Connect();

    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    my $account = $gallery->{'Account_ID'} ? $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=?", [$gallery->{'Account_ID'}]) : {};
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$gallery->{'Category'}]);
    my $annotation = undef;

    ## Determine if this thumbnail will get an annotation
    if( $category->{"Ann_$gallery->{'Format'}"} != 0 )
    {
        $annotation = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$category->{"Ann_$gallery->{'Format'}"}]);
    }


    ## Crop and save the thumbnail
    ManualResize("$THUMB_DIR/$F{'Image_Name'}", $annotation);
    rename("$THUMB_DIR/$F{'Image_Name'}", "$THUMB_DIR/$thumb_file");
    Mode(0666, "$THUMB_DIR/$thumb_file");


    ## Determine status
    my $status = 'Pending';
    my $require_confirm = ($O_CONFIRM_EMAIL && !$gallery->{'Account_ID'}) || ($gallery->{'Account_ID'} && $account->{'Confirm'});
    my $auto_approve = $account->{'Auto_Approve'} || $O_AUTO_APPROVE;

    if( $require_confirm )
    {
        $status = 'Unconfirmed';
    }
    elsif( $auto_approve )
    {
        $status = 'Approved';
    }


    ## Update the database 
    $DB->Update("UPDATE ags_Galleries SET Status=?,Has_Thumb=1,Thumbnail_URL=?,Thumb_Height=?,Thumb_Width=? WHERE Gallery_ID=?", [$status, "$THUMB_URL/$thumb_file", $THUMB_HEIGHT, $THUMB_WIDTH, $F{'Gallery_ID'}]);


    HashToTemplate($gallery);
    $T{'Status'} = $status;
    $T{'Has_Thumb'} = 1;
    $T{'Thumbnail_URL'} = "$THUMB_URL/$thumb_file";


    ## Send confirmation e-mail
    if( ($O_CONFIRM_EMAIL && !$gallery->{'Account_ID'}) || ($gallery->{'Account_ID'} && $account->{'Confirm'}) )
    {
        $T{'To'} = $gallery->{'Email'};
        $T{'From'} = $ADMIN_EMAIL;
        $T{'Confirm_ID'} = $gallery->{'Confirm_ID'};
        $T{'Confirm_URL'} = "$CGI_URL/confirm.cgi";

        Mail("$TDIR/email_confirm.tpl");
    }
    
    ## Display the submit_complete template
    ParseTemplate('submit_complete.tpl');
}


#REPLACE


## Process HTTP POST requests
sub ProcessPost
{
    my %map = ('D', 'DisplayUpload', 'U', 'UploadThumbnail', 'C', 'CropThumbnail', 'A', 'AccountData');

    if( $map{$F{'Run'}} )
    {
        &{$map{$F{'Run'}}};
    }
    else
    {
        ProcessSubmission();
    }
}



## Process a gallery submission
sub ProcessSubmission
{
    my $hex_ip = IP2Hex($ENV{'REMOTE_ADDR'});
    my $moderator = undef;
    my $status = 'Pending';
    my $icons = undef;
    my $account = {'Account_ID' => ''};
    my $approve_date = undef;
    my $approve_stamp = undef;
    my $annotation = undef;
    my $blacklisted = 0;
    my $confirm = $O_CONFIRM_EMAIL;
    my $confirm_id = undef;
    my $has_thumb = 0;
    my $weight = 1;
    my $min_thumbs = 0;
    my $max_thumbs = 0;
    my $min_size = 0;
    my $height = $THUMB_HEIGHT;
    my $width = $THUMB_WIDTH;


    ## Convert AutoGallery SQL v2.x.x form fields
    if( !$F{'Gallery_URL'} )
    {
        $F{'Username'} = $F{'user'};
        $F{'Password'} = $F{'pass'};   
        $F{'Gallery_URL'} = $F{'gurl'};
        $F{'Category'} = $F{'cat'};
        $F{'Thumbnails'} = $F{'pics'};
        $F{'Code'} = $F{'phrase'};
        $F{'Email'} = $F{'mail'} || "partner\@$ENV{'HTTP_HOST'}";
        $F{'Description'} = $F{'gdes'} || $F{'desc'};
        $F{'Preview'} = $F{'upfile'};

        if( $F{'turl'} )
        {
            $F{'Thumb_Source'} = 'Select';
        }
        elsif( $F{'upfile'} )
        {
            $F{'Thumb_Source'} = 'Upload';
        }        
    }

    ## Fields that cannot be null
    my @not_null = ('Email', 'Gallery_URL', 'Description', 'Thumbnails', 'Category', 'Nickname');

    for( @not_null )
    {
        if( !exists $F{$_} )
        {
            $F{$_} = '';
        }
    }


    ## Check form input
    SubmitError('E_BAD_EMAIL') if( $F{'Email'} !~ /^[\w\d][\w\d\,\.\-]*\@([\w\d\-]+\.)+([a-zA-Z]+)$/ );
    SubmitError('E_BAD_URL') if( $F{'Gallery_URL'} !~ /^http:\/\/[\w\d\-\.]+\.[\w\d\-\.]+/ );
    SubmitError('E_REQUIRED', 'DESCRIPTION') if( $O_NEED_DESC && !$F{'Description'} );
    SubmitError('E_REQUIRED', 'NICKNAME') if( $O_NEED_NAME && !$F{'Nickname'} );
    SubmitError('E_TOO_SHORT', 'DESCRIPTION') if( ($O_NEED_DESC || $F{'Description'}) && length($F{'Description'}) < $MIN_LENGTH );
    SubmitError('E_TOO_LONG', 'DESCRIPTION') if( ($O_NEED_DESC || $F{'Description'}) && length($F{'Description'}) > $MAX_LENGTH );
    SubmitError('E_NO_PASSWORD') if( $SUBMIT_STATUS eq 'Password' && !$F{'Password'} );


    $DB->Connect();


    ## See if maximum submissions have been reached
    if( $MAX_SUBMISSIONS != -1 )
    {
        if( $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Added_Date=?", [$MYSQL_DATE]) >= $MAX_SUBMISSIONS )
        {
            $DB->Disconnect();
            ParseTemplate('submit_globalfull.tpl');
            exit;
        }
    }


    ## If username/password were entered, check it
    if( $F{'Username'} || $F{'Password'} )
    {
        $account = $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=? AND Password=?", [$F{'Username'}, $F{'Password'}]);

        if( !$account )
        {
            SubmitError('E_BAD_PASSWORD');
        }


        ## Check for valid date
        if( $account->{'Start_Date'} )
        {
            if( !$DB->Count("SELECT '$MYSQL_DATE' BETWEEN '$account->{'Start_Date'}' AND '$account->{'End_Date'}'") )
            {
                SubmitError('E_DATE_RANGE', "$account->{'Start_Date'} ~ $account->{'End_Date'}");
            }
        }

        
        ## If global auto-approve is off, determine whether to auto-approve this gallery
        if( !$O_AUTO_APPROVE )
        {
            $O_AUTO_APPROVE = $account->{'Auto_Approve'};
        }

        $confirm = $account->{'Confirm'};
        $weight = $account->{'Weight'};
        $icons = $account->{'Icons'};
    }


    ## Check the submit code
    if( ($O_GEN_STRING && !$F{'Password'}) || ($O_TRUST_STRING && $F{'Password'}) )
    {
        if( !$DB->Count("SELECT COUNT(*) FROM ags_Codes WHERE IP_Address=? AND Code=?", [$hex_ip, $F{'Code'}]) )
        {
            SubmitError('E_BAD_CODE');
        }
    }


    ## Check for good category
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Hidden=0 AND Name=?", [$F{'Category'}]);

    if( !$category )
    {
        SubmitError('E_BAD_CATEGORY');
    }

    if( $category->{'Per_Day'} != -1 )
    {
        my $current = $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Category=? AND Added_Date=?", [$category->{'Name'}, $MYSQL_DATE]);

        if( $current >= $category->{'Per_Day'} )
        {
            $DB->Disconnect();
            $T{'Category'} = $category->{'Name'};
            ParseTemplate('submit_categoryfull.tpl');
            exit;
        }
    }


    ## Check for duplicate gallery URL
    if( $O_CHECK_DUPS && $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Gallery_URL=?", [$F{'Gallery_URL'}]) )
    {
        SubmitError('E_DUPLICATE');
    }


    ## See if the gallery is whitelisted
    my $whitelisted = IsWhitelisted($F{'Gallery_URL'});


    ## Scan the gallery
    my $results = ScanGallery($F{'Gallery_URL'}, $category, $whitelisted, $account);

    
    ## Setup the ending URL if a forward was done
    $F{'End_URL'} = $results->{'End_URL'};

    
    ## Setup min/max values based on the gallery type
    $min_thumbs = $category->{"Min_$results->{'Format'}"}; 
    $max_thumbs = $category->{"Max_$results->{'Format'}"}; 
    $min_size = $category->{"Size_$results->{'Format'}"}; 


    ## Load the annotation for this category and format
    if( $category->{"Ann_$results->{'Format'}"} != 0 )
    {
        $annotation = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$category->{"Ann_$results->{'Format'}"}]);
    }


    ## Broken gallery URL
    if( $results->{'Error'} )
    {
        SubmitError('E_BROKEN_URL', $results->{'Error'});
    }

    
    ## Check the blacklist
    $F{'Submit_IP'} = $ENV{'REMOTE_ADDR'};

    if( !$whitelisted )
    {
        $F{'Http_Headers'} = $results->{'Headers'}->{'All'};
        $blacklisted = IsBlacklisted(\%F);

        if( !$O_TRANSPARENT && $blacklisted && (!$account->{'Account_ID'} || $account->{'Check_Black'}) )
        {
            SubmitError('E_BLACKLISTED', $blacklisted->{'Item'});
        }
    }


    ## Check for banned HTML
    if( $results->{'Has_Banned'} )
    {
        if( !$account->{'Account_ID'} || $account->{'Check_HTML'} )
        {
            $blacklisted = 1;
            SubmitError('E_BAD_HTML') if( !$O_TRANSPARENT )
        }
    }


    ## Check reciprocal link
    my $general_recip_required = (!$account->{'Account_ID'} && $O_NEED_RECIP);
    my $partner_recip_required = $account->{'Check_Recip'};
    if( $general_recip_required || $partner_recip_required )
    {
        SubmitError('E_NO_RECIP') if( !$results->{'Has_Recip'} );
    }


    ## Check for 2257 code
    if( $O_CHECK_2257 && !$results->{'Has_2257'} )
    {
        SubmitError('E_NO_2257');
    }


    ## Give a rating boost for a recip
    if( $O_BOOST_RATING && $results->{'Has_Recip'} )
    {
        $weight++;
    }


    ## Override the submitted thumbnail count
    if( $O_COUNT_THUMBS )
    {
        $F{'Thumbnails'} = $results->{'Thumbnails'};
    }


    ## Make sure thumb count is within the min/max
    SubmitError('E_MIN_THUMBS', $min_thumbs) if( $F{'Thumbnails'} < $min_thumbs );
    SubmitError('E_MAX_THUMBS', $max_thumbs) if( $F{'Thumbnails'} > $max_thumbs );


    ## Check the number of external links
    if( $O_CHECK_LINKS )
    {
        SubmitError('E_EXCESSIVE_LINKS', $LINKS) if( $results->{'Links'} > $LINKS );
    }


    ## Check the mimimum content size
    if( $O_CHECK_SIZE )
    {
        for( @{$results->{'Sizes'}} )
        {
            my $item_size = $_;
            SubmitError('E_MIN_SIZE', "$min_size bytes") if( $item_size <= $min_size );
        }
    }


    ## Check download speed
    if( $O_CHECK_SPEED )
    {
        SubmitError('E_TOO_SLOW', "$SPEED KB/s") if( $results->{'Speed'} <= $SPEED );
    }


    ## Change the text case of the description
    ChangeCase(\$F{'Description'}, $TEXT_CASE);
  
    
    ## Only allowing partners to submit thumbnails
    if( $O_PARTNER_THUMB && !$account->{'Account_ID'} )
    {
        $O_NEED_THUMB = 0;
        $F{'Thumb_Source'} = 'Upload';
        $F{'Preview'} = undef;
    }


    ## If the source was an upload, see if a thumb was actually provided
    if( $F{'Thumb_Source'} eq 'Upload' )
    {
        ## No thumbnail uploaded
        if( !$F{'Preview'} )
        {
            if( $O_SELECT_THUMB )
            {
                $THUMB_NO_MATCH = 'AutoCrop';
                $F{'Preview'} = SelectThumbnail($results->{'Preview'}, $F{'Gallery_URL'});
            }
            elsif( $O_NEED_THUMB )
            {
                SubmitError('E_NO_THUMB');
            }
        }

        ## Make sure browser is capable of manual crop
        if( $THUMB_NO_MATCH eq 'ManualCrop' && BadBrowser() )
        {
            $THUMB_NO_MATCH = 'AutoCrop';
        }
    }
    ## Automatically selecting a thumbnail
    elsif( $F{'Thumb_Source'} eq 'Select' )
    {
        $THUMB_NO_MATCH = 'AutoCrop';
        $F{'Preview'} = SelectThumbnail($results->{'Preview'}, $F{'Gallery_URL'});
    }
    ## Select and crop a thumbnail
    else
    {
        $F{'Preview'} = undef;
    }


    ## Not allowing thumbnails
    if( !$O_ALLOW_THUMB )
    {
        $F{'Thumb_Source'} = 'Select';
        $F{'Preview'} = undef;
    }


    if( $F{'Preview'} )
    {
        require 'size.pl';

        ($width, $height, $image_id) = imgsize(\$F{'Preview'});

        if( !$width )
        {
            SubmitError('E_BAD_IMAGE');
        }

        ## Dimensions or filesize are not valid
        my $dimensions_too_large = ($width > $THUMB_WIDTH || $height > $THUMB_HEIGHT); 
        my $dimensions_dont_meet_requirement = ($O_FORCE_DIMS && ($width != $THUMB_WIDTH || $height != $THUMB_HEIGHT));
        my $filesize_too_large = (length($F{'Preview'}) > $THUMB_SIZE);
        if( $dimensions_dont_meet_requirement || $dimensions_too_large || $filesize_too_large )
        {
            if( $THUMB_NO_MATCH eq 'AutoCrop' )
            {
                require 'image.pl';
                AutoResize(\$F{'Preview'}, "t$hex_ip", $annotation);
                $width = $THUMB_WIDTH;
                $height = $THUMB_HEIGHT;
                $has_thumb = 1;
            }
            elsif( $THUMB_NO_MATCH eq 'Reject' )
            {   
                SubmitError('E_THUMB_SIZE');
            }
            else
            {
                $F{'Thumb_Source'} = 'Crop';
                FileWrite("$THUMB_DIR/t$hex_ip.jpg", $F{'Preview'});
            }
        }

        ## Good dimensions
        else
        {
            FileWrite("$THUMB_DIR/t$hex_ip.jpg", $F{'Preview'});

            if( $annotation )
            {
                require 'image.pl';
                Annotate("$THUMB_DIR/t$hex_ip.jpg", $annotation);
            }

            $has_thumb = 1;
        }

        $F{'Preview'} = 1;
    }


    ## Setup the status
    if( $confirm )
    {
        $confirm_id = int(rand(999999999));
        $status = 'Unconfirmed';
    }
    elsif( $O_AUTO_APPROVE )
    {
        $moderator = 'Auto-Approved';
        $status = 'Approved';
        $approve_date = $MYSQL_DATE;
        $approve_stamp = time;
    }


    ## Mark gallery as being in the process of submitting
    if( $F{'Thumb_Source'} eq 'Crop' )
    {
        $status = 'Submitting';
    }


    ## Check the number of submitted galleries
    if( $account->{'Account_ID'} )
    {
        if( $account->{'Allowed'} != -1 && $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Added_Date=? AND Account_ID=?", [$MYSQL_DATE, $account->{'Account_ID'}]) >= $account->{'Allowed'} )
        {
            SubmitError('E_LIMIT_REACHED');
        }
    }
    else
    {
        my $query = "SELECT COUNT(*) FROM ags_Galleries WHERE Added_Date=? AND (Submit_IP=? OR Email=? OR Gallery_URL LIKE ?)";
        
        if( $MAX_PERSON != -1 &&  $DB->Count($query, [$MYSQL_DATE, $ENV{'REMOTE_ADDR'}, $F{'Email'}, '%'.LevelUpURL($F{'Gallery_URL'}).'%']) >= $MAX_PERSON )
        {
            SubmitError('E_LIMIT_REACHED');
        }
    }


    ## Check the page ID
    if( $O_CHECK_PAGEID )
    {
        if( $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Page_ID=?", [$results->{'Page_ID'}]) )
        {
            SubmitError('E_SAME_CONTENT');
        }
    }


    ## Remove submit code from the database
    if( $F{'Code'} )
    {
        $DB->Delete("DELETE FROM ags_Codes WHERE Code=?", [$F{'Code'}]);
    }


    HashToTemplate(\%F);

    $T{'Status'} = $status;


    ## Transparently accept blacklisted galleries
    if( $blacklisted )
    {
        $DB->Disconnect();
        FileRemove("$THUMB_DIR/t$hex_ip.jpg") if( -e "$THUMB_DIR/t$hex_ip.jpg" );
        $T{'Gallery_ID'} = int(rand(9999)) + 287;
        ParseTemplate('submit_complete.tpl');
        exit;
    }


    ## Update the submit count if this is a partner
    if( $account->{'Account_ID'} )
    {
        $DB->Update("UPDATE ags_Accounts SET Submitted = Submitted + 1 WHERE Account_ID=?", [$account->{'Account_ID'}]);
    }

    my $keywords = '';
    if( $O_ALLOW_KEYWORDS )
    {
        $keywords = $F{'Keywords'};
    }

    my $bind_list = [undef,
                     $F{'Email'},
                     $F{'Gallery_URL'},
                     $F{'Description'},
                     $F{'Thumbnails'},
                     $F{'Category'},
                     '',
                     $has_thumb,
                     undef,
                     undef,
                     undef,
                     $weight,
                     $F{'Nickname'},
                     0,
                     'Submitted',
                     $results->{'Format'},
                     $status,
                     $confirm_id,
                     $MYSQL_DATE,
                     time,
                     $approve_date,
                     $approve_stamp,
                     undef,
                     undef,
                     undef,
                     $account->{'Account_ID'},
                     $moderator,
                     $ENV{'REMOTE_ADDR'},
                     $results->{'Gallery_IP'},
                     1,
                     $results->{'Links'},
                     $results->{'Has_Recip'},
                     $results->{'Bytes'},
                     $results->{'Page_ID'},
                     $results->{'Speed'},
                     $icons,
                     1,
                     1,
                     1,
                     1,
                     1,
                     $keywords,
                     undef,
                     undef];

    $DB->Insert("INSERT INTO ags_Galleries VALUES (" . MakeBindList(scalar @$bind_list) . ")", $bind_list);


    $T{'Gallery_ID'} = $DB->InsertID();
    $T{'Has_Thumb'} = $has_thumb;
    $T{'Thumbnail_URL'} = "$THUMB_URL/$T{'Gallery_ID'}.jpg";

    ## Add to the e-mail log
    $DEL = "\n"; DBInsert("$DDIR/emails", $F{'Email'}); $DEL = '|';

    if( $F{'Thumb_Source'} eq 'Crop' )
    {
        $T{'Image_Name'} = "t$hex_ip.jpg";
        DisplayCrop($results);
    }
    else
    {
        if( -e "$THUMB_DIR/t$hex_ip.jpg" )
        {
            $DB->Update("UPDATE ags_Galleries SET Thumbnail_URL=?,Thumb_Height=?,Thumb_Width=? WHERE Gallery_ID=?", [$T{'Thumbnail_URL'}, $height, $width, $T{'Gallery_ID'}]);
            rename("$THUMB_DIR/t$hex_ip.jpg", "$THUMB_DIR/$T{'Gallery_ID'}.jpg");
            Mode(0666, "$THUMB_DIR/$T{'Gallery_ID'}.jpg");
        }

        if( $confirm )
        {
            $T{'To'} = $F{'Email'};
            $T{'From'} = $ADMIN_EMAIL;
            $T{'Confirm_ID'} = $confirm_id;
            $T{'Confirm_URL'} = "$CGI_URL/confirm.cgi";

            Mail("$TDIR/email_confirm.tpl");
        }

        ParseTemplate('submit_complete.tpl');
    }
}
