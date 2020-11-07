.PHONY: test clean

test:
	prove t

clean:
	rm -rf test

# Update all the documentation files
doc: README.md man

# Update the README file. The Perl script no only converts the POD
# documentation to Markdown, it also adds a table of contents.
README.md: moku-pona
	./update-readme

# Create man pages.
man: moku-pona.1

%.1: %
	pod2man $< $@

# Install scripts and man pages in ~/.local
install: ${HOME}/.local/bin/moku-pona \
	${HOME}/.local/share/man/man1/moku-pona.1

${HOME}/.local/bin/%: %
	cp $< $@

${HOME}/.local/share/man/man1/%: %
	cp $< $@

uninstall:
	rm \
	${HOME}/.local/bin/moku-pona \
	${HOME}/.local/share/man/man1/moku-pona.1
