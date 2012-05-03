#!/usr/bin/perl
use warnings;
use strict;

use HTML::Template;
use CGI;
use Data::Dumper;
use lib "../";
use QueryResultFormatter;

sub artists_test {
	my $ref;
	$ref = QueryResultFormatter::get_possible_artists('The Beatles');
	my @artists;
	foreach my $key ( keys %{$ref} ) {
		push(
			@artists,
			{
				ID       => $key,
				SORTNAME => $ref->{$key}{'sort-name'},
				SCORE    => $ref->{$key}{'ext:score'}
			}
		);
	}
	
	print Dumper([@artists]);
}


artists_test();