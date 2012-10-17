package examples::dynamic_content;
use Dancer ':syntax';
use strict;
use warnings;
use POSIX qw(strftime);
use Data::Dumper;

=pod
This module demonstrates returning dynamic content to the user from a Dancer route handler.

The data is generated on-line, without having to temporarily store it in a file or in memory.
=cut

# Show the main page to the user
get '/dynamic_content' => sub {
	template 'examples/dynamic_content.tt';
};


=pod
  Return dynamic content to the user.
  The content is generated on-line, not from a stored file or a memory buffer.
  Common usage examples:
     Returning the results of a "select * from TABLE" query, without storing the results in a temporary file.


  Couple of technical notes:
     1. send_file() documentation:
           https://metacpan.org/module/Dancer#send_file

     2. send_file was originally designed to send either physical files, or in-memory scalars.
        The streaming option was added later - so some hacks are required.

     3. The "override" callback will take care of all data sent to the user/front-end-HTTP-server,
        and so the first parameter to 'send_file' doesn't matter
        (just needs to be a scalar-ref, otherwise it will be mistaken for a file-name).

     4. The "$respond" parameter is a PSGI-related opaque object. Use it to generate the 'writer' object.

     5. The "$response" parameter is the original Dancer::Response object that Dancer generated.
        Can be safely ignored, as we generate our own response.

=cut
get '/dynamic_content_download' => sub {
	send_file(
		\"foo", # anything, as long as it's a scalar-ref
		streaming => 1, # enable streaming
		callbacks => {
			override => sub {
				my ( $respond, $response ) = @_;


				my $http_status_code = 200 ;
				# Tech.note: This is a hash of HTTP header/values, but the
				#            function below requires an even-numbered array-ref.
				my @http_headers = ( 'Content-Type' => 'text/plain',
						     'Content-Disposition' => 'attachment; filename="foo.txt"',

						     # Since this is dynamic content,
						     # try hard (with extra HTTP headers) to prevent caching.
						     'Last-Modified' => strftime("%a, %d %b %Y %H:%M:%S GMT", gmtime),
						     'Expires' => 'Tue, 03 Jul 2001 06:00:00 GMT',
						     'Cache-Control' => 'no-store, no-cache, must-revalidate, max-age=0',
						     'Pragma' => 'no-cache' );

				# Send the HTTP headers
				# (back to either the user or the upstream HTTP web-server front-end)
				my $writer = $respond->( [ $http_status_code, \@http_headers ] );

				# Generate a lot of text...
				foreach my $line_number ( 1 .. 1000000 ) {
					$writer->write("Hello World (line $line_number)\n");
				}
			},
		},
	);
};


true;
