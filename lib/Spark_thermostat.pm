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
use DateTime::Format::ISO8601;

our $VERSION = '0.1';

my $cfg = new Config::Simple('../utilities/spark_core_info.cfg');
my %spark_core_props = (device_ID => $cfg->param('device_ID'), 
	access_token => $cfg->param('access_token'));

get '/' => sub {
	my @image_set = <../public/images/*.jpg>;
	@image_set = map { basename($_) } @image_set;

	my $parser = Text::CSV::Simple->new;
	my @data = $parser->read_file('../utilities/last_min.csv');
	
	my @last_data = @{$data[-1]};

	my $relay_status = 'Off';
	$relay_status = 'On' if ($last_data[3]);
	
	my $relay_color = '"red"';
	if ($relay_status eq 'On') {
		$relay_color = '"Green"';
	}

	my $dt = DateTime::Format::ISO8601->parse_datetime($last_data[0]);	
	$dt->set_time_zone('UTC');
	$dt->set_time_zone('EST');
	
    template 'index', { 
		'freezer_temp' => $last_data[1],
		'outside_temp' => $last_data[2],
		'target_temp' => $last_data[4],
		'relay_status' => $relay_status,
		'relay_color' => $relay_color,
		'image_set' => \@image_set,
		'last_time' => $dt->month() . "/" . $dt->day() ." " . $dt->hms,
	};
};

post '/' => sub {
	my @image_set = <../public/images/*.jpg>;
	@image_set = map { basename($_) } @image_set;

	my $parser = Text::CSV::Simple->new;
	my @data = $parser->read_file('../utilities/last_min.csv');
	
	my @last_data = @{$data[-1]};
	
	my $relay_status = 'Off';
	$relay_status = 'On' if ($last_data[3]);
	
	my $relay_color = '"red"';
	if ($relay_status eq 'On') {
		$relay_color = '"Green"';
	}
	
	my $dt = DateTime::Format::ISO8601->parse_datetime($last_data[0]);	
	$dt->set_time_zone('UTC');
	$dt->set_time_zone('EST');
	
	#Relay Control
	my $cfg = new Config::Simple('../lib/password.cfg') or die "$!";
	
	my $settings_update_msg = '';
	my $alert_class = '';
	my $password_match = 0;

	if (not(passphrase(params->{'password'})->matches($cfg->param('hash_pass')))) {
		$settings_update_msg .= 'Password doesn\'t match, no change made in settings.<br/>';
		$alert_class = "alert-danger";
	} else {
		$settings_update_msg .= 'Success, mode updated.';
		$alert_class = "alert-success";
		$password_match = 1;
	}
	
	# if (params->{'mode'} eq 'Constant') {
	# 	if (params->{'targetTemp'} < 32) {
	# 		$settings_update_msg .= 'Can\'t set temperature below 32.<br/>';
	# 	}
	# } elsif (params->{'mode'} eq 'Ramp') {
	# 	if (params->{'rampTime'} < 0.5) {
	# 		$settings_update_msg .= 'Can\'t set temperature below 32.<br/>';
	# 	}
	# }
	
	if ($password_match) {
		if (params->{'mode'} eq 'Constant') {
			if (not(params->{'targetTemp'} eq '')) {
				&setConstMode(params->{'targetTemp'});
			}
		} elsif (params->{'mode'} eq 'Ramp') {
			if (not(params->{'rampStart'} eq '') && not(params->{'rampEnd'} eq '') &&
				not(params->{'rampTime'} eq '')) {
				&setRampMode(params->{'rampStart'},params->{'rampEnd'},params->{'rampTime'});
			}
		}
	}

    template 'index', { 
		'freezer_temp' => $last_data[1],
		'outside_temp' => $last_data[2],
		'target_temp' => $last_data[4],
		'last_time' => $dt->month() . "/" . $dt->day() ." " . $dt->hms,
		'relay_status' => $relay_status,
		'relay_color' => $relay_color,
		'image_set' => \@image_set,
		'alert_message' => $settings_update_msg,
		'alert_class' => $alert_class,
	};
};

get '/archive' => sub {

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	#mon is returned as 0-11, so bump it up by one for the filename
	$mon++;
	
	#year is stored as years since 1900
	$year += 1900;
	
    template 'archive', {
		'suggested_name' => "BEER_NAME_$year-$mon-$mday.zip"
	};
};

post '/archive' => sub {
}; 

###############################################################################
# Functions
###############################################################################

#Constant mode setting functions
sub setConstMode {
	my $temp_target = shift;
	
	my %cmd_props = %spark_core_props;
	$cmd_props{args} = $temp_target;
	$cmd_props{cmd} = "setConstMode";

	my $command = &makeSparkFuncRequest(%cmd_props);	
	# warning $command;
	system("$command > /dev/null 2> /dev/null");
}

#Ramp mode setting functions
sub setRampMode {
	my ($rampStartTemp,$rampEndTemp,$rampDays) = @_;
	
	my %cmd_props = %spark_core_props;
	$cmd_props{args} = "$rampStartTemp,$rampEndTemp,$rampDays";
	$cmd_props{cmd} = "setRampMode";

	my $command = &makeSparkFuncRequest(%cmd_props);	
	# warning $command;
	system("$command > /dev/null 2> /dev/null");
}

sub makeSparkFuncRequest {
	my %props = @_;

	my $command = "curl --silent \"https://api.spark.io/v1/devices/$props{device_ID}/$props{cmd}\"";
	$command .= " -d access_token=$props{access_token}";
	if (defined $props{args}) {
		$command .= " -d 'args=$props{args}'";
	} else {
		$command .= " -d 'args=junk'";
	}
	return $command;
}

true;
