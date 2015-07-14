#!/usr/bin/perl
##############################
##  AutoGallery SQL v3.6.x  ##
#################################################################
##  cron.cgi - Page updates and database backups through cron  ##
#################################################################

my $cdir = '/home/soft/html/legacy/ags';

chdir($cdir) || die "Could not change into $cdir";

require 'common.pl';
require 'ags.pl';
require 'mysql.pl';


if( $ARGV[0] eq '--build' )
{
    BuildAllReorder();
}
elsif( $ARGV[0] eq '--build-with-new' )
{
    BuildAllNew();
}
elsif( $ARGV[0] eq '--backup' )
{
    DoBackup('backup.dat', $ARGV[1], $ARGV[2]);
}
elsif( $ARGV[0] eq '--reset-permanent' )
{
    ResetClicksPermanent();
}
elsif( $ARGV[0] eq '--reset-submitted' )
{
    ResetClicksSubmitted();
}
elsif( $ARGV[0] eq '--remove-unconfirmed' )
{
    RemoveOldUnconfirmed();
}
elsif( $ARGV[0] eq '--clearips' )
{
    ClearIPLogs();
}
elsif( $ARGV[0] eq '--process-clicklog' )
{
    ProcessClickLog();
}



## Clear the click tracking IP logs
sub ClearIPLogs
{
    $DB->Connect();
    $DB->Update("DELETE FROM ags_Addresses");
    $DB->Disconnect();
}


## Reset the click counts for permanent galleries
sub ResetClicksPermanent
{
    $DB->Connect();
    $DB->Update("UPDATE ags_Galleries SET Clicks=0 WHERE Type='Permanent'");
    $DB->Disconnect();
}


## Reset the click counts for submitted galleries
sub ResetClicksSubmitted
{
    $DB->Connect();
    $DB->Update("UPDATE ags_Galleries SET Clicks=0 WHERE Type='Submitted'");
    $DB->Disconnect();
}
