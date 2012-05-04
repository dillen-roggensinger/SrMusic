package MusicBrainzQuerier;

use strict;
use warnings;
use Data::Dumper;
use HTTP::Request;
use XML::Simple;
use URI::Escape;
use LWP::UserAgent;

#FOR REFERENCE
#http://musicbrainz.org/doc/XML_Web_Service/Version_2

#Usage: <offset>, domain>, <type>, <value>, <type>, <value> ...
#Example: 0, 'artist', 'alias', 'fred' <= searches for the alias fred under artists
#Returns: A wellformed query url
#Description: Creates a query string for the MusicBrainz XML based REST database
sub formulate_search_query {
	if (scalar @_ < 4 or scalar @_ % 2 != 0) {
		return undef;
	}
	my $offset = shift;
	my $domain = shift;
	my $type = shift;
	my $value = URI::Escape::uri_escape(shift);
	$value =~ s/%7C/|/g;
	my $url = "http://www.musicbrainz.org/ws/2/$domain/?query=$type:$value";
	while (@_) {
		$value = URI::Escape::uri_escape(shift(@_));
		$value =~ s/%7C/|/g;
		$url = "$url%20and%20" . shift(@_) . ":$value";
	}
	$url = "$url&offset=$offset&limit=100";
	return $url;
}

#Usage: <domain>, <id>, <optional info>, <optional info>, ...
#Example: 0, 'release','67d43db6-80dd-4e3f-adf1-53912c35f8e3','labels','recordings' <= searches for the song Lola by The Kinks with labels and recordings as additional info
#Returns: A wellformed query url
#Description: Creates a query string for the MusicBrainz XML based REST database using the lookup functionality
sub formulate_lookup_query {
	if (scalar @_ < 2) {
		return undef;
	}
	my $domain = shift;
	my $id = shift;
	my $url = "http://www.musicbrainz.org/ws/2/$domain/$id";
	if (scalar @_ > 0) {
		$url = "$url?inc=" . shift(@_);
		foreach (@_) {
			$url = "$url+$_"
		}
	}
	return $url;
}

#Usage: <offset>, domain>, <type>, <value>, <type>, <value> ...
#Example: 0, 'artist', 'alias', 'fred' <= searches for the alias fred under artists
#Returns: A wellformed query url
#Description: Creates a query string for the MusicBrainz XML based REST database
sub formulate_browse_query {
	if (scalar @_ < 4) {
		return undef;
	}
	my $offset = shift;
	my $domain = shift;
	my $given_domain = shift;
	my $id = shift;
	my $url = "http://www.musicbrainz.org/ws/2/$domain?$given_domain=$id";
	if (scalar @_ > 0) {
		$url = "$url?inc=" . shift(@_);
		foreach (@_) {
			$url = "$url+$_"
		}
	}
	$url = "$url&offset=$offset&limit=100";
	return $url;
}

#Usage: <url>
#Returns: the raw output of the HTTP request
#Description: executes a HTTP request with the url provided
sub execute_query {
	if (scalar @_ != 1) {
		return undef;
	}
	my $url = shift;
	my $request = HTTP::Request->new(GET=>"$url");
	my $ua = LWP::UserAgent->new;
	my $res = $ua->request($request);
	
	if ($res->is_success) {
		return $res->decoded_content;
	} else {
		return undef;
	}
}

#Usage: <url>
#Returns: a hash of results to their details
#Description: searches the provided artist name as an ALIAS (inorder to include and typos)
sub search {
	if (scalar @_ != 1) {
		return undef;
	}
	
	my $url = shift;
	my $output = execute_query($url);
	my $type;
	
	if (!defined($output)) {
		return {};
	}
	if ($output =~ m/(<metadata.*?><(.*?)-list.*?>.*<\/.*?-list><\/metadata>)/) {
		$output = $1;
		$type = $2;
	} else {
		return undef;
	}
	
	my $xs = XML::Simple->new();
	my $ref = $xs->XMLin("$output");

	
	return $ref->{"$type-list"}->{"$type"};
}

#Usage: <url>
#Returns: a hash of the result to their details
#Description: searches the provided artist name as an ALIAS (inorder to include and typos)
sub lookup {
	if (scalar @_ != 1) {
		return undef;
	}
	
	my $url = shift;
	my $output = execute_query($url);
	my $type;
	
	if (!defined($output)) {
		return {};
	}
	if ($output =~ m/(<metadata.*?><(.*?) .*<\/metadata>)/) {
		$output = $1;
		$type = $2;
	} else {
		return {};
	}
	
	my $xs = XML::Simple->new();
	my $ref = $xs->XMLin("$output");
	return $ref->{"$type"};
}

1;