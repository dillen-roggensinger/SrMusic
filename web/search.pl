#!/usr/bin/perl
use warnings;
use strict;

use CGI::Carp qw(fatalsToBrowser);
use HTML::Template;

#Simple Search Page which acts as the home page
my $template = HTML::Template->new( filename => 'templates/search.html' );
print "Content-Type: text/html\n\n", $template->output;



