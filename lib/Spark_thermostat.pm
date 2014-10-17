package Spark_thermostat;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

true;
