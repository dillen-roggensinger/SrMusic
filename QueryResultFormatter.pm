package QueryResultFormatter;

use warnings;
use strict;
use MusicBrainzQuerier;
use Data::Dumper;

#Usage: <recording> <OPTIONAL: starting offset> <OPTIONAL: max>
#Example: fred, 100, 200	<= Searches for the artist fred with a max of a 200 results, starting at the 101st result
#Returns: Hash of these:
#			id => {
#				'sort-name' =>
#				'ext:score' =>
#			}
#Description: Gets a 100 or <max> results that match the search. Max must be a multiple of 100.
sub get_possible_artists {
	if (scalar @_ < 1) {
		print "Incorrect number of arguments\n";
		return {};
	}
	my $artist = shift;
	my $offset = shift;
	my $max = shift;
	my $ref = {};
	my $artists_and_ids = {};
	if (!defined $offset) {
		$offset = 0;
	}
	if (!defined $max) {
		$max = $offset + 100;
	} else {
		$max = $offset + $max;
	}
	do {	#Loop through all the offsets until no more results are found
		my $url = MusicBrainzQuerier::formulate_search_query($offset, 'artist', 'alias', $artist);
		$ref = MusicBrainzQuerier::search($url);
		foreach (keys %{$ref}){
			$artists_and_ids->{$ref->{$_}->{'id'}} = {
				'sort-name' => $ref->{$_}->{'sort-name'},
				'ext:score' => $ref->{$_}->{'ext:score'} 
			};
		}
		$offset += 100;
	} while (scalar keys %$ref == 100 && $offset < $max);
	
	return $artists_and_ids;
}

#Usage: <recording> <OPTIONAL: starting offset> <OPTIONAL: max>
#Example: fred, 100, 200	<= Searches for the recording fred with a max of a 200 results, starting at the 101st result
#Returns: Hash of these:
#			'id' => {
#				'album' => {
#					'country' => 
#					'id' =>
#					'title' =>
#					'type' =>
#				}
#				'artists' => [
#					{
#						'artist' => {
#							'disambiguation' =>	NOT EVERY ARTIST HAS THIS
#							'sort-name' =>
#							'name' =>
#							'id' =>
#						}
#					}
#					{
#						'artist' => {
#							...
#						}
#					}
#					...
#				]
#				'title' =>
#				'ext:score' =>
#			}
#Description: Gets a 100 or <max> results that match the search. Max must be a multiple of 100.
sub get_possible_recordings {
	if (scalar @_ < 1) {
		print "Incorrect number of arguments\n";
		return {};
	}
	my $name = shift;
	my $offset = shift;
	my $max = shift;
	my $recordings_and_ids = {};
	my $ref = {};
	if (!defined $offset) {
		$offset = 0;
	}
	if (!defined $max) {
		$max = $offset + 100;
	} else {
		$max = $offset + $max;
	}
	do {	#Loop through all the offsets until no more results are found
		my $url = MusicBrainzQuerier::formulate_search_query($offset, 'recording','recording',$name);
		$ref = MusicBrainzQuerier::search($url);
		foreach my $id (keys %$ref){
			$recordings_and_ids->{$id} = {
				'artists' => [$ref->{$id}->{'artist-credit'}->{'name-credit'}],
				'title' => $ref->{$id}->{'title'},
				'album' => {
					'country' => $ref->{$id}->{'release-list'}->{'release'}->{'country'},
					'date' => $ref->{$id}->{'release-list'}->{'release'}->{'date'},
					'type' => $ref->{$id}->{'release-list'}->{'release'}->{'release-group'}->{'type'},
					'title' => $ref->{$id}->{'release-list'}->{'release'}->{'title'},
					'id' => $ref->{$id}->{'release-list'}->{'release'}->{'id'},
				},
				'ext:score' => $ref->{$id}->{'ext:score'}
			};
		}
		$offset += 100;
	} while (scalar keys %$ref == 100 && $offset < $max);
	
	return $recordings_and_ids;
}

#Usage: <album> <OPTIONAL: starting offset> <OPTIONAL: max>
#Example: fred, 100, 200 <= Searches for the album fred with a max of a 200 results, starting at the 101st result
#Returns: Hash of these:
#			'id' => {
#				'type' =>
#				'artists' => [
#					{
#						'artist' => {
#							'disambiguation' =>	NOT EVERY ARTIST HAS THIS
#							'sort-name' =>
#							'name' =>
#							'id' =>
#						}
#					}
#					{
#						'artist' => {
#							...
#						}
#					}
#					...
#				],
#				'title' =>
#				'ext:score' =>
#			}
#Description: Gets a 100 or <max> results that match the search. Max must be a multiple of 100.
sub get_possible_albums {
	if (scalar @_ < 1) {
		print "Incorrect number of arguments\n";
		return {};
	}
	my $name = shift;
	my $offset = shift;
	my $max = shift;
	my $recordings_and_ids = {};
	my $ref = {};
	if (!defined $offset) {
		$offset = 0;
	}
	if (!defined $max) {
		$max = $offset + 100;
	} else {
		$max = $offset + $max;
	}
	do {	#Loop through all the offsets until no more results are found
		my $url = MusicBrainzQuerier::formulate_search_query($offset, 'release-group','release-group',$name,'type','album|compilation|soundtrack|live');
		$ref = MusicBrainzQuerier::search($url);
		foreach my $id (keys %$ref){
			$recordings_and_ids->{$id} = {
				'artists' => [$ref->{$id}->{'artist-credit'}->{'name-credit'}],
				'title' => $ref->{$id}->{'title'},
				'ext:score' => $ref->{$id}->{'ext:score'},
				'type' => $ref->{$id}->{'type'}
			};
		}
		$offset += 100;
		print "Iteration $offset\n";
	} while (scalar keys %$ref == 100 && $offset < $max);
	
	return $recordings_and_ids;
}

1;