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

#Returns a page of Songs to Artists so the user can query artists
sub songs {
	(my $search_for, my $name) = (@_);
	
	my $ref;
	my @songs;
	
	$ref = QueryResultFormatter::get_artists($search_for);
	
	if ( !keys %{$ref} ) {
		Helper::error('Null Results');
		return;
	}
	my $template =
	  HTML::Template->new( filename => 'templates/songs_to_artists.html' );

	$template->param( SEARCH_FOR => $name );
	
	foreach my $name ( keys %{$ref} ) {
		my $artistid = $ref->{$name}{'id'};
		#Some of the data fields were not always present in the hash
		my $country = "N/A";
		if (exists $ref->{$name}{'country'}) {
			$country = $ref->{$name}{'country'};
		}
		my $type = "N/A";
		if (exists $ref->{$name}{'type'}) {
			$type = $ref->{$name}{'type'};
		}
		my $gender = "N/A";
		if (exists $ref->{$name}{'gender'}) {
			$gender = $ref->{$name}{'gender'};
		}
		#Creating a simple array of hashes for the injection
		push(
			@songs,
			{
				ARTISTNAME     => $name,
				ARTISTID => $artistid,
				COUNTRY  => $country,
				TYPE  => $type,
				GENDER  => $gender,
			}
		);
	}

	$template->param( SONG_INFO => [@songs] );
	print "Content-Type: text/html\n\n", $template->output;
}

my $query      = new CGI;
my $search_for = $query->param("id");
my $name = $query->param("name");
#Checking for No Parameters
if ( $search_for eq "" ) {
	Helper::error("No Parameters Set in CGI");
}
else {
	songs($search_for, $name);
}
