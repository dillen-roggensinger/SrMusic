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
	my $offset = 0;
	my $ref = {};
	my $artists_and_ids = {};
	do {	#Loop through all the offsets until no more results are found
		my $url = MusicBrainzQuerier::formulate_search_query($offset, 'artist','alias',$artist);
		$ref = MusicBrainzQuerier::search($url);
		foreach (keys %{$ref}){
			$artists_and_ids->{$ref->{$_}->{'id'}}=$ref->{$_}->{'sort-name'};
		}
		$offset += 25;
	} while (scalar keys %$ref == 25);
	
	return $artists_and_ids;
}

#artist, song name, release year, album name
sub get_possible_recordings {
	if (scalar @_ != 1) {
		print "Incorrect number of arguments\n";
		return {};
	}
	my $name = shift;
	my $recordings_and_ids = {};
	my $ref = {};
	my $offset = 0;
	
	do {	#Loop through all the offsets until no more results are found
		my $url = MusicBrainzQuerier::formulate_search_query($offset, 'recording','recording',$name);
		$ref = MusicBrainzQuerier::search($url);
		foreach my $id (keys %$ref){
			$recordings_and_ids->{$id} = {
				'artists' => [$ref->{$id}->{'artist-credit'}->{'name-credit'}],
				'title' => $ref->{$id}->{'title'},
				'album' => {
					'country' => $ref->{$id}->{'release-list'}->{'release'}->{'country'},
					'country' => $ref->{$id}->{'release-list'}->{'release'}->{'date'},
					'type' => $ref->{$id}->{'release-list'}->{'release'}->{'release-group'}->{'type'},
					'title' => $ref->{$id}->{'release-list'}->{'release'}->{'title'},
					'id' => $ref->{$id}->{'release-list'}->{'release'}->{'id'},
				}
			};
		}
		$offset += 25;
		print "Iteration $offset\n";
	} while (scalar keys %$ref == 25);
	
	return $recordings_and_ids;
}

sub get_possible_albums {
	
}

1;