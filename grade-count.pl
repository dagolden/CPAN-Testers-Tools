#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Path::Class;
use List::Util qw/sum/;

my $dir = shift;
die "usage: $0 <dir>\n" unless defined $dir && -d $dir;

my %grade_count;

for my $f ( dir($dir)->children ) {
  my $bn = $f->basename;
  my ($grade) = $bn =~ m{^(pass|fail|unknown|na)\.};
  next unless $grade;
  $grade_count{$grade}++;
}

my $total = sum values %grade_count;

if ( $total ) {
  for my $g ( qw/pass fail unknown na/ ) {
    printf( "%10s %d%%\n", $g, int(100*$grade_count{$g}/$total) );
  }
}



