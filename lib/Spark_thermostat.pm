package Spark_thermostat;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;
use File::Basename;
use Text::CSV::Simple;
use Data::Dumper;

our $VERSION = '0.1';

get '/' => sub {
	my @image_set = <../public/images/*.jpg>;
	@image_set = map { basename($_) } @image_set;

	my $parser = Text::CSV::Simple->new;
	my @data = $parser->read_file('../utilities/temperature_data.csv');
	
	my @last_data = @{$data[-1]};
	
	my $relay_status = 'Off';
	$relay_status = 'On' if ($last_data[3]);
	
	my $relay_color = '"red"';
	if ($relay_status eq 'On') {
		$relay_color = '"Green"';
	}

	warning Dumper(\@last_data);

    template 'index', { 
		'freezer_temp' => $last_data[1],
		'outside_temp' => $last_data[2],
		'target_temp' => $last_data[4],
		'relay_status' => $relay_status,
		'relay_color' => $relay_color,
		'image_set' => \@image_set,
	};
};

true;
