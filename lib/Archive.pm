package Archive;
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
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	#mon is returned as 0-11, so bump it up by one for the filename
	$mon++;
	
	#year is stored as years since 1900
	$year += 1900;
	
	var suggested_name => "BEER_NAME_$year-$mon-$mday.zip";
};

get '/archive' => sub {
	my @archive_set = <archive/*.zip>;
	map s/^archive\///, @archive_set;
    
	template 'archive', {
		'suggested_name' => vars->{suggested_name},
		'archive_set' => \@archive_set,
	};
};

post '/archive' => sub {
	my $zip_target = param('archiveName');
	my $folder_name = param('archiveName');
	$folder_name =~ s/\.zip//g;
	
	my @image_set = <../public/images/*>;
	my @data_files = <../utilities/*.csv>;
	
	my $cfg = new Config::Simple('../lib/password.cfg') or die "$!";
	my %password_info = &verifyPassword(params->{'password'}, $cfg->param('hash_pass'));
	
	if ($password_info{match}) {
		if (param('reset')) {
			for (@image_set) { unlink $_; }
			for (@data_files) { unlink $_; }
			$password_info{update_message} = "Success, current data cleared.";
		} else {
			mkdir($folder_name);
			
			for (@image_set) { move($_, $folder_name); }
			for (@data_files) { move($_, $folder_name); }

			system("zip -r $zip_target $folder_name");

			if (! -w 'archive') {
				mkdir('archive');
			}
			
			rmtree($folder_name);
			move($zip_target, 'archive');
			$password_info{update_message} = "Success, current data saved.";
		}
	} else {
		$password_info{update_message} = "Password doesn't match, no changes made.";
	}
	
	my @archive_set = <archive/*.zip>;
	map s/^archive\///, @archive_set;

    template 'archive', {
		'suggested_name' => vars->{suggested_name},
		'archive_set' => \@archive_set,
		
		'alert_message' => $password_info{update_message},
		'alert_class' => $password_info{alert_class},
	};
}; 

###############################################################################
# Functions
###############################################################################

true;
