#!/usr/bin/perl

my ($name, @headers) = @ARGV;
open FH, ">$name";
print FH join(' | ', @headers);
close FH;
