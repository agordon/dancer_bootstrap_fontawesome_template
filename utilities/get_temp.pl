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

print $all_json;
