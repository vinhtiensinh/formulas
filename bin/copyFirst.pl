#!/usr/bin/perl
use strict;

my @lines = <STDIN>;
my $firstLine = shift @lines;
my @firstLineElements = split('\|', $firstLine);
my $elementToCopy = $firstLineElements[0];

print $firstLine;
foreach my $line (@lines) {
  my @elements = split('\|', $line);
  $elements[0] = $elementToCopy;
  print join("|", @elements);
}
