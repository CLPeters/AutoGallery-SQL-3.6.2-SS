#!/usr/bin/perl


use Fcntl qw(:DEFAULT :flock);


chdir('..');


eval
{
    require 'common.pl';
    require 'ags.pl';
    require 'mysql.pl';
    require 'http.pl';
    require 'compiler.pl';
    Header("Content-type: text/html\n\n");
    main();
};


if( $@ )
{
    Error("$@", 'main.cgi');
}



sub main
{
    ParseRequest();
    GetAjaxUrls();

    if( !$ADMIN_EMAIL && !$F{'ADMIN_EMAIL'} )
    {
        DisplayOptions();
        exit;
    }

    if( !$F{'Run'} )
    {
        DisplayMain();
    }
    else
    {
        &{$F{'Run'}};
    }
}



## Display the main cpanel page
sub DisplayMain
{
    my $backup = FileReadLine("$DDIR/backup");

    $DB->Connect();

    $T{'Version'} = $VERSION;
    $T{'Username'} = $ENV{'REMOTE_USER'};
    $T{'Pending'} = $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Status='Pending'");
    $T{'Unconfirmed'} = $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Status='Unconfirmed'");
    $T{'Reports'} = $DB->Count("SELECT COUNT(*) FROM ags_Reports");
    $T{'Requests'} = $DB->Count("SELECT COUNT(*) FROM ags_Requests");
    $T{'Recommend'} = 1 if( $TIME - $backup > 259200 );
    $T{'Backup'} = Date(undef, $backup);
    $T{'Bad_Browser'} = BadBrowser();

    $DB->Disconnect();

    ParseTemplate('admin_index.tpl');

    CleanupThumbs();
}



## Display script template file editing page
sub DisplayScriptTemplates
{
    for( sort @{DirRead($TDIR, '^(submit|confirm|remind|report|partner)')} )
    {
        $T{'Template_Options'} .= "\t<option value=\"$_\">$_</option>\n";
    }

    ParseTemplate('admin_scripttemplates.tpl');
}



## Display the show page URLs interface
sub DisplayPageURLs
{
    my $page = undef;

    $DB->Connect();
    my $result = $DB->Query("SELECT * FROM ags_Pages ORDER BY Build_Order");

    while( $page = $DB->NextRow($result) )
    {
        $page->{'Http_Host'} = $ENV{'HTTP_HOST'};
        TemplateAdd('Pages', $page);
    }

    $DB->Free($result);

    ParseTemplate('admin_pageurls.tpl');
}



## Display page management interface
sub DisplayManagePages
{
    CheckAccessList();

    $T{'Document_Root'} = $DOCUMENT_ROOT;

    ## Add categories to the template
    GetCategoryList();
    for( @CATEGORIES )
    {
        my $H = {};
        $H->{'Name'} = $_;
        TemplateAdd('Categories', $H);
    }

    
    ## Get existing pages
    $DB->Connect();

    my $result = $DB->Query("SELECT * FROM ags_Pages ORDER BY Build_Order");
    while( $page = $DB->NextRow($result) )
    {
        $page->{'Http_Host'} = $ENV{'HTTP_HOST'};
        TemplateAdd('Pages', $page);
    }
    $DB->Free($result);

    $T{'Build_Order'} = $DB->Count("SELECT MAX(Build_Order) FROM ags_Pages") + 1;

    ParseTemplate('admin_managepages.tpl');
}



## Display the page editing interface
sub DisplayEditPage
{
    CheckAccessList();

    GetCategoryList();

    unshift(@CATEGORIES, 'Mixed');

    my $page = $DB->Row("SELECT * FROM ags_Pages WHERE Page_ID=?", [$F{'Page_ID'}]);

    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Name'} = $_;
        $H->{'Selected'} = 1 if( $H->{'Name'} eq $page->{'Category'} );
        
        TemplateAdd('Categories', $H);
    }

    map($T{$_} = $page->{$_}, keys %$page);

    $T{'Document_Root'} = $DOCUMENT_ROOT;

    ParseTemplate('admin_pageedit.tpl');
}



## Display TGP HTML editing page
sub DisplayPageTemplates
{
    CheckAccessList();

    my $total = 0;

    $DB->Connect();

    my $result = $DB->Query("SELECT * FROM ags_Pages ORDER BY Build_Order");
    while( $page = $DB->NextRow($result) )
    {
        $total++;
        TemplateAdd('Pages', $page);
    }
    $DB->Free($result);

    if( $total < 1 )
    {
        AdminError("One or more pages must be defined before accessing this function.<br />Use the Manage Pages interface to create one or more TGP pages.");
    }

    ParseTemplate('admin_pagetemplates.tpl');
}



## Display find and replace for TGP pages
sub DisplayPageReplace
{
    CheckAccessList();

    $DB->Connect();

    my $result = $DB->Query("SELECT * FROM ags_Pages ORDER BY Build_Order");
    while( $page = $DB->NextRow($result) )
    {
        TemplateAdd('Pages', $page);
    }
    $DB->Free($result);

    ParseTemplate('admin_pagereplace.tpl');
}



## Display e-mail template file editing page
sub DisplayEmailEditor
{
    for( @{DirRead($TDIR, '^email')} )
    {
        $T{'Template_Options'} .= "\t<option value=\"$_\">$_</option>\n";
    }

    ReadAttachments();
    ParseTemplate('admin_emaileditor.tpl');
}



## Display rejection e-mail template editing page
sub DisplayRejectEditor
{
    for( @{DirRead("$DDIR/reject", '^[^.]')} )
    {
        $T{'Template_Options'} .= "\t<option value=\"$_\">$_</option>\n";
    }

    ReadAttachments();
    ParseTemplate('admin_rejections.tpl');
}



## Display the language file editor
sub DisplayLangEditor
{
    my $lang = IniParse("$DDIR/language");

    for( sort keys %$lang )
    {
        my $H = {};

        $H->{'Identifier'} = $_;
        $H->{'Value'}      = $lang->{$_};

        TemplateAdd('Text', $H);
    }

    ParseTemplate('admin_languageedit.tpl');
}



## Display category management
sub DisplayManageCategories
{
    my $category = undef;
    my $annotation = undef;

    $DB->Connect();

    ## Add existing categories to the template
    my $result = $DB->Query("SELECT * FROM ags_Categories ORDER BY Name");
    while( $category = $DB->NextRow($result) )
    {
        StripHTML(\$category->{'Name'});
        TemplateAdd('Categories', $category);
    }
    $DB->Free($result);


    ## Add annotations to the template
    $result = $DB->Query("SELECT * FROM ags_Annotations ORDER BY Identifier");
    while( $annotation = $DB->NextRow($result) )
    {
        TemplateAdd('Annotations', $annotation);
    }
    $DB->Free($result);

    ParseTemplate('admin_categories.tpl');
}



## Display the variables screen
sub DisplayOptions
{
    CheckAccessList();

    ReadVariables();

    ParseTemplate('admin_options.tpl');
}



## Display add submitter account screen
sub DisplayAddAccount
{
    my $icons = IniParse("$DDIR/icons");

    for( keys %$icons )
    {
        my $H = {};

        $H->{'Identifier'} = $_;
        $H->{'HTML'} = $icons->{$_};

        TemplateAdd('Icons', $H);
    }

    ParseTemplate('admin_accountadd.tpl');
}



## Display edit submitter account screen
sub DisplayEditAccount
{
    CheckPrivileges($P_ACCOUNTS);

    my $account = undef;
    my $icons   = IniParse("$DDIR/icons");

    $DB->Connect();
    $account = $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=?", [$F{'Account_ID'}]);
    $DB->Disconnect();

    HashToTemplate($account);

    for( keys %$icons )
    {
        my $H = {};

        $H->{'Identifier'} = $_;
        $H->{'HTML'} = $icons->{$_};
        $H->{'Checked'} = ' checked' if( index(",$account->{'Icons'},", ",$H->{'Identifier'},") != -1 );

        TemplateAdd('Icon', $H);
    }

    ParseTemplate('admin_accountedit.tpl');
}



## Display submitter accounts
sub DisplayAccounts
{
    my $account = undef;    

    $T{'Page'}         = $F{'Page'} || 0;
    $T{'Per_Page'}     = $F{'Per_Page'} || 10;
    $T{'Order_Field'}  = $F{'Order_Field'} || 'Account_ID';
    $T{'Search_Value'} = $F{'Search_Value'};
    $T{'Search_Field'} = $F{'Search_Field'};
    $T{'Page_Next'}    = $T{'Page'} + 1;
    $T{'Page_Prev'}    = $T{'Page'} - 1;
    $T{'Limit'}        = $T{'Page'} * $T{'Per_Page'};

    AddSlashes(\%F);

    $T{'Query'} = "SELECT * FROM ags_Accounts " .
                  ($F{'Search_Value'} ? "WHERE $F{'Search_Field'} LIKE '%$F{'Search_Value'}%' " : '') .
                  "ORDER BY $T{'Order_Field'} LIMIT $T{'Limit'},$T{'Per_Page'}";

    $DB->Connect();    

    $T{'Total'} = $DB->Count("SELECT COUNT(*) FROM ags_Accounts" . ($F{'Search_Value'} ? " WHERE $F{'Search_Field'} LIKE '%$F{'Search_Value'}%' " : ''));
    $T{'Start'} = $T{'Limit'} + 1;

    my $result = $DB->Query($T{'Query'});

    $T{'Rows'} = $DB->NumRows($result);

    while( $account = $DB->NextRow($result) )
    {
        my $H = {};

        map( $H->{$_} = $account->{$_}, keys %$account );

        $H->{'Allowed'} = 'NL' if( $H->{'Allowed'} == -1 );

        if( $H->{'Start_Date'} )
        {
            $H->{'Dates'} = $H->{'Start_Date'} . ' to ' . $H->{'End_Date'};
        }
        else
        {
            $H->{'Dates'} = 'No Date Limit';
        }

        TemplateAdd('Accounts', $H);
    }    

    $DB->Free($result);

    ParseTemplate('admin_accounts.tpl');

    $DB->Disconnect();
}



## Display the add moderator screen
sub DisplayAddModerator
{
    CheckAccessList();

    ParseTemplate('admin_moderatoradd.tpl');
}



## Display the edit moderator screen
sub DisplayEditModerator
{
    CheckPrivileges($P_MODERATORS);

    my $account = undef;

    $DB->Connect();
    $account = $DB->Row("SELECT * FROM ags_Moderators WHERE Username=?", [$F{'Username'}]);
    $DB->Disconnect();

    HashToTemplate($account);

    ParseTemplate('admin_moderatoredit.tpl');
}



## Display moderator accounts
sub DisplayModerators
{
    my $account = undef;

    $T{'Page'} = $F{'Page'} || 0;
    $T{'Per_Page'} = $F{'Per_Page'} || 10;
    $T{'Order_Field'} = $F{'Order_Field'} || 'Username';
    $T{'Search_Value'} = $F{'Search_Value'};
    $T{'Search_Field'} = $F{'Search_Field'};
    $T{'Page_Next'} = $T{'Page'} + 1;
    $T{'Page_Prev'} = $T{'Page'} - 1;
    $T{'Limit'} = $T{'Page'} * $T{'Per_Page'};

    AddSlashes(\%F);

    $T{'Query'} = "SELECT * FROM ags_Moderators " .
                  ($F{'Search_Value'} ? "WHERE $F{'Search_Field'} LIKE '%$F{'Search_Value'}%' " : '') .
                  "ORDER BY $T{'Order_Field'} LIMIT $T{'Limit'},$T{'Per_Page'}";

    $DB->Connect();

    $T{'Total'} = $DB->Count("SELECT COUNT(*) FROM ags_Moderators" . ($F{'Search_Value'} ? " WHERE $F{'Search_Field'} LIKE '%$F{'Search_Value'}%' " : ''));
    $T{'Start'} = $T{'Limit'} + 1;

    my $result = $DB->Query($T{'Query'});

    while( $account = $DB->NextRow($result) )
    {
        my $H = {};

        map( $H->{$_} = $account->{$_}, keys %$account );

        TemplateAdd('Accounts', $H);
    }

    $T{'Rows'} = $DB->NumRows();

    $DB->Free($result);

    ParseTemplate('admin_moderators.tpl');

    $DB->Disconnect();
}



## Display blacklist editing screen
sub DisplayBlacklist
{
    ParseTemplate('admin_blacklist.tpl');
}



## Display 2257 link editing screen
sub Display2257
{
    $T{'Links'} = ${FileReadScalar("$DDIR/2257")};

    ParseTemplate('admin_2257.tpl');
}



## Display recprocal link editing screen
sub DisplayReciprocals
{
    my %types = ( 'General', 'generalrecips', 'Trusted', 'trustedrecips' );

    for( keys %types )
    {
        my $type = $_;
        my $ini  = IniParse("$DDIR/$types{$type}");

        for( keys %$ini )
        {
            my $H = {};

            $H->{'Identifier'} = $_;
            $H->{'HTML'}       = $ini->{$_};

            StripHTML(\$H->{'HTML'});

            TemplateAdd($type, $H);
        }
    }

    ParseTemplate('admin_reciprocals.tpl');
}



## Display gallery import screen
sub DisplayImport
{
    $DB->Connect();

    AdminError('E_NO_CATEGORIES') if( $DB->Count("SELECT COUNT(*) FROM ags_Categories") < 1 );

    $DB->Disconnect();

    ParseTemplate('admin_import.tpl');
}



## Display the manual gallery submission page
sub DisplaySubmit
{
    ## Add categories to the template
    GetCategoryList();

    if( !scalar(@CATEGORIES) )
    {
        AdminError('E_NO_CATEGORIES');
    }

    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Category'} = $_;

        TemplateAdd('Categories', $H);
    }

    $T{'Width'} = $THUMB_WIDTH;
    $T{'Height'} = $THUMB_HEIGHT;

    ParseTemplate('admin_submit.tpl');
}



## Display the cropping tool
sub DisplayCrop
{
    $T{'Gallery_ID'} = $F{'Gallery_ID'};
    $T{'Prefix'} = "_$F{'Gallery_ID'}_";
    $T{'Thumb_URL'} = $THUMB_URL;
    $T{'Thumb_Height'} = $THUMB_HEIGHT;
    $T{'Thumb_Width'} = $THUMB_WIDTH;
    $T{'Script_URL'} = $CGI_URL;

    ParseTemplate('admin_crop.tpl');
}



## Display a breakdown of the galleries in the database
sub DisplayBreakdown
{
    my $row = undef;
    my $result = undef;

    $DB->Connect();


    ## Get submitted gallery information
    $result = $DB->Query("SELECT Status,COUNT(*) AS Total FROM ags_Galleries WHERE Type='Submitted' AND Status!='Submitting' GROUP BY Status ORDER BY Status");
    while( $row = $DB->NextRow($result) )
    {
        TemplateAdd('Submitted', $row);
    }
    $DB->Free($result);


    ## Get permanent gallery information
    $result = $DB->Query("SELECT Status,COUNT(*) AS Total FROM ags_Galleries WHERE Type='Permanent' GROUP BY Status ORDER BY Status");
    while( $row = $DB->NextRow($result) )
    {
        TemplateAdd('Permanent', $row);
    }
    $DB->Free($result);


    ParseTemplate('admin_breakdown.tpl');
}



## Display the referrers and agents interface
sub DisplayReferrersAndAgents
{
    $T{'Agents'} = ${FileReadScalar("$DDIR/agents")};
    $T{'Referrers'} = ${FileReadScalar("$DDIR/referrers")};

    ParseTemplate('admin_referrersagents.tpl');
}



## Display the gallery scanner configuration/run screen
sub DisplayScanner
{
    ## Get types
    my @types = ('Submitted', 'Permanent');
    for( @types )
    {
        my $H = {};

        $H->{'Type'} = $_;

        if( $H->{'Type'} eq $T{'type'} )
        {
            $H->{'Selected'} = ' selected';
        }

        TemplateAdd('Types', $H);
    }


    ## Get statuses
    my @statuses = ('Unconfirmed', 'Pending', 'Approved', 'Used', 'Holding', 'Disabled');
    for( @statuses )
    {
        my $H = {};

        $H->{'Status'} = $_;

        if( $H->{'Status'} eq $T{'status'} )
        {
            $H->{'Selected'} = ' selected';
        }

        TemplateAdd('Statuses', $H);
    }


    ## Get categories
    GetCategoryList();
    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Name'} = $_;

        if( $H->{'Name'} eq $T{'category_name'} )
        {
            $H->{'Selected'} = ' selected';
        }

        TemplateAdd('Categories', $H);
    }


    ## Get sponsors
    $result = $DB->Query("SELECT DISTINCT Sponsor FROM ags_Galleries ORDER BY Sponsor");
    while( $sponsor = $DB->NextRow($result) )
    {
        my $H = {};

        if( !$sponsor->{'Sponsor'} )
        {
            next;
        }

        $H = $sponsor;

        if( $H->{'Sponsor'} eq $T{'sponsor_name'} )
        {
            $H->{'Selected'} = ' selected';
        }

        TemplateAdd('Sponsors', $H);
    }
    $DB->Free($result);


    for( @{DirRead("$DDIR/scanner", '^[^.]+$')} )
    {
        my $H = {};

        $H->{'Identifier'} = $_;

        TemplateAdd('Configurations', $H);

        if( -e "$DDIR/report-$H->{'Identifier'}.html" )
        {
            $H->{'Main_URL'} = $MAIN_URL;

            TemplateAdd('Reports', $H);
        }
    }

    $T{'height'} = $THUMB_HEIGHT if( !exists $T{'height'} );
    $T{'width'} = $THUMB_WIDTH if( !exists $T{'width'} );

    ParseTemplate('admin_scanner.tpl');
}



## Display galleries in the database
sub DisplayGalleries
{
    my $gallery = undef;
    my $qualify = undef;
    my $default_reject = 'None';


    $DB->Connect();


    ## Default values
    $T{'Per_Page'} = 20;
    $T{'Has_Thumb'} = '0,1';
    $T{'Order_Field'} = 'Gallery_ID';
    $T{'Direction'} = 'ASC';
    $T{'File_Name'} = 't' . IP2Hex($ENV{'REMOTE_ADDR'});
    $T{'Page'} = 0;
    $T{'Partner'} = 0;
    $T{'Unique'} = $UNIQUE;
    $T{'Status'} = 'Approved';
    $T{'Format'} = 'Pictures,Movies';
    $T{'Type'} = 'Submitted,Permanent';
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


    ## Copy the form variables into the template
    HashToTemplate(\%F);

    AddSlashes(\%T);


    ## Add icons to the template
    $T{'Icons'} = undef;
    my $icons = IniParse("$DDIR/icons");
    for( keys %$icons )
    {
        my $H = {};
        $H->{'Identifier'} = $_;
        $H->{'HTML'} = $icons->{$_};
        TemplateAdd('Icons', $H);
    }


    ## Add reject reasons to the template
    for( @{DirRead("$DDIR/reject", '^[^.]')} )
    {
        my $H = {};
        $H->{'Reason'} = $_;

        if( $H->{'Reason'} eq 'RejectGallery' )
        {
            $H->{'Selected'} = ' selected';
            $default_reject = 'RejectGallery'; 
        }

        TemplateAdd('Reasons', $H);
    }


    ## Load annotations for use on the template
    my $annresult = $DB->Query("SELECT * FROM ags_Annotations ORDER BY Identifier");
    while( $ann = $DB->NextRow($annresult) )
    {
        TemplateAdd('Annotations', $ann);
    }
    $DB->Free($annresult);


    ## Get selected categories
    my $selected_cats = GetSelectedCategories();


    ## Generate the SQL query qualifier
    $qualify = "Type IN (" . MakeList($T{'Type'}) . ") AND " .
               "Format IN (" . MakeList($T{'Format'}) . ") AND " .
               "Status IN (" . MakeList($T{'Status'}) . ") AND " .
               "Category IN (" . MakeList($selected_cats) . ") AND " .
               ($T{'Partner'} ? "Account_ID!='' AND " : '') .
               "Has_Thumb IN ($T{'Has_Thumb'}) " .               
               ($T{'Search_Value'} ? GetSearchString() : '');


    ## Count the total number of matches
    $T{'Total'} = $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE $qualify");


    ## Figure the start, end, page, and limit values
    CalculatePositions();


    ## Run the query to get the galleries from the database
    my $result = $DB->Query("SELECT * FROM ags_Galleries WHERE $qualify " . GetOrderString() . " LIMIT $T{'Limit'},$T{'Per_Page'}");


    ## Add galleries to the template
    while( $gallery = $DB->NextRow($result) )
    {
        my $H = {};

        StripHTMLHash($gallery);

        map( $H->{$_} = $gallery->{$_}, keys %$gallery );

        $H->{'Thumbnail'} = "$THUMB_URL/$gallery->{'Gallery_ID'}.jpg?" . rand(99999999);
        $H->{'Weight'} = sprintf("%.3f", $gallery->{'Weight'});
        $H->{'Added'} = Date('%Y-%m-%d', $gallery->{'Added_Stamp'} + 3600 * $TIME_ZONE);
        $H->{'AS_Checked'} = ' checked' if( $gallery->{'Allow_Scan'} );
        $H->{'AT_Checked'} = ' checked' if( $gallery->{'Allow_Thumb'} );
        $H->{'URL_Class'} = ($gallery->{'Has_Recip'} ? 'flatgreen' : 'flat');
        $H->{'Default_Reject'} = $default_reject;
        $H->{'Productivity'} = sprintf('%.2f', $gallery->{'Clicks'}/$gallery->{'Build_Counter'}) if( $F{'Order_Field'} eq '(Clicks/Build_Counter)' );

        TemplateAdd('Galleries', $H);
    }

    $DB->Free($result);
    $DB->Disconnect();

    StripSlashes(\%T);

    ParseTemplate('admin_galleries.tpl');
}



## Display a gallery scanner report
sub DisplayReport
{
    FileTaint("$DDIR/F{'Page'}");

    if( -e "$DDIR/$F{'Page'}" )
    {
        print ${FileReadScalar("$DDIR/$F{'Page'}")};
    }
    else
    {
        print "There is no gallery scanner report available yet for this configuration";
    }  
}



## Display the IP resolving screen
sub DisplayResolveIP
{
    use Socket;

    my $host = gethostbyaddr(gethostbyname($F{'IP'}), AF_INET) || 'Unknown';

    if( $host eq 'Unknown' )
    {
        $T{'Message'} = "Unable to resolve $F{'IP'}";
    }
    else
    {
        $T{'Message'} = "$F{'IP'} resolved to:<br />$host";
    }

    ParseTemplate('admin_resolveip.tpl');
}



## Display the quickban interface
sub DisplayQuickBan
{
    my $gallery = undef;

    $DB->Connect();
    $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    $DB->Disconnect();

    map($T{$_} = $gallery->{$_}, keys %$gallery);

    $T{'DNS'} = @{GetNS($gallery->{'Gallery_URL'})}[0];
    $T{'Gallery_IP'} = GetIPFromURL($gallery->{'Gallery_URL'}) if( !$T{'Gallery_IP'} );

    ParseTemplate('admin_quickban.tpl');
}



## Display the gallery quick scan page
sub DisplayScanGallery
{
    my $whitelisted = 0;
    my $first_scan = 0;
    my $account = {};
    my $changes = {};

    $DB->Connect();

    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$gallery->{'Category'}]);

    if( $gallery->{'Account_ID'} )
    {
        $account = $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
    }


    ## See if the gallery is whitelisted
    if( $gallery->{'Type'} eq 'Permanent' || IsWhitelisted($gallery->{'Gallery_URL'}) )
    {
        $whitelisted = 1;
    }
    

    ## Scan the gallery
    $O_CHECK_SIZE = 0;
    my $results = ScanGallery($gallery->{'Gallery_URL'}, $category, $whitelisted, $account);


    ## Update gallery information if the gallery URL is still working    
    if( !$results->{'Error'} )
    {
        ## Not scanned before
        if( !$gallery->{'Scanned'} )
        {
            $first_scan = 1;
            $changes->{'Scanned'} = 1;
        }


        ## Page ID changed
        if( $results->{'Page_ID'} ne $gallery->{'Page_ID'} )
        {
            $changes->{'Page_ID'} = $results->{'Page_ID'};
        }

        
        ## Format changed
        if( $results->{'Format'} ne $gallery->{'Format'} )
        {
            $changes->{'Format'} = $results->{'Format'};
        }


        ## Gallery IP changed
        if( $results->{'Gallery_IP'} ne $gallery->{'Gallery_IP'} )
        {
            $changes->{'Gallery_IP'} = $results->{'Gallery_IP'};
        }


        ## Thumbnails changed
        if( $results->{'Thumbnails'} != $gallery->{'Thumbnails'} && $gallery->{'Thumbnails'} > 0 )
        {
            $changes->{'Thumbnails'} = $results->{'Thumbnails'};
        }


        ## Links changed
        if( $results->{'Links'} != $gallery->{'Links'} )
        {
            $changes->{'Links'} = $results->{'Links'};
        }


        ## Recip changed
        if( $results->{'Has_Recip'} != $gallery->{'Has_Recip'} )
        {
            $changes->{'Has_Recip'} = $results->{'Has_Recip'};
        }

        $changes->{'Speed'} = $results->{'Speed'};
        $changes->{'Page_Bytes'} = $results->{'Bytes'};

        if( scalar keys %$changes )
        {
            my @bind_values = ();
            my @bind_list = ();

            for( sort keys %$changes )
            {
                $T{$_."_Changed"} = 1 if( !$first_scan );
                push(@bind_values, $changes->{$_});
                push(@bind_list, "$_=?");
            }
            
            $DB->Update("UPDATE ags_Galleries SET " . join(',', @bind_list) . " WHERE Gallery_ID=?", [@bind_values, $F{'Gallery_ID'}]);
        }

        if( !$whitelisted )
        {
            $gallery->{'Http_Headers'} = $results->{'Headers'}->{'All'};
            my $blacklisted = IsBlacklisted($gallery);

            if( $blacklisted )
            {
                $results->{'Blacklisted'} = "$blacklisted->{'Type'}: $blacklisted->{'Item'}";
            }
        }
    }

    $DB->Disconnect();

    map($T{$_} = $results->{$_}, keys %$results);

    $T{'Gallery_ID'} = $F{'Gallery_ID'};

    ParseTemplate('admin_quickscan.tpl');
}



sub DisplayEmail
{
    ReadAttachments();
    ParseTemplate('admin_sendemail.tpl');
}



sub DisplayUpload
{
    $T{'Gallery_ID'} = $F{'Gallery_ID'};
    $T{'Width'} = $THUMB_WIDTH;
    $T{'Height'} = $THUMB_HEIGHT;

    ParseTemplate('admin_upload.tpl');
}



sub DisplayCheats
{
    my $report = undef;

    $DB->Connect();

    ## Run the query to get the cheat reports from the database
    my $result = $DB->Query("SELECT * FROM ags_Reports");

    ## Add galleries to the template
    while( $report = $DB->NextRow($result) )
    {
        TemplateAdd('Reports', $report);
    }

    $DB->Free($result);

    ParseTemplate('admin_cheats.tpl');
}



sub DisplayManageAnnotations
{
     my $annotation = undef;

    $DB->Connect();
    my $result = $DB->Query("SELECT * FROM ags_Annotations ORDER BY Identifier");

    while( $annotation = $DB->NextRow($result) )
    {
        if( $annotation->{'Unique_ID'} == $F{'Load_ID'} )
        {
            $annotation->{'Selected'} = ' selected';
        }

        TemplateAdd('Annotations', $annotation);
    }

    $DB->Disconnect();

    ParseTemplate('admin_annotations.tpl');
}


sub DisplayIcons
{
    my $ini = IniParse("$DDIR/icons");

    for( keys %$ini )
    {
        my $H = {};

        $H->{'Identifier'} = $_;
        $H->{'HTML'}       = $ini->{$_};

        StripHTML(\$H->{'HTML'});

        TemplateAdd('Icons', $H);
    }

    ParseTemplate('admin_icons.tpl');
}



## Display the quick tasks interface
sub DisplayQuickTasks
{
    ParseTemplate('admin_quicktasks.tpl');
}



sub DisplaySkippedCat
{
    for( @{FileReadArray("$DDIR/skippedcat.txt")} )
    {
        my $line = $_;
        my $H    = {};

        StripReturns(\$line);

        ($H->{'Line'}, $H->{'Data'}) = split(/\|/, $line, 2);

        $H->{'Line'} = sprintf("%5d", $H->{'Line'});

        TemplateAdd('Skipped', $H);
    }

    ParseTemplate('admin_skippedcat.tpl');
}



## This will display galleries that were not imported because they are duplicates
sub DisplaySkippedDupe
{
    for( @{FileReadArray("$DDIR/skippeddupe.txt")} )
    {
        my $line = $_;
        my $H    = {};

        StripReturns(\$line);

        ($H->{'Line'}, $H->{'Data'}) = split(/\|/, $line, 2);

        $H->{'Line'} = sprintf("%5d", $H->{'Line'});

        TemplateAdd('Skipped', $H);
    }

    ParseTemplate('admin_skippeddupe.tpl');
}



## Display duplicate submitted galleries
sub DisplayDuplicates
{
    $DB->Connect();

    my $result = $DB->Query("SELECT Gallery_URL,COUNT(*) AS Total FROM ags_Galleries GROUP BY Gallery_URL HAVING Total > 1");

    while( $gallery = $DB->NextRow($result) )
    {
        my $H = {};
    
        $H->{'Gallery_URL'} = $gallery->{'Gallery_URL'};
        $H->{'Total'}       = $gallery->{'Total'};

        TemplateAdd('Duplicates', $H);
    }

    $DB->Free($result);

    ParseTemplate('admin_duplicates.tpl');
}



## Display the raw HTTP headers and source of a gallery
sub DisplayRaw
{
    $DB->Connect();

    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$gallery->{'Category'}]);

    $DB->Disconnect();

    my $whitelisted = (IsWhitelisted($gallery->{'Gallery_URL'}) || $gallery->{'Type'} eq 'Permanent');

    my $results = ScanGallery($gallery->{'Gallery_URL'}, $category, $iswhitelisted);

    map($T{$_} = $results->{$_}, keys %$results);

    $T{'Gallery_ID'} = $F{'Gallery_ID'};
    $T{'All_Headers'} = "$results->{'StatusLine'}\n$results->{'Headers'}->{'All'}";
    
    StripHTML(\$T{'Body'});

    ParseTemplate('admin_sourceheaders.tpl');
}



## Display requests for partner accounts
sub DisplayAccountRequests
{
    $DB->Connect();

    ## Add reject reasons to the template
    for( @{DirRead("$DDIR/reject", '^[^.]')} )
    {
        $T{'Reject_Options'} .= "<option value=\"$_\"" . 
                                ($_ eq 'RejectPartner' ? ' selected' : '') .
                                ">$_</option>\n";
    }

    my $icons = IniParse("$DDIR/icons");
    my $icon_code = undef;

    for( keys %$icons )
    {
        $icon_code .= "<input type=\"checkbox\" name=\"Icons_##ID##\" value=\"$_\" style=\"margin: 0px 0px 0px 0px;\"> $icons->{$_} &nbsp;&nbsp;";
    }


    my $result = $DB->Query("SELECT * FROM ags_Requests ORDER BY Added");

    while( $request = $DB->NextRow($result) )
    {
        my $H = {};

        map($H->{$_} = $request->{$_}, keys %$request);

        $H->{'Reject_Options'} = $T{'Reject_Options'};
        $H->{'Added'} = Date("$DATE_FORMAT $TIME_FORMAT", $H->{'Added'});
        $H->{'Icons'} = $icon_code;

        $H->{'Icons'} =~ s/##ID##/$H->{'Unique_ID'}/gi;
        
        TemplateAdd('Requests', $H);
    }

    $DB->Free($result);

    

    ParseTemplate('admin_accountrequests.tpl');
}



## Display the automatic category page creation interface
sub DisplayAddCategoryPages
{
    CheckAccessList();
    GetCategoryList();

    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Name'} = $_;
       
        TemplateAdd('Categories', $H);
    }

    $T{'Document_Root'} = $DOCUMENT_ROOT;
    $T{'Base_URL'} = "http://$ENV{'HTTP_HOST'}";

    ParseTemplate('admin_addcategorypage.tpl')
}




## Display the error log
sub DisplayErrorLog
{
    $T{'Errors'} = ${FileReadScalar("$DDIR/error_log")} if( -e "$DDIR/error_log" );

    ParseTemplate('admin_errorlog.tpl')
}



## Display thumbnail management interface
sub DisplayThumbManager
{
    ParseTemplate('admin_thumbs.tpl');
}



## Display database tools interface
sub DisplayDatabaseTools
{
    CheckAccessList();

    ParseTemplate('admin_database.tpl');
}



################################################################################################################
################################################################################################################
####                                                                                                        ####
####                                                                                                        ####
####                                     END OF THE DISPLAY FUNCTIONS                                       ####
####                                                                                                        ####
####                                                                                                        ####
################################################################################################################
################################################################################################################




## Execute a raw SQL command
sub RawSQL
{
    CheckAccessList();
    CheckPrivileges($P_BACKUP);

    $DB->Connect();
    my $affected = $DB->Update($F{'SQL'});
    $DB->Disconnect();

    $T{'Message'} = "SQL query has been executed affecting $affected rows";

    DisplayDatabaseTools();
}



## TGP page find and replace
sub PageReplace
{
    CheckAccessList();
    CheckPrivileges($P_TEMPLATES);

    UnixFormat(\$F{'Find'});
    UnixFormat(\$F{'Replace'});

    my $compiler = new Compiler();
    my $replacements = 0;
    my $find = quotemeta($F{'Find'});

    $DB->Connect();

    for( split(',', $F{'Template'}) )
    {
        my $page_id = $_;
        my $contents = FileReadScalar("$DDIR/html/$page_id");

        $replacements += ($$contents =~ s/$find/$F{'Replace'}/gm);        

        my $page = $DB->Row("SELECT * FROM ags_Pages WHERE Page_ID=?", [$page_id]);
        my $success = $compiler->Compile($contents, $page->{'Category'}, $page->{'Page_ID'});

        if( !$success )
        {
            AdminError($compiler->GetLastError());
        }

        FileWrite("$DDIR/html/$page->{'Page_ID'}", $$contents);
        FileWrite("$DDIR/html/$page->{'Page_ID'}.comp", $compiler->{'Code'});
    }
    
    $T{'Message'} = "$replacements total replacements have been made";

    DisplayPageReplace();
}



## Remove thumbs based on input from the thumbnail management interface
sub DeleteThumbs
{
    my @wheres = ('Has_Thumb=1');
    my @ids = ();
    my $gallery = undef;

    CheckPrivileges($P_GALLERIES);

    AddSlashes(\%F);

    if( $F{'Status'} )
    {
        push(@wheres, "Status IN (" . MakeList($F{'Status'}) . ")");
    }

    if( $F{'Type'} )
    {
        push(@wheres, "Type IN (" . MakeList($F{'Type'}) . ")");
    }

    if( $F{'Format'} )
    {
        push(@wheres, "Format IN (" . MakeList($F{'Format'}) . ")");
    }

    if( $F{'Search'} )
    {
        if( $F{'Match'} eq '=' )
        {
            push(@wheres, "$F{'Field'}='$F{'Search'}'");
        }
        else
        {
            push(@wheres, "$F{'Field'} LIKE '%$F{'Search'}%'");
        }
    }

    my $query = "SELECT * FROM ags_Galleries WHERE " . join(' AND ', @wheres);

    $DB->Connect();
    my $result = $DB->Query($query);
    my $count = $DB->NumRows($result);

    while( $gallery = $DB->NextRow($result) )
    {
        push(@ids, $gallery->{'Gallery_ID'});

        if( -e "$THUMB_DIR/$gallery->{'Gallery_ID'}.jpg" )
        {
            unlink("$THUMB_DIR/$gallery->{'Gallery_ID'}.jpg");
        }
    }

    $DB->Free($result);
    $DB->Update("UPDATE ags_Galleries SET Has_Thumb=0,Thumbnail_URL=NULL WHERE Gallery_ID IN (" . MakeList(\@ids) . ")");
    $DB->Disconnect();
    
    $T{'Message'} = "$count thumbs have been removed";

    DisplayThumbManager();
}



## Run through the database and cleanup any galleries with broken thumbnails
sub ManualThumbCleanup
{
    my @ids = ();

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();
    my $result = $DB->Query("SELECT * FROM ags_Galleries WHERE Has_Thumb=1");
    my $gallery = undef;

    while( $gallery = $DB->NextRow($result) )
    {
        ## Thumbnail is located on local server
        if( $gallery->{'Thumbnail_URL'} eq "$THUMB_URL/$gallery->{'Gallery_ID'}.jpg" )
        {
            if( !-e "$THUMB_DIR/$gallery->{'Gallery_ID'}.jpg" )
            {
                push(@ids, $gallery->{'Gallery_ID'});
            }
        }
    }

    $DB->Free($result);
    $DB->Update("UPDATE ags_Galleries SET Has_Thumb=0,Thumbnail_URL=NULL WHERE Gallery_ID IN (" . MakeList(\@ids) . ")");
    $DB->Disconnect();

    $T{'Message'} = "Thumbnail cleanup routine completed";

    DisplayThumbManager();
}



## Clear the error_log file
sub ClearErrorLog
{
    CheckPrivileges($P_OPTIONS);

    FileWrite("$DDIR/error_log", '');
    FileWrite("$DDIR/last_error", (stat("$DDIR/error_log"))[9]); 

    $T{'Message'} = 'Error log has been cleared';

    DisplayErrorLog();
}



## Update a page in the database
sub EditPage
{
    CheckAccessList();
    CheckPrivileges($P_PAGES);

    my $compiler = new Compiler();

    my $fullpath = "$DOCUMENT_ROOT/$F{'Filename'}";
    my $filename = BaseName($fullpath);
    my $directory = LevelUpPath($fullpath);


    ## Invalid characters in filename
    if( $fullpath =~ /\.\.|\||;/ )
    {
        AdminError("For security reasons, the filename may not contain .., |, or ; characters");
    }


    ## Make sure the directory exists
    if( !-e $directory )
    {
        AdminError("The directory $directory does not exist.  Please create this directory and set it's permissions to 777");
    }

    ## Make sure the directory is writeable
    if( !-w $directory )
    {
        AdminError("The directory $directory has incorrect permissions.  Please set them to 777");
    }


    $DB->Connect();

    ## See if this page already exists
    if( $DB->Count("SELECT COUNT(*) FROM ags_Pages WHERE Page_ID!=? AND Filename=?", [$F{'Page_ID'}, $F{'Filename'}]) > 0 )
    {
        AdminError("The page you are trying to create already exists");
    }

    ## Update build order if supplied value is already in use
    if( $DB->Count("SELECT COUNT(*) FROM ags_Pages WHERE Page_ID!=? AND Build_Order=?", [$F{'Page_ID'}, $F{'Build_Order'}]) > 0 )
    {
        $DB->Update("UPDATE ags_Pages SET Build_Order=Build_Order+1 WHERE Build_Order >= ?", [$F{'Build_Order'}]);
    }

    $DB->Update("UPDATE ags_Pages SET " .
                "Filename=?, " .
                "Category=?, " .
                "Build_Order=? " .
                "WHERE Page_ID=?",
                [$F{'Filename'},
                 $F{'Category'},
                 $F{'Build_Order'},
                 $F{'Page_ID'}]);


    ## Recompile the template
    my $success = $compiler->Compile("$DDIR/html/$F{'Page_ID'}", $F{'Category'}, $F{'Page_ID'});
    FileWrite("$DDIR/html/$F{'Page_ID'}.comp", $compiler->{'Code'});


    ## Warn if the file is not writeable
    if( -e $fullpath && !-w $fullpath )
    {
        $T{'WarnPerms'} = 1;
    }

    RenumberPageOrder();

    $T{'Message'} = "This page has been successfully updated";
    $T{'Reload'} = 1;

    DisplayEditPage();
}



## Delete a page from the database
sub DeletePage
{
    CheckAccessList();
    CheckPrivileges($P_PAGES);

    $DB->Connect();

    FileRemove("$DDIR/pages/$F{'Page_ID'}") if( -e "$DDIR/pages/$F{'Page_ID'}" );
    FileRemove("$DDIR/pages/$F{'Page_ID'}.comp") if( -e "$DDIR/pages/$F{'Page_ID'}.comp" );

    $DB->Delete("DELETE FROM ags_Pages WHERE Page_ID=?", [$F{'Page_ID'}]);

    RenumberPageOrder();

    DisplayManagePages();
}



## Delete a page from the database
sub DeleteSelectedPages
{
    CheckAccessList();
    CheckPrivileges($P_PAGES);

    $DB->Connect();

    for( split(/,/, $F{'Page_ID'}) )
    {
        my $page_id = $_;

        FileRemove("$DDIR/pages/$page_id") if( -e "$DDIR/pages/$page_id" );
        FileRemove("$DDIR/pages/$page_id.comp") if( -e "$DDIR/pages/$page_id.comp" );

        $DB->Delete("DELETE FROM ags_Pages WHERE Page_ID=?", [$page_id]);
    }

    RenumberPageOrder();

    DisplayManagePages();
}




## Add a new TGP page to the database
sub AddPage
{
    CheckAccessList();
    CheckPrivileges($P_PAGES);

    my $compiler = new Compiler();
    my $default = FileReadScalar("$DDIR/default");
    my $fullpath = "$DOCUMENT_ROOT/$F{'Filename'}";
    my $filename = BaseName($fullpath);
    my $directory = LevelUpPath($fullpath);


    ## Invalid characters in filename
    if( $fullpath =~ /\.\.|\||;/ )
    {
        AdminError("For security reasons, the filename may not contain .., |, or ; characters");
    }


    ## Make sure the directory exists
    if( !-e $directory )
    {
        AdminError("The directory $directory does not exist.  Please create this directory and set it's permissions to 777");
    }

    ## Make sure the directory is writeable
    if( !-w $directory )
    {
        AdminError("The directory $directory has incorrect permissions.  Please set them to 777");
    }


    $DB->Connect();

    ## See if this page already exists
    if( $DB->Count("SELECT COUNT(*) FROM ags_Pages WHERE Filename=?", [$F{'Filename'}]) > 0 )
    {
        AdminError("The page you are trying to create already exists");
    }

    ## Update build order if supplied value is already in use
    if( $DB->Count("SELECT COUNT(*) FROM ags_Pages WHERE Build_Order=?", [$F{'Build_Order'}]) > 0 )
    {
        $DB->Update("UPDATE ags_Pages SET Build_Order=Build_Order+1 WHERE Build_Order >= ?", [$F{'Build_Order'}]);
    }

    $DB->Insert("INSERT INTO ags_Pages VALUES (?,?,?,?)", 
                 [undef,
                 $F{'Filename'},
                 $F{'Category'},
                 $F{'Build_Order'}]);

    $F{'Page_ID'} = $DB->InsertID();

    if( !-e "$DDIR/html/$F{'Page_ID'}" )
    {
        FileWrite("$DDIR/html/$F{'Page_ID'}", $$default);

        my $success = $compiler->Compile($default, $F{'Category'}, $F{'Page_ID'});

        FileWrite("$DDIR/html/$F{'Page_ID'}.comp", $compiler->{'Code'});
    }

    map($T{$_} = $F{$_}, keys %F);

    ## Warn if the file already exists
    if( -e $fullpath )
    {
        $T{'WarnExists'} = 1;

        ## Warn if the file is not writeable
        if( !-w $fullpath )
        {
            $T{'WarnPerms'} = 1;
        }
    }   

    RenumberPageOrder();

    $T{'Filename'} = $filename;
    $T{'Directory'} = $directory;
    $T{'Message'} = "New page $fullpath has been added";

    DisplayManagePages();
}



## Automatically generate category pages
sub AddCategoryPages
{
    CheckAccessList();
    CheckPrivileges($P_PAGES);

    my @selected_cats = ($F{'Category'});
    my $extension = $F{'Extension'};
    my $compiler = new Compiler();
    my $default = FileReadScalar("$DDIR/default");
    my $fullpath = "$DOCUMENT_ROOT/$F{'Directory'}";

    ## Remove trailing slashes
    $F{'Directory'} =~ s/\/$//;
    $fullpath =~ s/\/$//;


    ## Invalid characters in filename
    if( $fullpath =~ /\.\.|\||;/ )
    {
        AdminError("For security reasons, the filename may not contain .., |, or ; characters");
    }

    ## Make sure the directory exists
    if( !-e $fullpath )
    {
        AdminError("The directory $fullpath does not exist.  Please create this directory and set it's permissions to 777");
    }

    ## Make sure the directory is writeable
    if( !-w $fullpath )
    {
        AdminError("The directory $fullpath has incorrect permissions.  Please set them to 777");
    }


    $DB->Connect();


    if( $F{'Category'} eq '_ALL_' )
    {
        GetCategoryList();
        @selected_cats = @CATEGORIES;
    }

    
    my $build_order = $DB->Count("SELECT MAX(Build_Order) FROM ags_Pages") + 1;


    ## Add each page
    for( @selected_cats )
    {
        my $category = $_;
        my $prefix = $category;
        my $filename = undef;

        ## Handle conversion of non-alphanumeric characters
        $prefix =~ s/[^a-z0-9]/$F{'AlphaNum'}/gi;

        ## Handle text case change
        if( $F{'Case'} )
        {
             ChangeCase(\$prefix, $F{'Case'});
        }

        for( 1..$F{'Pages'} )
        {
            my $page_number = $_;

            ## Don't number the first page
            if( $page_number == 1 )
            {
                $page_number = undef;
            }

            $filename = $F{'Directory'} ? "$F{'Directory'}/$prefix$page_number.$extension" : "$prefix$page_number.$extension";

            ## See if this page already exists
            if( $DB->Count("SELECT COUNT(*) FROM ags_Pages WHERE Filename=?", [$filename]) > 0 )
            {
                next;
            }

            $DB->Insert("INSERT INTO ags_Pages VALUES (?, ?, ?, ?)",
                        [undef,
                         $filename,
                         $category,
                         $build_order]);

            $build_order++;

            $F{'Page_ID'} = $DB->InsertID();

            if( !-e "$DDIR/html/$F{'Page_ID'}" )
            {
                FileWrite("$DDIR/html/$F{'Page_ID'}", $$default);

                my $success = $compiler->Compile($default, $category, $F{'Page_ID'});

                FileWrite("$DDIR/html/$F{'Page_ID'}.comp", $compiler->{'Code'});
            }
        }
    }

    RenumberPageOrder();

    $T{'Message'} = "Category pages have been added";

    DisplayAddCategoryPages();
}


sub RenumberPageOrder
{
    $DB->Connect();

    $DB->Update("SET \@build_order=0");
    my $result = $DB->Query("SELECT * FROM ags_Pages ORDER BY Build_Order");

    while( $page = $DB->NextRow($result) )
    {
        $DB->Update("UPDATE ags_Pages SET Build_Order=\@build_order:=\@build_order+1 WHERE Page_ID=?", [$page->{'Page_ID'}]);
    }

    $DB->Free($result);
}



## Add a new annotation to the database
sub AddAnnotation
{
    CheckPrivileges($P_CATEGORIES);

    if( $F{'Type'} eq 'Text' && !-f "$ANNOTATION_DIR/$F{'Font_File'}" )
    {
        AdminError("The font file '$F{'Font_File'}' has not been uploaded to the annotations directory");
    }
    elsif( $F{'Type'} eq 'Image' && !-f "$ANNOTATION_DIR/$F{'Image_File'}" )
    {
        AdminError("The image file '$F{'Image_File'}' has not been uploaded to the annotations directory");
    }

    $DB->Connect();

    $DB->Insert("INSERT INTO ags_Annotations VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [undef,
                 $F{'Identifier'},
                 $F{'Type'},
                 $F{'Font_File'},
                 $F{'Image_File'},
                 $F{'String'},
                 $F{'Size'},
                 $F{'Color'},
                 $F{'Shadow'},
                 $F{'Location'},
                 $F{'Transparency'}]);


    $T{'Message'} = 'Annotation successfully added to the database';

    DisplayManageAnnotations();
}



## Update an annotation in the database
sub UpdateAnnotation
{
    CheckPrivileges($P_CATEGORIES);

    $DB->Connect();

    $DB->Update("UPDATE ags_Annotations SET " .
                "Identifier=?," .
                "Type=?," .
                "Font_File=?," .
                "Image_File=?," .
                "String=?," .
                "Size=?," .
                "Color=?," .
                "Shadow=?," .
                "Location=?," .
                "Transparency=? " .
                "WHERE Unique_ID=?",
                [$F{'Identifier'},
                 $F{'Type'},
                 $F{'Font_File'},
                 $F{'Image_File'},
                 $F{'String'},
                 $F{'Size'},
                 $F{'Color'},
                 $F{'Shadow'},
                 $F{'Location'},
                 $F{'Transparency'},
                 $F{'Unique_ID'}]);

    $T{'Message'} = 'Annotation successfully updated';

    DisplayManageAnnotations();
}



## Delete an annotation from the database
sub DeleteAnnotation
{
    CheckPrivileges($P_CATEGORIES);

    $DB->Connect();

    ## Update categories that reference this annotation
    $DB->Update("UPDATE ags_Categories SET Ann_Movies=0 WHERE Ann_Movies=?", [$F{'Load_ID'}]);
    $DB->Update("UPDATE ags_Categories SET Ann_Pictures=0 WHERE Ann_Pictures=?", [$F{'Load_ID'}]);

    $DB->Update("DELETE FROM ags_Annotations WHERE Unique_ID=?", [$F{'Load_ID'}]);   

    $T{'Message'} = 'Annotation has been removed';

    DisplayManageAnnotations();
}



## Load an annotation
sub LoadAnnotation
{
    $DB->Connect();

    $annotation = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$F{'Load_ID'}]);

    if( $annotation->{'Size'} == 0 )
    {
        $annotation->{'Size'} = undef;
    }

    HashToTemplate($annotation);

    $T{'Loaded'} = 1;

    DisplayManageAnnotations();
}



## Process partner account requests
sub ProcessAccountRequests
{
    my @skipped = ();

    CheckPrivileges($P_ACCOUNTS);

    $DB->Connect();

    ## Process approved accounts
    for( split(/,/, $F{'Approved'}) )
    {
        my $unique_id = $_;
        my $request = $DB->Row("SELECT * FROM ags_Requests WHERE Unique_ID=?", [$unique_id]);

        $request->{'Account_ID'} = $F{"Account_ID_$unique_id"};
        $request->{'Password'} = $F{"Password_$unique_id"};

        ## Check for existing username
        if( $DB->Count("SELECT COUNT(*) FROM ags_Accounts WHERE Account_ID=?", [$request->{'Account_ID'}]) > 0 )
        {
            push(@skipped, $request->{'Account_ID'});
            next;
        }

        if( $F{"Start_Date_$unique_id"} !~ /^\d\d\d\d-\d\d-\d\d$/ || $F{"End_Date_$unique_id"} !~ /^\d\d\d\d-\d\d-\d\d$/ )
        {
            $F{"Start_Date_$unique_id"} = $F{"End_Date_$unique_id"} = undef;
        }

        
        ## Create the partner account
        $DB->Insert("INSERT INTO ags_Accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
                    [$request->{'Account_ID'},
                     $request->{'Password'},
                     $request->{'Email'},
                     $F{"Weight_$unique_id"},
                     $F{"Allowed_$unique_id"},
                     0,
                     0,
                     int($F{"Auto_Approve_$unique_id"}),
                     int($F{"Check_Recip_$unique_id"}),
                     int($F{"Check_Black_$unique_id"}),
                     int($F{"Check_HTML_$unique_id"}),
                     int($F{"Confirm_$unique_id"}),
                     $F{"Icons_$unique_id"},
                     $F{"Start_Date_$unique_id"},
                     $F{"End_Date_$unique_id"}]);


        ## Send e-mail message
        %T = ();

        $T{'To'} = $request->{'Email'};
        $T{'From'} = $ADMIN_EMAIL;
        $T{'Submit_URL'} = "$CGI_URL/submit.cgi";
        
        map($T{$_} = $request->{$_}, keys %$request);

        Mail("$TDIR/email_account.tpl");


        ## Remove the request
        $DB->Delete("DELETE FROM ags_Requests WHERE Unique_ID=?", [$unique_id]);
    }


    ## Process rejected accounts
    for( split(/,/, $F{'Rejected'}) )
    {
        my $unique_id = $_;
        my $reject = $F{"Reject_$unique_id"};

        if( $reject ne 'None' )
        {
            my $request = $DB->Row("SELECT * FROM ags_Requests WHERE Unique_ID=?", [$unique_id]);

            %T = ();

            ## Send rejection e-mail
            $T{'To'} = $request->{'Email'};
            $T{'From'} = $ADMIN_EMAIL;

            map($T{$_} = $request->{$_}, keys %$request);

            Mail("$DDIR/reject/$reject");
        }

        $DB->Delete("DELETE FROM ags_Requests WHERE Unique_ID=?", [$unique_id]);
    }

    $T{'Message'} = 'The selected partner account requests have been processed';

    DisplayAccountRequests();
}



## Remove duplicates from the database
sub RemoveDuplicates
{
    my $deleted = 0;

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    my $result = $DB->Query("SELECT Gallery_URL,COUNT(*) AS Total FROM ags_Galleries GROUP BY Gallery_URL HAVING Total > 1");

    while( $gallery = $DB->NextRow($result) )
    {
        my $limit = $gallery->{'Total'} - 1;

        $limit = 0 if( $limit < 0 );

        $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_URL=? LIMIT $limit", [$gallery->{'Gallery_URL'}]);

        $deleted += $limit;
    }

    $DB->Free($result);

    CleanupThumbs();

    $T{'Message'} = "$deleted duplicate galleries have been deleted";

    ParseTemplate('admin_popup.tpl');
}



## Reset the number of hits sent to each gallery
sub ResetSubmittedClicks
{
    CheckPrivileges($P_GALLERIES);

    $DB->Connect();
    $DB->Update("UPDATE ags_Galleries SET Clicks=0 WHERE Type='Submitted'");
    $DB->Disconnect();

    $T{'Message'} = 'Click counts have been reset to 0 for all submitted galleries';

    DisplayQuickTasks();
}



## Reset the number of hits sent to each gallery
sub ResetPermanentClicks
{
    CheckPrivileges($P_GALLERIES);

    $DB->Connect();
    $DB->Update("UPDATE ags_Galleries SET Clicks=0 WHERE Type='Permanent'");
    $DB->Disconnect();

    $T{'Message'} = 'Click counts have been reset to 0 for all permanent galleries';

    DisplayQuickTasks();
}



## Do a search and set on the galleries table
sub SearchAndSet
{
    my $count = 0;

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    if( $F{'SSFind'} eq '[EMPTY]' )
    {
        $count = $DB->Update("UPDATE ags_Galleries SET $F{'SSSetIn'}=? WHERE $F{'SSFindIn'}='' OR $F{'SSFindIn'} IS NULL", [$F{'SSSet'}]);
    }
    else
    {
        $count = $DB->Update("UPDATE ags_Galleries SET $F{'SSSetIn'}=? WHERE $F{'SSFindIn'} LIKE ?", [$F{'SSSet'}, "%$F{'SSFind'}%"]);
    }

    $DB->Disconnect();
    
    $count = int($count);

    $T{'Message'} = "$count changes have been made";

    DisplayQuickTasks();
}



## Do a search and delete on the galleries table
sub SearchAndDelete
{
    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    my $count = $DB->Delete("DELETE FROM ags_Galleries WHERE $F{'SDFindIn'} LIKE ?", ["%$F{'SDFind'}%"]);
    
    $count = int($count);

    $T{'Message'} = "$count galleries have been deleted";

    CleanupThumbs();

    DisplayQuickTasks();
}



## Do a search and replace on the galleries table
sub SearchAndReplace
{
    my $count = 0;

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    if( $F{'SRFind'} eq '[EMPTY]' )
    {
        $count = $DB->Update("UPDATE ags_Galleries SET $F{'SRFindIn'}=? WHERE $F{'SRFindIn'}='' OR $F{'SRFindIn'} IS NULL", [$F{'SRReplace'}]);
    }
    else
    {
        $count = $DB->Update("UPDATE ags_Galleries SET $F{'SRFindIn'}=REPLACE($F{'SRFindIn'},?,?) WHERE $F{'SRFindIn'} LIKE ?", [$F{'SRFind'}, $F{'SRReplace'}, "%$F{'SRFind'}%"]);
    }

    $DB->Disconnect();
    
    $count = int($count);

    $T{'Message'} = "$count replacements have been made";

    DisplayQuickTasks();
}



## Decrement the build and used counters
sub DecrementCounters
{
    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    $DB->Update("UPDATE ags_Galleries SET Build_Counter=Build_Counter-1 WHERE Status='Used' OR Status='Holding'");
    $DB->Update("UPDATE ags_Galleries SET Used_Counter=Used_Counter-1 WHERE Status='Used'");

    $DB->Update("UPDATE ags_Galleries SET Build_Counter=1 WHERE Build_Counter < 1");
    $DB->Update("UPDATE ags_Galleries SET Used_Counter=1 WHERE Used_Counter < 1");

    $T{'Message'} = "Used and build counters have been decremented";

    DisplayQuickTasks();
}



## Handle uploaded thumbnail
sub UploadThumbnail
{
    CheckPrivileges($P_GALLERIES);

    require 'size.pl';

    my $filename = "$F{'Gallery_ID'}.jpg";
    my $annotation = undef;
    my $gallery = undef;
    my $category = undef;

    FileWrite("$THUMB_DIR/$filename", $F{'Preview'});

    my($width, $height) = imgsize(\$F{'Preview'});

    $width = $THUMB_WIDTH if( !$width );
    $height = $THUMB_HEIGHT if( !$height );

    $DB->Connect();

    if( $HAVE_MAGICK )
    {
        require 'image.pl';

        $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
        $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$gallery->{'Category'}]);

        if( $category->{"Ann_$gallery->{'Format'}"} != 0 )
        {
            $annotation = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$category->{"Ann_$gallery->{'Format'}"}]);
        }

        if( $F{'Crop'} )
        {
            $width = $THUMB_WIDTH = $F{'Width'};
            $height = $THUMB_HEIGHT = $F{'Height'};
            AutoResize("$THUMB_DIR/$filename", $F{'Gallery_ID'}, $annotation);
        }
        else
        {
            Annotate("$THUMB_DIR/$filename", $annotation);
        }
    }


    ## Update the database
    $DB->Update("UPDATE ags_Galleries SET Has_Thumb=1,Thumb_Width=?,Thumb_Height=?,Thumbnail_URL=? WHERE Gallery_ID=?", [$width, $height, "$THUMB_URL/$filename", $F{'Gallery_ID'}]);

    $DB->Disconnect();

    $T{'Thumbnail_URL'} = "$THUMB_URL/$filename";
    $T{'Gallery_ID'} = $F{'Gallery_ID'};
    $T{'Thumb_Width'} = $width;
    $T{'Thumb_Height'} = $height;

    ParseTemplate('admin_cropcomplete.tpl');
}



## Send e-mail to submitter accounts
sub SendAccountMail
{
    CheckPrivileges($P_EMAIL);

    my $result = undef;
    my $account = undef;
    my $message = undef;
    my $temp = undef;

    ## Generate the e-mail message
    $message = "=>[Subject]\n" .
               "$F{'Subject'}\n" .
               "=>[Text]\n" .
               "$F{'Text'}\n" .
               "=>[HTML]\n" .
               "$F{'HTML'}\n" .
               "=>[Attach]\n" .
               "$F{'Attach'}";


    $DB->Connect();

    ## Get correct accounts to e-mail
    if( $F{'ID'} eq 'ALLOFTHEM' )
    {
        $result = $DB->Query("SELECT * FROM ags_Accounts");
    }
    else
    {
        my @ids = split(/,/, $F{'ID'});
        $result = $DB->Query("SELECT * FROM ags_Accounts WHERE Account_ID IN (" . MakeBindList(scalar @ids) . ")", \@ids);
    }
    

    ## Send to each account
    while( $account = $DB->NextRow($result) )
    {
        $T{'To'} = $account->{'Email'};
        $T{'From'} = $ADMIN_EMAIL;

        map($T{$_} = $account->{$_}, keys %$account);

        $temp = $message;

        Mail(\$temp);
    }

    $DB->Free($result);

    $T{'Message'} = 'Accounts have been e-mailed';

    DisplayAccounts();
}



## Send e-mail to moderators
sub SendModeratorMail
{
    CheckPrivileges($P_EMAIL);

    my $result = undef;
    my $account = undef;
    my $message = undef;
    my $temp = undef;

    ## Generate the e-mail message
    $message = "=>[Subject]\n" .
               "$F{'Subject'}\n" .
               "=>[Text]\n" .
               "$F{'Text'}\n" .
               "=>[HTML]\n" .
               "$F{'HTML'}\n" .
               "=>[Attach]\n" .
               "$F{'Attach'}";


    $DB->Connect();
    

    ## Select the SQL query to use
    if( $F{'ID'} eq 'ALLOFTHEM' )
    {
        $result = $DB->Query("SELECT * FROM ags_Moderators");
    }
    else
    {
        my @ids = split(/,/, $F{'ID'});
        $result = $DB->Query("SELECT * FROM ags_Moderators WHERE Username IN (" . MakeBindList(scalar @ids) . ")", \@ids);
    }

    

    ## Send to each account
    while( $account = $DB->NextRow($result) )
    {
        $T{'To'} = $account->{'Email'};
        $T{'From'} = $ADMIN_EMAIL;

        map($T{$_} = $account->{$_}, keys %$account);

        $temp = $message;

        Mail(\$temp);
    }

    $DB->Free($result);


    $T{'Message'} = 'Accounts have been e-mailed';

    DisplayModerators();
}



## Display e-mail selected submitter accounts
sub EmailSelectedAccounts
{
    $T{'To'} = 'Selected submitter accounts';
    $T{'ID'} = $F{'Account_ID'};
    $T{'Run'} = 'SendAccountMail';

    DisplayEmail();
}



## Display e-mail all submitter accounts
sub EmailAllAccounts
{
    $T{'To'} = 'All submitter accounts';
    $T{'ID'} = 'ALLOFTHEM';
    $T{'Run'} = 'SendAccountMail';

    DisplayEmail();
}



## Display e-mail selected moderator accounts
sub EmailSelectedModerators
{
    $T{'To'} = 'Selected control panel accounts';
    $T{'ID'} = $F{'Username'};
    $T{'Run'} = 'SendModeratorMail';

    DisplayEmail();
}


## Display e-mail selected moderator accounts
sub EmailAllModerators
{
    $T{'To'} = 'All control panel accounts';
    $T{'ID'} = 'ALLOFTHEM';
    $T{'Run'} = 'SendModeratorMail';

    DisplayEmail();
}



## Process changes to galleries
sub ProcessGalleries
{
    my $approved = 0;
    my $rejected = 0;

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    for( split(/,/, $F{'Changed'}) )
    {
        my $id = $_;
        my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$id]);
        my $status = $F{$id . '_Status'};
        my $approve_date = $gallery->{'Approve_Date'};        
        my $approve_stamp = $gallery->{'Approve_Stamp'};
        my $scheduled_date = $F{$id . '_Scheduled_Date'};
        my $delete_date = $F{$id . '_Delete_Date'};
        my $display_date = $F{$id . '_Display_Date'};
        my $moderator = $gallery->{'Moderator'};
        my $was_unapproved = ($gallery->{'Status'} eq 'Unconfirmed' || $gallery->{'Status'} eq 'Pending' || ($gallery->{'Status'} eq 'Disabled' && !$moderator));
        my $is_approved = ($status eq 'Approved' || $status eq 'Used');
        my $is_used = ($gallery->{'Status'} ne 'Used' && $status eq 'Used');
        my $reject = $F{$id . '_Reject'};


        if( $scheduled_date !~ /^\d\d\d\d-\d\d-\d\d$/ )
        {
            $scheduled_date = undef;
        }

        if( $delete_date !~ /^\d\d\d\d-\d\d-\d\d$/ )
        {
            $delete_date = undef;
        }

        if( $display_date !~ /^\d\d\d\d-\d\d-\d\d$/ )
        {
            if( $status eq 'Used' )
            {
                $display_date = $MYSQL_DATE;
            }
            else
            {
                $display_date = undef;
            }
        }


        ## Gallery is NOT being rejected
        if( $status ne 'Reject' )
        {        
            ## Approving a new gallery
            if( $is_approved && $was_unapproved && $gallery->{'Type'} eq 'Submitted' )
            {
                $approved++;
                $approve_stamp = time;
                $approve_date = $MYSQL_DATE;
                $moderator = $ENV{'REMOTE_USER'};

                ## Send approval e-mail
                ## But do not send if the gallery e-mail is the same as the admin e-mail
                if( $O_PROCESS_EMAIL && $gallery->{'Email'} ne $ADMIN_EMAIL )
                {
                    %T = ();

                    $T{'To'} = $gallery->{'Email'};
                    $T{'From'} = $ADMIN_EMAIL;

                    map($T{$_} = $gallery->{$_}, keys %$gallery);

                    Mail("$TDIR/email_approved.tpl");
                }
            }

            ## Clear comments for galleries that are not disabled
            $gallery->{'Comments'} = '' if( $F{$id . '_Status'} ne 'Disabled' );

            $DB->Update("UPDATE ags_Galleries SET " .
                        "Gallery_URL=?, " .
                        "Description=?, " .
                        "Thumbnails=?, " .
                        "Category=?, " .
                        "Sponsor=?, " .
                        "Weight=?, " .
                        "Nickname=?, " .
                        "Clicks=?, " .
                        "Type=?, " .
                        "Format=?, " .
                        "Status=?, " .
                        "Approve_Date=?, " .
                        "Approve_Stamp=?, " .
                        "Scheduled_Date=?, " .
                        "Delete_Date=?, " .
                        "Display_Date=?, " .
                        ($is_used ? "Times_Selected=Times_Selected+1, " : '') .
                        "Moderator=?, " .
                        "Icons=?, " .
                        "Allow_Scan=?, " .
                        "Allow_Thumb=?, " .
                        "Keywords=?, " .
                        "Comments=?, " .
                        "Tag=? " .
                        "WHERE Gallery_ID=?", 
                        [$F{$id . '_Gallery_URL'},
                         $F{$id . '_Description'},
                         $F{$id . '_Thumbnails'},
                         $F{$id . '_Category'},
                         $F{$id . '_Sponsor'},
                         $F{$id . '_Weight'},
                         $F{$id . '_Nickname'},
                         $F{$id . '_Clicks'},
                         $F{$id . '_Type'},
                         $F{$id . '_Format'},
                         $F{$id . '_Status'},
                         $approve_date,
                         $approve_stamp,
                         $scheduled_date,
                         $delete_date,
                         $display_date,
                         $moderator,
                         $F{$id . '_Icons'},
                         int($F{$id . '_Allow_Scan'}),
                         int($F{$id . '_Allow_Thumb'}),
                         $F{$id . '_Keywords'},
                         $gallery->{'Comments'},
                         $F{$id . '_Tag'},
                         $id]);
        }


        ## Gallery IS being rejected
        else
        {
            ## Send rejection e-mail
            if( $O_PROCESS_EMAIL && $reject ne 'None' && $was_unapproved && $status eq 'Reject' )
            {
                %T = ();

                $T{'To'} = $gallery->{'Email'};
                $T{'From'} = $ADMIN_EMAIL;

                map($T{$_} = $gallery->{$_}, keys %$gallery);

                Mail("$DDIR/reject/$reject");
            }

            $rejected++;

            if( $gallery->{'Account_ID'} )
            {
                $DB->Update("UPDATE ags_Accounts SET Removed = Removed + 1 WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
            }

            $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$id]);

            
            ## Remove preview thumbnail
            if( -e "$THUMB_DIR/$id.jpg" )
            {
                unlink("$THUMB_DIR/$id.jpg");
            }
        }
    }

    $DB->Update("UPDATE ags_Moderators SET Approved=Approved+$approved, Declined=Declined+$rejected WHERE Username=?", [$ENV{'REMOTE_USER'}]);

    DisplayGalleries();
}



## Save a gallery scanner configuration
sub SaveScannerConfig
{
    CheckPrivileges($P_SCANNER);

    my $id = $F{'Identifier'};

    AdminError('The identifier may only contain letters and numbers') if( $id =~ /[^0-9A-Z_]/i );

    delete($F{'Identifier'});
    delete($F{'Config'});
    delete($F{'Run'});

    FileWrite("$DDIR/scanner/$id", '');

    AddSlashes(\%F);

    for( keys %F )
    {
        if( $F{$_} !~ /^[0-9x]+$/ )
        {
            FileAppend("$DDIR/scanner/$id", "\$$_ = '$F{$_}';\n");
        }
        else
        {
            FileAppend("$DDIR/scanner/$id", "\$$_ = $F{$_};\n");
        }
    }

    FileAppend("$DDIR/scanner/$id", "1;\n");

    $T{'Message'} = 'Gallery scanner configuration saved';

    DisplayScanner();
}



## Delete a gallery scanner configuration
sub DeleteScannerConfig
{
    CheckPrivileges($P_SCANNER);

    FileRemove("$DDIR/scanner/$F{'Config'}");

    $T{'Message'} = 'Gallery scanner configuration deleted';

    DisplayScanner();
}



## Load a gallery scanner configuration
sub LoadScannerConfig
{
    for( @{FileReadArray("$DDIR/scanner/$F{'Config'}")} )
    {
        if( $_ =~ /^\$(\w+)\s+=\s+'?(.*?)'?;/ )
        {
            $T{$1} = $2;
        }
    }

    $T{'FormatMovies'} = ' selected' if( $T{'only_format'} && $T{'format'} eq 'Movies' );
    $T{'FormatPictures'} = ' selected' if( $T{'only_format'} && $T{'format'} eq 'Pictures' );
    $T{'Identifier'} = $F{'Config'};

    StripSlashes(\%T);

    DisplayScanner();
}



## Build the TGP pages
sub BuildAllPages
{
    CheckPrivileges($P_REBUILD);

    CheckPermissions();

    $DB->Disconnect();

    my $pid = fork();

    $ERROR_LOG = 1;

    if( !$pid )
    {
        close STDIN; close STDOUT; close STDERR;
        &{$F{'Which'}}();
    }
    else
    {
        #$T{'NoClose'} = 1;
        $T{'Message'} = 'Page(s) Are Being Generated';

        ParseTemplate('admin_popup.tpl');
    }
}



## Check permissions on TGP pages and directories before building
sub CheckPermissions
{
    my $page = undef;

    $DB->Connect();

    ## Make sure all pages are writable
    my $result = $DB->Query("SELECT * FROM ags_Pages");

    while( $page = $DB->NextRow($result) )
    {
        my $cause = undef;
        my $filename = "$DOCUMENT_ROOT/$page->{'Filename'}";
        my $directory = LevelUpPath($filename);

        ## Directory does not exist
        if( !-e $directory )
        {
            $cause = "Directory '$directory' does not exist";
        }
        ## Directory not writeable
        elsif( !-w $directory )
        {
            $cause = "Directory '$directory' has incorrect permissions. Change to 777";
        }
        ## File not writeable
        elsif( -e $filename && !-w $filename )
        {
            $cause = "$filename has incorrect permissions. Change to 666.";
        }
        
        if( $cause )
        {
            $DB->Free($result);

            AdminError("Cannot build $filename<br />$cause");
        }
    }

    $DB->Free($result);
}



## Remove unconfirmed galleries more than 48 hours old
sub RemoveUnconfirmed
{
    CheckPrivileges($P_GALLERIES);

    RemoveOldUnconfirmed();

    $T{'Message'} = 'Old unconfirmed galleries have been removed';

    DisplayQuickTasks();
}



## Delete multiple galleries
sub DeleteSelectedGalleries
{
    my $gallery = undef;

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    for( split(/,/, $F{'Gallery_ID'}) )
    {
        my $id = $_;

        if( -e "$THUMB_DIR/$id.jpg" )
        {
            FileRemove("$THUMB_DIR/$id.jpg");
        }        

        $gallery = $DB->Row("SELECT * From ags_Galleries WHERE Gallery_ID=?", [$id]);

        if( $gallery->{'Account_ID'} )
        {
            $DB->Update("UPDATE ags_Accounts SET Removed = Removed + 1 WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
        }

        $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$id]);
    }

    DisplayGalleries();
}



## Delete a gallery
sub DeleteGallery
{
    my $gallery = undef;

    $ERROR_LOG = 1;

    CheckPrivileges($P_GALLERIES);

    if( -e "$THUMB_DIR/$F{'Gallery_ID'}.jpg" )
    {
        FileRemove("$THUMB_DIR/$F{'Gallery_ID'}.jpg");
    }

    $DB->Connect();

    $gallery = $DB->Row("SELECT * From ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);

    if( $gallery->{'Account_ID'} )
    {
        $DB->Update("UPDATE ags_Accounts SET Removed = Removed + 1 WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
    }

    $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);

    $DB->Disconnect();

    OutputAjax('Success', $F{'Gallery_ID'});
}



## Delete a thumbnail for a submitted gallery
sub DeleteThumbnail
{
    $ERROR_LOG = 1;

    CheckPrivileges($P_GALLERIES);

    if( -e "$THUMB_DIR/$F{'Gallery_ID'}.jpg" )
    {
        FileRemove("$THUMB_DIR/$F{'Gallery_ID'}.jpg");
    }

    $DB->Connect();
    $DB->Update("UPDATE ags_Galleries SET Has_Thumb=0,Thumbnail_URL=NULL,Thumb_Width=NULL,Thumb_Height=NULL WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    $DB->Disconnect();

    OutputAjax('Success', $F{'Gallery_ID'});
}



## Crop the thumbnail
sub CropThumbnail
{
    my $new_file = "$F{'Gallery_ID'}.jpg";

    $|++;

    CheckPrivileges($P_GALLERIES);

    $DB->Connect();

    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$gallery->{'Category'}]);
    my $annotation = undef;

    ## Determine if this thumbnail will get an annotation
    if( $category->{"Ann_$gallery->{'Format'}"} != 0 )
    {
        $annotation = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$category->{"Ann_$gallery->{'Format'}"}]);
    }


    ## Get the correct size to use for the preview thumbnail
    $THUMB_WIDTH  = $F{'thumb_width'};
    $THUMB_HEIGHT = $F{'thumb_height'};


    ## If user is going to custom filter the thumbnail
    ## set it to the highest quality setting for best
    ## possible results and do not annotate the image
    if( exists $F{'filter'} )
    {
        $THUMB_QUALITY = 100;
        $annotation = undef;
    }


    ## Crop and save the thumbnail
    require 'image.pl';
    FileCopy("$THUMB_DIR/cache/$F{'Image_Name'}", "$THUMB_DIR/$new_file");
    ManualResize("$THUMB_DIR/$new_file", $annotation);
    Mode(0666, "$THUMB_DIR/$new_file");


    ## Update the database 
    $DB->Update("UPDATE ags_Galleries SET Has_Thumb=1,Thumbnail_URL=?,Thumb_Height=?,Thumb_Width=? WHERE Gallery_ID=?", ["$THUMB_URL/$new_file", $THUMB_HEIGHT, $THUMB_WIDTH, $F{'Gallery_ID'}]);

    $T{'Thumbnail_URL'} = "$THUMB_URL/$new_file";
    $T{'Gallery_ID'} = $F{'Gallery_ID'};
    $T{'Thumb_Height'} = $THUMB_HEIGHT;
    $T{'Thumb_Width'} = $THUMB_WIDTH;

    if( exists $F{'filter'} )
    {
        $T{'Script_URL'} = "$CGI_URL/admin/xml.cgi";
        $T{'Unique'} = $UNIQUE;
        $T{'Custom_Filters'} = 1;

        ## Load annotations for use on the template
        my $result = $DB->Query("SELECT * FROM ags_Annotations ORDER BY Identifier");
        while( $ann = $DB->NextRow($result) )
        {
            TemplateAdd('Annotations', $ann);
        }
        $DB->Free($result);

        ## Prepare the undo table
        $DB->Update("DELETE FROM ags_Undos WHERE Image_ID=?", [$F{'Gallery_ID'}]);
        $DB->Insert("INSERT INTO ags_Undos VALUES (?, 0, ?)", [$F{'Gallery_ID'}, ${FileReadScalar("$THUMB_DIR/$new_file")}]);
    }

    ParseTemplate('admin_cropcomplete.tpl');

    $DB->Disconnect();
}



## Add a gallery to the database
sub SubmitGallery
{
    CheckPrivileges($P_GALLERIES);

    my $thumb_name = 't' . IP2Hex($ENV{'REMOTE_ADDR'}) . '.jpg';
    my $has_thumb = 1;
    my $moderator = undef;
    my $approve_stamp = undef;
    my $approve_date = undef;


    $DB->Connect();


    ## Get information on the selected category
    my $category = $DB->Row("SELECT * FROM ags_Categories WHERE Name=?", [$F{'Category'}]);  

    
    ## See if the gallery is whitelisted
    my $whitelisted = IsWhitelisted($F{'Gallery_URL'});


    ## Scan the gallery
    $O_CHECK_SIZE = 0;
    my $results = ScanGallery($F{'Gallery_URL'}, $category, $whitelisted);


    ## Setup date values if they were not supplied
    $F{'Scheduled_Date'} = undef if( $F{'Scheduled_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ );
    $F{'Delete_Date'} = undef if( $F{'Delete_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ );


    ## Set values if user selected Approved status
    if( $F{'Status'} eq 'Approved' )
    {
        $moderator = $ENV{'REMOTE_USER'};
        $approve_date = $MYSQL_DATE;
        $approve_stamp = time;
    }


    ## Clear fields if user did not select to specify thumbnail details
    if( $F{'Preview'} ne 'Specify' )
    {
        $has_thumb = 0;
        $F{'Thumbnail_URL'} = undef;
        $F{'Thumb_Width'} = undef;
        $F{'Thumb_Height'} = undef;
    }


    my $bind_list = [undef,
                     $F{'Email'},
                     $F{'Gallery_URL'},
                     $F{'Description'},
                     $F{'Thumbnails'},
                     $F{'Category'},
                     $F{'Sponsor'},
                     $has_thumb,
                     $F{'Thumbnail_URL'},
                     $F{'Thumb_Width'},
                     $F{'Thumb_Height'},
                     $F{'Weight'},
                     $F{'Nickname'},
                     0,
                     $F{'Type'},
                     $F{'Format'},
                     $F{'Status'},
                     undef,
                     $MYSQL_DATE,
                     time,
                     $approve_date,
                     $approve_stamp,
                     $F{'Scheduled_Date'},
                     undef,
                     $F{'Delete_Date'},
                     '',
                     $moderator,
                     $ENV{'REMOTE_ADDR'},
                     $results->{'Gallery_IP'},
                     1,
                     $results->{'Links'},
                     $results->{'Has_Recip'},
                     $results->{'Bytes'},
                     $results->{'Page_ID'},
                     $results->{'Speed'},
                     '',
                     int($F{'Allow_Scan'}),
                     int($F{'Allow_Thumb'}),
                     1,
                     1,
                     1,
                     $F{'Keywords'},
                     undef,
                     undef];
    

    ## Insert gallery into the database
    $DB->Insert("INSERT INTO ags_Galleries VALUES (" . MakeBindList(scalar @$bind_list) . ")", $bind_list);


    $T{'Gallery_ID'} = $DB->InsertID();
    $T{'Message'} = "Gallery has been added to the database with ID $T{'Gallery_ID'}";
    $T{'File_Name'} = $thumb_name;
    $T{'Gallery_URL'} = $F{'Gallery_URL'};
    $T{'Crop'} = 1 if( $F{'Preview'} eq 'Crop' );


    ## Save the uploaded thumbnail
    if( $F{'Preview'} eq 'Upload' )
    {
        require 'size.pl';

        my($width, $height, $id) = imgsize(\$F{'Upload'});

        if( $width && $height )
        {
            require 'image.pl';

            FileWrite("$THUMB_DIR/$T{'Gallery_ID'}.jpg", $F{'Upload'});
            Mode(0666, "$THUMB_DIR/$T{'Gallery_ID'}.jpg");

            if( $category->{"Ann_$F{'Format'}"} != 0 )
            {
                $annotation = $DB->Row("SELECT * FROM ags_Annotations WHERE Unique_ID=?", [$category->{"Ann_$F{'Format'}"}]);
            }

            if( $F{'Crop'} )
            {
                $width = $THUMB_WIDTH = $F{'Width'};
                $height = $THUMB_HEIGHT = $F{'Height'};
                AutoResize("$THUMB_DIR/$T{'Gallery_ID'}.jpg", $F{'Gallery_ID'}, $annotation);
            }
            else
            {
                Annotate("$THUMB_DIR/$T{'Gallery_ID'}.jpg", $annotation);
            }

            $DB->Update("UPDATE ags_Galleries SET " .
                        "Has_Thumb=1, " .
                        "Thumbnail_URL=?, " .
                        "Thumb_Width=?, " .
                        "Thumb_Height=? " .
                        "WHERE Gallery_ID=?",
                        ["$THUMB_URL/$T{'Gallery_ID'}.jpg",
                         $width,
                         $height,
                         $T{'Gallery_ID'}]);
        }
    }
    
    ## Setup for TGP Cropper
    if( $O_TGP_CROPPER )
    {
        $T{'TGP_Cropper'} = "tgpcropper://Post_Back_URL=" . URLEncode("$CGI_URL/admin/main.cgi") . 
                            "&Run=UploadThumbnail" .                        
                            "&Height=$THUMB_HEIGHT" .
                            "&Width=$THUMB_WIDTH" .
                            "&Quality=$THUMB_QUALITY";
    }

    ## Warn user that the URL is not working
    if( $results->{'Error'} )
    {
        $T{'WarnURL'} = $results->{'Error'};
    }

    ## Warn user that no thumbs could be found on the gallery
    if( !$results->{'Thumbnails'} )
    {
        $T{'WarnNoThumbs'} = 1;
    }

    DisplaySubmit();
}



## Record input to a temporary file so it can be analyzed
sub AnalyzeInput
{
    AdminError('E_REQUIRED', 'Gallery Input Box') if( !$F{'Input'} );

    UnixFormat(\$F{'Input'});

    ## Write data to a temporary file
    FileWrite("$DDIR/temp_import.txt", $F{'Input'});

    AnalyzeFile('temp_import.txt');
}



## Analyze the contents of the gallery import file
sub AnalyzeFile
{
    my $filename = shift || 'import.txt';

    if( -e "$DDIR/$filename" )
    {
        my $fields = FileReadSplit("$DDIR/$filename");

        for( my $i = 0; $i <= $#{$fields}; $i++ )
        {
            my $H = {};

            $H->{'Position'} = $i;
            $H->{'Value'} = $fields->[$i];

            TemplateAdd('Fields', $H);
        }
    }
    else
    {
        AdminError('E_NO_FILE', "$DDIR/$filename");
    }

    GetCategoryList();

    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Name'} = $_;

        TemplateAdd('Categories', $H);
    }

    $T{'Filename'} = $filename;

    ParseTemplate('admin_importanalyze.tpl');
}



## Import galleries into the database
sub ImportGalleries
{
    CheckPrivileges($P_IMPORT);

    ## Clear logs of previously skipped galleries
    FileWrite("$DDIR/skippedcat.txt", undef);
    FileWrite("$DDIR/skippeddupe.txt", undef);

    my $gallery = {};

    ## Default values
    $gallery->{'Gallery_ID'} = undef;
    $gallery->{'Email'} = $ADMIN_EMAIL;
    $gallery->{'Description'} = '';
    $gallery->{'Thumbnails'} = 0;
    $gallery->{'Nickname'} = '';
    $gallery->{'Sponsor'} = '';
    $gallery->{'Has_Thumb'} = 0;
    $gallery->{'Thumbnail_URL'} = undef;
    $gallery->{'Thumb_Width'} = undef;
    $gallery->{'Thumb_Height'} = undef;
    $gallery->{'Weight'} = 1.000;
    $gallery->{'Clicks'} = 0;
    $gallery->{'Type'} = $F{'Type'};
    $gallery->{'Format'} = $F{'Format'};
    $gallery->{'Status'} = $F{'Status'};
    $gallery->{'Confirm_ID'} = undef;
    $gallery->{'Added_Date'} = $MYSQL_DATE;
    $gallery->{'Added_Stamp'} = time;
    $gallery->{'Approve_Date'} = $MYSQL_DATE;
    $gallery->{'Approve_Stamp'} = time;
    $gallery->{'Scheduled_Date'} = undef;
    $gallery->{'Display_Date'} = undef;
    $gallery->{'Delete_Date'} = undef;
    $gallery->{'Account_ID'} = '';
    $gallery->{'Moderator'} = $ENV{'REMOTE_USER'};
    $gallery->{'Submit_IP'} = $ENV{'REMOTE_ADDR'};
    $gallery->{'Gallery_IP'} = '';
    $gallery->{'Scanned'} = 0;
    $gallery->{'Links'} = 0;
    $gallery->{'Has_Recip'} = 0;
    $gallery->{'Page_Bytes'} = 0;
    $gallery->{'Page_ID'} = '';
    $gallery->{'Speed'} = 0.0;
    $gallery->{'Icons'} = '';
    $gallery->{'Allow_Scan'} = 1;
    $gallery->{'Allow_Thumb'} = 1;
    $gallery->{'Times_Selected'} = 1;
    $gallery->{'Used_Counter'} = 1;
    $gallery->{'Build_Counter'} = 1;
    $gallery->{'Keywords'} = '';

    if( $gallery->{'Status'} eq 'Pending' )
    {
        $gallery->{'Approve_Date'} = undef;
        $gallery->{'Approve_Stamp'} = undef;
        $gallery->{'Moderator'} = undef;
    }

    
    ## Record supplied fields
    my $supplied = {};
    for( keys %F )
    {
        my $key = $_;

        if( $key =~ /^\d+$/ )
        {
            $supplied->{$F{$key}} = 1;
        }
    }

    AdminError("A gallery URL must be supplied in order to import galleries") if( !$supplied->{'Gallery_URL'} );
    AdminError("A valid category must be supplied in order to import galleries") if( !$F{'DefaultCat'} && !$supplied->{'Category'} );
    AdminError("You have indicated that the type will be taken from the import data, however a Type field has not been specified") if( !$F{'Type'} && !$supplied->{'Type'} );
    AdminError("You have indicated that the format will be taken from the import data, however a Format field has not been specified") if( !$F{'Format'} && !$supplied->{'Format'} );

    
    ## Get valid categories
    my $categories = {};
    GetCategoryList();
    map($categories->{$_} = 1, @CATEGORIES);


    $DB->Connect();

    my $bad_category = 0;
    my $duplicates = 0;
    my $line_number = 0;
    my $imported = 0;
    my @fields = ();
   
    for( @{FileReadArray("$DDIR/$F{'Filename'}")} )
    {
        my $line = $_;

        $line_number++;

        ## skip empty lines
        if( IsEmptyString($line) )
        {
            next;
        }

        StripReturns(\$line);

        @fields = split(/\|/, $line);

        map($gallery->{$F{$_}} = $fields[$_], keys %F);


        ## Handle bad category
        if( !exists $categories->{$gallery->{'Category'}} )
        {
            if( $F{'DefaultCat'} )
            {
                $gallery->{'Category'} = $F{'Category'};
            }
            else
            {
                FileAppend("$DDIR/skippedcat.txt", "$line_number|$line\n");
                $bad_category++;
                next;
            }
        }


        ## Handle the gallery description length
        if( $F{'Truncate'} )
        {
            if( length($gallery->{'Description'}) > $F{'Length'} )
            {
                if( $F{'Method'} eq 'Reject' )
                {
                    next;
                }
                else
                {
                    $gallery->{'Description'} = substr($gallery->{'Description'}, 0, $F{'Length'});
                }
            }
        }


        ## Change the text case of the description
        if( $F{'ChangeCase'} )
        {
            ChangeCase(\$gallery->{'Description'}, $F{'Case'});
        }


        ## See if this gallery is already in the database
        if( $F{'Duplicates'} )
        {
            if( $DB->Count("SELECT COUNT(*) FROM ags_Galleries WHERE Gallery_URL=?", [$gallery->{'Gallery_URL'}]) > 0 )
            {
                FileAppend("$DDIR/skippeddupe.txt", "$line_number|$line\n");
                $duplicates++;
                next;
            }
        }

        
        ## Make sure a valid format and type were provided
        $gallery->{'Format'} = 'Pictures' if( $gallery->{'Format'} ne 'Pictures' && $gallery->{'Format'} ne 'Movies' );
        $gallery->{'Type'} = 'Submitted' if( $gallery->{'Type'} ne 'Submitted' && $gallery->{'Type'} ne 'Permanent' );
        
        ## Check for valid date format
        $gallery->{'Scheduled_Date'} = undef if( $gallery->{'Scheduled_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ );
        $gallery->{'Delete_Date'} = undef if( $gallery->{'Delete_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ );

        
        ## Handle galleries with a Thumbnail URL
        if( $gallery->{'Thumbnail_URL'} )
        {
            $gallery->{'Has_Thumb'} = 1;
            $gallery->{'Thumb_Width'} = $THUMB_WIDTH if( !$gallery->{'Thumb_Width'} );
            $gallery->{'Thumb_Height'} = $THUMB_HEIGHT if( !$gallery->{'Thumb_Height'} );
        }


        my $bind_list = [$gallery->{'Gallery_ID'},
                         $gallery->{'Email'},
                         $gallery->{'Gallery_URL'},
                         $gallery->{'Description'},
                         int($gallery->{'Thumbnails'}),
                         $gallery->{'Category'},
                         $gallery->{'Sponsor'},
                         $gallery->{'Has_Thumb'},
                         $gallery->{'Thumbnail_URL'},
                         $gallery->{'Thumb_Width'},
                         $gallery->{'Thumb_Height'},
                         $gallery->{'Weight'},
                         $gallery->{'Nickname'},
                         $gallery->{'Clicks'},
                         $gallery->{'Type'},
                         $gallery->{'Format'},
                         $gallery->{'Status'},
                         $gallery->{'Confirm_ID'},
                         $gallery->{'Added_Date'},
                         $gallery->{'Added_Stamp'},
                         $gallery->{'Approve_Date'},
                         $gallery->{'Approve_Stamp'},
                         $gallery->{'Scheduled_Date'},
                         $gallery->{'Display_Date'},
                         $gallery->{'Delete_Date'},
                         $gallery->{'Account_ID'},
                         $gallery->{'Moderator'},
                         $gallery->{'Submit_IP'},
                         $gallery->{'Gallery_IP'},
                         $gallery->{'Scanned'},
                         $gallery->{'Links'},
                         $gallery->{'Has_Recip'},
                         $gallery->{'Page_Bytes'},
                         $gallery->{'Page_ID'},
                         $gallery->{'Speed'},
                         $gallery->{'Icons'},
                         $gallery->{'Allow_Scan'},
                         $gallery->{'Allow_Thumb'},
                         $gallery->{'Times_Selected'},
                         $gallery->{'Used_Counter'},
                         $gallery->{'Build_Counter'},
                         $gallery->{'Keywords'},
                         $gallery->{'Comments'},
                         $gallery->{'Tag'}];

        $DB->Insert("INSERT INTO ags_Galleries VALUES (" . MakeBindList(scalar @$bind_list) . ")", $bind_list);

        $imported++;
    }

    $DB->Disconnect();

    $T{'Message'} = "$imported Galleries Have Been Imported";

    ## Make note of galleries that were skipped because of a bad category
    if( $bad_category > 0 )
    {
        $T{'Message'} .= "<br />$bad_category galleries were skipped because they did not fit into a defined category<br />" .
                         "<a href=\"main.cgi?Run=DisplaySkippedCat\" target=\"main\" style=\"margin-left: 20px\" class=\"link\">" .
                         "View Skipped Galleries</a>";
    }

    
    ## Make note of galleries that were skipped because they were duplicates
    if( $duplicates > 0 )
    {
        $T{'Message'} .= "<br />$duplicates galleries were skipped because they are duplicates<br />" .
                         "<a href=\"main.cgi?Run=DisplaySkippedDupe\" target=\"main\" style=\"margin-left: 20px\" class=\"link\">". 
                         "View Duplicate Galleries</a>";
    }

    DisplayImport();
}



## Add items to the blacklist
sub QuickBan
{
    CheckPrivileges($P_BLACKLIST);

    $T{'More'} = 'blacklisted and';
    $T{'Gallery_ID'} = $F{'Gallery_ID'};

    delete $F{'Gallery_ID'};
    delete $F{'Run'};

    KEYS:
    for( keys %F )
    {
        my $type  = $_;
        my $found = 0;

        if( $F{$type} )
        {
            FileTaint("$DDIR/blacklist/$type");
            sysopen(DB, "$DDIR/blacklist/$type", O_RDWR|O_CREAT) || Error("$!", "$DDIR/blacklist/$type");
            flock(DB, LOCK_EX);

            for( <DB> )
            {
                if( $_ eq "$F{$type}\n" )
                {
                    $found = 1;
                    last;
                }
            }

            if( !$found )
            {
                print DB "$F{$type}\n";
            }

            flock(DB, LOCK_UN);
            close(DB);
        }
    }

    $DB->Connect();
    $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$T{'Gallery_ID'}]);    
    $DB->Update("UPDATE ags_Moderators SET Banned=Banned+1 WHERE Username=?", [$ENV{'REMOTE_USER'}]);
    $DB->Disconnect();

    if( -e "$THUMB_DIR/$T{'Gallery_ID'}.jpg" )
    {
        FileRemove("$THUMB_DIR/$T{'Gallery_ID'}.jpg");
    }

    ParseTemplate('admin_deletegallery.tpl');
}



## Remove a cheat report
sub ReportRemoveAll
{
    CheckPrivileges($P_CHEATS);

    $DB->Connect();
    $DB->Delete("DELETE FROM ags_Reports");

    $T{'Message'} = 'All cheat reports have been removed';

    DisplayCheats();
}



## Remove a cheat report
sub ReportRemove
{
    CheckPrivileges($P_CHEATS);

    AdminError('E_NO_SELECTION') if( !$F{'Report_ID'} );

    $DB->Connect();

    for( split(/,/, $F{'Report_ID'}) )
    {
        $DB->Delete("DELETE FROM ags_Reports WHERE Report_ID=?", [$_]);
    }

    $T{'Message'} = 'Selected reports have been removed';

    DisplayCheats();
}



## Remove a gallery that was reported
sub ReportDelete
{
    my $report = undef;

    CheckPrivileges($P_CHEATS);

    AdminError('E_NO_SELECTION') if( !$F{'Report_ID'} );

    $DB->Connect();

    for( split(/,/, $F{'Report_ID'}) )
    {
        my $id = $_;

        $report = $DB->Row("SELECT * FROM ags_Reports WHERE Report_ID=?", [$id]);

        next if( !$report );

        $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$report->{'Gallery_ID'}]);
        $DB->Delete("DELETE FROM ags_Reports WHERE Report_ID=?", [$id]);

        ## Remove thumbnail
        if( -e "$THUMB_DIR/$report->{'Gallery_ID'}.jpg" )
        {
            FileRemove("$THUMB_DIR/$report->{'Gallery_ID'}.jpg");
        }
    }

    $T{'Message'} = 'Selected galleries have been removed';

    DisplayCheats();
}



## Remove and ban a gallery that was reported
sub ReportBan
{
    my $report  = undef;
    my $gallery = undef;

    CheckPrivileges($P_CHEATS);

    AdminError('E_NO_SELECTION') if( !$F{'Report_ID'} );

    $DB->Connect();

    for( split(/,/, $F{'Report_ID'}) )
    {
        my $id = $_;

        $report = $DB->Row("SELECT * FROM ags_Reports WHERE Report_ID=?", [$id]);        

        next if( !$report );

        $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$report->{'Gallery_ID'}]);

        if( !$gallery )
        {
            $DB->Delete("DELETE FROM ags_Reports WHERE Report_ID=?", [$id]);
            next;
        }

        $DB->Delete("DELETE FROM ags_Galleries WHERE Gallery_ID=?", [$report->{'Gallery_ID'}]);
        
        $DEL = "\n";
        DBInsert("$DDIR/blacklist/domain", LevelUpURL($gallery->{'Gallery_URL'}));
        DBInsert("$DDIR/blacklist/email", $gallery->{'Email'});
        DBInsert("$DDIR/blacklist/submitip", $gallery->{'Submit_IP'});
        $DEL = '|';

        if( -e "$THUMB_DIR/$report->{'Gallery_ID'}.jpg" )
        {
            FileRemove("$THUMB_DIR/$report->{'Gallery_ID'}.jpg");
        }
    }

    $T{'Message'} = 'Selected galleries have been removed and banned';

    DisplayCheats();
}



## Add item to the blacklist
sub AddBlacklist
{
    CheckPrivileges($P_BLACKLIST);

    UnixFormat(\$F{'Items'});

    FileTaint("$DDIR/blacklist/$F{'Type'}");
    sysopen(DB, "$DDIR/blacklist/$F{'Type'}", O_RDWR|O_CREAT) || Error("$!", "$DDIR/blacklist/$F{'Type'}");
    flock(DB, LOCK_EX);

    ITEMS:
    for( split(/\n/, $F{'Items'}) )
    {
        my $item = lc($_);

        seek(DB, 0, 0);

        for( <DB> )
        {
            if( $_ eq "$item\n" )
            {
                next ITEMS;
            }
        }

        print DB "$item\n";
    }

    flock(DB, LOCK_UN);
    close(DB);

    $T{'Message'} = 'Specified items have been added to the blacklist';

    DisplayBlacklist();
}



## Remove item from the blacklist
sub DeleteBlacklist
{
    CheckPrivileges($P_BLACKLIST);

    UnixFormat(\$F{'Items'});

    for( split(/\n/, $F{'Items'}) )
    {
        DBDelete("$DDIR/blacklist/$F{'Type'}", $_, "\n");
    }

    $T{'Message'} = 'Specified items have been removed from the blacklist';
    $T{'View'}    = $F{'View'};

    DisplayBlacklist();
}



## Add/update an icon
sub AddIcon
{
    CheckPrivileges($P_TEMPLATES);

    my $ini = IniParse("$DDIR/icons");
    my $id  = $F{'Identifier'};

    UnixFormat(\$F{'HTML'});

    $ini->{$id} = $F{'HTML'};

    %F = %$ini;

    IniWrite("$DDIR/icons", keys %F);

    $T{'Message'} = "Icon '$id' has been added/updated";

    DisplayIcons();
}



## Delete an icon
sub DeleteIcon
{
    CheckPrivileges($P_TEMPLATES);

    my $ini = IniParse("$DDIR/icons");
    my $id  = $F{'Identifier'};

    delete $ini->{$id};

    %F = %$ini;

    IniWrite("$DDIR/icons", keys %F);

    $T{'Message'} = "Icon '$id' has been deleted";

    DisplayIcons();
}



## Update the 2257 link file
sub Update2257
{
    CheckPrivileges($P_2257);

    UnixFormat(\$F{'Links'});

    FileWrite("$DDIR/2257", $F{'Links'});

    $T{'Message'} = "2257 search code has been updated";

    Display2257();
}



## Add/update a reciprocal link
sub AddReciprocal
{
    CheckAccessList();
    CheckPrivileges($P_RECIP);

    my $ini  = undef;
    my %form = %F;

    UnixFormat(\$form{'HTML'});

    for( split(',', $form{'Type'}) )
    {
        my $file = $_;

        %F = %{IniParse("$DDIR/$file")};

        $F{$form{'Identifier'}} = $form{'HTML'};

        IniWrite("$DDIR/$file", keys %F);
    }

    $T{'Message'} = "Reciprocal link '$form{'Identifier'}' has been updated";

    DisplayReciprocals();
}



## Delete a reciprocal link
sub DeleteReciprocal
{
    CheckPrivileges($P_RECIP);

    my $ini = undef;
    my %form = %F;

    for( split(',', $form{'Type'}) )
    {
        my $file = $_;

        %F = %{IniParse("$DDIR/$file")};

        delete $F{$form{'Identifier'}};

        IniWrite("$DDIR/$file", keys %F);
    }

    $T{'Message'} = "Reciprocal link '$form{'Identifier'}' has been deleted";

    DisplayReciprocals();
}



## Add a moderator account
sub AddModerator
{
    CheckAccessList();
    CheckPrivileges($P_MODERATORS);

    my $mask = 0x00000000;

    ## Calculate the privilege mask for the moderator
    map($mask |= hex($F{$_}), grep(/^P_/, keys %F));

    $DB->Connect();

    ## Existing Account ID
    if( $DB->Count("SELECT COUNT(*) FROM ags_Moderators WHERE Username=?", [$F{'Username'}]) )
    {
        AdminError('E_USER');
    }

    ## Insert values into .htpasswd file
    FileAppend("$ADIR/.htpasswd", "$F{'Username'}:" . crypt($F{'Password'}, Salt()) . "\n");


    $DB->Insert("INSERT INTO ags_Moderators VALUES (?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP(), ?, ?)", 
                [$F{'Username'}, 
                 '********', 
                 $F{'Email'}, 
                 0, 
                 0, 
                 0, 
                 '', 
                 $mask]);

    $DB->Disconnect();

    if( $F{'Send_Email'} )
    {
        HashToTemplate(\%F);
        $T{'To'} = $F{'Email'};
        $T{'From'} = $ADMIN_EMAIL;
        $T{'Admin_URL'} = "$CGI_URL/admin/admin.cgi";
        Mail("$TDIR/email_cpanel.tpl");
    }

    $T{'Message'} = "Account '$F{'Username'}' has been added";

    DisplayAddModerator();
}



## Delete a moderator account
sub DeleteModerator
{
    CheckAccessList();
    CheckPrivileges($P_MODERATORS);

    $DB->Connect();
    $DB->Delete("DELETE FROM ags_Moderators WHERE Username=?", [$F{'Username'}]);
    $DB->Disconnect();

    DBDelete("$ADIR/.htpasswd", $F{'Username'}, ':');

    $T{'Message'} = "Account '$F{'Username'}' Has Been Deleted";

    ParseTemplate('admin_popup.tpl');
}



## Update a moderator account
sub UpdateModerator
{
    CheckAccessList();
    CheckPrivileges($P_MODERATORS);

    my $mask = 0x00000000;

    ## Calculate the privilege mask for the moderator
    map($mask |= hex($F{$_}), grep(/^P_/, keys %F));

    $DB->Connect();

    ## Update .htpasswd entry
    if( !IsEmptyString($F{'Password'}) )
    {
        $DEL = ':';
        DBUpdate("$ADIR/.htpasswd", $F{'Username'}, $F{'Username'}, crypt($F{'Password'}, Salt()));
        $DEL = '|';
    }

    $DB->Update("UPDATE ags_Moderators SET " .
                "Password=?, " .
                "Email=?, " .
                "Approved=?, " .
                "Declined=?, " .
                "Banned=?, " .
                "Rights=? " .
                "WHERE Username=?",
                ['********', 
                 $F{'Email'}, 
                 $F{'Approved'}, 
                 $F{'Declined'}, 
                 $F{'Banned'}, 
                 $mask, 
                 $F{'Username'}]);

    $DB->Disconnect();

    $T{'Message'} = "Account '$F{'Username'}' Has Been Updated";

    ParseTemplate('admin_popup.tpl');
}



## Add a submitter account
sub AddAccount
{
    CheckPrivileges($P_ACCOUNTS);

    $DB->Connect();

    ## Existing Account ID
    if( $DB->Count("SELECT COUNT(*) FROM ags_Accounts WHERE Account_ID=?", [$F{'Account_ID'}]) )
    {
        AdminError('E_USER');
    }

    if( !exists $F{'Icons'} )
    {
        $F{'Icons'} = '';
    }

    if( $F{'Start_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ || $F{'End_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ )
    {
        $F{'Start_Date'} = $F{'End_Date'} = undef;
    }

    $DB->Insert("INSERT INTO ags_Accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [$F{'Account_ID'}, 
                 $F{'Password'}, 
                 $F{'Email'}, 
                 $F{'Weight'}, 
                 $F{'Allowed'}, 
                 0, 
                 0, 
                 $F{'Auto_Approve'}, 
                 $F{'Check_Recip'}, 
                 $F{'Check_Black'}, 
                 $F{'Check_HTML'}, 
                 $F{'Confirm'},
                 $F{'Icons'},
                 $F{'Start_Date'},
                 $F{'End_Date'}]);

    $DB->Disconnect();

    if( $F{'Send_Email'} )
    {
        HashToTemplate(\%F);
        $T{'To'} = $F{'Email'};
        $T{'From'} = $ADMIN_EMAIL;
        $T{'Submit_URL'} = "$CGI_URL/submit.cgi";
        Mail("$TDIR/email_account.tpl");
    }

    $T{'Message'} = "Account '$F{'Account_ID'}' has been added";

    DisplayAddAccount();
}



## Delete a partner account
sub DeleteAccount
{
    CheckPrivileges($P_ACCOUNTS);

    $DB->Connect();
    $DB->Delete("DELETE FROM ags_Galleries WHERE Account_ID=?", [$F{'Account_ID'}]);
    $DB->Delete("DELETE FROM ags_Accounts WHERE Account_ID=?", [$F{'Account_ID'}]);
    $DB->Disconnect();

    $T{'Message'} = "Account '$F{'Account_ID'}' Has Been Deleted";

    ParseTemplate('admin_popup.tpl');
}



## Update a partner account
sub UpdateAccount
{
    CheckPrivileges($P_ACCOUNTS);

    if( !exists $F{'Icons'} )
    {
        $F{'Icons'} = '';
    }

    if( $F{'Start_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ || $F{'End_Date'} !~ /^\d\d\d\d-\d\d-\d\d$/ )
    {
        $F{'Start_Date'} = $F{'End_Date'} = undef;
    }

    $DB->Connect();

    $DB->Update("UPDATE ags_Accounts SET " .
                "Password=?, " .
                "Email=?, " .
                "Weight=?, " .
                "Allowed=?, " .
                "Submitted=?, " .
                "Removed=?, " .
                "Auto_Approve=?, " .
                "Check_Recip=?, " .
                "Check_Black=?, " .
                "Check_HTML=?, " .
                "Confirm=?, " .
                "Icons=?, " .
                "Start_Date=?, " .
                "End_Date=? " .
                "WHERE Account_ID=?",
                [$F{'Password'}, 
                 $F{'Email'}, 
                 $F{'Weight'}, 
                 $F{'Allowed'}, 
                 $F{'Submitted'}, 
                 $F{'Removed'}, 
                 $F{'Auto_Approve'}, 
                 $F{'Check_Recip'}, 
                 $F{'Check_Black'}, 
                 $F{'Check_HTML'},
                 $F{'Confirm'},
                 $F{'Icons'},
                 $F{'Start_Date'},
                 $F{'End_Date'},
                 $F{'Account_ID'}]);  

    $DB->Update("UPDATE ags_Galleries SET Icons=? WHERE Account_ID=?", [$F{'Icons'}, $F{'Account_ID'}]);

    $DB->Disconnect();

    $T{'Message'} = "Account '$F{'Account_ID'}' Has Been Updated";

    ParseTemplate('admin_popup.tpl');
}



## Load an e-mail template file for editing
sub LoadEmail
{
    my $contents = IniParse("$TDIR/$F{'Load'}");

    HashToTemplate($contents);

    $T{'Template'} = $F{'Load'};
    $T{'Message'} = $F{'Load'} . ' has been loaded';

    DisplayEmailEditor();
}



## Save an e-mail template
sub SaveEmail
{
    CheckPrivileges($P_TEMPLATES);

    $F{'Attach'} =~ s/,/\n/g;

    IniWrite("$TDIR/$F{'Template'}", qw(Subject Text HTML Attach));
    HashToTemplate(\%F);

    $T{'Message'} = $F{'Template'} . ' has been saved';

    DisplayEmailEditor();
}



## Load a rejection e-mail for editing
sub LoadReject
{
    my $contents = IniParse("$DDIR/reject/$F{'Load'}");

    HashToTemplate($contents);

    $T{'Template'} = $F{'Load'};
    $T{'Message'} = "Rejection e-mail '$F{'Load'}' has been loaded";

    DisplayRejectEditor();
}



## Save a rejection e-mail
sub SaveReject
{
    CheckAccessList();
    CheckPrivileges($P_TEMPLATES);

    $F{'Attach'} =~ s/,/\n/g;

    IniWrite("$DDIR/reject/$F{'Template'}", qw(Subject Text HTML Attach));
    HashToTemplate(\%F);

    $T{'Message'} = "Rejection e-mail '$F{'Template'}' has been saved";

    DisplayRejectEditor();
}



## Delete a rejection e-mail
sub DeleteReject
{
    CheckAccessList();
    CheckPrivileges($P_TEMPLATES);

    FileRemove("$DDIR/reject/$F{'Template'}");

    $T{'Message'} = "Rejection e-mail '$F{'Template'}' has been deleted";

    DisplayRejectEditor();
}



## Load a TGP HTML file for editing
sub LoadPageTemplate
{
    CheckAccessList();
    my $contents = FileReadScalar("$DDIR/html/$F{'Template'}");

    $$contents =~ s/&/&amp;/gi;
    StripHTML($contents);

    $DB->Connect();
    my $page = $DB->Row("SELECT * FROM ags_Pages WHERE Page_ID=?", [$F{'Template'}]);

    $T{'Template'} = $F{'Template'};
    $T{'Filename'} = $page->{'Filename'};
    $T{'Contents'} = $$contents;
    $T{'Message'} = "Template for /$page->{'Filename'} has been loaded";

    DisplayPageTemplates();
}



## Save TGP HTML file
sub SavePageTemplate
{
    CheckAccessList();
    CheckPrivileges($P_TEMPLATES);

    UnixFormat(\$F{'Contents'});
    
    my $compiler = new Compiler();

    $DB->Connect();

    for( split(',', $F{'Template'}) )
    {
        my $page = $DB->Row("SELECT * FROM ags_Pages WHERE Page_ID=?", [$_]);
        my $success = $compiler->Compile(\$F{'Contents'}, $page->{'Category'}, $page->{'Page_ID'});

        if( !$success )
        {
            AdminError($compiler->GetLastError());
        }

        FileWrite("$DDIR/html/$page->{'Page_ID'}", $F{'Contents'});
        FileWrite("$DDIR/html/$page->{'Page_ID'}.comp", $compiler->{'Code'});

        if( !$T{'Template'} )
        {
            $T{'Template'} = $page->{'Page_ID'};
            $T{'Filename'} = $page->{'Filename'};
        }
    }
    
    $F{'Contents'} =~ s/&/&amp;/gi;
    StripHTML(\$F{'Contents'});

    $T{'Contents'} = $F{'Contents'};
    $T{'Message'} = 'The selected TGP page templates have been saved';

    DisplayPageTemplates();
}



## Load a template file for editing
sub LoadScriptTemplate
{
    CheckAccessList();
    my $contents = FileReadScalar("$TDIR/$F{'Load'}");

    StripHTML($contents);

    $T{'Template'} = $F{'Load'};
    $T{'Contents'} = $$contents;
    $T{'Message'}  = $F{'Load'} . ' has been loaded';

    DisplayScriptTemplates();
}



## Save a template file
sub SaveScriptTemplate
{
    CheckAccessList();
    CheckPrivileges($P_TEMPLATES);

    FileWrite("$TDIR/$F{'Template'}", $F{'Contents'});

    HashToTemplate(\%F);

    $T{'Message'} = $F{'Template'} . ' has been saved';

    DisplayScriptTemplates();
}



## Save changes to the language file
sub SaveLanguage
{
    CheckPrivileges($P_TEMPLATES);

    my $ini = undef;

    delete($F{'Run'});

    IniWrite("$DDIR/language", keys %F);

    $T{'Message'} = 'Language settings have been saved';

    DisplayLangEditor();
}



## Add new categories to the database
sub AddCategories
{
    CheckPrivileges($P_CATEGORIES);

    $DB->Connect();

    UnixFormat(\$F{'Names'});

    for( split(/\n/, $F{'Names'}) )
    {
        my $name = $_;

        if( $name =~ /^mixed$/i )
        {
            AdminError("Cannot create category with name $name. That is a reserved word for the TGP page templates");
        }

        if( $DB->Count("SELECT COUNT(*) FROM ags_Categories WHERE Name=?", [$name]) == 0 )
        {
            $DB->Insert("INSERT INTO ags_Categories VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        [$name,
                         $F{'Ext_Pictures'},
                         $F{'Ext_Movies'},
                         $F{'Min_Pictures'},
                         $F{'Min_Movies'},
                         $F{'Max_Pictures'},
                         $F{'Max_Movies'},
                         $F{'Size_Pictures'},
                         $F{'Size_Movies'},
                         $F{'Per_Day'},
                         $F{'Ann_Pictures'},
                         $F{'Ann_Movies'},
                         int($F{'Hidden'})]);
        }
    }

    $T{'Message'} = 'New categories have been successfully added';

    DisplayManageCategories();
}



## Update categories in the database
sub UpdateCategories
{
    CheckPrivileges($P_CATEGORIES);

    $DB->Connect();  

    if( !IsEmptyString($F{'Categories'}) )
    {
        my $categories = my $categories = ParseMulti('Categories');
        my $list = MakeBindList(scalar @$categories);

        $DB->Update("UPDATE ags_Categories SET " .
                    "Ext_Pictures=?, " .
                    "Ext_Movies=?, " .
                    "Min_Pictures=?, " .
                    "Min_Movies=?, " .
                    "Max_Pictures=?, " .
                    "Max_Movies=?, " .
                    "Size_Pictures=?, " .
                    "Size_Movies=?, " .
                    "Per_Day=?, " .
                    "Ann_Pictures=?, " .
                    "Ann_Movies=?, " .
                    "Hidden=? " .
                    "WHERE Name IN ($list)",
                    [$F{'Ext_Pictures'},
                     $F{'Ext_Movies'},
                     $F{'Min_Pictures'},
                     $F{'Min_Movies'},
                     $F{'Max_Pictures'},
                     $F{'Max_Movies'},
                     $F{'Size_Pictures'},
                     $F{'Size_Movies'},
                     $F{'Per_Day'},
                     $F{'Ann_Pictures'},
                     $F{'Ann_Movies'},
                     int($F{'Hidden'}),
                     @$categories]);
    }

    $T{'Message'} = 'Categories successfully updated';

    DisplayManageCategories();
}


## Rename a category
sub RenameCategory
{
    CheckPrivileges($P_CATEGORIES);

    if( $F{'NewName'} =~ /^mixed$/i )
    {
        AdminError("Cannot create category with name $F{'NewName'}. That is a reserved word for the TGP page templates.");
    }

    $DB->Connect();

    $DB->Update("UPDATE ags_Categories SET Name=? WHERE Name=?", [$F{'NewName'}, $F{'Rename'}]);
    $DB->Update("UPDATE ags_Galleries SET Category=? WHERE Category=?", [$F{'NewName'}, $F{'Rename'}]);

    ## Update pages
    my $page = undef;
    my $compiler = new Compiler();
    my $result = $DB->Query("SELECT * FROM ags_Pages WHERE Category=?", [$F{'Rename'}]);
    while( $page = $DB->NextRow($result) )
    {
        ## Recompile
        my $success = $compiler->Compile("$DDIR/html/$page->{'Page_ID'}", $F{'NewName'}, $page->{'Page_ID'});

        if( $success )
        {
            FileWrite("$DDIR/html/$page->{'Page_ID'}.comp", $compiler->{'Code'});
        }

        ## Update database
        $DB->Update("UPDATE ags_Pages SET Category=? WHERE Page_ID=?", [$F{'NewName'}, $page->{'Page_ID'}]);
    }
    $DB->Free($result);

    $T{'Message'} = 'Category successfully renamed';

    DisplayManageCategories();
}



## Delete categories from the database
sub DeleteCategories
{
    CheckPrivileges($P_CATEGORIES);

    $DB->Connect();

    if( !IsEmptyString($F{'Categories'}) )
    {
        my $categories = ParseMulti('Categories');
        my $list = MakeBindList(scalar @$categories);

        $DB->Delete("DELETE FROM ags_Categories WHERE Name IN ($list)", $categories);
        $DB->Delete("DELETE FROM ags_Galleries WHERE Category IN ($list)", $categories);

        CleanupThumbs();
    }

    $T{'Message'} = 'Selected categories have been deleted';

    DisplayManageCategories();
}



sub UpdateReferrersAndAgents
{
    UnixFormat(\$F{'Agents'});
    UnixFormat(\$F{'Referrers'});

    FileWrite("$DDIR/agents", $F{'Agents'});
    FileWrite("$DDIR/referrers", $F{'Referrers'});

    DisplayReferrersAndAgents();
}



## Save variables and options
sub SaveOptions
{
    CheckAccessList();
    CheckPrivileges($P_OPTIONS);

    my $cwd = GetCwd();

    delete($F{'Run'});

    AddSlashes(\%F);
    CheckModules();    

    ## Create required directories
    DirCreate("$DDIR/annotations");
    DirCreate("$DDIR/attachments");
    DirCreate("$DDIR/blacklist");
    DirCreate("$DDIR/fonts");
    DirCreate("$DDIR/html");
    DirCreate("$DDIR/reject");
    DirCreate("$DDIR/scanner");
    DirCreate("$DDIR/random");

    ## Create required files
    FileWriteNew("$DDIR/generalrecips", "=>[Default]\nhttp://$ENV{'HTTP_HOST'}\n");
    FileWriteNew("$DDIR/trustedrecips", "=>[Default]\nhttp://$ENV{'HTTP_HOST'}\n");
    FileWriteNew("$DDIR/backup", time);
    FileWriteNew("$DDIR/icons");
    FileWriteNew("$DDIR/emails");
    FileWriteNew("$DDIR/2257", "18 U.S.C. 2257\n18 USC 2257\nUSC2257\n2257.html\n2257.php\n2257.htm\n");
    FileWriteNew("$DDIR/clicklog");
    FileWriteNew("$DDIR/error_log");
    FileWriteNew("$DDIR/last_error", (stat("$DDIR/error_log"))[9]);
    FileWriteNew("$DDIR/blacklist/dns");
    FileWriteNew("$DDIR/blacklist/domain");
    FileWriteNew("$DDIR/blacklist/domainip");
    FileWriteNew("$DDIR/blacklist/email");
    FileWriteNew("$DDIR/blacklist/html");
    FileWriteNew("$DDIR/blacklist/submitip");
    FileWriteNew("$DDIR/blacklist/word");
    FileWriteNew("$DDIR/blacklist/headers");
    FileWriteNew("$DDIR/blacklist/whitelist");

    
    $F{'SENDMAIL'} = SafePathname($F{'SENDMAIL'});

    ## Determine and test the thumbnail directory
    $F{'THUMB_DIR'} = GetDirectoryFromURL($F{'DOCUMENT_ROOT'}, $F{'THUMB_URL'});
    AdminError('E_BAD_DIR', $F{'THUMB_URL'}) if( !-w $F{'THUMB_DIR'} );
    AdminError('The Thumbnail URL setting cannot point to the base directory of your website') if( $F{'THUMB_DIR'} eq $F{'DOCUMENT_ROOT'} );
    DirCreate("$F{'THUMB_DIR'}/cache");

    ## Get the script URL
    $F{'CGI_URL'} = GetScriptURL();

    ## Remove trailing slash from document root
    $F{'DOCUMENT_ROOT'} =~ s/\/$//;

    ## Update the variables file
    FileWrite("$DDIR/variables", undef);

    for( sort keys %F )
    {
        FileAppend("$DDIR/variables", "\$$_ = '$F{$_}';\n");

        ${$_} = $F{$_};
    }

    FileAppend("$DDIR/variables", "\$ANNOTATION_DIR = '$cwd/data/annotations';\n" .
                                  "\$FONT_DIR = '$cwd/data/fonts';\n" .
                                  "\$PAGE_LIST = '$list';\n" .
                                  "\$CONVERT = '$CONVERT';\n" .
                                  "\$IDENTIFY = '$IDENTIFY';\n" .
                                  "\$COMPOSITE = '$COMPOSITE';\n" .
                                  "\$HAVE_GD = '$HAVE_GD';\n" .
                                  "\$HAVE_MAGICK = '$HAVE_MAGICK';\n" .
                                  "\$IM_CLI_ONLY = '$IM_CLI_ONLY';\n" .
                                  ($MAGICK6 ? "\$MAGICK6 = 1;\n" : '') .
                                  ($MAGICK5 ? "\$MAGICK5 = 1;\n" : '') .
                                  "\$HOSTNAME = '$HOSTNAME';\n" .
                                  "\$USERNAME = '$USERNAME';\n" .
                                  "\$PASSWORD = '$PASSWORD';\n" .
                                  "\$DATABASE = '$DATABASE';\n" .
                                  "1;\n");

    $T{'Message'} = 'Options have been saved';

    DisplayOptions();
}



## Read files in the attachments directory
sub ReadAttachments
{
    for( @{DirRead("$DDIR/attachments", '^[^.]')} )
    {
        $T{'Attach_Options'} .= "<option value='$DDIR/attachments/$_'" .
                                ($T{'Attach'} =~ /$_$/m ? ' selected' : '') .  ## see if file is in Attach list of ini file
                                ">$_ (" .
                                (-s "$DDIR/attachments/$_") .                  ## get the file size
                                " bytes)</option>\n";
    }
}



## Read the contents of the variables and constants files
sub ReadVariables
{
    $T{'NSLOOKUP'} = LocateBinary('nslookup');
    $T{'MYSQL'} = LocateBinary('mysql');
    $T{'MYSQLDUMP'} = LocateBinary('mysqldump');
    $T{'SENDMAIL'} = LocateBinary('sendmail');
    $T{'DOCUMENT_ROOT'} = $ENV{'DOCUMENT_ROOT'};

    for( @{FileReadArray("$DDIR/variables")} )
    {
        if( $_ =~ /\$([^\s]+)\s+=\s+'([^']+)';/gi )
        {
            $T{$1} = $2;
        }
    }

    ## fill in the javascript array with the names of checked options
    $T{'Checked'} = "'" . join("', '", grep(/^O_/, keys %T)) . "'";

    ## see if ImageMagick and GD are available
    CheckModules();
}



sub CheckModules
{
    my $im_version = 0;

    $HAVE_GD = 0;
    $HAVE_MAGICK = 0;
    $IM_CLI_ONLY = 1;
    $CONVERT = LocateBinary('convert');
    $IDENTIFY = LocateBinary('identify');
    $COMPOSITE = LocateBinary('composite');
    $F{'NSLOOKUP'} = LocateBinary('nslookup') || LocateBinary('host');
  

    ## Check ImageMagick
    if( $CONVERT && $IDENTIFY )
    {
        $HAVE_MAGICK = 1;
        $im_version = GetMagickCliVersion($CONVERT);
    }

    eval("use Image::Magick;");

    if( !$@ )
    {
        $im_version = $Image::Magick::VERSION;
        $IM_CLI_ONLY = 0;
        $HAVE_MAGICK = 1;
    }


    if( $HAVE_MAGICK )
    {
        my $im_major_version = (split(/\./, $im_version))[0];

        if( $im_major_version > 5 )
        {
            $MAGICK6 = 1;
            $MAGICK5 = undef;
        }
        else
        {
            $MAGICK5 = 1;
            $MAGICK6 = undef;
        }
    }


    ## See if GD is available
    eval("use GD;");
    $HAVE_GD = 1 if( !$@ );
}



sub GetAjaxUrls
{
    my $host = $ENV{'HTTP_HOST'};

    if( $host !~ /^www\./ )
    {
        $CGI_URL =~ s|http://www\.|http://|i;
        $THUMB_URL =~ s|http://www\.|http://|i;
    }
}



sub SafePathname
{
    my $binary_path = shift;

    $binary_path =~ s/[^a-z0-9.-\/]//gi;

    return $binary_path;
}



## Get the version of the ImageMagick command line tools
sub GetMagickCliVersion
{
    my $convert = shift;
    my $version = `$convert -version`;

    if( $version =~ m/ImageMagick ([^ ]+)/i )
    {
        return $1;
    }
    else
    {
        return 0;
    }
}



## Get directory path from a URL and document root
sub GetDirectoryFromURL
{
    my $document_root = shift;
    my $full_url = shift;
    my $directory_path = undef;

    $document_root =~ s|/$||;

    if( $full_url =~ m|http://[^/]+/(.+)| )
    {
        $directory_path = "$document_root/$1";
    }
    else
    {
        $directory_path = $document_root;
    }

    return $directory_path;
}



## Print the blacklist
sub PrintBlacklist
{
    print '<style>.link{text-decoration: none;color: DarkBlue;}</style>';
    print '<span style="font-family: Verdana; font-size: 11px;">';

    for( sort @{FileReadArray("$DDIR/blacklist/$F{'Type'}")} )
    {
        chomp(my $item = $_);
        my $stripped = $item;

        StripHTML(\$stripped);

        print "$stripped &nbsp;&nbsp;<a href='main.cgi?Run=DeleteBlacklist&View=$F{'Type'}&Type=$F{'Type'}&Items=" .
              URLEncode($item) . "' target='_parent' class='link'>[Delete]</a><br />\n";
    }

    print '</span>';
}



## Recompile the TGP page templates
sub RecompileTemplates
{
    CheckAccessList();
    my $compiler = new Compiler();

    $DB->Connect();

    my $result = $DB->Query("SELECT * FROM ags_Pages");

    while( $page = $DB->NextRow($result) )
    {
        my $success = $compiler->Compile("$DDIR/html/$page->{'Page_ID'}", $page->{'Category'}, $page->{'Page_ID'});

        if( $success )
        {
            FileWrite("$DDIR/html/$page->{'Page_ID'}.comp", $compiler->{'Code'});
        }
    }

    $DB->Free();

    $T{'Message'} = 'TGP Page Templates Have Been Recompiled';

    ParseTemplate('admin_popup.tpl');
}



## Show gallery breakdown
sub Breakdown
{
    my $row = undef;
    my $aggregate = 'Category';
    my %cats = ();

    $DB->Connect();

    if( $F{'Method'} eq 'Date' )
    {
        if( $F{'Status'} eq 'Used' || $F{'Status'} eq 'Holding' )
        {
            $aggregate = 'Display_Date';
        }
        else
        {
            $aggregate = 'Added_Date';
        }
    }
    else
    {
        GetCategoryList();
    }


    my $result = $DB->Query("SELECT $aggregate,COUNT(*) AS Total FROM ags_Galleries WHERE Status=? AND Type=? GROUP BY $aggregate", [$F{'Status'}, $F{'Type'}]);

    while( $row = $DB->NextRow($result) )
    {
        ## Record categories so empty categories can be shown
        $cats{$row->{'Category'}} = 1 if( $aggregate eq 'Category' );

        $row->{'Display'} = $row->{$aggregate};
        TemplateAdd('Breakdown', $row);
    }

    $DB->Free($result);

    if( $aggregate eq 'Category' )
    {
        for( @CATEGORIES )
        {
            if( !exists $cats{$_} )
            {
                my $H = {};

                $H->{'Display'} = $_;
                $H->{'Total'} = 0;

                TemplateAdd('Breakdown', $H);
            }
        }

        @{$T{'Breakdown'}} = sort { $a->{'Display'} cmp $b->{'Display'} } @{$T{'Breakdown'}};
    }

    $T{'Aggregate'} = $aggregate;
    $T{'Aggregate'} =~ s/_/ /g;

    HashToTemplate(\%F);

    ParseTemplate('admin_breakdownmore.tpl');
}



## Get the selected categories for the Display Galleries page
sub GetSelectedCategories
{
    my $selected_hash = {};
    my $selected = [];

    GetCategoryList();

    if( !$T{'Category'} )
    {
        map($selected_hash->{$_} = 1, @CATEGORIES);
    }
    else
    {
        map($selected_hash->{$_} = 1, @{ParseMulti('Category')});
    }

    for( @CATEGORIES )
    {
        my $H = {};

        $H->{'Name'} = $_;

        TemplateAdd('Categories', $H);

        $T{'Category_Options'} .= "<option value=\"$H->{'Name'}\"" . (exists $selected_hash->{$_} ? ' selected' : '') . ">$H->{'Name'}</option>\n";
    }

    $selected = [keys %$selected_hash];

    AddSlashes($selected);

    return $selected;
}



## Generate a search string
sub GetSearchString
{
    if( $T{'Search_Value'} eq '[EMPTY]' )
    {
        return "AND ($T{'Search_Field'}='' OR $T{'Search_Field'} IS NULL)";
    }
    elsif( $T{'Match'} eq 'Matches' )
    {
        return "AND $T{'Search_Field'}='$T{'Search_Value'}'";
    }
    else
    {
        return "AND $T{'Search_Field'} LIKE '%$T{'Search_Value'}%'";
    }
}



## Get the ORDER BY string for the DisplayGalleries page
sub GetOrderString
{
    my $order1 = $T{'Order_Field'};
    my $order2 = $T{'Order_Field2'};

    ## Setup for RAND() sorting
    my $rand1 = int(rand(999999999));
    my $rand2 = int(rand(999999999));
    $order1 =~ s/RAND\(\)/RAND($rand1)/gi;
    $order2 =~ s/RAND\(\)/RAND($rand2)/gi;

    if( $T{'Order_Field2'} )
    {
        return "ORDER BY $order1 $T{'Direction'}, $order2 $T{'Direction2'}";
    }
    else
    {
        return "ORDER BY $order1 $T{'Direction'}";
    }
}



## Figure the start, end, page, and limit values for the DisplayGalleries page
sub CalculatePositions
{
    if( $T{'Page'} < 0 )
    {
        $T{'Page'} = 0;
    }

    $T{'Limit'} = $T{'Page'} * $T{'Per_Page'};

    while( $T{'Limit'} >= $T{'Total'} && $T{'Page'} > 0 )
    {
        $T{'Page'}--;
        $T{'Limit'} = $T{'Page'} * $T{'Per_Page'};
    }

    $T{'Start'} = $T{'Page'} * $T{'Per_Page'} + 1;
    $T{'End'}   = ($T{'Page'} + 1) * $T{'Per_Page'};

    if( $T{'Total'} < $T{'End'} )
    {
        $T{'End'} = $T{'Total'};
    }

    if( $T{'Start'} < 1 )
    {
        $T{'Start'} = 1;
    }
}



## Clean out the thumbnail directory
sub CleanupThumbs
{
    my $row = undef;
    my $thumbs = {};
    my $max_age = time - 10800;

    $DB->Connect();

    ## Remove galleries with Submitting status
    $DB->Update("DELETE FROM ags_Galleries WHERE Status='Submitting' AND Added_Stamp <= ?", [$max_age]);

    ## Clear out the undos table
    $DB->Update("DELETE FROM ags_Undos");
    
    if( $THUMB_DIR && -e $THUMB_DIR )
    {
        my $result = $DB->Query("SELECT Gallery_ID FROM ags_Galleries WHERE Has_Thumb=1");

        while( $row = $DB->NextRow($result) )
        {
            $thumbs->{"$row->{'Gallery_ID'}.jpg"} = 1;
        }

        $DB->Free($result);


        for( @{DirRead($THUMB_DIR, '^[^.]')} )
        {
            my $file = $_;

            if( !exists $thumbs->{$file} )
            {
                unlink("$THUMB_DIR/$file");
            }
        }


        ## Clear cache directory
        if( -e "$THUMB_DIR/cache" )
        {
            for( @{DirRead("$THUMB_DIR/cache", '^[^.]')} )
            {
                my $file = $_;
                my @stat = stat("$THUMB_DIR/cache/$file");

                if( $stat[9] <= $max_age )
                {
                    unlink("$THUMB_DIR/cache/$file");
                }
            }
        }
    }
}


