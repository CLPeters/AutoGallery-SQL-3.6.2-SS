#!/usr/bin/perl

require 'common.pl';
require 'ags.pl';
require 'mysql.pl';


## Run from shell only
if( $ENV{'REQUEST_METHOD'} )
{
    exit;
}


print "Gallery database is now being shuffled.\n" .
      "Please allow several minutes for this process\n" .
      "to complete.  Do not access any of the software\n" .
      "functions while the shuffling is in progress.\n\n";


my $tables = IniParse("$DDIR/tables");


$DB->Connect();


## Create the new table
$DB->Insert("CREATE TABLE IF NOT EXISTS temp_ags_Galleries ($tables->{'ags_Galleries'}) TYPE=MyISAM");


## Make sure the table is empty
$DB->Update("DELETE FROM temp_ags_Galleries");


## Copy all galleries in random order from the current table to the new table
my $result = $DB->Query("SELECT * FROM ags_Galleries ORDER BY RAND()");

print "Randomizing galleries in the database...";

while( $gallery = $DB->NextRow($result) )
{
    my $current_id = $gallery->{'Gallery_ID'};

    my $bind_values = [undef,
                       $gallery->{'Email'},
                       $gallery->{'Gallery_URL'},
                       $gallery->{'Description'},
                       $gallery->{'Thumbnails'},
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

    ## Insert gallery data into the new table
    $DB->Insert("INSERT INTO temp_ags_Galleries VALUES (" . MakeBindList(scalar @$bind_values) . ")", $bind_values);               


    ## Get the new ID number
    my $new_id = $DB->InsertID();


    ## Rename thumbnail
    if( $gallery->{'Has_Thumb'} && -e "$THUMB_DIR/$current_id.jpg" )
    {
        rename("$THUMB_DIR/$current_id.jpg", "$THUMB_DIR/temp_$new_id.jpg");
        $DB->Update("UPDATE temp_ags_Galleries SET Thumbnail_URL=? WHERE Gallery_ID=?", ["$THUMB_URL/$new_id.jpg", $new_id]);
    }
}

$DB->Free($result);

print "done\n";



print "Updating database tables...";

## Drop the old table
$DB->Update("DROP TABLE ags_Galleries");


## Rename the new table
$DB->Update("ALTER TABLE temp_ags_Galleries RENAME TO ags_Galleries");

print "done\n";



print "Optimizing the database tables...";

$DB->Update("OPTIMIZE TABLE ags_Galleries");

print "done\n";



print "Processing preview thumbnails...";

## Rename all thumbnails
for( @{DirRead("$THUMB_DIR", '^temp_')} )
{
    my $temp_file = $_;
    my $new_file = $temp_file;

    $new_file =~ s/temp_//;

    rename("$THUMB_DIR/$temp_file", "$THUMB_DIR/$new_file");
}

print "done\n\n";


print "The shuffling process has been completed.\n\n";
