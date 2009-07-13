#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Lucid qw/:all/;
use File::Basename qw/basename/;
use File::Path qw/mkpath rmtree/;
use File::pushd qw/pushd tempd/;
use File::Slurp qw/read_file/;
use Path::Class;
use Config::Tiny;

# Notes
# 
# When regression testing, not only do the normal CPAN "speed" config
# settings need to be turned on, but the index_timeout needs to 
# be made quite long or CPAN will constantly be trying to update it,
# which slows things down

my $suffix = qr{\.(?:tar\.(?:bz2|gz|Z)|t(?:gz|bz)|(?<!ppm\.)zip|pm.gz)$}i; 
my $dist_re = qr{[a-zA-Z]+/.+?$suffix};

my @spec = (
  # required
  Param("perl|p", sub { -x } )->required,
  Param("dir|D", sub { -d } )->required,
  Param("list|L", sub { -r } )->required,
  # optional
  Param("temp|-T"),
  List("extra|x"), 
  Switch("help|h"),
);

my $usage = << "ENDHELP";
usage: $0 <required options> <other options>

REQUIRED OPTIONS:
  --perl|-p   PERL      perl binary to use for testing
  --dir|-D    DIR       directory for results
  --list|-L   FILE      file with list of dists to test

OTHER OPTIONS:
  --extra|-x  MOD       extra module to install (can be repeated)
  --temp|-T   DIR       used in place of temporary directory         
  --help|-h             usage guide
ENDHELP

# XXX nasty hack until Getopt::Lucid has better help
if ( grep { /--help|-h/ } @ARGV ) {
  print STDERR "$usage\n" and exit 
}

my $opt = Getopt::Lucid->getopt( \@spec );

main($opt);
exit;

#--------------------------------------------------------------------------#

sub main {
  my ($opt) = @_;

  print "*** Starting isolated smoke test main loop ***\n";

  # must have CPAN already configured
  die "CPAN must be configured using ~/.cpan/CPAN/MyConfig.pm\n"
    unless -r file( $ENV{HOME}, qw/ .cpan CPAN MyConfig.pm / );

  # get email from regular config or prompt
  my $email_from;
  my $reg_config 
    = $ENV{PERL_CPAN_REPORTER_CONFIG} ? $ENV{PERL_CPAN_REPORTER_CONFIG} 
    : $ENV{PERL_CPAN_REPORTER_DIR}    ? file( $ENV{PERL_CPAN_REPORTER_DIR},'config.ini') 
    : file( $ENV{HOME}, qw/.cpanreporter config.ini/ ) ;

  if ( -r $reg_config ) {
    my $ct = Config::Tiny->read($reg_config);
    $email_from = $ct->{_}{email_from};
  }
  while ( ! $email_from ) {
    local $|=1;
    print "Enter email address for reports: ";
    chomp($email_from = <STDIN>);
  }
    
  # make paths absolute before changing directories
  my $output_dir = dir( $opt->get_dir )->absolute;
  my $list = file($opt->get_list)->absolute;
  my $perl_bin = file($opt->get_perl)->absolute;

  # setup temporary work directory
  my $work_dir = $opt->get_temp ? pushd( $opt->get_temp ) 
                                : tempd();
  
  print "*** Working directory is '$work_dir' ***\n";

  smoke_it( $opt, $work_dir, $output_dir, $perl_bin, $list, $email_from );

}

sub smoke_it {
  my ($opt, $work_dir, $result_dir, $perl_bin, $list, $email_from) = @_;
  print "*** Preparing to smoke test with $perl_bin ***\n";
  $result_dir = $result_dir->absolute;

  # create output directory for results
  mkpath( "$result_dir" );

  # set temporary CPAN::Reporter config dir
  my $config_dir = dir( $work_dir , 'cpan-reporter-config', $perl_bin->basename );
  $config_dir->mkpath;
  local $ENV{PERL_CPAN_REPORTER_DIR} = $config_dir;

  # CPAN::Reporter config.ini to save files to output directory
  my $fh = file( $config_dir, 'config.ini' )->openw
    or die "Couldn't create CPAN::Reporter config file; $!\n";
  print {$fh} << "ENDCONFIG";
email_from = $email_from
transport = File $result_dir
ENDCONFIG

  # smoke the list
  print "*** Smoke testing distributions in '$list' ***\n";
  rmtree( File::Spec->catdir($ENV{HOME}, qw/.cpan build/) );
  local %ENV = (%ENV, _automated_testing_env());
  system( "$perl_bin -MCPAN::Reporter::Smoker -e 'start(list => q{$list})'" );
  system('stty sane');
  
}

sub _automated_testing_env {
  return (
    AUTOMATED_TESTING => 1,
    PERL_MM_USE_DEFAULT => 1,
    PERL_EXTUTILS_AUTOINSTALL => '--default-deps',
  );
}

