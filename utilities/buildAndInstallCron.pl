#!/usr/bin/perl -w

use strict;
use Cwd;

my $dir = getcwd;

open OUTPUT, ">temp_cron" or die $!;
print OUTPUT "* * * * * cd $dir; ./record_temperature.pl; ./plot_temperatures.R temperature_data.csv ../public/images/\n";
close OUTPUT;

system "crontab temp_cron";

unlink "temp_cron";
