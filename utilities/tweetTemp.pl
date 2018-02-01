#!/usr/bin/perl

use strict;
use warnings;

use Net::Twitter;
use Config::Tiny;
use Data::Dumper qw(Dumper);

my $config_file = "twitter.cfg";
die "$config_file is missing\n" if not -e $config_file;
my $config = Config::Tiny->read( $config_file, 'utf8' );

my $nt = Net::Twitter->new(
	ssl      => 1,
	traits   => [qw/API::RESTv1_1/],
	consumer_key        => $config->{_}->{api_key},
	consumer_secret     => $config->{_}->{api_secret},
	access_token        => $config->{_}->{access_token},
	access_token_secret => $config->{_}->{access_token_secret},
);

$nt->update_with_media('',['../public/images/day.jpg']);
