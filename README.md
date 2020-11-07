# Moku Pona

Moku Pona a Gemini based feed reader. It can monitor URLs to feeds or regular
pages for changes and keeps and updated list of these in a Gemini list.

You manage your subscriptions using the command-line, with Moku Pona.

You read the resulting file using your Gemini client.

Moku Pona knows how to fetch Gopher URLs, Gemini URLs, and regular web URLs.

**Table of Contents**

- [Limitations](#limitations)
- [Dependencies](#dependencies)
- [The Data Directory](#the-data-directory)
- [Migration from 1.1](#migration-from-1-1)
- [List your subscriptions](#list-your-subscriptions)
- [Add a subscription](#add-a-subscription)
- [Remove a subscription](#remove-a-subscription)
- [Clean up the data directory](#clean-up-the-data-directory)
- [Update](#update)
- [Subscribing to feeds](#subscribing-to-feeds)
- [Publishing your subscription](#publishing-your-subscription)
- [Serving your subscriptions via Gemini](#serving-your-subscriptions-via-gemini)

## Limitations

Moku Pona only detects changes. Thus, if there is an item that points to a phlog
or blog, that's great. Sometimes people put their phlog in a folder per year. If
the Gopher menu lists each folder and a date with the latest change, then that's
great, you can use it. Without it, you're in trouble: you need to subscribe to
the item for the current year in order to see changes, but when the next year
comes around, you're subscribed to the wrong item. Sometimes you're lucky and
there will be a menu somewhere with a timestamp for the last change. Use that
instead. Good luck!

## Dependencies

There are some Perl dependencies you need to satisfy in order to run this
program:

- [Modern::Perl](https://metacpan.org/pod/Modern%3A%3APerl), or `libmodern-perl-perl`
- [IO::Socket::SSL](https://metacpan.org/pod/IO%3A%3ASocket%3A%3ASSL), or `libio-socket-ssl-perl`
- [Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent), or `libmojolicious-perl`
- [XML::LibXML](https://metacpan.org/pod/XML%3A%3ALibXML), or `libxml-libxml-perl`
- [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape), or `liburi-escape-xs-perl`
- [URI](https://metacpan.org/pod/URI), or `liburi-perl`

## The Data Directory

Moku Pona keeps the list of URLs you are subscribed to in directory. It's
probably `~/.moku-pona` on your system.

- If you have `MOKU_PONA` environment variable set, then that's your data
directory.
- If you don't, but you have the `HOME` environment variable set (this is
what usually happens), then your data directory is `$HOME/.moku-pona`.
- The last option is to have the `LOGDIR` environment variable set.

The data directory contains a copy of the latest resources. The names of these
cache files are simply the URL with all the slashes replaced by a hyphen.

The `sites.txt` file is a file containing a gemtext list of links, i.e. entries
such as these:

    => gemini://alexschroeder.ch Alex Schroeder

The `updates.txt` file is a file containing a gemtext list of links based on
`sites.txt`, but with a timestamp of their last change, and with new updates
moved to the top. The ISO date is simply inserted after the URL:

    => gemini://alexschroeder.ch 2020-11-07 Alex Schroeder

In order to be at least somewhat backwards compatible with Moku Pona versions
1.1 and earlier, `sites.txt` may contain Gopher menu items. These are converted
to Gemini URLs during processing and thus the `updates.txt` file still contains
regular gemtext.

    1Alex Schroeder ⭾ ⭾ alexschroeder.ch ⭾ 70

As was said above, however, the recommended format is the use of URLs. Moku Pona
supports Gemini, Gopher, and the web (gemini, gopher, gophers, http, and https
schemes).

## Migration from 1.1

The best way to migrate your setup is probably to use the `list` subcommand
explained later, and to recreate your list of subscriptions. Then your
`sites.txt` file will use gemtext format.

    moku-pona list > commands
    mv ~/.moku-pona/sites.txt ~/.moku-pona/sites.txt~
    sh commands

## List your subscriptions

## Add a subscription

    moku-pona add url [description]

This adds a URL to the list of subscribed items. If the target is an Atom or RSS
feed, then that's also supported. You can provide an optional description for
this URL. If you don't provide a description, the URL will be used as the item's
description.

Example:

    moku-pona add gemini://alexschroeder.ch kensanata

## Remove a subscription

    moku-pona remove description

This removes one or more URLs from the list of subscribed items.

Example:

    moku-pona remove kensanata

## Clean up the data directory

    moku-pona cleanup [--confirm]

When Moku Pona updates, copies of the URL targets are saved in the data
directory. If you remove a subscription (see above), that leaves a cache file in
the data directory that is no longer used – and it leaves an entry in
`updates.txt` that is no longer wanted. The cleanup command fixes this. It
deletes all the cached pages that you are no longer subscribed to, and it
removes those entries from `updates.txt` as well.

Actually, just to be sure, if you run it without the `--confirm` argument, it
simply prints which files it would trash. Rerun it with the `--confirm`
argument to actually do it.

Example:

    moku-pona cleanup

## Update

    moku-pona update [--quiet]

This updates all the subscribed items and generates a new local page for you to
visit: `updates.txt`.

Example:

    moku-pona update

If you call it from a cron job, you might want to use the `--quiet` argument to
prevent it from printing all the sites it's contacting (since cron will then
mail this to you and you might not care for it unless there's a problem). If
there's a problem, you'll still get a message.

This is how I call it from my `crontab`, for example

    #m   h  dom mon dow   command
    11 7,14 *   *   *     /home/alex/bin/moku-pona update --quiet

## Subscribing to feeds

When the result of an update is an XML document, then it is parsed and the links
of its items (if RSS) or entries (if Atom) are extracted and saved in the cache
file in the data directory. The effect is this:

- If you subscribe to a regular page, then the link to it in `updates.txt`
moves to the top when it changes.
- If you subscribe to a feed, then the link in `updates.txt` moves to the
top when it changes and it links to a file in the data directory that links to
the individual items in the feed.

Example:

    moku-pona add https://campaignwiki.org/rpg/feed.xml "RPG"
    moku-pona update

This adds the RPG entry to `updates.txt` as follows:

    => https%3A--campaignwiki.org-rpg-feed.xml 2020-11-07 RPG

And if you check the file `https:--campaignwiki.org-rpg-feed.xml`, you'll see
that it's a regular Gemini list. You'll find 100 links like the following:

    => https://alexschroeder.ch/wiki/2020-11-05_Episode_34 Episode 34

Now use `moku-pona publish` (see below) to move the files to the correct
directory where your Gemini server expects them.

## Publishing your subscription

    moku-pona publish <directory>

This takes the important files from your data directory and copies them to a
target directory. You could just use symbolic links for `sites.txt` and
`updates.txt`, of course. But if you've subscribed to actual feeds as described
above, then the cache files need to get copied as well!

Example:

    mkdir ~/subs
    moku-pona publish ~/subs

## Serving your subscriptions via Gemini

This depends entirely on your Gemini server. If you like it really simple, you
can use [Lupa Pona](https://alexschroeder.ch/cgit/lupa-pona/about/). It comes
with it's own documentation. Here's how to create the certificate and key files,
copy them to the `~/subs` directory created above, and run `lupa-pona` for a
quick test.

    make cert
    cp *.pem ~/subs
    cd ~/subs
    lupa-pona
