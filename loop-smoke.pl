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
  system($perl, "-Ilib", "-MCPAN", "-e", "install('Bundle::Smoke')" );
  system($perl, 'start-smoke.pl');
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

