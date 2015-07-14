#!/usr/bin/perl

my $remote_url = 'http://www.remoteserver.com/thumbs';

my $ftp_host = 'ftp.remoteserver.com';
my $ftp_user = 'username';
my $ftp_pass = 'password';
my $ftp_port = '21';
my $ftp_dir = 'public_html/thumbs';


use Net::FTP;

require 'common.pl';
require 'ags.pl';
require 'mysql.pl';

## Run from shell only
if( $ENV{'REQUEST_METHOD'} )
{
    exit;
}

$ERROR_LOG = 1;

close STDIN; close STDOUT; close STDERR;

my $transferred = {};
my $ftp = Net::FTP->new($ftp_host, Debug => 0, Port => $ftp_port) || Error("Cannot connect to $ftp_host: $@", "FTP Connection");

$ftp->login($ftp_user, $ftp_pass) || Error("Cannot login: " . $ftp->message, "FTP Connection");
$ftp->cwd($ftp_dir) || Error("Cannot change to $ftp_dir: " . $ftp->message, "FTP Connection");
$ftp->binary();

my $dir_contents = $ftp->ls();

$DB->Connect();

my $result = $DB->Query("SELECT * FROM ags_Galleries WHERE Has_Thumb=1");
my $gallery = undef;

while( $gallery = $DB->NextRow($result) )
{
    ## Thumb already located on remote server, so only mark it as still in use
    if( $gallery->{'Thumbnail_URL'} =~ /^$remote_url/ )
    {
        $transferred->{"$gallery->{'Gallery_ID'}.jpg"} = 1;
    }

    ## Thumb needs to be transferred and DB updated
    elsif( $gallery->{'Thumbnail_URL'} =~ /^$THUMB_URL/ )
    {
        my $filename = $ftp->put("$THUMB_DIR/$gallery->{'Gallery_ID'}.jpg", "$gallery->{'Gallery_ID'}.jpg");
        $transferred->{"$gallery->{'Gallery_ID'}.jpg"} = 1;

        if( $filename )
        {
            $DB->Update("UPDATE ags_Galleries SET Thumbnail_URL=? WHERE Gallery_ID=?", ["$remote_url/$gallery->{'Gallery_ID'}.jpg", $gallery->{'Gallery_ID'}]);
        }
    }   
}

$DB->Free($result);


## Cleanup thumbs that are no longer used
if( ref($dir_contents) eq 'ARRAY' )
{
    for( @$dir_contents )
    {
        my $file = $_;

        if( !exists $transferred->{$file} )
        {
            $ftp->delete($file);
        }
    }
}

$ftp->quit;

