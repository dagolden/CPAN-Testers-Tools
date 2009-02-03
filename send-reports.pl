#!/usr/bin/env perl
use strict;
use warnings;
use Test::Reporter;
use IO::Dir;
use File::Spec::Functions qw/catfile/;

my $dir_name = shift or die "usage: $0 <directory>\n";

my $dir = IO::Dir->new($dir_name) or die "Couldn't read $dir_name\n";

while (my $f = $dir->read) {
  next if $f eq "." || $f eq "..";
  my $file_name = catfile($dir_name,$f);
  my $tr = Test::Reporter->new->read($file_name);
  if ( $tr->send ) {
    print "$f\n";
    unlink $file_name;
  }
  else {
    die $tr->errorstr
  }
}

