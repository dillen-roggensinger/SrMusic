package MusicBrainzQuerier;

use strict;
use warnings;
use HTTP::Request;
use XML::Simple;

#Usage: <domain>,type>,<value>
#Example: artist, alias, fred <= searches for the alias fred under artists
#Returns: A wellformed query url
#Description: Creates a query string for the MusicBrainz XML based REST database
sub formulate_search_query {
	if (scalar @_ != 3) {
		print "Incorrect number of args\n";
		return undef;
	}
	my $domain = shift;
	my $type = shift;
	my $value = shift;
	return "http://www.musicbrainz.org/ws/2/$domain/?query=$type:$value";
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
		print STDERR $res->status_line, "<br>";
		return undef;
	}
}

#Usage: <url>
#Returns: a hash of artist names to their information
#Description: searches the provided artist name as an ALIAS (inorder to include and typos)
sub search {
	if (scalar @_ != 1) {
		return undef;
	}
	
	my $url = shift;
	my $output = execute_query($url);
	
	if (!defined($output)) {
		return {};
	}
	if ($output =~ m/(<metadata.*?><.*?-list.*?>.*<\/.*?-list><\/metadata>)/) {
		$output = $1;
	} else {
		print "Invalid query";
		return undef;
	}
	
	
	my $xs = XML::Simple->new();
	my $ref = $xs->XMLin("$output");
	return $ref->{'artist-list'}->{'artist'};
}


1;