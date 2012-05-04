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

#Function to format Artists data for Albums
sub artist {
	(my $search_for, my $name) = (@_);
	
	my $ref;
	my @albums;
	
	$ref = QueryResultFormatter::get_albums($search_for);

	#Errors
	if ( !keys %{$ref} ) {
		Helper::error('Null Results');
		return;
	}
	#This is where we create the template
	my $template =
	  HTML::Template->new( filename => 'templates/artists_to_albums.html' );

	#Injecting data into the template
	$template->param( SEARCH_FOR => $name );	

	foreach my $id ( keys %{$ref} ) {
		my $release = "N/A";
		if (ref ($ref->{$id}{'first-release-date'}) eq 'HASH') {
			$release = $ref->{$id}{'first-release-date'};
		}
		push(
			@albums,
			{
				ALBUMID     => $id,
				RELEASEDATE => $release,
				ALBUMTYPE   => $ref->{$id}{'type'},
				ALBUMTITLE  => $ref->{$id}{'title'},
			}
		);
	}

	$template->param( SONG_INFO => [@albums] );
	
	print "Content-Type: text/html\n\n", $template->output;
}

#Creating a new CGI handler
my $query      = new CGI;
my $search_for = $query->param("id");
my $name = $query->param("name");
if ( $search_for eq "" ) {
	Helper::error("No Parameters Set in CGI");
}
else {
	artist($search_for, $name);
}
