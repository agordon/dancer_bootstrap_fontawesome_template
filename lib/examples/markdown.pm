package examples::markdown;
use Dancer ':syntax';
use strict;
use warnings;

my $have_text_markdown = 1 ;
eval {
	require Text::Markdown;
	require Template::Plugin::Markdown;
};
if ($@) {
	$have_text_markdown = 0 ;
};

=pod
Example of using "Text::Markdown" to render text to HTML.

NOTE:
1. "Text::Markdown" and "Template::Plugin::Markdown" are loaded dynamically,
   and if not found/not installed, this example still works (but rendering is not done).
   This allows users running the example Dancer/Bootstrap website without
   installing "Text::Markdown".

   In a production web-site, you can just require the installation of those modules,
   and skip this check.

2. The actual rendering is done *in the template file*, using the "Markdown" Filter.

=cut

my $markdown_text=<<EOF;

Hello From Markdown Text
========================

Features
--------

* All standard Markdown features, such as
     * lists
     * headings
     * *bold*, _italics_, **strong bold**
     * code
     * Links

Syntax
------

* [Basic Usage](http://daringfireball.net/projects/markdown/basics)
* [Full Syntax](http://daringfireball.net/projects/markdown/syntax)
* [Wikipedia Page](http://en.wikipedia.org/wiki/Markdown)

EOF

get '/markdown' => sub {
	template 'examples/markdown', {
				have_text_markdown => $have_text_markdown,
				text => $markdown_text
			};
};

true;
