#!/usr/bin/env perl
use strict;
use warnings;
use Test::Reporter;
use IO::Dir;
use File::Spec::Functions qw/catfile/;
use Config::Tiny;

my $dir_name = shift or die "usage: $0 <directory>\n";

my $dir = IO::Dir->new($dir_name) or die "Couldn't read $dir_name\n";

# get email from regular config or prompt
my $email_from;
my $reg_config 
  = $ENV{PERL_CPAN_REPORTER_CONFIG} ? $ENV{PERL_CPAN_REPORTER_CONFIG} 
  : $ENV{PERL_CPAN_REPORTER_DIR}    ? file( $ENV{PERL_CPAN_REPORTER_DIR},'config.ini') 
  : catfile( $ENV{HOME}, qw/.cpanreporter config.ini/ ) ;

if ( -r $reg_config ) {
  my $ct = Config::Tiny->read($reg_config);
  $email_from = $ct->{_}{email_from};
  print "Sending emails with 'From: $email_from'\n";
}
while ( ! $email_from ) {
  local $|=1;
  print "Enter email address for reports: ";
  chomp($email_from = <STDIN>);
}
    
while (my $f = $dir->read) {
  next if $f eq "." || $f eq "..";
  my $file_name = catfile($dir_name,$f);
  my $tr = Test::Reporter->new->read($file_name);
  $tr->from($email_from);
  if ( $tr->send ) {
    print "$f\n";
    unlink $file_name;
  }
  else {
    die $tr->errorstr
  }
}

