package Helper;

use warnings;
use strict;

#SrMusic Project
#Spring 2012
#author @epkatz



sub error {
	my $error = shift;
	my $template = HTML::Template->new( filename => 'templates/error.html' );
	$template->param(ERROR => $error);
	print "Content-Type: text/html\n\n", $template->output;	
}

1;