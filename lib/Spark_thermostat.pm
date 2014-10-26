package Spark_thermostat;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;
use File::Basename;
use Text::CSV::Simple;
use Dancer::Plugin::Passphrase;
use Data::Dumper;
use Config::Simple;

our $VERSION = '0.1';

my $cfg = new Config::Simple('../utilities/spark_core_info.cfg');
my $device_ID = $cfg->param('device_ID');
my $access_token = $cfg->param('access_token');

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

    template 'index', { 
		'freezer_temp' => $last_data[1],
		'outside_temp' => $last_data[2],
		'target_temp' => $last_data[4],
		'relay_status' => $relay_status,
		'relay_color' => $relay_color,
		'image_set' => \@image_set,
	};
};

post '/' => sub {
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
	
	my $cfg = new Config::Simple('../lib/password.cfg') or die "$!";
	
	my $warning_message = '';

	if (not(passphrase(params->{'password'})->matches($cfg->param('hash_pass')))) {
		$warning_message .= 'Password doesn\'t match, no change made in settings.<br/>';
	}
	
	if (params->{'mode'} eq 'Constant') {
		if (params->{'targetTemp'} < 32) {
			$warning_message .= 'Can\'t set temperature below 32.<br/>';
		}
	} elsif (params->{'mode'} eq 'Ramp') {
		if (params->{'rampTime'} < 0.5) {
			$warning_message .= 'Can\'t set temperature below 32.<br/>';
		}
	}

    template 'index', { 
		'freezer_temp' => $last_data[1],
		'outside_temp' => $last_data[2],
		'target_temp' => $last_data[4],
		'relay_status' => $relay_status,
		'relay_color' => $relay_color,
		'image_set' => \@image_set,
	};
	
	if (params->{'mode'} eq 'Constant') {

	} elsif (params->{'mode'} eq 'Ramp') {
	}
};

###############################################################################
# Functions
###############################################################################

sub setConstantMode {
	my $command = `curl --silent "https://api.spark.io/v1/devices/$device_ID/setConstMode?access_token=$access_token"`;
	system('$command');
}

sub setRampMode {
	my $command = `curl --silent "https://api.spark.io/v1/devices/$device_ID/setConstMode?access_token=$access_token"`;
	system('$command');
}

true;
