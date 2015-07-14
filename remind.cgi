#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#######################################################################
##  remind.cgi - Remind partner of their username and password       ##
#######################################################################

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
    Error("$@", 'remind.cgi');
}



sub main
{
    ParseRequest(1);

    if( $ENV{'REQUEST_METHOD'} eq 'GET' )
    {
        ParseTemplate('remind_main.tpl');
    }
    else
    {
        my $query = "SELECT * FROM ags_Accounts WHERE Account_ID=?";

        SubmitError('E_REQUIRED', 'EMAIL_USER') if( !$F{'Input'} );

        $DB->Connect();

        if( $F{'Input'} =~ /@/ )
        {
            $query = "SELECT * FROM ags_Accounts WHERE Email=?";
        }

        my $account = $DB->Row($query, [$F{'Input'}]);

        SubmitError('E_NO_ACCOUNT') if( !$account );

        $T{'To'} = $account->{'Email'};
        $T{'From'} = $ADMIN_EMAIL;
        $T{'Submit_URL'} = "$CGI_URL/submit.cgi";

        HashToTemplate($account);

        Mail("$TDIR/email_remind.tpl");

        ParseTemplate('remind_sent.tpl');
    }
}
