package dancer_bootstrap_fontawesome_template;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/deploy' => sub {
    my $project_dir = getcwd();
    my $hostname = hostname;
    template 'deployment_wizard', {
		directory => $project_dir,
		hostname  => $hostname
	};
};

true;
