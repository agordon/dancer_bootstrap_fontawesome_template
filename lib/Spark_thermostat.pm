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

our $VERSION = '0.1';

my $cfg = new Config::Simple('../utilities/spark_core_info.cfg');
my %spark_core_props = (device_ID => $cfg->param('device_ID'), 
	access_token => $cfg->param('access_token'));

hook 'before' => sub {
	my @image_set = <../public/images/*.jpg>;
	@image_set = reverse map { basename($_) } @image_set;
	@image_set = @image_set[0];
	var image_set => \@image_set;
	
	my $parser = Text::CSV::Simple->new;
	my @data = $parser->read_file('../utilities/last_min.csv');
	
	my @last_data = @{$data[-1]};
	
	var last_data => \@last_data;

	var relay_status => 'Off';
	var relay_status => 'On' if ($last_data[3]);

	var relay_color => '"red"';
	if (vars->{relay_status} eq 'On') {
		var relay_color => '"Green"';
	}

	my $dt = DateTime::Format::ISO8601->parse_datetime($last_data[0]);	
	$dt->set_time_zone('UTC');
	$dt->set_time_zone('EST');

	var last_time => $dt->month() . "/" . $dt->day() ." " . $dt->hms;
};

get '/' => sub {
	
    template 'index', { 
		'freezer_temp' => vars->{last_data}[1],
		'outside_temp' => vars->{last_data}[2],
		'target_temp' => vars->{last_data}[4],
		'relay_status' => vars->{relay_status},
		'relay_color' => vars->{relay_color},
		'image_set' => vars->{image_set},
		'last_time' => vars->{last_time},
	};
};

post '/' => sub {
	#Relay Control
	my $cfg = new Config::Simple('../lib/password.cfg') or die "$!";
	
	my %password_info = &verifyPassword(params->{'password'}, $cfg->param('hash_pass'));
	
	if ($password_info{match}) {
		$password_info{update_message} = 'Success, mode updated.';
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
	} else {
		$password_info{update_message} = 'Password doesn\'t match, no change made in settings.<br/>';
	}

    template 'index', { 
		'freezer_temp' => vars->{last_data}[1],
		'outside_temp' => vars->{last_data}[2],
		'target_temp' => vars->{last_data}[4],
		'relay_status' => vars->{relay_status},
		'relay_color' => vars->{relay_color},
		'image_set' => vars->{image_set},
		'last_time' => vars->{last_time},
		
		'alert_message' => $password_info{update_message},
		'alert_class' => $password_info{alert_class},
	};
};

get '/archive' => sub {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	#mon is returned as 0-11, so bump it up by one for the filename
	$mon++;
	
	#year is stored as years since 1900
	$year += 1900;
	
	my @archive_set = <archive/*.zip>;
	map s/^archive\///, @archive_set;

    template 'archive', {
		'suggested_name' => "BEER_NAME_$year-$mon-$mday.zip",
		'archive_set' => \@archive_set,
	};
};

post '/archive' => sub {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	#mon is returned as 0-11, so bump it up by one for the filename
	$mon++;
	
	#year is stored as years since 1900
	$year += 1900;
	
	my $zip_target = param('archiveName');
	my $folder_name = param('archiveName');
	$folder_name =~ s/\.zip//g;
	
	my @image_set = <../public/images/*>;
	my @data_files = <../utilities/*.csv>;
	
	my $cfg = new Config::Simple('../lib/password.cfg') or die "$!";
	my %password_info = &verifyPassword(params->{'password'}, $cfg->param('hash_pass'));
	
	if ($password_info{match}) {
		if (param('reset')) {
			for (@image_set) { unlink $_ or warning $!; }
			for (@data_files) { unlink $_; }
			$password_info{update_message} = "Success, current data cleared.";
		} else {
			mkdir($folder_name);

			for (@image_set) { copy($_, $folder_name); }
			for (@data_files) { copy($_, $folder_name); }

			system("zip -r $zip_target $folder_name");

			if (! -w 'archive') {
				mkdir('archive');
			}
			
			rmtree($folder_name);
			move($zip_target, 'archive');
			$password_info{update_message} = "Success, current data saved.";
		}
	} else {
		$password_info{update_message} = "Password doesn't match, no changes made.";
	}
	
	my @archive_set = <archive/*.zip>;
	map s/^archive\///, @archive_set;

    template 'archive', {
		'suggested_name' => "BEER_NAME_$year-$mon-$mday.zip",
		'archive_set' => \@archive_set,
		'alert_message' => $password_info{update_message},
		'alert_class' => $password_info{alert_class},
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

#######################################
# Others
#######################################
sub verifyPassword {
	my $submited_password = $_[0]; 
	my $password_hash = $_[1]; 
	
	my %password_info;
	
	if (passphrase($submited_password)->matches($password_hash)) {
		$password_info{match} = 1;
		$password_info{alert_class} = "alert-success";
	} else {
		$password_info{match} = 0;
		$password_info{alert_class} = "alert-danger";
	}

	return %password_info;
}

true;
