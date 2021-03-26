# What to do for a release?

Run `make README.md`.

Update `Changes` with user-visible changes.

Check the copyright year in the `LICENSE`.

Increase the version in `lib/App/mokupona.pm`.

Double check the `MANIFEST`. Did we add new files that should be in
here?

```
make manifest
```

Use n.nn_nn for developer releases:

```
make distdir
mv App-mokupona-2.11 App-mokupona-2.11_00
tar czf App-mokupona-2.11_00.tar.gz App-mokupona-2.11_00
trash App-mokupona-2.11_00
cpan-upload -u SCHROEDER App-mokupona-2.11_00.tar.gz
```

Commit any changes. If you’re happy, tag the release and make the
actual release:

```
perl Makefile.PL && make manifest && make && make dist
cpan-upload -u SCHROEDER App-mokupona-2.11.tar.gz
```

Based on [How to upload a script to
CPAN](https://www.perl.com/article/how-to-upload-a-script-to-cpan/) by
David Farrell (2016).
