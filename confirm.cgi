#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
########################################################
##  confirm.cgi - Handle confirmation of submissions  ##
########################################################

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
    Error("$@", 'confirm.cgi');
}


sub main
{
    ParseRequest(1);

    if( $ENV{'REQUEST_METHOD'} eq 'GET' )
    {
        if( $O_CONFIRM_CLICK && $F{'ID'} )
        {
            $F{'Confirm_ID'} = $F{'ID'};
            ConfirmSubmission();
        }
        else
        {
            DisplayConfirm();
        }
    }
    else
    {
        ConfirmSubmission();
    }
}



sub DisplayConfirm()
{
    ParseTemplate('confirm_main.tpl');
}



sub ConfirmSubmission
{
    my $moderator = undef;
    my $approve_date = undef;
    my $approve_stamp = undef;
    my $status = 'Pending';
    
    if( $F{'Confirm_ID'} !~ /^[0-9]+$/ )
    {
        ConfirmError('E_INVALID_CONFIRMID');
    }

    $DB->Connect();
    
    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Confirm_ID=? AND Status='Unconfirmed'", [$F{'Confirm_ID'}]);


    ## No such confirmation ID or already confirmed
    if( !$gallery )
    {
        ConfirmError('E_BAD_CONFIRMID');
    }


    ## If this was from a partner account, look it up
    ## to see if it is set on auto-approve
    if( $gallery->{'Account_ID'} )
    {
        $O_AUTO_APPROVE = $DB->Count("SELECT Auto_Approve FROM ags_Accounts WHERE Account_ID=?", [$gallery->{'Account_ID'}]);
    }


    if( $O_AUTO_APPROVE )
    {       
        $approve_date = $MYSQL_DATE;
        $approve_stamp = time;
        $moderator = 'Auto-Approved';
        $status = 'Approved';
    }


    ## Update the gallery record
    $DB->Update("UPDATE ags_Galleries SET " .
                "Status=?, " .
                "Confirm_ID=?, " .
                "Approve_Date=?, " .
                "Approve_Stamp=?, " .
                "Moderator=? " .
                "WHERE Gallery_ID=?",
                [$status,
                 undef,
                 $approve_date,
                 $approve_stamp,
                 $moderator,
                 $gallery->{'Gallery_ID'}]);

    $DB->Disconnect();

    HashToTemplate($gallery);

    $T{'Status'} = $status;

    ParseTemplate('confirm_complete.tpl');
}



## Display the submission error page
sub ConfirmError
{
    my $error = shift;
    my $more  = shift;
    my $lang  = IniParse("$DDIR/language");

    if( $lang->{$more} )
    {
        $T{'Error'} = "$lang->{$error}: $lang->{$more}";
    }
    else
    {
        $T{'Error'} = $lang->{$error} . ($more ? ": $more" : '');
    }

    ParseTemplate('submit_error.tpl');

    exit;
}
