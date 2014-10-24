#!/usr/bin/perl -w

use Dancer::Plugin::Passphrase;
use Data::Dumper;
use Config::Simple;

my $password = $ARGV[0];
die "Please specify a single parameter, the password, at the command line." if (scalar(@ARGV) == 0);

my $phrase = passphrase($password)->generate;

if (not(passphrase($password)->matches($phrase->{rfc2307}))) {
	die "Alert passwords don't match before saving!!!";
}

open OUTPUT, ">../lib/password.cfg";
print OUTPUT "hash_pass $phrase->{rfc2307}\n";
close OUTPUT;

$cfg = new Config::Simple('../lib/password.cfg');

if (not(passphrase($password)->matches($cfg->param('hash_pass')))) {
	die "Alert passwords don't match after saving!!!";
}
