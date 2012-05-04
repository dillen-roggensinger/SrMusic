#!/usr/bin/perl

use lib "../";
use warnings;
use strict;
use QueryResultFormatter;
use Data::Dumper;
use URI::Escape;

#my $hash = QueryResultFormatter::get_possible_artists('LMFAO');
#print Dumper($hash);

#my $hash = QueryResultFormatter::get_possible_recordings('under pressure');
#print Dumper($hash);

#my $hash = QueryResultFormatter::get_possible_albums('take off your pants and jacket');
#print Dumper($hash);

#my $id = QueryResultFormatter::get_artist_id('recording', 'd0bd2a62-5dd8-49bf-ae51-8872a49184c0');
#print Dumper($id);

#my $id = QueryResultFormatter::get_release_id('02c2b0c7-065d-38b4-8ac0-3391839f2418');
#print Dumper($id);

my $hash = QueryResultFormatter::get_albums('f46bd570-5768-462e-b84c-c7c993bbf47e');
print Dumper($hash);

#my $hash = QueryResultFormatter::get_songs('d33aadd5-bcc2-3531-b96d-378da2e04a4e'); #f5201f3a-aea3-3f19-93d9-d89d3d976f67 02c2b0c7-065d-38b4-8ac0-3391839f2418
#print Dumper($hash);

#my $hash = QueryResultFormatter::get_artists('d0bd2a62-5dd8-49bf-ae51-8872a49184c0');
#print Dumper($hash);
