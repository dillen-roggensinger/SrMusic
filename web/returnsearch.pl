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

#Each function has a slightly different formatting function so they were all 
#seperated for simplicity. They could have been ecapsulted in smaller functions 
#but this seemed much harder to error handle

#Returning Artists based on a search
sub artist {
	my $ref;
	( my $search_for, my $search_by, my $more) = @_;
	$ref = QueryResultFormatter::get_possible_artists($search_for, $more);
	
	#We return an error if there are no more results left
	 if (!keys $ref) {
	 	Helper::error('Null Results');
	 	return;
	 }

	my $template = HTML::Template->new( filename => 'templates/artist.html' );

	$template->param( SEARCH_FOR => $search_for );
	$template->param( SEARCH_BY  => $search_by );
	#More variable is to continually scroll through the results
	$template->param( MORE       => ($more + 100));

	my @artists;
	#This is the easiest filter. See the backend docs for how the query gets formatted
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
	
	my @sorted =  sort { $b->{SCORE} <=> $a->{SCORE} } @artists;

	$template->param( SONG_INFO => [@sorted] );

	print "Content-Type: text/html\n\n", $template->output;
}

#Return all the songs that matched the query
sub song {
	( my $search_for, my $search_by, my $more) = @_;
	my $template =
	  HTML::Template->new( filename => 'templates/songs.html' );
	$template->param( SEARCH_FOR => $search_for );
	$template->param( SEARCH_BY  => $search_by );
	$template->param( MORE       => ($more + 100) );

	my $ref = QueryResultFormatter::get_possible_recordings($search_for, $more);
	
	if (!keys $ref) {
	 	Helper::error('Null Results');
	 	return;
	 }
	
	#The format that is returned was too complex for the injection so 
	#it must go through an extra layer of processing which also
	#happened to be good data structures practice like our hw
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
				#We commented out data we decided not to use
				SONGID     => $SONGID,
				#ALBUMID    => $ALBUMID,
				ALBUMTITLE => $ALBUMTITLE,
				ARTISTNAME => $ARTISTNAME,
				#ARTISTID   => $ARTISTID,
				SONGTITLE  => $SONGTITLE,
				SONGSCORE  => $SONGSCORE,
			}
		);
	}
	
	#We sort by score
	my @sorted =  sort { $b->{SONGSCORE} <=> $a->{SONGSCORE} } @songs;
	
	$template->param( SONG_INFO => [@sorted] );

	print "Content-Type: text/html\n\n", $template->output;
}

#Return all the Albums that match the query
sub album {
	( my $search_for, my $search_by, my $more) = @_;
	my $template =
	  HTML::Template->new( filename => 'templates/albums.html' );
	$template->param( SEARCH_FOR => $search_for );
	$template->param( SEARCH_BY  => $search_by );
	$template->param( MORE       => ($more + 100) );
	
	my $ref = 	QueryResultFormatter::get_possible_albums($search_for, $more);
	
	if (!keys $ref) {
	 	Helper::error('Null Results');
	 	return;
	 }
	
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
				#ARTISTID   => $ARTISTID,
				ALBUMSCORE => $ALBUMSCORE,
				ALBUMTYPE  => $ALBUMTYPE,
			}
		);
	}
	
	#The relevancy comes from the database itself
	my @sorted =  sort { $b->{ALBUMSCORE} <=> $a->{ALBUMSCORE} } @albums;
	
	$template->param(SONG_INFO => [@sorted]);

	print "Content-Type: text/html\n\n", $template->output;
}

#This function will decide which function to send it to
sub returnSearch {
	( my $search_for, my $search_by, my $more) = @_;
	my $ref;
	if ( $search_by eq "artist" ) {
		artist( $search_for, $search_by, $more);
	}
	elsif ( $search_by eq "song" ) {
		song( $search_for, $search_by, $more);
	}
	else {    #Default to Album
		album( $search_for, $search_by, $more);
	}

}

#All calls come through this point
my $query      = new CGI;
#Form data
my $search_for = $query->param("main-search-text");
my $search_by  = $query->param("main-search-by");
my $more       = $query->param("more");

if ( $search_for eq "" || $search_by eq "" ) {
	Helper::error("No Parameters Set in CGI");
}
else {
	#Send to helper function
	returnSearch( $search_for, $search_by, $more);
}
