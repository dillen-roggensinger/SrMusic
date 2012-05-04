#!/usr/bin/perl
use warnings;
use strict;

use HTML::Template;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use lib "../";
use Helper;
use QueryResultFormatter;

sub songs {
	(my $search_for, my $name) = (@_);
	
	my $ref;
	my @songs;
	
	$ref = QueryResultFormatter::get_songs($search_for);

	if ( !keys %{$ref} ) {
		Helper::error('Null Results');
		return;
	}
	my $template =
	  HTML::Template->new( filename => 'templates/albums_to_songs.html' );

	$template->param( SEARCH_FOR => $name );

	foreach my $id ( keys %{$ref} ) {
		push(
			@songs,
			{
				SONGID     => $id,
				LENGTH => $ref->{$id}{'length'},
				SONGTITLE  => $ref->{$id}{'title'},
			}
		);
	}

	$template->param( SONG_INFO => [@songs] );
	print "Content-Type: text/html\n\n", $template->output;
}

my $query      = new CGI;
my $search_for = $query->param("id");
my $name = $query->param("name");
if ( $search_for eq "" ) {
	Helper::error("No Parameters Set in CGI");
}
else {
	songs($search_for, $name);
}
