package examples::template_plugins;
use Dancer ':syntax';
use strict;
use warnings;

=pod
Show-case Template::Toolkit's Template::Plugins::* plugins.
There's no Dancer code involved - all is done in the template itself.
=cut

get '/template_plugins' => sub {
	template 'examples/template_plugins';
};

true;
