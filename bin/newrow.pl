#!/usr/bin/perl
use strict;
my $line = <STDIN>;
print $line;
$line =~ s/[\w,>=]/ /g;
print $line;
