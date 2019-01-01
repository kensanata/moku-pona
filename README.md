# Moku Pona

Moku Pona will visit a set of gopher items you provided and add these
to a gopher map if they changed since the last time you looked at
them.

## Usage

List the sites you are subscribed to:

```
$ ./moku-pona list
Subscribed items in /home/alex/.moku-pona/sites.txt:
none
```

This makes sense. So lets add some:

```
$ ./moku-pona add gopher://alexschroeder.ch "Alex Schroeder"
$ ./moku-pona add gopher://sdf.org/1/users/tomasino/phlog Tomasino
```

Check the list:

```
$ ./moku-pona list
Subscribed items in /home/alex/.moku-pona/sites.txt:
moku-pona add alexschroeder.ch:70 "Alex Schroeder"
moku-pona add sdf.org:70/1/users/tomasino/phlog "Tomasino"
```

Notice how this makes it easier to share your subscriptions with
others as they can just run it from the shell.

Use a Gopher client like [VF-1](https://github.com/solderpunk/VF-1) to
browse the same list:

```
$ vf1 ~/.moku-pona/sites.txt 
Welcome to VF-1!
Enjoy your flight through Gopherspace...
[1] Alex Schroeder/
[2] Tomasino/
VF-1> 
```

Update your subscriptions:

```
$ ./moku-pona update
Fetching Alex Schroeder...updated
Fetching Tomasino...updated
```

Do it again:

```
$ ./moku-pona update
Fetching Alex Schroeder...unchanged
Fetching Tomasino...unchanged
```

Browse your list of updates:

```
$ vf1 ~/.moku-pona/updates.txt 
Welcome to VF-1!
Enjoy your flight through Gopherspace...
[1] 2018-02-05 Tomasino/
[2] 2018-02-05 Alex Schroeder/
```

And that's it!

When adding this to a cron job, you might want to use the `--quiet`
flag to the update command.

## Clean Up

You can simply edit `~/.moku-pona/sites.txt` to add and remove entries
but there's also a shortcut to remove entries:

```
$ moku-pona remove "Alex Schroeder"
Removed 1 subscription
```

Run `moku-pona cleanup` to get rid of any remaining caches and updates
you're no longer subscribed to.

## Fancy Header

You can edit `~/.moku-pona/updates.txt` and add stuff to the top or
bottom. Just remember that any lines you add must be regular Gopher
menu items. If they're information, they must must start with "i" and
end with "\t\t\t\r\n", three tabulators, a carriage return and a
newline.

## How does it work?

Anytime moku pona fetches a subscribed item, it is saved in
`~/.moku-pona` unless it is unchanged. If it is new or updated,
`~/.moku-pona/updates.txt` is updated.

## Change the data directory

If you set the environment variable `MOKU_PONA` then it's value will
be used as the data directory.

```
MOKU_PONA=/var/gopher/moku-pona moku-pona update
```

## Limitations

It only detects changes. Thus, if there is an item that points to a
phlog, that's great. Sometimes people put their phlog in a folder per
year. If the Gopher menu lists each folder and a date with the latest
change, then that's great, you can use it. Without it, you're in
trouble: you need to subscribe to the item for the current year in
order to see changes, but when the next year comes around, you're
subscribed to the wrong item. Sometimes you're lucky and there will be
a menu somewhere with a timestamp for the last change. Add that page
and you'll get notified when the timestamp changes.

## Dependencies

I'm listing the Perl module if you're installing them via `cpan` or
`cpanm`, and the Debian package if you're installing them via `apt
install`.

* XML::LibXML (libxml-libxml-perl) is optional, used to parse RSS or
  Atom feeds. This requires the libxml2 library as a dependency. Thus,
  if you build it yourself, you need a package like libxml2-dev, and
  if you install the package, it should install libxml2 as a
  dependency.

* Modern::Perl (libmodern-perl-perl) is good practice but it isn't
  strictly required so if it isn't installed on your system and you're
  having a hard time installing it, then just get rid of the line that
  uses it. That should be no problem!

* Mojo::File (libmojolicious-perl) is used when publishing.

## If you don't know Perl

Your system probably comes with a minimal Perl. You should try to
install all the modules listed above using your system's packet
manager. If you want more control, here's what I do:

1. Don't install things using `sudo`. All your Perl stuff should be in
   `~/perl5`. This requires changes to your PATH environment variable,
   and the setting of a PERL5LIB environment variable. The
   installation of the tools below should set this up for you.

2. Install `perlbrew` which allows you to install multiple versions of
   Perl and to switch between them. Eventually you're going to need
   this if you're releasing code that needs to be backwards
   compatible. How else are you going to reproduce bug reports?

3. Perl comes with `cpan` to install libraries, but I actually prefer
   `cpanm` which is part of `App::cpanminus`. So use `cpan` to install
   `App::cpanminus`, and from then on use `cpanm` to install things.
