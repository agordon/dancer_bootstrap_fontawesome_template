package shared_functions;
use strict;
use warnings;
use Cwd;
use Dancer::Plugin::Passphrase;
use Data::Dumper;

use Exporter 'import';
our @EXPORT  = qw(verifyPassword);

###############################################################################
# Functions
###############################################################################

sub verifyPassword {
	my $submited_password = $_[0]; 
	my $password_hash = $_[1]; 
	
	my %password_info;
	
	if (passphrase($submited_password)->matches($password_hash)) {
		$password_info{match} = 1;
		$password_info{alert_class} = "alert-success";
	} else {
		$password_info{match} = 0;
		$password_info{alert_class} = "alert-danger";
	}

	return %password_info;
}
