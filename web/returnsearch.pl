#!/usr/bin/perl
use warnings;
use strict;

#SrMusic Project
#Spring 2012
#author @epkatz

use HTML::Template;
use CGI;

my $query      = new CGI;
my $search_for = $query->param("main-search-text");
my $search_by  = $query->param("main-search-by");

my $template = HTML::Template->new( filename => 'templates/returnsearch.html' );
$template->param(SEARCH_FOR => $search_for);
$template->param(SEARCH_BY => $search_by);
$template->param(
	SONG_INFO => [
		{ ARTIST => 'dillen', ALBUM => 'sucks', SONG => 'FUCK MY NUTS'},
		{ ARTIST => 'Terrance', ALBUM => 'greatest hits', SONG => 'Fuck you'},
	]
);

print "Content-Type: text/html\n\n", $template->output;

