#!/usr/bin/perl

chdir('..');

eval
{
    require 'common.pl';
    require 'ags.pl';
    Header("Content-type: text/html\n\n");
    main();
};


if( $@ )
{
    Error("$@", 'menu.cgi');
}


sub main
{
    ParseRequest();

    $T{'Script_URL'} = GetScriptURL();

    ParseTemplate('admin_menu.tpl');
}
