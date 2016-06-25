package Spark_thermostat;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;
use File::Basename;
use File::Copy;
use File::Path;
use Text::CSV::Simple;
use Dancer::Plugin::Passphrase;
use Data::Dumper;
use Config::Simple;
use DateTime::Format::ISO8601;
use Statistics::Descriptive;

#Other pages/functions in the rest of the app
use shared_functions;
use Archive;
use Calculators;

our $VERSION = '0.1';

my $cfg = new Config::Simple('../utilities/spark_core_info.cfg') or die $!;
my %spark_core_props = (device_ID => $cfg->param('device_ID'), 
	access_token => $cfg->param('access_token'));

hook 'before' => sub {
	my @image_set = <../public/images/day*.jpg>;
	@image_set = reverse map { basename($_) } @image_set;
	@image_set = $image_set[0];
	$image_set[1] = "week.jpg";
	var image_set => \@image_set;
	
	my $parser = Text::CSV::Simple->new;
	my @last_data;
	if (-e '../utilities/last_min.csv') {
		@last_data = $parser->read_file('../utilities/last_min.csv');
		@last_data = @{$last_data[-1]};
		var recordingEnabled => 1;
	} else {
		#Fake data for the cases when there isn't a data file available, format:
		#	-Date,Freezer Temp,Outside Temp,Relay Status,Target Temp
		@last_data = ("2015-01-06T19:13:01.629Z","NA","NA",0,"NA");
		var recordingEnabled => 0;
	}
	
	$parser = Text::CSV::Simple->new;
	my @last_hour;
	if (-e '../utilities/last_hour.csv') {
		@last_hour = $parser->read_file('../utilities/last_hour.csv');
		my $stat = Statistics::Descriptive::Full->new();
		foreach my $i (1..$#last_hour) {
			$stat->add_data($last_hour[$i][1]);
		}
		var hourMean => sprintf('%0.1f',$stat->mean);
	} else {
		var hourMean => "NA";
	}
	
	var last_data => \@last_data;

	var relay_status => 'Off';
	var relay_status => 'On' if ($last_data[3]);

	var relay_color => '"red"';
	if (vars->{relay_status} eq 'On') {
		var relay_color => '"Green"';
	}
	
	my $dt = DateTime::Format::ISO8601->parse_datetime($last_data[0]) or die $!;	
	$dt->set_time_zone('UTC');
	$dt->set_time_zone('local');

	var last_time => $dt->month() . "/" . $dt->day() ." " . $dt->hms;
};

get '/' => sub {
    template 'index', { 
		freezer_temp => vars->{last_data}[1],
		outside_temp => vars->{last_data}[2],
		target_temp => vars->{last_data}[4],
		relay_status => vars->{relay_status},
		relay_color => vars->{relay_color},
		image_set => vars->{image_set},
		last_time => vars->{last_time},
		hourMean => vars->{hourMean},
		recordingEnabled => vars->{recordingEnabled},
	};
};

post '/' => sub {
	#Relay Control
	my $cfg = new Config::Simple('../lib/password.cfg') or die "$!";
	
	my %password_info = &verifyPassword(params->{'password'}, $cfg->param('hash_pass'));
	
	if ($password_info{match}) {
		if (defined params->{'enableRecording'}) {
			&enableRecording;
		} else {
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
		$password_info{update_message} = 'Success, mode updated.';
	} else {
		$password_info{update_message} = 'Password doesn\'t match, no change made in settings.<br/>';
	}

    template 'index', { 
		freezer_temp => vars->{last_data}[1],
		outside_temp => vars->{last_data}[2],
		target_temp => vars->{last_data}[4],
		relay_status => vars->{relay_status},
		relay_color => vars->{relay_color},
		image_set => vars->{image_set},
		last_time => vars->{last_time},
		hourMean => vars->{hourMean},
		
		alert_message => $password_info{update_message},
		alert_class => $password_info{alert_class},
	};
};

###############################################################################
# Functions
###############################################################################

#######################################
# Spark Control Functions
#######################################
sub setConstMode {
	my $temp_target = shift;
	
	my %cmd_props = %spark_core_props;
	$cmd_props{args} = $temp_target;
	$cmd_props{cmd} = "setConstMode";

	my $command = &makeSparkFuncRequest(%cmd_props);	
	# warning $command;
	system("$command > /dev/null 2> /dev/null");
}

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
