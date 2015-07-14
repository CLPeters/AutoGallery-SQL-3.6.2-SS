#!/usr/bin/perl

my $cdir = '/home/soft/cgi-bin/ags';
chdir($cdir) || die "Could not change into $cdir";

my @dirs = ('/home/soft/cgi-bin/autogs');

my $cp = 'cp';  ## cp command on your server (may need to be changed to a full path)
my $chmod = 'chmod -f';  ## chmod command on your server (may need to be changed to a full path) 

require 'common.pl';
require 'ags.pl';
require 'mysql.pl';


## Run from shell only
if( $ENV{'REQUEST_METHOD'} )
{
    exit;
}


## Enable the error log
$ERROR_LOG = 1;


## Process command line arguments
my $options = ProcessOptions();


## Directory specified on command line
if( $options->{'d'} )
{
    @dirs = ($options->{'d'});
}


## Close everything if not in verbose mode
if( !exists $options->{'v'} )
{
    close STDIN; close STDOUT; close STDERR;
}


## Get information from the source database
$DB->Connect();
$DB->BackupTables(['ags_Galleries', 'ags_Accounts', 'ags_Categories'], "$DDIR/syncdb.txt", {quotemeta($THUMB_URL) => '##Sync_Thumb_URL##'});
$DB->Disconnect();


for( @dirs )
{
    my $dir = $_;

    if( -d $dir )
    {
        my $version = ExtractVariable("$dir/ags.pl", 'VERSION');
        my $username = ExtractVariable("$dir/data/variables", 'USERNAME');
        my $password = ExtractVariable("$dir/data/variables", 'PASSWORD');
        my $database = ExtractVariable("$dir/data/variables", 'DATABASE');
        my $hostname = ExtractVariable("$dir/data/variables", 'HOSTNAME');
        my $thumb_dir = ExtractVariable("$dir/data/variables", 'THUMB_DIR');
        my $thumb_url = ExtractVariable("$dir/data/variables", 'THUMB_URL');

        ## Make sure both installations are the same version
        if( $version eq $VERSION )
        {
            my $dbh = new SQL(Hostname => $hostname, Username => $username, Password => $password, Database => $database);

            ## Sync database
            $dbh->Connect();
            $dbh->RestoreTables("$DDIR/syncdb.txt", {'##Sync_Thumb_URL##' => $thumb_url});
            $dbh->Disconnect();

            ## Sync thumbs
            for( @{DirRead($THUMB_DIR, '\.jpg$')} )
            {
                my $thumb_file = $_;

                system("$cp $THUMB_DIR/$thumb_file $thumb_dir");
                system("$chmod 666 $thumb_dir/$thumb_file");
            }

            ## Run build function
            if( $options->{'b'} )
            {
                system("$dir/cron.cgi --build");
            }
            elsif( $options->{'bn'} )
            {
                system("$dir/cron.cgi --build-with-new");
            }
        }
    }
}

FileRemove("$DDIR/syncdb.txt");


## Run build function for local install
if( $options->{'bl'} )
{
    BuildAllReorder();
}
elsif( $options->{'bnl'} )
{
    BuildAllNew();
}



sub ExtractVariable
{
    my $file = shift;
    my $variable = shift;
    my $contents = FileReadScalar($file);
    my $value = undef;

    if( $$contents =~ /\$$variable\s*=\s*'([^']+)';/ )
    {
        $value = $1;
    }

    return $value;
}



sub ProcessOptions
{
    my $options = {};

    for( @ARGV )
    {
        if( $_ =~ /-([a-z]+)=(.*)/i )
        {
            $options->{$1} = $2;
        }
        elsif( $_ =~ /-([a-z]+)/i )
        {
            $options->{$1} = 1;
        }
    }

    return $options;
}

