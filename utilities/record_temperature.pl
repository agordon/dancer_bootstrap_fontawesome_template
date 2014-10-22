#!/usr/bin/perl -w

use strict;
use JSON;
use Config::Simple;

###############################################################################
# Variables and Setup
###############################################################################

my $cfg = new Config::Simple('spark_core_info.cfg');

my $device_ID = $cfg->param('device_ID');
my $access_token = $cfg->param('access_token');

###############################################################################
# Main
###############################################################################

my $temp_json = `curl -m 10 --silent "https://api.spark.io/v1/devices/$device_ID/temp?access_token=$access_token"`;

#If there was no response from the server, this string will be empty
if ($temp_json eq '') {
	exit;
}

my $temp_out_json = `curl --silent "https://api.spark.io/v1/devices/$device_ID/tempOut?access_token=$access_token"`;
my $relay_on_json = `curl --silent "https://api.spark.io/v1/devices/$device_ID/relayOn?access_token=$access_token"`;
my $tarTemp_on_json = `curl --silent "https://api.spark.io/v1/devices/$device_ID/tarTemp?access_token=$access_token"`;

my %temp_data = %{decode_json $temp_json};
my %temp_out_data = %{decode_json $temp_out_json};
my %relay_on_data = %{decode_json $relay_on_json};
my %tarTempData = %{decode_json $tarTemp_on_json};

open OUTPUT, ">>temperature_data.csv";
print OUTPUT "$temp_data{coreInfo}{last_heard},$temp_data{result},$temp_out_data{result},$relay_on_data{result},$tarTempData{result}\n";
close OUTPUT;
