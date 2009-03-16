use strict;
use warnings;
use Config;

my $perl_list = shift;
unless ( defined $perl_list && -r $perl_list ) {
  die "Usage: $0 <file-with-perl-paths>\n";
}

open my $fh, "<", $perl_list;
my @perls = <$fh>;
chomp for @perls;
close $fh;

$ENV{PERL_CR_SMOKER_RUNONCE} = 1;
$ENV{PERL_CR_SMOKER_SHORTCUT} = 1;

my $finish=0;
$SIG{HUP} = $SIG{TERM} = $SIG{INT} = \&prompt_quit; 

for my $perl ( @perls ) {
  print "\n#######################################################################\n";
  print "### --- TESTING WITH '$perl'\n";
  print "#######################################################################\n\n";

  unless ( -x $perl ) {
    warn "Not executable: '$perl'\n";
    next;
  }
  system($perl, "-Ilib", "-MCPAN", "-e", "install('Bundle::Smoker')" );
  system($perl, 'start-smoke.pl');

  print "\n#######################################################################\n";
  print "### --- FINISHED WITH '$perl'\n";
  print "#######################################################################\n\n";

  sleep 5;
}

#--------------------------------------------------------------------------#

sub prompt_quit {
    my ($sig) = @_;
    # convert numeric to name
    if ( $sig =~ /\d+/ ) {
        my @signals = split q{ }, $Config{sig_name};
        $sig = $signals[$sig] || '???';
    }
    print(
        "\nCPAN testing halted on SIG$sig.  Continue (y/n)? [n]\n"
    );
    my $answer = <STDIN>;
    exit 0 unless substr( lc($answer), 0, 1) eq 'y';
    return;
}

