#!/usr/bin/perl
use warnings;
use strict;

use HTML::Template;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use lib "../";
use Helper;
use QueryResultFormatter;


my $query      = new CGI;
my $search_for = $query->param("main-search-text");
my $search_by  = $query->param("main-search-by");

if ( $search_for eq "" || $search_by eq "" ) {
	Helper::error("No Parameters Set in CGI");
}
else {
	returnSearch( $search_for, $search_by );
}