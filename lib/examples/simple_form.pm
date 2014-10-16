package examples::simple_form;
use Dancer ':syntax';
use strict;
use warnings;

=pod
This is a minimal example of using Bootstrap's <FORM> elements with Dancer's POST processing.

The <FORM> entry template is "./views/examples/simple_form_entry.tt".
If the user submitted a valid form, the results are showing using "./views/examples/simple_form_results.tt".
=cut

my @animals = qw/dogs cats camels mooses vogons/;

get '/simple_form' => sub {
	template 'examples/simple_form_entry', { animals => \@animals };
};

post '/simple_form' => sub {
	## Get the <FORM> CGI parameters
	my $username = param 'username' ;
	my $animal = param 'animal' ;
	my $magic = param 'magic' ;

	## Example: if the user submitted invalid data,
	## Show the form again, with a warning.
	## The template file has code that shows a warning <div> if this variable is set.
	$username =~ s/^\s*//;
	$username =~ s/\s*$//;
	if (length($username)==0) {
		return template 'examples/simple_form_entry', {
			show_warning => "Throw me a bone here, give me a name!",
			animals => \@animals };
	}
	if ($username eq "gordon") {
		return template 'examples/simple_form_entry', {
			show_warning => "Can't use that name. Try another.",
			animals => \@animals };
	}

	## If all OK, show the result of the <form>
	template 'examples/simple_form_results', {
			username => $username,
			animal => $animal,
			magic => $magic };
};

true;
