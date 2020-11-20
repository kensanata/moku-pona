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

use Test::More;
use Encode qw(decode_utf8);

require "./script/moku-pona";

our $data_dir = 'test';
our $site_list = $data_dir . '/sites.txt';
our $updated_list = $data_dir . '/updates.txt';

sub to_string {
  my $sub_ref = shift;
  my $output;
  open(my $outputFH, '>:encoding(UTF-8)', \$output) or die "Can't open memory file: $!";
  my $oldFH = select $outputFH;
  $sub_ref->(@_);
  select $oldFH;
  close $outputFH;
  return decode_utf8($output);
}

unlink $site_list if -f $site_list;
is(scalar(@{load_site()}), 0, "$site_list starts out empty");
my $url = "gopher://gopher.club/1phlogs";
my $name = "Gopher Club";
do_add($url, $name);
do_add("$url-2", "$name-2");
my $site = load_site();
is(@$site, 2, "after adding two entries, $site_list has two lines");
my $text = to_string(\&do_list);
like($text, qr(moku-pona add gopher://gopher.club/1phlogs "Gopher Club"), "First site is listed");
like($text, qr(moku-pona add gopher://gopher.club/1phlogs-2 "Gopher Club-2"), "Second site is listed");
done_testing();
