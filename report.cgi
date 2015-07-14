#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#############################################################
##  report.cgi - Handle broken link and cheater reporting  ##
#############################################################


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
    Error("$@", 'report.cgi');
}



sub main
{
    ParseRequest(1);

    if( $ENV{'REQUEST_METHOD'} eq 'GET' )
    {
        DisplayReport();
    }
    else
    {
        ProcessReport();
    }
}



sub DisplayReport
{
    $DB->Connect();
    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'ID'}]);
    $DB->Disconnect();

    if( !$gallery )
    {
        SubmitError('E_BAD_ID');
    }

    HashToTemplate($gallery);

    ParseTemplate('report_main.tpl');
}



sub ProcessReport
{
    SubmitError('E_REQUIRED', 'REPORT') if( !$F{'Report'} );

    $DB->Connect();

    my $gallery = $DB->Row("SELECT * FROM ags_Galleries WHERE Gallery_ID=?", [$F{'Gallery_ID'}]);

    $DB->Insert("INSERT INTO ags_Reports VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                [undef,
                 $gallery->{'Gallery_ID'},
                 $gallery->{'Gallery_URL'},
                 $gallery->{'Description'},
                 $gallery->{'Email'},
                 $gallery->{'Submit_IP'},
                 $ENV{'REMOTE_ADDR'},
                 $F{'Report'}]);

    my $main_page = $DB->Row("SELECT * FROM ags_Pages ORDER BY Build_Order LIMIT 1");

    $T{'Report_ID'} = $DB->InsertID();
    $T{'Report'} = $F{'Report'};
    $T{'TGP_URL'} = "/$main_page->{'Filename'}";

    ParseTemplate('report_sent.tpl');

    $DB->Disconnect();
}

