#!/usr/bin/perl
use warnings;
use strict;

use CGI::Carp qw(fatalsToBrowser);
use HTML::Template;

my $template = HTML::Template->new( filename => 'templates/search.html' );
print "Content-Type: text/html\n\n", $template->output;



