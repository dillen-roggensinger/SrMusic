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

sub artist {
	my $ref;
	( my $search_for, my $search_by ) = @_;
	$ref = QueryResultFormatter::get_possible_artists($search_for);

	my $template = HTML::Template->new( filename => 'templates/artist.html' );

	$template->param( SEARCH_FOR => $search_for );
	$template->param( SEARCH_BY  => $search_by );

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

	$template->param( SONG_INFO => [@artists] );

	print "Content-Type: text/html\n\n", $template->output;
}

sub song {
	( my $search_for, my $search_by ) = @_;
	my $template =
	  HTML::Template->new( filename => 'templates/songs.html' );
	$template->param( SEARCH_FOR => $search_for );
	$template->param( SEARCH_BY  => $search_by );

	my $ref = QueryResultFormatter::get_possible_recordings($search_for);
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
	$template->param( SONG_INFO => [@songs] );

	print "Content-Type: text/html\n\n", $template->output;
}

sub album {
	( my $search_for, my $search_by ) = @_;
	my $template =
	  HTML::Template->new( filename => 'templates/albums.html' );
	$template->param( SEARCH_FOR => $search_for );
	$template->param( SEARCH_BY  => $search_by );
	
	my $ref = 	QueryResultFormatter::get_possible_albums($search_for);
	my @albums;
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
			@albums,
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
	
	$template->param(SONG_INFO => [@albums]);

	print "Content-Type: text/html\n\n", $template->output;
}

sub returnSearch {
	( my $search_for, my $search_by ) = @_;
	my $ref;
	if ( $search_by eq "artist" ) {
		artist( $search_for, $search_by );
	}
	elsif ( $search_by eq "song" ) {
		song( $search_for, $search_by );
	}
	else {    #Default to Album
		album( $search_for, $search_by );
	}

}

my $query      = new CGI;
my $search_for = $query->param("main-search-text");
my $search_by  = $query->param("main-search-by");

if ( $search_for eq "" || $search_by eq "" ) {
	Helper::error("No Parameters Set in CGI");
}
else {
	returnSearch( $search_for, $search_by );
}
