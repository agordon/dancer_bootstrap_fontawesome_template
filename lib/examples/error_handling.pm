package examples::error_handling;
use Dancer ':syntax';
use strict;
use warnings;

=pod
This module demonstrates Dancer's error handling capabilities, in development and production modes.

=cut

get '/error_handling' => sub {
	template 'examples/error_handling';
};

post '/error_handling' => sub {
	my $show_errors = param 'showerrors';
	print STDERR "show_errors = $show_errors\n";
	$show_errors = 1 unless $show_errors eq "0";

=pod
NOTE:
 In a real project, you should never set "show_errors" like this.
 Set it properly in both "./environments/development.yml" and
 ./environments/production.yml" .
=cut
	set show_errors => $show_errors;
	die "Oops, I did it again";
};

true;
