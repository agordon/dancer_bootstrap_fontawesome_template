package examples::show_file;
use Dancer ':syntax';
use strict;
use warnings;
use File::Basename qw/fileparse/;

=pod
Meta example: showing source code of other examples
=cut

get '/show_file' => sub {
	my $filename = param 'file';
	my $example = param 'example';
	my $back_url = param 'url';

	if (! defined $filename || ! defined $example || ! defined $back_url) {
		return template 'examples/show_file', { show_error => "missing parameters. Don't call this page directly." };
	}

	my ($name,$path,$suffix) = fileparse($filename,".tt",".pm");
	if ( $suffix ne ".tt" && $suffix ne ".pm" ) {
		return template 'examples/show_file', { show_error => "Bad filename suffix" };
	}

	# Be strict about files to show - always look for them in the "examples" directories.
	my $appdir = config->{appdir};
	my $directory = ($suffix eq ".tt") ? "/views/examples/" : "/lib/examples/" ;
	my $fullpath = $appdir . $directory . $name . $suffix ;
	if (! -e $fullpath) {
		return template 'examples/show_file', { show_error => "File ($directory$name$suffix) doesn't exist." };
	}

	## Read the entire file
	if (! open FILE,"<",$fullpath ) {
		return template 'examples/show_file', { show_error => "Failed to open file ($fullpath): $!" };
	}
	my @lines = <FILE> ;
	close FILE;

	return template 'examples/show_file', {
			filename => $directory . $name . $suffix,
			example => $example,
			back_url => $back_url,
			source => join("",@lines)
		};
};

true;
