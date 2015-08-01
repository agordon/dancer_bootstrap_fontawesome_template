package Calculators;
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

use shared_functions;

our $VERSION = '0.1';

hook 'before' => sub {
};

get '/calculators' => sub {
	template 'calculators';
};

###############################################################################
# Functions
###############################################################################

true;
