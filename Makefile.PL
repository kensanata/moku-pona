use 5.008004;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME             => 'App::mokupona',
  VERSION_FROM     => 'lib/App/mokupona.pm',
  ABSTRACT_FROM    => 'lib/App/mokupona.pm',
  AUTHOR           => 'Alex Schroeder',
  LICENSE          => 'agpl_3',
  MIN_PERL_VERSION => '5.26.0', # Modern::Perl '2018'
  EXE_FILES        => [
    'script/moku-pona',
  ],
  PREREQ_PM        => {
    'strict'   => 0,
    'warnings' => 0,
    'Modern::Perl' => 1.20180701, # for '2018'
    'Mojolicious'    => 9.00,     # removed tls_verify from Mojo::IOLoop::TLS 9.0
    'IO::Socket::SSL' => 2.069,   # optional for Mojo::IOLoop
    'Encode::Locale' => 0,
    'XML::LibXML' => 0,
    'URI::Escape' => 0,
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
	type => 'git',
	url  => 'https://alexschroeder.ch/cgit/moku-pona',
	web  => 'https://alexschroeder.ch/cgit/moku-pona/about/',
      },
    },
  },
  clean => {
    FILES => "test target",
  },
);

sub MY::postamble {
  return <<'MOKU_PONA_TARGETS';
# Update the README file. The Perl script no only converts the POD
# documentation to Markdown, it also adds a table of contents.
README.md: script/moku-pona
	./update-readme script/moku-pona
MOKU_PONA_TARGETS
}
