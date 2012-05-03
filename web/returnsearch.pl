#!/usr/bin/perl
use warnings;
use strict;

#SrMusic Project
#Spring 2012
#author @epkatz

use HTML::Template;
use CGI;
use Data::Dumper;
use lib "../";
use Helper;
use QueryResultFormatter;


sub returnSearch {
	(my $search_for, my $search_by) = @_;
	my $ref;
	if ($search_by eq "artist") {
		$ref = QueryResultFormatter::get_possible_artists($search_for);
	}
	if ($search_by eq "song") {
		QueryResultFormatter::get_possible_recordings($search_for);
	}
	else { #Default to Album
		QueryResultFormatter::get_possible_albums($search_for);
	}
	
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
}

my $query      = new CGI;
my $search_for = $query->param("main-search-text");
my $search_by  = $query->param("main-search-by");

if ($search_for eq "" || $search_by eq "") {
	Helper::error("No Parameters Set in CGI");
} 
else {
	returnSearch($search_for, $search_by);
}