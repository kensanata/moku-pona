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
use Test::More;
use utf8;

require "./moku-pona";

our $data_dir = 'test';
our $site_list = $data_dir . '/sites.txt';
our $updated_list = $data_dir . '/updates.txt';

my $rss = << 'EOT';
<rss version="2.0"
    xmlns:wiki="http://purl.org/rss/1.0/modules/wiki/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<docs>http://blogs.law.harvard.edu/tech/rss</docs>
<title>Alex Schroeder: Diary</title>
<link>gopher://alexschroeder.ch:70/0Diary</link>
<managingEditor>kensanata@gmail.com</managingEditor>
<webMaster>kensanata@gmail.com</webMaster>
<atom:link href="gopher://alexschroeder.ch:70/?action=rc" rel="self" type="application/rss+xml" />
<atom:link href="gopher://alexschroeder.ch:70/?action=rc;from=1538751808;upto=1541171008" rel="previous" type="application/rss+xml" />
<atom:link href="gopher://alexschroeder.ch:70/?action=rc" rel="last" type="application/rss+xml" />
<description>The Homepage of Alex Schroeder.</description>
<pubDate>Fri, 30 Nov 2018 14:09:08 GMT</pubDate>
<lastBuildDate>Fri, 30 Nov 2018 14:09:08 GMT</lastBuildDate>
<generator>Oddmuse</generator>
<copyright>Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation.</copyright>
<cc:license>http://www.gnu.org/copyleft/fdl.html</cc:license>
<image>
<url>https://alexschroeder.ch/pics/alex.png</url>
<title>Alex Schroeder: Diary</title>
<link>gopher://alexschroeder.ch:70/</link>
</image>

<item>
<title>Moku Pona and Gopher Feeds</title>
<link>gopher://alexschroeder.ch:70/02018-11-30_Moku_Pona_and_Gopher_Feeds</link>
<guid>gopher://alexschroeder.ch:70/02018-11-30_Moku_Pona_and_Gopher_Feeds</guid>
<description>I'm adding Gopher feed support to Moku Pona. In this context, a Gopher feed is a Gopher resource that returns a RSS 2.0 or Atom feed with links in the Gopher namespace as defined in the Gopher Module. Gopher Module 1.0 is the technical specification and 2018-11-27 Gopher Module is a blog post of…</description>
<pubDate>Fri, 30 Nov 2018 14:06:20 GMT</pubDate>
<comments>gopher://alexschroeder.ch:70/0Comments_on_2018-11-30_Moku_Pona_and_Gopher_Feeds</comments>
<dc:contributor>Alex Schroeder</dc:contributor>
<wiki:status>new</wiki:status>
<wiki:importance>major</wiki:importance>
<wiki:version>1</wiki:version>
<wiki:history>gopher://alexschroeder.ch:70/12018-11-30_Moku_Pona_and_Gopher_Feeds/history</wiki:history>
<category>Gopher</category>
<category>Moku Pona</category>
</item>

<item>
<title>Ship «Hoffnung»</title>
<link>gopher://alexschroeder.ch:70/02018-11-30_Ship_%c2%abHoffnung%c2%bb</link>
<guid>gopher://alexschroeder.ch:70/02018-11-30_Ship_%c2%abHoffnung%c2%bb</guid>
<description>I've continued writing on Cosmic Voyage. ~~~ -+-+-+- Regular Report -+-+-+- C98.204 -+-+-+- Orange      -+-+-+- Dr. med. Ursula Hägi reporting on the second scheduled inspection. The passenger status in cryo sleep is nominal. We have had no failures. My companion for this round is Dr. phys. Hans…</description>
<pubDate>Fri, 30 Nov 2018 11:21:16 GMT</pubDate>
<comments>gopher://alexschroeder.ch:70/0Comments_on_2018-11-30_Ship_%c2%abHoffnung%c2%bb</comments>
<dc:contributor>Alex Schroeder</dc:contributor>
<wiki:status>new</wiki:status>
<wiki:importance>major</wiki:importance>
<wiki:version>1</wiki:version>
<wiki:history>gopher://alexschroeder.ch:70/12018-11-30_Ship_%c2%abHoffnung%c2%bb/history</wiki:history>
<category>Writing</category>
<category>Science Fiction</category>
</item>

</channel>
</rss>
EOT

my $expected = << 'EOT';
=> gopher://alexschroeder.ch:70/02018-11-30_Moku_Pona_and_Gopher_Feeds Moku Pona and Gopher Feeds
=> gopher://alexschroeder.ch:70/02018-11-30_Ship_%c2%abHoffnung%c2%bb Ship «Hoffnung»
EOT

is(to_gemini($rss), $expected, "Parsing RSS 2.0");

done_testing();
