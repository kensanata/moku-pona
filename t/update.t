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

# setup tests
open(my $fh, ">", "$site_list") or die "Cannot write $site_list: $!\n";
my $line = "1Test Phlog\tselector\tlocalhost\t$port\r\n";
print $fh $line;
close($fh);

unlink($updated_list) if -f $updated_list;

my $cache = "$data_dir/localhost-$port-selector.txt";

unlink($cache) if -f $cache;

# run tests
my $site = load_site();
is(@$site, 1, "$site_list has one line");
is($site->[0], $line, "entry was added");

do_update();

ok(-f $cache, "cache was written");

my $data = load_file($updated_list);
like($data, qr/^i\d\d\d\d-\d\d-\d\d\t/, "updated list has date");
like($data, qr/$line/, "updated list has line");

do_update();

$data = load_file($updated_list);
is(grep(qr/^i\d\d\d\d-\d\d-\d\d\t/, $data), 1, "just one date");
is(grep(qr/$line/, $data), 1, "just one line");

unlink($cache) if -f $cache;

done_testing();
