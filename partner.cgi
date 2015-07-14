#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
###################################################################
##  partner.cgi - Handle partner account requests and maitenance ##
###################################################################


%functions = ( 'request' => \&SubmitRequest,
               'login' => \&DisplayLogin,
               'overview' => \&DisplayOverview,
               'edit' => \&DisplayEdit,
               'update' => \&UpdateAccount,
               'disable' => \&DisableGallery );


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
    Error("$@", 'partner.cgi');
}


sub main
{
    ParseRequest(1);

    if( defined $functions{$F{'r'}} )
    {
        &{$functions{$F{'r'}}}();
    }
    else
    {
        DisplayRequest();
    }
}



sub DisplayOverview
{
    my $partner = VerifyLogin($F{'Account_ID'}, $F{'Password'});
    my $lang = IniParse("$DDIR/language");
    my $per_page = 10;
    my $sort = {'Clicks' => 'Clicks DESC', 'Added' => 'Added_Stamp DESC', 'Approved' => 'Approve_Stamp DESC', 'Status' => 'Status'};

    HashToTemplate($partner);

    $F{'Sort'} = 'Added' if( !$F{'Sort'} );
    my $sortstring = $sort->{$F{'Sort'}} || $sort->{'Added'};

    ## Defaults
    $T{'Num_Galleries'} = 0;
    $T{'Clicks'} = 0;
    $T{'Unconfirmed'} = 0;
    $T{'Pending'} = 0;
    $T{'Approved'} = 0;
    $T{'Used'} = 0;
    $T{'Holding'} = 0;
    $T{'Disabled'} = 0;

    my $result = $DB->Query("SELECT * FROM ags_Galleries WHERE Account_ID=? AND Status!='Submitting' ORDER BY $sortstring", [$F{'Account_ID'}]);
    my $total = $DB->NumRows($result);
    my $pagination = HandlePagination($total, $F{'Page'}, $per_page);
    my $gallery = undef;
    my $counter = 0;

    while( $gallery = $DB->NextRow($result) )
    {
        $counter++;

        $T{$gallery->{'Status'}}++;
        $T{'Clicks'} += $gallery->{'Clicks'};
        
        next if( $counter < $pagination->{'start'} || $counter > $pagination->{'end'} );

        my $H = {};

        map($H->{$_} = $gallery->{$_}, keys %$gallery);        

        $H->{'Submitted'} = Date("$DATE_FORMAT $TIME_FORMAT", $gallery->{'Added_Stamp'} + 3600 * $TIME_ZONE);
        $H->{'Enabled'} = $gallery->{'Status'} eq 'Disabled' ? 0 : 1;
        
        TemplateAdd('Galleries', $H);
    }
    $DB->Free($result);

    $T{'Admin_Email'} = $ADMIN_EMAIL;
    $T{'Start_Date'} = $T{'Start_Date'} ? Date($DATE_FORMAT, $DB->Count("SELECT UNIX_TIMESTAMP('$T{'Start_Date'} 12:00:00')")) : $lang->{'ALWAYS'};
    $T{'End_Date'} = $T{'End_Date'} ? Date($DATE_FORMAT, $DB->Count("SELECT UNIX_TIMESTAMP('$T{'End_Date'} 12:00:00')")) : $lang->{'NEVER'};
    $T{'Allowed'} = $T{'Allowed'} eq -1 ? $lang->{'UNLIMITED'} : $T{'Allowed'};
    $T{'Next'} = $pagination->{'next'};
    $T{'Previous'} = $pagination->{'previous'};
    $T{'Start'} = $pagination->{'start'};
    $T{'End'} = $pagination->{'end'};
    $T{'Total'} = $total;
    $T{'Sort'} = $F{'Sort'};

    ParseTemplate('partner_overview.tpl');
}



sub DisplayRequest
{
    ParseTemplate('partner_request.tpl');
}



sub DisplayLogin
{
    ParseTemplate('partner_login.tpl');
}



sub DisplayEdit
{
    my $partner = VerifyLogin($F{'Account_ID'}, $F{'Password'});

    HashToTemplate($partner);

    ParseTemplate('partner_edit.tpl');
}




sub DisableGallery
{
    my $partner = VerifyLogin($F{'Account_ID'}, $F{'Password'});

    if( IsEmptyString($F{'Reason'}) )
    {
        my $lang = IniParse("$DDIR/language");
        $T{'Error'} = "$lang->{'E_REQUIRED'}: $lang->{'REASON'}";
    }
    else
    {
        my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=? AND Account_ID=?", [$F{'Gallery_ID'}, $partner->{'Account_ID'}]);
        $DB->Update("UPDATE ags_Galleries SET Status='Disabled',Comments=? WHERE Gallery_ID=? AND Account_ID=?", ["[Partner Request] $F{'Reason'}", $F{'Gallery_ID'}, $partner->{'Account_ID'}]);

        $T{'Gallery_URL'} = $gallery->{'Gallery_URL'};
    }

    DisplayOverview();
}



sub UpdateAccount
{
    my $partner = VerifyLogin($F{'Account_ID'}, $F{'Password'});

    if( $F{'New_Password'} )
    {
        $partner->{'Password'} = $F{'New_Password'};
    }

    $DB->Update("UPDATE ags_Accounts SET Email=?,Password=? WHERE Account_ID=?", [$F{'Email'}, $partner->{'Password'}, $F{'Account_ID'}]);

    $partner = $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=?", [$F{'Account_ID'}]);

    HashToTemplate($partner);

    $T{'Message'} = 1;

    ParseTemplate('partner_edit.tpl');
}



sub SubmitRequest
{
    ## Check form input
    SubmitError('E_BAD_EMAIL') if( $F{'Email'} !~ /^[\w\d][\w\d\,\.\-]*\@([\w\d\-]+\.)+([a-zA-Z]+)$/ );
    SubmitError('E_BAD_URL') if( $F{'Gallery_1'} !~ /^http:\/\/[\w\d\-\.]+\.[\w\d\-\.]+/ );
    SubmitError('E_BAD_URL') if( $F{'Gallery_2'} !~ /^http:\/\/[\w\d\-\.]+\.[\w\d\-\.]+/ );
    SubmitError('E_BAD_URL') if( $F{'Gallery_3'} !~ /^http:\/\/[\w\d\-\.]+\.[\w\d\-\.]+/ );
    SubmitError('E_REQUIRED', 'NAME') if( IsEmptyString($F{'Name'}) );
    SubmitError('E_REQUIRED', 'PASSWORD') if( IsEmptyString($F{'Password'}) );
    SubmitError('E_REQUIRED', 'USERNAME') if( IsEmptyString($F{'Account_ID'}) );
    SubmitError('E_REQUIRED', 'HOST') if( $O_REQ_HOST && IsEmptyString($F{'Host'}) );
    SubmitError('E_REQUIRED', 'PROVIDER') if( $O_REQ_PROVIDER && IsEmptyString($F{'Provider'}) );


    ## Check if data is blacklisted
    my $blacklisted = IsBlacklisted({'Gallery_URL' => $F{'Gallery_1'}, 'Email' => $F{'Email'}, 'Submit_IP' => $ENV{'REMOTE_ADDR'}});
    if( $blacklisted )
    {
        SubmitError('E_BLACKLISTED', $blacklisted->{'Item'});
    }


    $DB->Connect();


    ## Check to see if this username is already taken
    if( $DB->Count("SELECT COUNT(*) FROM ags_Accounts WHERE Account_ID=?", [$F{'Account_ID'}]) > 0 ||
        $DB->Count("SELECT COUNT(*) FROM ags_Requests WHERE Account_ID=?", [$F{'Account_ID'}]) > 0 )
    {
        SubmitError('E_EXISTING_ACCOUNT');
    }


    ## Check to see if there is already a partner request from this e-mail
    if( $DB->Count("SELECT COUNT(*) FROM ags_Requests WHERE Email=?", [$F{'Email'}]) > 0 )
    {
        SubmitError('E_EXISTING_REQUEST');
    }


    $DB->Insert("INSERT INTO ags_Requests VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                ['NULL',
                 $F{'Name'},
                 $F{'Email'},
                 $F{'Account_ID'},
                 $F{'Password'},
                 $F{'Gallery_1'},
                 $F{'Gallery_2'},
                 $F{'Gallery_3'},
                 $F{'Host'},
                 $F{'Provider'},
                 $ENV{'REMOTE_ADDR'},
                 $TIME]);


    HashToTemplate(\%F);

    ParseTemplate('partner_submitted.tpl');
}



sub VerifyLogin
{
    my $username = shift;
    my $password = shift;

    SubmitError('E_REQUIRED', 'USERNAME') if( IsEmptyString($username) );
    SubmitError('E_REQUIRED', 'PASSWORD') if( IsEmptyString($password) );
    
    $DB->Connect();

    my $partner = $DB->Row("SELECT * FROM ags_Accounts WHERE Account_ID=? AND Password=?", [$username, $password]);

    if( !$partner )
    {
        SubmitError('E_BAD_PASSWORD');
    }

    return $partner;
}



sub HandlePagination
{
    my $total = int(shift);
    my $page = int(shift);
    my $per_page = int(shift);
    my $num_pages = int($total/$per_page) + 1;
    my $result = {};

    $page = 1 if( $page < 1 );
    $page = $num_pages if( $page > $num_pages );

    $result->{'start'} = ($page - 1) * $per_page + 1;
    $result->{'end'} = $page * $per_page;
    $result->{'end'} = $total if( $result->{'end'} > $total );
    $result->{'previous'} = $page - 1 if( $page > 1 );
    $result->{'next'} = $page + 1 if( $page < $num_pages );

    return $result;
}
