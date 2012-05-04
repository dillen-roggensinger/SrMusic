#!/usr/bin/perl
use warnings;
use strict;

use HTML::Template;
use CGI;
use Data::Dumper;
use lib "../";
use QueryResultFormatter;

#Transforming the data into a single hash per each search

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

	print Dumper( [@artists] );
}

sub songs_test {
	my $ref;
	$ref = QueryResultFormatter::get_possible_recordings('Party Rock');
	my @songs;
	foreach my $id ( keys %{$ref} ) {
		my $SONGID = $id;
		my $ALBUMID;
		my $ALBUMTITLE;
		my $ARTISTNAME;
		my $ARTISTID;
		if ( defined( $ref->{$id}{'album'}{'id'} ) ) {
			$ALBUMID = $ref->{$id}{'album'}{'id'};
		}
		else {
			next;
		}
		if ( defined( $ref->{$id}{'album'}{'title'} ) ) {
			$ALBUMTITLE = $ref->{$id}{'album'}{'title'};
		}
		else {
			next;
		}
		if ( ref( $ref->{$id}{'artists'}[0] ) eq 'HASH' ) {
			$ARTISTNAME = $ref->{$id}{'artists'}[0]{'artist'}{'name'};
			$ARTISTID   = $ref->{$id}{'artists'}[0]{'artist'}{'id'};
		}
		else {
			next;
		}
		my $SONGTITLE = $ref->{$id}{'title'};
		my $SONGSCORE = $ref->{$id}{'ext:score'};
		push(
			@songs,
			{
				SONGID     => $SONGID,
				ALBUMID    => $ALBUMID,
				ALBUMTITLE => $ALBUMTITLE,
				ARTISTNAME => $ARTISTNAME,
				ARTISTID   => $ARTISTID,
				SONGTITLE  => $SONGTITLE,
				SONGSCORE  => $SONGSCORE,
			}
		);
	}
}

sub albums_test {
	my $ref;
	$ref = QueryResultFormatter::get_possible_albums('The Eagles');
	my @songs;
	foreach my $id ( keys %{$ref} ) {
		my $ALBUMID = $id;
		my $ARTISTNAME;
		my $ARTISTID;
		my $ALBUMTYPE;
		if ( ref( $ref->{$id}{'artists'}[0] ) eq 'HASH' ) {
			$ARTISTNAME = $ref->{$id}{'artists'}[0]{'artist'}{'name'};
			$ARTISTID   = $ref->{$id}{'artists'}[0]{'artist'}{'id'};
		}
		else {
			next;
		}
		my $ALBUMTITLE = $ref->{$id}{'title'};
		my $ALBUMSCORE = $ref->{$id}{'ext:score'};
		if (defined($ref->{$id}{'type'})) {
			$ALBUMTYPE  = $ref->{$id}{'type'};
		} 
		else {
			$ALBUMTYPE = "N/A";
		}
		push(
			@songs,
			{
				ALBUMID    => $ALBUMID,
				ALBUMTITLE => $ALBUMTITLE,
				ARTISTNAME => $ARTISTNAME,
				ARTISTID   => $ARTISTID,
				ALBUMSCORE => $ALBUMSCORE,
				ALBUMTYPE  => $ALBUMTYPE,
			}
		);
	}
	print Dumper(@songs);
}

albums_test();
