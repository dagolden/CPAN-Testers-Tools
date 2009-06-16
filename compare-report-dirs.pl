#!/usr/bin/env perl
use strict;
use warnings;
use File::Slurp qw/read_file/;

my ($list, $dir1, $dir2) = @ARGV;
die "usage: $0 <dir1> <dir2>\n" unless -d $dir1 && -d $dir2;

my $suffix = qr{\.(?:tar\.(?:bz2|gz|Z)|t(?:gz|bz)|(?<!ppm\.)zip|pm.gz)$}i; 

my %mb_dists = map {
  chomp;
  s{[^/]+/(.*)$suffix}{$1};
  ( $_ => 1 )
} read_file( $list );

my @dir1 = `ls $dir1`;
my @dir2 = `ls $dir2`;

my %dir1;
my %dir2;

for my $f ( @dir1 ) {
  $f =~ /^(\w+)\.(.+?)\.i686-linux/;
  warn "Couldn't parse '$f'\n" unless defined $1 && defined $2;
  $dir1{ $2 } = $1;
}

for my $f ( @dir2 ) {
  $f =~ /^(\w+)\.(.+?)\.i686-linux/;
  warn "Couldn't parse '$f'\n" unless defined $1 && defined $2;
  $dir2{ $2 } = $1;
}

my %dists = map { $_ => 1 } keys %dir1, keys %dir2;

for my $d ( sort keys %dists ) {
  next unless exists $mb_dists{$d};
  next if exists $dir1{$d} && exists $dir2{$d} && $dir1{$d} eq $dir2{$d};
  printf "%8s %8s %s\n", $dir1{$d} || 'missing', $dir2{$d} || 'missing', $d;
}
