#!/usr/bin/perl

use lib "../";
use warnings;
use strict;
use MusicBrainzQuerier;
use Data::Dumper;



my $url = MusicBrainzQuerier::formulate_search_query('artist','alias','michael');
print $url . "\n";
my $ref = MusicBrainzQuerier::search($url);
print "Number of args " . scalar keys %$ref;
print "\n";

print Dumper($ref);

#my $url = MusicBrainzQuerier::formulate_lookup_query('release','67d43db6-80dd-4e3f-adf1-53912c35f8e3','labels','recordings');

#my $ref = MusicBrainzQuerier::lookup($url);

#print Dumper($ref);