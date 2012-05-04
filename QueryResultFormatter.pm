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
	} while (scalar keys %$ref == 100 && $offset < $max);
	
	return $recordings_and_ids;
}

#Usage: <domain> <recording id>
#Example: 'recording' d0bd2a62-5dd8-49bf-ae51-8872a49184c0 <= Layla by Eric Clapton
#Return: <release-group id>
#Description: Gets the release-group id, given a domain and id
sub get_artist_id {
	if (scalar @_ != 2) {
		return {};
	}
	my $domain = shift;
	my $id = shift;

	my $url = MusicBrainzQuerier::formulate_browse_query(0, 'artist', $domain, $id);
	my $ref = MusicBrainzQuerier::search($url);
	return $ref->{'id'};
}

#Usage: <artist id>
#Example: 618b6900-0618-4f1e-b835-bccb17f84294 <= Eric Clapton
#Return:
#			id => {
#				first-release-date =>
#				type =>
#				title =>
#			}
#Description: Gets all the release groups given an artist id
sub get_albums {
	if (scalar @_ < 1) {
		return {};
	}
	my $id = shift;
	my $offset = shift;
	if (!defined $offset) {
		$offset = 0;
	}

	my $url = MusicBrainzQuerier::formulate_browse_query($offset, 'release-group', 'artist', $id);
	my $ref = MusicBrainzQuerier::search($url);
	return $ref;
}

#Usage: <release-group id>
#Example: 02c2b0c7-065d-38b4-8ac0-3391839f2418 <= Eric Clapton's Slow Hand
#Return: <release id>
#Description: Gets the release id, given a release group
sub get_release_id {
	if (scalar @_ < 1) {
		return {};
	}
	my $id = shift;
	
	my $url = MusicBrainzQuerier::formulate_browse_query(0, 'release', 'release-group', $id);
	my $ref = MusicBrainzQuerier::search($url);
	
	#Just take one of the releases, they should all have the same amount of content
	if (defined $ref->{'id'}) {	#Single result
		return $ref->{'id'};
	}
	foreach (keys %$ref) {	#Multiple results
		return $_;
	}
}

#Usage: <release-group id>
#Example: 02c2b0c7-065d-38b4-8ac0-3391839f2418 <= Eric Clapton's Slow Hand
#Return:
#			id => {
#				length =>
#				title =>
#			}
#Description: Gets all the recordings in a release group
sub get_songs {
	if (scalar @_ < 1) {
		return {};
	}
	my $id = shift;
	my $offset = shift;
	if (!defined $offset) {
		$offset = 0;
	}

	$id = get_release_id($id);
	my $url = MusicBrainzQuerier::formulate_browse_query(0, 'recording', 'release', $id);
	my $ref = MusicBrainzQuerier::search($url);
	return $ref;
}

#Usage: <recording id>
#Example: d0bd2a62-5dd8-49bf-ae51-8872a49184c0 <= Layla by Eric Clapton
#Return:
#			name => {
#				all types of shit =>
#				id =>
#			}
#Description: Gets all the artists that sung a song
sub get_artists {
	if (scalar @_ < 1) {
		return {};
	}
	my $id = shift;
	my $offset = shift;
	if (!defined $offset) {
		$offset = 0;
	}

	my $url = MusicBrainzQuerier::formulate_browse_query($offset, 'artist', 'recording', $id);
	my $ref = MusicBrainzQuerier::search($url);
	
	#Just take one of the releases, they should all have the same amount of content
	if (defined $ref->{'id'}) {	#Single result
		return {
			$ref->{'id'} => $ref
		};
	}
	return $ref;
}

1;