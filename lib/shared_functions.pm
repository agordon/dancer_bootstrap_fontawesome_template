package shared_functions;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Dancer::Plugin::Passphrase;
use Data::Dumper;
use Config::Crontab;

use Exporter 'import';
our @EXPORT  = qw(verifyPassword isRecordingEnabled enableRecording);

###############################################################################
# Functions
###############################################################################

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

sub isRecordingEnabled {
	my $ct = new Config::Crontab; $ct->read;

	#The command which records the temp is called record_temperature, the plotting command is 
	my $recording_event = $ct->select(-command_re => 'record_temperature.pl');

	warning Dumper $recording_event->dump;
}

sub enableRecording {
	my $ct = new Config::Crontab; $ct->read;

	#The command which records the temp is called record_temperature, the plotting command is 
	$_->active(1) for $ct->select(-command_re => 'record_temperature.pl');
	$_->active(1) for $ct->select(-command_re => 'plot_temperatures.R');

	$ct->write;
}

sub disableRecording {
	my $ct = new Config::Crontab; $ct->read;

	#The command which records the temp is called record_temperature, the plotting command is 
	$_->active(0) for $ct->select(-command_re => 'record_temperature.pl');
	$_->active(0) for $ct->select(-command_re => 'plot_temperatures.R');

	$ct->write;
}
