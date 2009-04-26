#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use App::CPAN::Mini::Visit;
use Archive::Tar ();
use Getopt::Lucid qw/:all/;
use File::Path qw/mkpath rmtree/;
use File::pushd qw/pushd/;
use File::Temp ();

my $suffix = qr{\.(?:tar\.(?:bz2|gz|Z)|t(?:gz|bz)|(?<!ppm\.)zip|pm.gz)$}i; 
my $dist_re = qr{[a-zA-Z]+/.+?$suffix};

my @spec = (
  Param(
    "src|S", sub { -e "$_/makeaperl" or die "Not a perl source directory"
  )->required,
  Param("old|O", $dist_re)->required,
  Param("new|N", $dist_re)->required,
  Param("dir|D")->required,
  Switch("help|h"),
);

my $usage = << "ENDHELP";
usage: $0 <required options> <other options>

REQUIRED OPTIONS:
  --src|-S      perl source directory
  --old|-O      older distfile to test ("AUTHOR/TARBALL")
  --new|-N      newer distfile to test ("AUTHOR/TARBALL")
  --dir|-D      directory for results
  --list|-L     file with list of dists to test

OTHER OPTIONS:

ENDHELP

my $opt = Getopt::Lucid::getopt( \@spec );

if ( $opt->get_help ) {
  say $usage and exit 
}

main( $opt );
exit;

#--------------------------------------------------------------------------#

sub main {
  my ($opt) = @_;

  # build perl in temp directory

  # install CPAN::Reporter::Smoker

  # archive perl directory

  # smoke_it( old dist )

  # restore perl from archive file

  # smoke_it( new dist )

  # compare output directories

}

sub build_perl {
  my ($opt, $target_dir) = @_;
  
}

sub smoke_it {
  my ($opt, $work_dir, $perl_path, $regression_dist) = @_;

  # install regression distfile

  # create output directory for results

  # create temporary CPAN::Reporter config dir

  # CPAN::Reporter config.ini to save files to output directory

  # smoke the list

}

