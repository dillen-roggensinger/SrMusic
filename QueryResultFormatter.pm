package QueryResultFormatter;

use warnings;
use strict;
use MusicBrainzQuerier;
use Data::Dumper;

sub get_possible_artists {
	if (scalar @_ != 1) {
		print "Incorrect number of arguments\n";
		return {};
	}
	my $artist = shift;
	my $url = MusicBrainzQuerier::formulate_search_query('artist','alias',$artist);
	my $ref = MusicBrainzQuerier::search($url);
	my $artists_and_ids = {};
	foreach (keys %{$ref}){
		$artists_and_ids->{$ref->{$_}->{'id'}}=$ref->{$_}->{'sort-name'};
	}
	return $artists_and_ids;
}

sub get_possible_recordings {
	if (scalar @_ != 1) {
		print "Incorrect number of arguments\n";
		return {};
	}
	my $name = shift;
	my $url = MusicBrainzQuerier::formulate_search_query('recording','recording',$name,'type','single');
	my $ref = MusicBrainzQuerier::search($url);
	#print Dumper($ref);
	my $recordings_and_ids = {};
	print $recordings_and_ids;
	foreach my $id (keys %$ref){
		$recordings_and_ids->{$id} = {
			'artist' => $ref->{$id}->{'artist-credit'}->{'name-credit'},
			'title' => $ref->{$id}->{'title'},
			'album' => $ref->{$id}->{'release-list'}->{'release'}->{'title'},
			#'artist' => $ref->{$id}->{'artist-credit'}->{'name-credit'}->{'artist'}->{'sort-name'}
		};
	}
	return $recordings_and_ids;
}

sub get_possible_albums {
	
}

1;