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

use Modern::Perl;
use Test::More;

require "./moku-pona";

my $atom = << 'EOT';
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:gopher="https://communitywiki.org/wiki/Gopher_Module_1.0">
<title>RPoD Phlog</title>
<subtitle>Cromagnon had it right. Civilization is a scourge.</subtitle>
<link href="https://leveck.us/phlogfeed/phlog.atom" rel="self" />
<link href="gopher://gopher.leveck.us/0/phlog.atom" rel="self" />
<link href="gopher://gopher.leveck.us/1/phlog" />
<link href="gopher://sdf.org/1/users/jynx/phlog" />
<updated>2018-11-30T00:00:00Z</updated><entry>
<title># The 1436-Files</title>
<id>tag:leveck.us,2018-11-30:/phlog/20181130.post</id>
<author><name>Mr. Leveck</name><email>leveck@leveck.us</email></author>
<link rel="alternate" type="text/plain" href="gopher://leveck.us/0/Phlog/20181130.post" />
<gopher:link href="gopher://leveck.us/0/Phlog/20181130.post" />
<updated>2018-11-30T00:00:00Z</updated>
<content type="text">
<![CDATA[<pre># The 1436-Files
### 20181130

Introducing The 1436-Files. A community based fiction
habitat. In T1436F, all conspiracies are fact, and you are
a co-conspirator to a subset of them.

The USA never went to the moon. The Earth is hollow, or
flat. You may be a part of a crew spraying chem-trails, or
a commitee member sanctioning it. You may be a foot soldier
or a Prime Minister.

This community is 100% anonymous. There are no accounts.
Telnet to 1436.ninja, port 9001, user: T1436F, pass: T1436F
and follow the prompts. Play nice. :^)

See The 1436-Files @ gopher://1436.ninja/1/T1436F

Tags: #publishsomething #federation #conspiracy #telnet
</pre>]]>
</content>
</entry><entry>
<title># On Projects [Nov2018] </title>
<id>tag:leveck.us,2018-11-29:/phlog/20181129.post</id>
<author><name>Mr. Leveck</name><email>leveck@leveck.us</email></author>
<link rel="alternate" type="text/plain" href="gopher://leveck.us/0/Phlog/20181129.post" />
<gopher:link href="gopher://leveck.us/0/Phlog/20181129.post" />
<updated>2018-11-29T00:00:00Z</updated>
<content type="text">
<![CDATA[<pre># On Projects [Nov2018]
### 20181129

I came up with an idea for my hosting contribution. Step
the next -- figure out how I would like to handle this.
Accounts and ssh, git, ftp, telnet, custom app, hybrid of
the above... Choices, choices, choices.

I am able to reveal that the offering will be in the form
of a directory on RPoD. At one point I owned over a dozen
domains. My registrar started hiking up the costs, &quot;you&#39;re
domain is worth $1,000. It&#39;ll cost you $120 / year to renew
it now.&quot; Now, this is a game I didn&#39;t wish to play. Over
time I have whittled down the number. I do not wish to
reprolifferate. I do not see this as a barrier to adoption
as in my estimation, the theme is interesting.

I am leaning towards a custom app set as shell like tfurrows
did with the redconsensus, accessible through telnet. Why
telnet? It seems suitably primitive and can be sufficiently
locked down to the app user. The app will handle user
differentiation similar to the RC setup. This will all also
take place inside the chroot on RPoD.

I have no set timeline for this, but it will likely go
pretty quick. I do think that prior to debuting, I will down
RPoD for a few hours to dd the drive to a 256gb microSD.
Plenty of wiggle room.

Tags: #typed-on-ux50 #federation #hosting #comingsoon
</pre>]]>
</content>
</entry></feed>
EOT

my $expected = << 'EOT';
0# The 1436-Files	/Phlog/20181130.post	leveck.us	70
0# On Projects [Nov2018] 	/Phlog/20181129.post	leveck.us	70
EOT

is(to_gopher($atom), $expected, "Parsing Atom");

done_testing();
