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
use Test::More;

require "./moku-pona";

our $data_dir = 'test';
our $site_list = $data_dir . '/sites.txt';
our $updated_list = $data_dir . '/updates.txt';
my $target = 'target';
my $file = 'alexschroeder.ch-70-do-rss.txt';

$/ = "\r\n";
my @lines;

mkdir($target) unless -d $target;
unlink("$target/$file") if -f "$target/$file";

my $fh;

open($fh, ">", "$data_dir/$file");
print $fh "0Lifting a rock\t2012-01-27_Lifting_a_rock\talexschroeder.ch\t70\r\n";
close $fh;

open($fh, ">", $updated_list);
print $fh "12018-12-26 Alex RSS\t$data_dir/$file\t\t\r\n";
close $fh;

do_publish($target);

for my $f (qw(sites.txt updates.txt), $file) {
  ok(-f "$target/$f", "$f was published");
}

open($fh, "<", $updated_list);
@lines = <$fh>;
close $fh;

my $found = grep(/$data_dir/, @lines);
ok($found, "Found data dir in the old updates.txt");

open($fh, "<", "$target/updates.txt");
@lines = <$fh>;
close $fh;

$found = grep(/$data_dir/, @lines);
ok(!$found, "Data dir not found in the new updates.txt");

is(scalar(@lines), 1, "updates.txt contains just one line");

done_testing();
