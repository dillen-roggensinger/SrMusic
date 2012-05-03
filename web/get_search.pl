#!/usr/bin/perl
use warnings;
use strict;

#SrMusic Project
#Spring 2012
#author @epkatz

use HTML::Template;

my $template = HTML::Template->new( filename => 'templates/search.html' );
print "Content-Type: text/html\n\n", $template->output;
