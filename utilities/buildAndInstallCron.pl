#!/usr/bin/perl -w

use strict;
use Cwd;

my $dir = getcwd;

open OUTPUT, ">temp_cron" or die $!;
print OUTPUT "* * * * * cd $dir; ./record_temperature.pl\n";
print OUTPUT "* * * * * cd $dir; ./plot_temperatures.R temperature_data.csv ../public/images/\n";
close OUTPUT;

system "crontab temp_cron";

unlink "temp_cron";
