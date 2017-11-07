#!/usr/bin/perl -w

use strict;
use Cwd;

my $dir = getcwd;

open OUTPUT, ">temp_cron" or die $!;
print OUTPUT "* * * * * cd $dir; ./record_temperature.pl; ./plot_temperatures.R --folder ../public/images/\n";
print OUTPUT "\@daily cd /home/ubuntu/Spark-thermostat/utilities; ./tweetTemp.pl\n";
close OUTPUT;

system "crontab temp_cron";

unlink "temp_cron";
