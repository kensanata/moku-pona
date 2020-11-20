#!/usr/bin/env perl
# Copyright (C) 2018–2020  Alex Schroeder <alex@gnu.org>

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

use Modern::Perl;
use Mojo::IOLoop;
use IO::Socket::IP;
use Test::More;

my $title = "Moku Pona and Gopher Feeds";
my $link = "gopher://alexschroeder.ch:70/02018-11-30_Moku_Pona_and_Gopher_Feeds";
my $rss = << "EOT";
<rss version="2.0">
<channel>
<item>
<title>$title</title>
<link>$link</link>
</item>
</channel>
</rss>
EOT

my $port = Mojo::IOLoop::Server->generate_port;

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
  Mojo::IOLoop->server({port => $port} => sub {
    my ($loop, $stream) = @_;
    $stream->on(read => sub {
      my ($stream, $bytes) = @_;
      $bytes =~ s/[\r\n]+$//;
      if ($bytes =~ /feed$/) {
	$stream->write($rss);
      } else {
	$stream->write("$bytes\r\n"); # echo
      }
      $stream->close_gracefully()})});
  Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

require "./script/moku-pona";

our $data_dir = 'test';
our $site_list = $data_dir . '/sites.txt';
our $updated_list = $data_dir . '/updates.txt';

# setup

if (-d $data_dir) {
  opendir(my $dh, $data_dir) or die "Cannot open $data_dir";
  my @files = map { "$data_dir/$_" } grep { /^[a-z]/ } readdir($dh);
  closedir($dh);
  unlink(@files);
}

open(my $fh, ">", "$site_list") or die "Cannot write $site_list: $!\n";
my $line = "1Test Phlog\tselector\tlocalhost\t$port";
print $fh "$line\n";
close($fh);

unlink($updated_list) if -f $updated_list;

my $cache = "$data_dir/gopher:--localhost:$port-1selector";
unlink($cache) if -f $cache;

my $site = load_site();
is(@$site, 1, "$site_list has one line");
is($site->[0], "=> gopher://localhost:$port/1selector Test Phlog", "entry was added");

# first test

do_update();

ok(-f $cache, "cache was written");

my $data = load_file($updated_list);
my $re = qr/=> gopher:\/\/localhost:$port\/1selector \d\d\d\d-\d\d-\d\d Test Phlog/;
like($data, $re, "updated list has line");

# make sure we don't get duplicates

do_update();

# how to get the number of matches involves forcing list context:
# my $number = () = $string =~ /\./gi;

$data = load_file($updated_list);
is(scalar(() = $data =~ m/$re/mg), 1, "just one line");

# Add a header

$data = "# Information\n" . $data;
save_file($updated_list, $data);

# add another phlog

open($fh, ">>", "$site_list") or die "Cannot append to $site_list: $!\n";
$line = "1Other Phlog\tother\tlocalhost\t$port";
print $fh "$line\n";
close($fh);

do_update();

$data = load_file($updated_list);
is(scalar(() = $data =~ m/=>/g), 2, "two menus");
$re = qr/=> gopher:\/\/localhost:$port\/1(selector|other) \d\d\d\d-\d\d-\d\d (Test|Other) Phlog/;
like($data, $re, "order of entries is correct");
is(scalar(() = $data =~ m/# Information/g), 1, "one header line");

# add a feed

open($fh, ">>", "$site_list") or die "Cannot append to $site_list: $!\n";
$line = "1Feed\tfeed\tlocalhost\t$port";
print $fh "$line\n";
close($fh);

do_update();

$data = load_file($updated_list);
is(scalar(() = $data =~ m/=>/g), 3, "three menus");

my $url = "gopher://localhost:$port/1feed";
my $file = $url;
$file =~ s/\//-/g;
my $uri = uri_escape_utf8($file);
like($data, qr(=> $uri \d\d\d\d-\d\d-\d\d Feed), "feed file is listed in the updates");
ok(-f "test/$file", "feed cache test/$file exists");

my $feed = load_file("test/$file");
like($feed, qr(=> $link $title), "feed file links to feed item");

save_file("test/$file", "old data");
ok($data =~ s/$uri \d\d\d\d-\d\d-\d\d Feed/$file 1900-01-03 Feed/, "backdated feed update");
# save bogus updates: one backdated entry, and an even older entry
save_file($updated_list, "=> $file 1900-01-02 Feed\n" . $data);

do_update();

$data = load_file($updated_list);
is(scalar(() = $data =~ m/=>/g), 3, "still only three menus");

done_testing();
