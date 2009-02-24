use strict;
use warnings;
use CPAN::Reporter::Smoker;
use File::Path qw/rmtree/;
use File::Spec;
print "Cleaning up CPAN build directory\n";
rmtree( File::Spec->catdir($ENV{HOME}, qw/.cpan build/) );
local $SIG{TERM} = sub { exit 1 };
start(
  status_file=> "smoking.txt", 
  list => shift,
);
END {
  system('stty sane') unless $^O eq 'MSWin32';
}
