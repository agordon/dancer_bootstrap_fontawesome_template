package examples::photo_gallery;
use Dancer ':syntax';
use strict;
use warnings;

=pod
Example of using Bootstrap's Photo-Carousel and Thumbnails components.

NOTE:
  The images are stored in "./public/images/gallery",
  which is available as "[% request.uri_base %]/images/gallery/" URL.
  If you put them in a different location, modify the template accordingly.
=cut

my @photos = (
	{
		file => "cshl13.jpg",
		caption => "Fall",
		text => "View from accross Cold Spring Harbor",
	},
	{
		file => "cshl12.jpg",
		caption => "Fall",
		text => "Cold Spring Harbor Campus",
	},
	{
		file => "cshl11.jpg",
		caption => "Winter",
		text => "View of the Cold Spring (frozen) harbor",
	},
	{
		file => "cshl3.jpg",
		caption => "Summer Dusk",
		text => "Cold Spring Harbor",
	},
	{
		file => "cshl6.jpg",
		caption => "Spring",
		text => "Cold Spring Harbor Campus",
	},
	{
		file => "cshl8.jpg",
		caption => "Onley House",
		text => "Cold Spring Harbor Campus",
	},
);

get '/photo_carousel' => sub {
	template 'examples/photo_carousel', { photos => \@photos };
};

get '/photo_grid' => sub {
	template 'examples/photo_grid', { photos => \@photos };
};

true;
