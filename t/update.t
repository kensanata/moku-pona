#!/usr/bin/env perl
# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package server;

use Modern::Perl;
use base qw(Net::Server);

sub process_request {
    my $self = shift;

    local $SIG{'ALRM'} = sub {
      die "Timed Out!\n";
    };

    alarm(3); # timeout 3s

    while (<STDIN>) {
	s/[\r\n]+$//;
	print "$_\r\n"; # basic echo
	last if /quit/i;
    }
}

package main;

use Modern::Perl;
use Test::More;
use IO::Socket::IP;

require "./moku-pona";

our $data_dir = 'test';
our $site_list = $data_dir . '/sites.txt';
our $updated_list = $data_dir . '/updates.txt';

# Find an unused port
sub random_port {
  use Errno  qw( EADDRINUSE );
  use Socket qw( PF_INET SOCK_STREAM INADDR_ANY sockaddr_in );
  
  my $family = PF_INET;
  my $type   = SOCK_STREAM;
  my $proto  = getprotobyname('tcp')  or die "getprotobyname: $!";
  my $host   = INADDR_ANY;  # Use inet_aton for a specific interface

  for my $i (1..3) {
    my $port   = 1024 + int(rand(65535 - 1024));
    socket(my $sock, $family, $type, $proto) or die "socket: $!";
    my $name = sockaddr_in($port, $host)     or die "sockaddr_in: $!";
    setsockopt($sock, SOL_SOCKET, SO_REUSEADDR, 1);
    bind($sock, $name)
	and close($sock)
	and return $port;
    die "bind: $!" if $! != EADDRINUSE;
    print "Port $port in use, retrying...\n";
  }
  die "Tried 3 random ports and failed.\n"
}

# forking a test server
my $port = random_port();
my $pid = fork();

END {
  # kill server
  if ($pid) {
    kill 'KILL', $pid or warn "Could not kill server $pid";
  }  
}

if (!defined $pid) {
  die "Cannot fork: $!";
} elsif ($pid == 0) {
  server->run(port => $port);
}

# setup

open(my $fh, ">", "$site_list") or die "Cannot write $site_list: $!\n";
my $line = "1Test Phlog\tselector\tlocalhost\t$port";
print $fh $line . "\r\n";
close($fh);

unlink($updated_list) if -f $updated_list;

my $cache = "$data_dir/localhost-$port-selector.txt";
unlink($cache) if -f $cache;

my $site = load_site();
is(@$site, 1, "$site_list has one line");
is($site->[0], $line, "entry was added");

# first test

do_update();

ok(-f $cache, "cache was written");

my $data = load_file($updated_list);
like($data, qr/^1\d\d\d\d-\d\d-\d\d Test Phlog\tselector\tlocalhost\t$port/,
     "updated list has line");

# make sure we don't get duplicates

do_update();

# how to get the number of matches involves forcing list context:
# my $number = () = $string =~ /\./gi;

$data = load_file($updated_list);
is(scalar(() = $data =~ m/^1\d\d\d\d-\d\d-\d\d Test Phlog\tselector\tlocalhost\t$port/mg),
   1, "just one line");

# Add a header

$data = "iInformation\t\t\t\r\n" . $data;
save_file($updated_list, $data);

# add another phlog

open($fh, ">>", "$site_list") or die "Cannot append to $site_list: $!\n";
$line = "1Other Phlog\tother\tlocalhost\t$port";
print $fh $line . "\r\n";
close($fh);

do_update();

$data = load_file($updated_list);
is(scalar(() = $data =~ m/^1/mg), 2, "two menus");
like($data, qr/1\d\d\d\d-\d\d-\d\d Other.*\r\n1\d\d\d\d-\d\d-\d\d Test.*\r\n/,
     "order of entries is correct");
is(scalar(() = $data =~ m/^iInformation/mg), 1, "one header line");

# clean up

unlink($cache) if -f $cache;

done_testing();
