#!/usr/bin/perl

use lib "../";
use warnings;
use strict;
use QueryResultFormatter;
use Data::Dumper;

#my $hash = QueryResultFormatter::get_possible_artists('bruce');
#print Dumper($hash);

my $hash = QueryResultFormatter::get_possible_recordings('layla');
print Dumper($hash);

#my $hash = QueryResultFormatter::get_possible_albums('take off your pants and jacket');
#print Dumper($hash);
