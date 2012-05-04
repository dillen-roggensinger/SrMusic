#!/usr/bin/perl

use lib "../";
use warnings;
use strict;
use QueryResultFormatter;
use Data::Dumper;
use URI::Escape;

#my $hash = QueryResultFormatter::get_possible_artists('neon trees');
#print Dumper($hash);

#my $hash = QueryResultFormatter::get_possible_recordings('layla');
#print Dumper($hash);

#my $hash = QueryResultFormatter::get_possible_albums('take off your pants and jacket');
#print Dumper($hash);

my $id = QueryResultFormatter::get_artist('recording', 'd0bd2a62-5dd8-49bf-ae51-8872a49184c0');
print Dumper($id);

my $hash = QueryResultFormatter::get_albums('618b6900-0618-4f1e-b835-bccb17f84294');
print Dumper($hash);