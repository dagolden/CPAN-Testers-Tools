#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Lucid qw/:all/;
use File::Path qw/mkpath rmtree/;
use File::pushd qw/pushd tempd/;
use Path::Class;

my $suffix = qr{\.(?:tar\.(?:bz2|gz|Z)|t(?:gz|bz)|(?<!ppm\.)zip|pm.gz)$}i; 
my $dist_re = qr{[a-zA-Z]+/.+?$suffix};

my @spec = (
  Param(
    "src|S", sub { -e "$_/makeaperl" or die "Not a perl source directory" }
  )->required,
#  Param("old|O", $dist_re)->required,
#  Param("new|N", $dist_re)->required,
#  Param("dir|D")->required,
#  Param("list|L")->required,
  Param("threads|t"),
  Param("temp|-T"),
  List("extra|x"), 
  Switch("help|h"),
);

my $usage = << "ENDHELP";
usage: $0 <required options> <other options>

REQUIRED OPTIONS:
  --src|-S    DIR       perl source directory
  --old|-O    DISTFILE  older distfile to test ("AUTHOR/TARBALL")
  --new|-N    DISTFILE  newer distfile to test ("AUTHOR/TARBALL")
  --dir|-D    DIR       directory for results
  --list|-L   FILE      file with list of dists to test

OTHER OPTIONS:
  --extra|-x  MOD       extra module to install (can be repeated)
  --temp|-T   DIR       used in place of temporary directory         
  --threads|-t          build perl with threads
  --help|-h             usage guide
ENDHELP

# XXX nasty hack until Getopt::Lucid has better help
if ( grep { /--help|-h/ } @ARGV ) {
  print STDERR "$usage\n" and exit 
}

my $opt = Getopt::Lucid->getopt( \@spec );

main( $opt );
exit;

#--------------------------------------------------------------------------#

sub main {
  my ($opt) = @_;

  # setup temporary work directory
  my $work_dir = $opt->get_temp ? pushd( $opt->get_temp ) | tempd();
  my $perldir = dir($work_dir, 'perl'); 
  my $perlbin = file($perldir, 'bin', 'perl');
  
  print "*** Working directory is '$work_dir' ***\n";

  # build perl in work directory
  build_perl( $opt, $perldir );

  # install CPAN::Reporter::Smoker and extra modules
  for my $mod ( 'YAML', 'CPAN::Reporter::Smoker', $opt->get_extra ) {
    print "*** Installing $mod  ***\n";
    local %ENV = (%ENV, _automated_testing_env());
    system("$perlbin -MCPAN -e 'install(q{$mod})'")
      and die "Problem installing CPAN::Reporter::Smoker. Stopping\n";
    system("$perlbin -M$mod -e 1")
      and die "Could not confirm $mod installed\n";
  }

  # archive perl directory
  system("tar clpf perl.tar perl") 
    and die "Problem archiving perl dir. Stopping.\n"; 

  # smoke_it( old dist )
  smoke_it( $opt, $work_dir, $perlbin, $opt->get_old );

  # restore perl from archive file
  eval { rmtree ($perldir); 1} 
    or die "Problem removing modified perl directory. Stopping\n";
  system( 'tar xf perl.tar') 
    and die "Problem extracting archived perl directory. Stopping\n";

  # smoke_it( new dist )
  smoke_it( $opt, $work_dir, $perlbin, $opt->get_new );
  
  # compare output directories

}

sub build_perl {
  my ($opt, $target_dir) = @_;
  my $pd = pushd( $opt->get_src );
  print "*** Building perl from '$pd' ***\n";
  my $config_args="-des -Dprefix=$target_dir";
  $config_args .= " -Dusethreads" if $opt->get_threads;
  system("make realclean");
  system("rm -f config.sh Policy.sh");
  system("sh ./Configure $config_args") 
    and die "Problem with Configuration. Stopping.\n";
  system("make depend") and die "Problem with make depend. Stopping.\n";
  system("make") and die "Problem with make. Stopping\n";
  system("make install") and die "Problem with install. Stopping\n";
}

sub smoke_it {
  my ($opt, $work_dir, $perl_path, $regression_dist) = @_;

  # install regression distfile

  # create output directory for results

  # create temporary CPAN::Reporter config dir

  # CPAN::Reporter config.ini to save files to output directory

  # smoke the list

}

sub _automated_testing_env {
  return (
    AUTOMATED_TESTING => 1,
    PERL_MM_USE_DEFAULT => 1,
    PERL_EXTUTILS_AUTOINSTALL => '--default-deps',
  );
}

