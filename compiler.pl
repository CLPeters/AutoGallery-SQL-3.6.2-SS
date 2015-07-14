package Compiler;


my %function_map = ('DEFINE' => \&Compiler::ProcessDefine, 
                    'TEMPLATE' => \&Compiler::ProcessTemplate, 
                    'INCLUDE' => \&Compiler::ProcessInclude, 
                    'GALLERIES' => \&Compiler::ProcessGalleries,
                    'RANDOM' => \&Compiler::ProcessRandom,
                    'CATEGORIES' => \&Compiler::ProcessCategories,
                    'PERL' => \&Compiler::ProcessPerl);


sub new
{
    my $type   = shift;
    my %params = @_;
    my $self   = {};

    $self->{'Output'} = $params{'Output'};
    $self->{'Code'} = undef;
    $self->{'Defines'} = {};
    $self->{'Templates'} = {};
    $self->{'ID'} = 1000;

    bless($self);

    return $self;
}



sub DESTROY
{
    my $self = shift;

    $self->{'Code'} = undef;    
}



## Compile a template into Perl code
sub Compile
{
    my $self = shift;
    my $template = shift;
    my $category = shift;
    my $page_id = shift;
    my $count = 0;
    my $buffer = undef;
    my $directive = undef;
    my $in_directive = 0;
    my $start_heredoc = '$data .= <<__HTML__;' . "\n";
    my $end_heredoc = "__HTML__\n";


    $self->{'Category'} = $category;


    ## Load template from file if necessary
    if( !ref($template) )
    {
        $template = ::FileReadScalar($template);
    }

    
    ## Make sure end-of-line characters are Unix style
    ::UnixFormat($template);


    ## Start the Perl code
    $self->{'Code'} = "\%page_used = ();\n" .
                      "\$gallery_count = 0;\n" .
                      "\$thumbnails = 0;\n" .
                      "\$data = undef;\n" .
                      "\%random = ();\n";


    for( split("\n", $$template) )
    {
        my $line = $_;

        ## Increment line counter
        $count++;


        ## skip blank lines
        next if( ::IsEmptyString($line) );


        ## Opening directive tag is not on a line by itself
        if( $line =~ /^[^\s]+<%/i )
        {
            $self->{'Error'} = "Opening directive tag must be on a line by itself at line $count";
            return 0;
        }


        ## Closing directive tag is not on a line by itself
        elsif( $line =~ /^%>[^\s]+$/i )
        {
            $self->{'Error'} = "Closing directive tag must be on a line by itself at line $count";
            return 0;
        }


        ## Handle opening directive tag
        elsif( $line =~ /^\s*<%([A-Z]+)\s*$/ )
        {
            ## If already in a directive, it is an error to open another directive
            if( $in_directive )
            {
                $self->{'Error'} = "Cannot open a new directive before closing tag from previous directive at line $count";
                return 0;
            }

            if( !::IsEmptyString($buffer) )
            {
                $self->{'Code'} .= $start_heredoc . $buffer . $end_heredoc;
            }

            $in_directive = 1;
            $directive = $1;
            $buffer = undef;

            if( !exists $function_map{$directive} )
            {
                $self->{'Error'} = "Unrecognized directive '$directive' at line $count";
                return 0;
            }
        }


        ## Handle closing directive tag
        elsif( $line =~ /^\s*%>\s*$/ )
        {
            ## If not in a directive, it is an error to have a closing directive tag
            if( !$in_directive )
            {
                $self->{'Error'} = "Cannot have closing directive tag without opening directive tag at line $count";
                return 0;
            }

            ## Process the directive
            if( !&{$function_map{$directive}}($self, \$buffer, $count) )
            {
                return 0;
            }

            $in_directive = 0;
            $directive = undef;
            $buffer = undef;
        }


        ## Handle all other lines
        else
        {
            if( !$in_directive )
            {
                $line =~ s/(?<!\\)\\(?!\\)/\\\\/g;
                $line =~ s/\$/\\\$/g;
                $line =~ s/\@/\\\@/g;                
                $line =~ s/##(.*?)##/\$T\{'$1'\}/g;
            }

            $buffer .= "$line\n";
        }
    }

    
    ## Handle end-of-document code
    if( !::IsEmptyString($buffer) )
    {
        $self->{'Code'} .= $start_heredoc . $buffer . $end_heredoc;
    }

    
    ## Complete the Perl code
    $self->{'Code'} .= '$data .= "<!-- 47b07f3b -->\n";' . "\n";
    $self->{'Code'} .= '$data =~ s/##Thumbnails##/$thumbnails/g;p();' . "\n" .                       
                       '$data =~ s/##Galleries##/$gallery_count/g;' . "\n" .
                       'print TGPPAGE $data;' . "\n";

    return 1;
}



## Process DEFINE directives
sub ProcessDefine
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;
    my $options = {
                   'GLOBALDUPES' => 'False',
                   'PAGEDUPES' => 'False',
                   'DATEFORMAT' => $::DATE_FORMAT,
                   'TIMEFORMAT' => $::TIME_FORMAT
                  };
                  
    ## Extract the options from the directive
    $options = ExtractOptions($buffer, $options);

    for( keys %$options )
    {
        $self->{'Defines'}->{$_} = $options->{$_};
    }

    if( $options->{'DATEFORMAT'} ne $::DATE_FORMAT )
    {
        $self->{'Code'} .= "\$T{'Updated_Date'} = Date('" . EscapeApostrophe($options->{'DATEFORMAT'}) . "');\n";
    }

    if( $options->{'TIMEFORMAT'} ne $::TIME_FORMAT )
    {
        $self->{'Code'} .= "\$T{'Updated_Time'} = Date('" . EscapeApostrophe($options->{'TIMEFORMAT'}) . "');\n";
                           
    }

    $self->{'Code'} .= "\$T{'Updated'} = \"\$T{'Updated_Date'} \$T{'Updated_Time'}\";\n";

    return 1;
}



## Process PERL directives
sub ProcessPerl
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;

    $self->{'Code'} .= $$buffer;

    return 1;
}



## Process INCLUDE directives
sub ProcessInclude
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;
    my $options = ExtractOptions($buffer);

    if( !exists $options->{'FILE'} )
    {
        $self->{'Error'} = "The FILE option must be present in all INCLUDE directives at line $line_number";
        return 0;
    }

    if( !-f $options->{'FILE'} )
    {
        $self->{'Error'} = "File '$options->{'FILE'}' does not exist at line $line_number";
        return 0;
    }

    $self->{'Code'} .= "\$data .= \${FileReadScalar('$options->{'FILE'}')} if( -f '$options->{'FILE'}' );\n";

    return 1;
}



## Process TEMPLATE directives
sub ProcessTemplate
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;
    my $options = ExtractOptions($buffer);

    $self->{'Templates'}->{$options->{'NAME'}} = $options->{'HTML'};

    return 1;
}



## Process RANDOM directives
sub ProcessRandom
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;
    my $options = ExtractOptions($buffer);

    my $html = $self->ProcessHTML($options->{'HTML'}, '$gallery->');

    $self->{'Code'} .= "if( !\$random{'$options->{'FILE'}'} )\n" .
                       "{\n" .
                       "\$random{'$options->{'FILE'}'} = Randomize('$options->{'FILE'}');\n" .
                       "}\n" .
                       "for( 1..$options->{'AMOUNT'} )\n" .
                       "{\n" .
                       "my \$gallery = ProcessRandomGallery(pop(\@{\$random{'$options->{'FILE'}'}}));\n" .
                       "last if( !\$gallery );\n" .
                       "\$gallery_count++;\n" .
                       "\$thumbnails += \$gallery->{'Thumbnails'};\n" .
                       "\$gallery->{'Format'} = \$g_lang->{\$gallery->{'Format'}};\n" .
                       "\$gallery->{'Today'} = \$T{'Today'};\n" .
                       "\$gallery->{'Date'} = \$T{'Today'};\n" .
                       "\$gallery->{'Icons'} = GetIcons(\$gallery->{'Icons'});\n" .
                       "\$gallery->{'Encoded_URL'} = URLEncode(\$gallery->{'Gallery_URL'});\n" .
                       "\$gallery->{'Thumbnails'} = sprintf(\"%02d\", \$gallery->{'Thumbnails'}) if( \$O_PREFIX );\n" .
                       "\$data .= <<__HTML__;\n" .
                       "$html\n" .
                       "__HTML__\n" .
                       "}\n";

    return 1;
}



## Process CATEGORIES directives
sub ProcessCategories
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;
    my $letter_code = undef;
    my $query = undef;
    my $subdirectives = ExtractSubDirectives($buffer);

    ## Setup the default options for CATEGORIES directive
    my $options = {
                   'AMOUNT' => 'All',
                   'ORDER' => 'Name'
                  };

    ## Extract options from the CATEGORIES directive
    ExtractOptions($buffer, $options);


    ## Handle INSERT sub-directives
    my $insert_code = $self->ProcessInsertSub($subdirectives->{'INSERT'});

    ## Process the HTML option
    my $html = $self->ProcessHTML($options->{'HTML'}, '$category->');

    if( !$options->{'WHERE'} )
    {
        ## Process the LETTERHTML option
        if( $options->{'LETTERHTML'} )
        {
            my $letter_html = $self->ProcessHTML($options->{'LETTERHTML'}, '$category->');

            $letter_code = "\$category->{'First_Letter'} = substr(\$category->{'Name'}, 0, 1);\n" .
                           "if( \$last_letter ne \$category->{'First_Letter'} )\n" .
                           "{\n" .
                           "\$data .= <<__HTML__;\n" .
                           "$letter_html\n" .
                           "__HTML__\n" .
                           "\$last_letter = \$category->{'First_Letter'};\n" .
                           "}\n";
        }

        ## Generate the exclude list
        FormatCommaSeparatedList(\$options->{'EXCLUDE'});

        AddDoubleSlashes($options);

        ## Generate MySQL query
        $query = "SELECT * FROM " .
                 "ags_temp_Categories " .
                 ($options->{'EXCLUDE'} ? "WHERE Name NOT IN (" . ::MakeList($options->{'EXCLUDE'}) . ") " : '') .
                 "ORDER BY $options->{'ORDER'}" .
                 ($options->{'AMOUNT'} =~ /^[0-9,]+$/ ? " LIMIT $options->{'AMOUNT'}" : '');
    }
    else
    {
        ## Generate MySQL query
        $query = "SELECT * FROM " .
                 "ags_temp_Categories " .
                 "WHERE $options->{'WHERE'} " .
                 "ORDER BY $options->{'ORDER'}" .
                 ($options->{'AMOUNT'} =~ /^[0-9,]+$/ ? " LIMIT $options->{'AMOUNT'}" : '');
    }


    $self->{'Code'} .= "\$last_letter = undef;\n" .
                       "\$total_counter = 0;\n" .
                       "\$counter = 0;\n" .
                       "\$result = \$DB->Query(\"$query\");\n" .
                       "\$amount = \$DB->NumRows(\$result);\n" .
                       "while( \$category = \$DB->NextRow(\$result) )\n" .
                       "{\n" .
                       "\$total_counter++;\n" .
                       "\$counter++;\n" .
                       "\$page = \$DB->Row(\"SELECT * FROM ags_Pages WHERE Category=? ORDER BY Build_Order LIMIT 1\", [\$category->{'Name'}]);\n" .
                       "\$category->{'Page'} = \"/\$page->{'Filename'}\";\n" .
                       "$letter_code" .
                       "\$data .= <<__HTML__;\n" .
                       "$html\n" .
                       "__HTML__\n" .
                       "$insert_code" .
                       "}\n" .
                       "\$DB->Free($result);\n";

    return 1;
}



## Process GALLERIES directives
sub ProcessGalleries
{
    my $self = shift;
    my $buffer = shift;
    my $line_number = shift;
    my $subdirectives = ExtractSubDirectives($buffer);
    my $id = $self->{'ID'}++;

    ## Setup the default options for GALLERIES directive
    my $options = {'HASTHUMB' => 'Any',
                   'TYPE' => 'Submitted',
                   'FORMAT' => 'Any',
                   'CATEGORY' => 'Mixed',
                   'ORDER' => 'Build_Counter',
                   'SPONSOR' => 'Any',
                   'WEIGHT' => 'Any',
                   'HEIGHT' => 'Any',
                   'WIDTH' => 'Any',
                   'GLOBALDUPES' => $self->{'Defines'}->{'GLOBALDUPES'} || 'False',
                   'PAGEDUPES' => $self->{'Defines'}->{'PAGEDUPES'} || 'False',
                   'DESCREQ' => 'False',
                   'GETNEW' => 'False',
                   'ALLOWUSED' => 'False',
                   'FILL' => 'False',
                   'FILLORDER' => 'Times_Selected, Approve_Stamp',
                   'FILLREORDER' => 'Build_Counter',
                   'TRIMDESC' => 0,
                   'DATEFORMAT' => $self->{'Defines'}->{'DATEFORMAT'} || $::DATE_FORMAT};


    ## Extract options from the GALLERIES directive
    ExtractOptions($buffer, $options);


    ## Format the category list and then set the CATEGORY option
    ## appropriately if this page is restricted to a specific category
    FormatCommaSeparatedList(\$options->{'CATEGORY'});
    $options->{'CATEGORY'} = $self->{'Category'} if( $self->{'Category'} ne 'Mixed' );

    
    ## Format the category exclusion list
    FormatCommaSeparatedList(\$options->{'EXCLUDE'});


    ## Generate MySQL queries based on the directive options
    my $queries = $self->GenerateQueries($options);


    ## Process the HTML option
    my $default_html = $self->ProcessHTML($options->{'HTML'}, '$row->');


    ## Process the DATEHTML option
    my $date_html = undef;
    if( $options->{'DATEHTML'} )
    {
        $date_html = $self->ProcessHTML($options->{'DATEHTML'}, '$T');
        $date_html = "if( \$last_date ne \$row->{'Display_Date'} )\n" .
                     "{\n" .
                     "\$T{'Date'} = \$row->{'Date'};\n" .
                     "\$data .= <<__HTML__;\n" .
                     "$date_html\n" .
                     "__HTML__\n" .
                     "}\n";
    }


    ## Handle INSERT sub-directives
    my $insert_code = $self->ProcessInsertSub($subdirectives->{'INSERT'});


    ## Handle GALLERIES sub-directives
    my $galleries_code = $self->ProcessGalleriesSub($subdirectives->{'GALLERIES'}, $options);


    ## Handle RANDOM sub-directives
    my $random_code = $self->ProcessRandomSub($subdirectives->{'RANDOM'}, $options);


    ## Handle SWITCH sub-directives
    my $main_html = $self->ProcessSwitchSub($subdirectives->{'SWITCH'}, \$default_html, $id);


    ## Determine the code to use to set a gallery's display date
    my $displaydate_code = GetDisplayDateCode($options, $id);


    ## Generate Perl code
    $self->{'Code'} .= "DebugMessage(\"\tProcessing GALLERIES directive ending on line $line_number\");\n" .
                       "\$amount = $options->{'AMOUNT'};\n" .
                       "\$counter = 0;\n" .
                       "\$total_counter = 0;\n" .
                       "\$last_timestamp = undef;\n" .
                       "\$last_date = undef;\n" .
                       "\$galleries = [];\n" .
                       "\$formats = {'$id' => '$options->{'DATEFORMAT'}'" . ($galleries_code->{'format_code'} ? ", $galleries_code->{'format_code'}" : "") . "};\n" .
                       "if( \$g_build_type == \$BUILD_TYPE_REORDER )\n" .
                       "{\n" .
                       "AddGalleries(\$galleries, \$amount, \"$queries->{'Reorder'}\", 0, '$id');\n" .
                       ($options->{'FILL'} eq 'True' ? "AddGalleries(\$galleries, \$amount, \"$queries->{'Fill_Reorder_Primary'}\", 1, '$id');\n" : "") .
                       ($options->{'FILL'} eq 'True' ? "AddGalleries(\$galleries, \$amount, \"$queries->{'Fill_Reorder_Secondary'}\", 1, '$id');\n" : "") .
                       $galleries_code->{'add_reorder'} .
                       $random_code->{'add_code'} .
                       "}\n" .
                       "else\n" .
                       "{\n" .
                       "AddGalleries(\$galleries, \$amount, \"$queries->{'New'}\", 0, '$id');\n" .
                       ($options->{'ALLOWUSED'} eq 'True' ? "AddGalleries(\$galleries, \$amount, \"$queries->{'Reorder'}\", 0, '$id');\n" : "") .
                       ($options->{'FILL'} eq 'True' ? "AddGalleries(\$galleries, \$amount, \"$queries->{'Fill_New'}\", 1, '$id');\n" : "") .
                       $galleries_code->{'add_new'} .
                       $random_code->{'add_code'} .
                       "}\n" .
                       "\$galleries = FlattenBuckets(\$galleries);\n" .
                       "for( \@\$galleries )\n" .
                       "{\n" .
                       "my \$row = \$_;\n" .
                       "if( \$row->{'Status'} eq 'Approved' && !exists \$new_selected{\$row->{'Gallery_ID'}} )\n" .
                       "{\n" .
                       "if( !\$last_date || !\$last_timestamp )\n" .
                       "{\n" .
                       $displaydate_code .
                       $galleries_code->{'displaydate_code'} .
                       "\$row->{'Timestamp'} = \$DB->Count(\"SELECT UNIX_TIMESTAMP(?)\", [\"\$display_date 12:00:00\"]);\n" .
                       "}\n" .
                       "else\n" .
                       "{\n" .
                       "\$row->{'Timestamp'} = \$last_timestamp;\n" .
                       "\$row->{'Display_Date'} = \$display_date = \$last_date;\n" .
                       "}\n" .
                       "\$DB->Update(\"UPDATE ags_Galleries SET Times_Selected=Times_Selected+1,Display_Date=?,Scheduled_Date=NULL WHERE Gallery_ID=?\", [\$display_date, \$row->{'Gallery_ID'}]);\n" .
                       "\$new_selected{\$row->{'Gallery_ID'}} = 1;\n" .
                       "}\n" .
                       "\$total_counter++;\n" .
                       "\$gallery_count++;\n" .
                       "\$thumbnails += \$row->{'Thumbnails'};\n" .
                       "StripHTMLHash(\$row);\n" .
                       "\$row->{'Format'} = \$g_lang->{\$row->{'Format'}};\n" .
                       "\$row->{'Thumbnails'} = sprintf(\"%02d\", \$row->{'Thumbnails'}) if( \$O_PREFIX );\n" .
                       "\$row->{'Encoded_URL'} = URLEncode(\$row->{'Gallery_URL'});\n" .
                       "\$row->{'Rss_URL'} = StripHTMLAll(\$row->{'Gallery_URL'});\n" .
                       "\$row->{'Rss_Description'} = StripHTMLAll(\$row->{'Description'});\n" .
                       "\$row->{'Today'} = \$T{'Today'};\n" .
                       "\$row->{'Icons'} = GetIcons(\$row->{'Icons'});\n" .
                       "\$row->{'Cheat_URL'} = \"\$CGI_URL/report.cgi?ID=\$row->{'Gallery_ID'}\";\n" .
                       "\$row->{'Date'} = Date(\$formats->{\$row->{'ID'}} || '$options->{'DATEFORMAT'}', \$row->{'Timestamp'});\n" .
                       "\$row->{'Last_Date'} = Date(\$formats->{\$row->{'ID'}} || '$options->{'DATEFORMAT'}', \$last_timestamp || \$TIME);\n" .
                       "\$row->{'Productivity'} = \$row->{'Build_Counter'} > 0 ? sprintf(\"%d\", (\$row->{'Clicks'}/\$row->{'Build_Counter'})) : 0;\n" .
                       $galleries_code->{'trim_code'} .
                       ($options->{'TRIMDESC'} > 0 ? "\$row->{'Trimmed_Description'} = TrimString(\$row->{'Description'}, $options->{'TRIMDESC'}) if( \$row->{'ID'} eq '$id' );\n" : "") .                       
                       "if( !\$row->{'Filler'} )\n" .
                       "{\n" .
                       "\$counter++;\n" .
                       $date_html .                       
                       "\$last_timestamp = \$row->{'Timestamp'};\n" .
                       "\$last_date = \$row->{'Display_Date'};\n" .
                       "}\n" .
                       $main_html .
                       $galleries_code->{'html_code'} .
                       $random_code->{'html_code'} .
                       $insert_code .
                       "}\n";

    return 1;
}



## Process the RANDOM sub-directive
sub ProcessRandomSub
{
    my $self = shift;
    my $subdirectives = shift;
    my $parent_options = shift;
    my $id = $self->{'ID'}++;
    my $result = {};

    for( @$subdirectives )
    {
        my $options = $_;

        ## If HTML option was not provided, get it from the parent options
        $options->{'HTML'} = $parent_options->{'HTML'} if( !$options->{'HTML'} );
        $options->{'DATEFORMAT'} = $self->{'Defines'}->{'DATEFORMAT'} || $::DATE_FORMAT;

        my $html = $self->ProcessHTML($options->{'HTML'}, '$row->');

        FormatCommaSeparatedList(\$options->{'LOCATION'});

        $result->{'add_code'} .= "AddRandGalleries(\$galleries, '$options->{'LOCATION'}', \$amount, '" . EscapeApostrophe($options->{'FILE'}) . "', \\%random, '$id');\n";
        $result->{'html_code'} .= "if( \$row->{'ID'} eq '$id' )\n" .
                                  "{\n" .
                                  "\$data .= <<__HTML__;\n" .
                                  "$html\n" .
                                  "__HTML__\n" .
                                  "}\n";
    }

    $result->{'id'} = $id;

    return $result;
}



## Process the GALLERIES sub-directive
sub ProcessGalleriesSub
{
    my $self = shift;
    my $subdirectives = shift;
    my $parent_options = shift;    
    my $result = {};

    if( scalar(@$subdirectives) )
    {
        for( @$subdirectives )
        {
            my $id = $self->{'ID'}++;
            my $options = $_;

            ## Setup values from the parent options        
            for( ('HASTHUMB', 'TYPE', 'FORMAT', 'CATEGORY', 'HTML', 'GETNEW', 'DATEFORMAT') )
            {
                my $option = $_;
                if( !$options->{$option} )
                {
                    $options->{$option} = $parent_options->{$option};
                }
            }

            FormatCommaSeparatedList(\$options->{'CATEGORY'});
            FormatCommaSeparatedList(\$options->{'EXCLUDE'});

            $options->{'PAGEDUPES'} = 'False';

            ## Setup proper category
            $options->{'CATEGORY'} = $parent_options->{'CATEGORY'} if( $options->{'CATEGORY'} eq 'Parent_Category' );
            $options->{'CATEGORY'} = $self->{'Category'} if( $self->{'Category'} ne 'Mixed' );

            my $html = $self->ProcessHTML($options->{'HTML'}, '$row->');        
        
            ## Setup default values
            for( keys %$parent_options )
            {
                if( !$options->{$_} )
                {
                    $options->{$_} = $parent_options->{$_};
                }
            }

            my $queries = $self->GenerateQueries($options);
                   
            $result->{'add_new'} .= "AddSubGalleries(\$galleries, '$options->{'LOCATION'}', \$amount, [\"$queries->{'New'}\"" .
                                   ($options->{'ALLOWUSED'} eq 'True' ? ", \"$queries->{'Reorder'}\"" : "") . "], '$id');\n";
            $result->{'add_reorder'} .= "AddSubGalleries(\$galleries, '$options->{'LOCATION'}', \$amount, \"$queries->{'Reorder'}\", '$id');\n";

            if( $options->{'TRIMDESC'} > 0 )
            {
                $result->{'trim_code'} .= "\$row->{'Trimmed_Description'} = TrimString(\$row->{'Description'}, $options->{'TRIMDESC'}) " .
                                         "if( \$row->{'ID'} eq '$id' );\n";
            }

            $result->{'html_code'} .= "if( \$row->{'ID'} eq '$id' )\n" .
                                     "{\n" .
                                     "\$data .= <<__HTML__;\n" .
                                     "$html\n" .
                                     "__HTML__\n" .
                                     "}\n";

            push(@{$result->{'format_code'}}, "'$id' => '" . EscapeApostrophe($options->{'DATEFORMAT'}) . "'");

            $result->{'displaydate_code'} .= GetDisplayDateCode($options, $id);
        }

        $result->{'format_code'} = join(', ', @{$result->{'format_code'}});
    }

    return $result;
}



## Process the SWITCH sub-directive
sub ProcessSwitchSub
{
    my $self = shift;
    my $subdirectives = shift;
    my $default_html = shift;
    my $id = shift;
    my $main_html = undef;
    my $code = undef;
    my $count = 0;

    for( @$subdirectives )
    {
        my $options = $_;
        my $statement = ProcessLocation($options->{'LOCATION'}, 'SWITCH');
        my $html = $self->ProcessHTML($options->{'HTML'}, '$row->');

        if( $count == 0 )
        {
            $count++;
            $code .= "if( $statement )\n" .
                     "{\n" .
                     "\$data .= <<__HTML__;\n" .
                     "$html\n" .
                     "__HTML__\n" .
                     "}\n";            
        }
        else
        {
            $code .= "elsif( $statement )\n" .
                     "{\n" .
                     "\$data .= <<__HTML__;\n" .
                     "$html\n" .
                     "__HTML__\n" .
                     "}\n";
        }
    }


    ## Decide if an else statement is needed
    if( $code )
    {
        $main_html = "if( \$row->{'ID'} eq '$id' )\n" .
                     "{\n" .
                     $code . 
                     "else\n" .
                     "{\n" .
                     "\$data .= <<__HTML__;\n" .
                     "$$default_html\n" .
                     "__HTML__\n" .
                     "}\n" .
                     "}\n";
    }
    else
    {
        $main_html = "if( \$row->{'ID'} eq '$id' )\n" .
                     "{\n" .
                     "\$data .= <<__HTML__;\n" .
                     "$$default_html\n" .
                     "__HTML__\n" .
                     "}\n";
    }

    return $main_html;
}



## Process the INSERT sub-directive
sub ProcessInsertSub
{
    my $self = shift;
    my $subdirectives = shift;
    my $code = undef;

    for( @$subdirectives )
    {
        my $options = $_;
        my $statement = ProcessLocation($options->{'LOCATION'}, 'INSERT');
        my $html = $self->ProcessHTML($options->{'HTML'}, '$T');

        $code .= "if( $statement )\n" .
                 "{\n" .
                 "\$data .= <<__HTML__;\n" .
                 "$html\n" .
                 "__HTML__\n" .
                 "}\n";
    }

    return $code;
}



## Generate perl code that will determine the display date for a gallery
sub GetDisplayDateCode
{
    my $options = shift;
    my $id = shift;
    my $code = "\$display_date = \$row->{'Display_Date'} = \$MYSQL_DATE";

    if( exists $options->{'AGE'} )
    {
        $code = "\$display_date = \$row->{'Display_Date'} = \$DB->Count(\"SELECT SUBDATE(?, INTERVAL $options->{'AGE'} DAY)\", [\$MYSQL_DATE])";
    }
    elsif( exists $options->{'MINAGE'} )
    {
        $code = "\$display_date = \$row->{'Display_Date'} = \$DB->Count(\"SELECT SUBDATE(?, INTERVAL $options->{'MINAGE'} DAY)\", [\$MYSQL_DATE])";
    }

    $code .= " if( \$row->{'ID'} eq '$id' );\n";

    return $code;
}



## Generate MySQL queries from directive options
sub GenerateQueries
{
    my $self = shift;
    my $options = shift;
    my $wheres = {};
    my $queries = {};
    my $query_start = "SELECT *,UNIX_TIMESTAMP(CONCAT(Display_Date, ' 12:00:00')) AS Timestamp FROM ags_Galleries WHERE";


    ## AGE cannot be specified if either MAXAGE or MINAGE is also specified
    if( exists $options->{'AGE'} && (exists $options->{'MAXAGE'} || exists $options->{'MINAGE'}) )
    {
        $self->{'Error'} = "The AGE option cannot be specified when the MAXAGE or MINAGE options have been specified. Line";
        return 0;
    }


    ## Setup the REORDER option if it was not specified
    if( !exists $options->{'REORDER'} )
    {
        $options->{'REORDER'} = $options->{'ORDER'};
    }


    ## Setup the REWHERE option if it was not specified
    if( !exists $options->{'REWHERE'} )
    {
        $options->{'REWHERE'} = $options->{'WHERE'};
    }


    ## Setup the ORDER, REORDER, FILLORDER options if it contains RAND()
    $options->{'ORDER'} =~ s/RAND\(\)/RAND(##Rand##)/gi;
    $options->{'REORDER'} =~ s/RAND\(\)/RAND(##Rand##)/gi;
    $options->{'FILLORDER'} =~ s/RAND\(\)/RAND(##Rand##)/gi;
    $options->{'FILLREORDER'} =~ s/RAND\(\)/RAND(##Rand##)/gi;


    ## Only process if the WHERE option was not specified
    if( !exists $options->{'WHERE'} )
    {
        AddDoubleSlashes($options);

        $wheres->{'Type'} = "Type='$options->{'TYPE'}'" if( $options->{'TYPE'} ne 'Any' );
        $wheres->{'Category'} = "Category IN (" . ::MakeList($options->{'CATEGORY'}) . ")" if( $options->{'CATEGORY'} ne 'Mixed' );
        $wheres->{'Exclude'} = "Category NOT IN (" . ::MakeList($options->{'EXCLUDE'}) . ")" if( $options->{'EXCLUDE'} );
        $wheres->{'Sponsor'} = "Sponsor IN (" . ::MakeList($options->{'SPONSOR'}) . ")" if( $options->{'SPONSOR'} ne 'Any' );
        $wheres->{'Descreq'} = "Description!=''" if( $options->{'DESCREQ'} eq 'True' );
        $wheres->{'HasThumb'} = "Has_Thumb=$options->{'HASTHUMB'}" if( $options->{'HASTHUMB'} ne 'Any' );
        $wheres->{'Format'} = "Format='$options->{'FORMAT'}'" if( $options->{'FORMAT'} ne 'Any' );
        $wheres->{'Height'} = "Thumb_Height$options->{'HEIGHT'}" if( $options->{'HEIGHT'} ne 'Any' );
        $wheres->{'Width'} = "Thumb_Width$options->{'WIDTH'}" if( $options->{'WIDTH'} ne 'Any' );
        $wheres->{'Weight'} = "Weight$options->{'WEIGHT'}" if( $options->{'WEIGHT'} ne 'Any' );
        $wheres->{'Scheduled'} = "(Scheduled_Date IS NULL OR Scheduled_Date <= '\$MYSQL_DATE')" if( $options->{'GETNEW'} eq 'True' );
        $wheres->{'Status'} = "Status='" . ($options->{'GETNEW'} eq 'False' ? 'Used' : 'Approved') . "'";
        
        ## Process the KEYWORDS option
        if( exists $options->{'KEYWORDS'} )
        {
            FormatCommaSeparatedList(\$options->{'KEYWORDS'});

            my @keywords = map("Keywords LIKE '%$_%'", split(/,/, $options->{'KEYWORDS'}));

            $wheres->{'Keywords'} = "(" . join(' OR ', @keywords) . ")";
        }


        ## Process the MAXAGE and MINAGE options
        if( exists $options->{'AGE'} )
        {
            $wheres->{'Age'} = "Display_Date=SUBDATE('\$MYSQL_DATE', INTERVAL $options->{'AGE'} DAY)"
        }
        if( exists($options->{'MINAGE'}) && exists($options->{'MAXAGE'}) )
        {
            $wheres->{'Age'} = "Display_Date BETWEEN SUBDATE('\$MYSQL_DATE', INTERVAL $options->{'MAXAGE'} DAY) AND SUBDATE('\$MYSQL_DATE', INTERVAL $options->{'MINAGE'} DAY)";
        }
        elsif( exists($options->{'MINAGE'}) )
        {
            $wheres->{'Age'} = "Display_Date <= SUBDATE('\$MYSQL_DATE', INTERVAL $options->{'MINAGE'} DAY)";
        }
        elsif( exists($options->{'MAXAGE'}) )
        {
            $wheres->{'Age'} = "Display_Date >= SUBDATE('\$MYSQL_DATE', INTERVAL $options->{'MAXAGE'} DAY)";
        }

        StripDoubleSlashes($options);
    }
    else
    {
        $wheres->{'Where'} = $options->{'WHERE'};
        $wheres->{'Rewhere'} = $options->{'REWHERE'};
    }


    ## Handle the GLOBALDUPES and PAGEDUPES options
    if( $options->{'GLOBALDUPES'} eq 'True' && $options->{'PAGEDUPES'} eq 'False' )
    {
        $wheres->{'Dupes'} = "Gallery_ID NOT IN ('##Page_Used##')";
    }
    elsif( $options->{'GLOBALDUPES'} eq 'False' && $options->{'PAGEDUPES'} eq 'True' )
    {
        $wheres->{'Dupes'} = "Gallery_ID NOT IN ('##Global_Used##')";
    }
    elsif( $options->{'GLOBALDUPES'} eq 'False' && $options->{'PAGEDUPES'} eq 'False' )
    {
        $wheres->{'Dupes'} = "Gallery_ID NOT IN ('##Page_Used##','##Global_Used##')";
    }
    

    ## Setup the MySQL WHERE clause for builds that only reorder
    my $reorder_where = CreateWhere($wheres, ['Type', 'Category', 'Exclude', 'Sponsor', 'Descreq', 'HasThumb', 'Format', 'Height', 'Width', 'Weight', 'Age', 'Dupes', 'Where', 'Keywords'], ["Status='Used'"]);
    my $fill_reorder_prim_where = CreateWhere($wheres, ['Category', 'Exclude', 'Descreq', 'HasThumb', 'Format', 'Height', 'Width', 'Weight', 'Dupes', 'Where'], ["Status='Used'", "Type='Permanent'"]);
    my $fill_reorder_sec_where = CreateWhere($wheres, ['Category', 'Exclude', 'Descreq', 'HasThumb', 'Format', 'Height', 'Width', 'Weight', 'Dupes', 'Where'], ["Status='Approved'", "Type='Permanent'", "(Scheduled_Date IS NULL OR Scheduled_Date <= '\$MYSQL_DATE')"]);
    


    ## Setup the MySQL WHERE clause for builds with new galleries
    delete $wheres->{'Age'} if( $options->{'GETNEW'} eq 'True' );
    my $new_where = CreateWhere($wheres, ['Type', 'Category', 'Exclude', 'Sponsor', 'Descreq', 'HasThumb', 'Format', 'Height', 'Width', 'Weight', 'Age', 'Dupes', 'Where', 'Status', 'Scheduled', 'Keywords']);
    my $fill_new_where = CreateWhere($wheres, ['Category', 'Exclude', 'Descreq', 'HasThumb', 'Format', 'Height', 'Width', 'Weight', 'Dupes', 'Where', 'Scheduled'], ["Status='Approved'", "Type='Permanent'", "(Scheduled_Date IS NULL OR Scheduled_Date <= '\$MYSQL_DATE')"]);

    $queries->{'New'} = "$query_start $new_where ORDER BY $options->{'ORDER'}";
    $queries->{'Reorder'} = "$query_start $reorder_where ORDER BY $options->{'REORDER'}";

    if( $options->{'FILL'} eq 'True' )
    {
        $queries->{'Fill_New'} = "$query_start $fill_new_where ORDER BY $options->{'FILLORDER'}";
        $queries->{'Fill_Reorder_Primary'} = "$query_start $fill_reorder_prim_where ORDER BY $options->{'FILLREORDER'}";
        $queries->{'Fill_Reorder_Secondary'} = "$query_start $fill_reorder_sec_where ORDER BY $options->{'FILLREORDER'}";
    }

    return $queries;
}



sub CreateWhere
{
    my $wheres = shift;
    my $keys = shift;
    my $extras = shift;
    my @where = (@$extras);

    for( @$keys )
    {
        my $key = $_;

        if( !::IsEmptyString($wheres->{$key}) )
        {
            push(@where, $wheres->{$key});
        }
    }

    return join(' AND ', @where);
}



## Extract sub-directives from a directive
sub ExtractSubDirectives
{
    my $input = shift;
    my $suboptions = undef;
    my $subdirectives = {};

    while( $$input =~ s/^([A-Z]+)\s+{\s+([^}]+)}\s+//m )
    {
        $suboptions = $2;
        push(@{$subdirectives->{$1}}, ExtractOptions(\$suboptions));
    }

    return $subdirectives;
}



## Extract the options from a directive or sub-directive
sub ExtractOptions
{
    my $input = shift;
    my $options = shift || {};
    my $buffer = undef;
    my $current_option = undef;
    
    for( split("\n", $$input) )
    {
        my $line = $_;

        ## Skip empty lines
        next if( ::IsEmptyString($line) );

        ## Start of new option
        if( $line =~ /^\s*([A-Z]+)\s*(.*)$/ )
        {
            if( $buffer )
            {
                $options->{$current_option} .= $buffer;
                $buffer = undef;
            }

            $current_option = $1;
            $options->{$current_option} = $2;
        }
        else
        {
            $buffer .= $line;
        }
    }

    if( $buffer )
    {
        $options->{$current_option} .= $buffer;
    }

    return $options;
}



## Process the LOCATION option of the INSERT, GALLERIES, SWITCH, and RANDOM subdirectives
sub ProcessLocation
{
    my $location  = shift;
    my $type = shift;
    my $statement = undef;
    my $var_name = ($type eq 'SWITCH') ? 'counter' : 'total_counter';
    my $comparison = $type eq 'SWITCH' ? '>=' : '==';

    FormatCommaSeparatedList(\$location);

    ## Format: +5
    if( $location =~ /\+(\d+)/ )
    {
        $statement = "\$$var_name % $1 == 0" . ($type eq 'INSERT' ? " && \$counter != \$amount" : '');
    }

    ## Format: 5,10,15
    elsif( $location =~ /,/ )
    {
        $statement = "index(\",$location,\", \",\$$var_name,\") != -1";
    }

    ## Format: 5
    else
    {
        $statement = "\$$var_name $comparison $location";
    }

    return $statement;
}



## Determine the limit to use for GALLERIES sub-directives
sub ProcessLimit
{
    my $location = shift;
    my $amount = shift;

    FormatCommaSeparatedList(\$location);

    ## Format: +5
    if( $location =~ /\+(\d+)/ )
    {
        return int($amount/$1);
    }

    ## Format: 5,10,15
    elsif( @matches = ($location =~ /,/g) )
    {
        return scalar(@matches) + 1;
    }

    ## Format: 5
    else
    {
        return 1;
    }
}



## Process the HTML directive option
sub ProcessHTML
{
    my $self = shift;
    my $html = shift;
    my $prefix = shift;

    $html = $self->{'Templates'}->{$html} || $html;
    $html =~ s/__EOL__/\n/g;
    $html =~ s/\$/\\\$/g;
    $html =~ s/##(Today.*?)##/\$T\{'$1'\}/g;
    $html =~ s/##(Weekday.*?)##/\$T\{'$1'\}/g;
    $html =~ s/##(.*?)##/$prefix\{'$1'\}/g;

    return $html;
}



## Format comma separated lists of values
sub FormatCommaSeparatedList
{
    my $list = shift;

    ## Remove whitespace at the beginning of the string
    $$list =~ s/^\s+//g;

    ## Remove whitespace at the end of the string
    $$list =~ s/\s+$//g;

    ## Remove whitespace before or after a comma
    $$list =~ s/\s+,\s+|,\s+|\s+,/,/g;
}



## Get the most recent error message
sub GetLastError
{
    my $self = shift;

    return $self->{'Error'};
}



## Escape apostrophe characters
sub EscapeApostrophe
{
    my $string = shift;

    $string =~ s/'/\\'/g;

    return $string;
}



sub AddDoubleSlashes
{
    my $hash = shift;
    
    for( keys %$hash )
    {
        $hash->{$_} =~ s/'/\\\\'/g;
    }
}



sub StripDoubleSlashes
{
    my $hash = shift;

    for( keys %$hash )
    {
        $hash->{$_} =~ s/\\\\//g;
    }
}

1;
