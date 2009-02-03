#!/usr/bin/env perl
use strict;
use warnings;

my ($dir1, $dir2) = @ARGV;
die "usage: $0 <dir1> <dir2>\n" unless -d $dir1 && -d $dir2;

my @dir1 = `ls $dir1`;
my @dir2 = `ls $dir2`;

my %dir1;
my %dir2;

for my $f ( @dir1 ) {
  $f =~ /^(\w+)\.(.+?)\.i686-linux/;
  $dir1{ $2 } = $1;
}

for my $f ( @dir2 ) {
  $f =~ /^(\w+)\.(.+?)\.i686-linux/;
  $dir2{ $2 } = $1;
}

my %dists = map { $_ => 1 } keys %dir1, keys %dir2;

for my $d ( sort keys %dists ) {
  next if exists $dir1{$d} && exists $dir2{$d} && $dir1{$d} eq $dir2{$d};
  printf "%8s %8s %s\n", $dir1{$d}, $dir2{$d}, $d;
}
