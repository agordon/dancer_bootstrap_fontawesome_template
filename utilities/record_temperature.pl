#!/usr/bin/perl -w

use strict;
use JSON;
use Config::Simple;
use Data::Dumper;
use Text::CSV::Simple;

###############################################################################
# Variables and Setup
###############################################################################

my $cfg = new Config::Simple('spark_core_info.cfg');

my $device_ID = $cfg->param('device_ID');
my $access_token = $cfg->param('access_token');

my $target_file = "temperature_data.csv"; 

###############################################################################
# Main
###############################################################################

my $all_json = `curl -m 10 --silent "https://api.particle.io/v1/devices/$device_ID/tempInfo?access_token=$access_token"`;

#If there was no response from the server, this string will be empty
if ($all_json eq '') {
	#if no response, then we want to put in a line of NA's
	my $parser = Text::CSV::Simple->new;
	my @data = $parser->read_file("last_min.csv");
	my $column_count = scalar(@{$data[0]});
	
	my $out_str = 'NA';
	for (2..$column_count) {
		$out_str .= ",NA";
	}
	$out_str .= "\n";
	
	open OUTPUT, ">>$target_file";
	print OUTPUT $out_str;
	close OUTPUT;
	
	exit;
}

my %all_data = %{decode_json $all_json};
my %temp_data = %{decode_json $all_data{result}};


if (! -e $target_file) {
	open OUTPUT, ">>$target_file";
	print OUTPUT "Time,Freezer_temp,Outside_Temp,Relay,Target_temp\n";
	close OUTPUT;
}

open OUTPUT, ">>$target_file";
print OUTPUT "$all_data{coreInfo}{last_heard},$temp_data{temp},$temp_data{tempOut},$temp_data{relayOn},$temp_data{targetTemp}\n";
close OUTPUT;

system("head -n 1 $target_file > last_min.csv");
system("tail -n 1 $target_file >> last_min.csv");
system("head -n 1 $target_file > last_hour.csv");
system("tail -n 60 $target_file >> last_hour.csv");
system("head -n 1 $target_file > last_week.csv");
system("tail -n 10080 $target_file >> last_week.csv");
