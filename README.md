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
Alex Schroeder (alexschroeder.ch:70)
Tomasino (sdf.org:70/1/users/tomasino/phlog)
```

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
2018-02-05
[1] Tomasino/
[2] Alex Schroeder/
```

And that's it!

## How does it work?

Anytime moku pona fetches a subscribed item, it is saved in
`~/.moku-pona` unless it is unchanged. If it is new or updated,
`~/.moku-pona/updates.txt` is updated. Items are placed at the top
under a date header which is based on the current time, UTC. Any
previous mention of the item is removed. Thus, every item is just
listed once, under the date it was last updated.
