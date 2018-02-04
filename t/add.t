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

use Test::More;

require "./moku-pona";

our $data_dir = 'test';
our $site_list = $data_dir . '/sites.txt';
our $updated_list = $data_dir . '/updates.txt';

unlink $site_list if -f $site_list;
is(load_site(), undef, "$site_list is empty");
do_add("gopher://gopher.club/1phlogs", "Gopher Club");
my $site = load_site();
is(@$site, 1, "$site_list has one line");
is($site->[0], "1Gopher Club\tphlogs\tgopher.club\t70\r\n", "entry was added");
done_testing();
