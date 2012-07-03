package examples::TODO_NAME_OF_EXAMPLE
use Dancer ':syntax';
use strict;
use warnings;

=pod
This is a minimal stub for a Dancer/Bootstrap example page.

To create a new example:
1. Copy this file to a new module
2. Change all the "TODO_" strings in the file.
3. Add "use examples::NAME_OF_EXAMPLE" to "./lib/dancer_bootstrap_fontawesome_template.pm"
4. Create a new template file in "./views/examples" based on "./views/examples/example_stub.tt"
5. Add any additional code necessary.

=cut

get '/TODO_URL_OF_EXAMPLE' => sub {
	template 'examples/TODO_NAME_OF_TEMPLATE';
};

true;
