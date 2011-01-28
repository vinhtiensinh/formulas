#!/usr/bin/perl

## Reindents Pipe Seperated Values from stdin, printing the filtered structure
## to stdout.
## eg. handy to align Cucumber Scenario Outline Examples

use strict;

my @allLines = <STDIN>;

my @tobeProcessedSection = ();
foreach my $line (@allLines) {
  if ($line =~ /^\s*]/) {
      process(@tobeProcessedSection) if scalar @tobeProcessedSection;
      @tobeProcessedSection = ();
  }

  push @tobeProcessedSection, $line;
}

## process last one if it doesnt have -- at the end.
process(@tobeProcessedSection) if scalar @tobeProcessedSection;

sub process() {
  my @lines = @_;
  my %maxColumnLength = getMaxColumnLength(@lines);
  my $lineGroupCount = 0;

  for my $line (@lines) {
      my $isCommentLine = $line =~ /^\s*--/;
      my $isEmptyLine   = $line =~ /^\s*$/;
      my $isSectionLine = $line =~ /\[/ || $line =~ /\]/;
      if ($isCommentLine || $isEmptyLine || $isSectionLine) {
        print $line;
        next;
      }

      my @columns = split '\|', $line;
          my @niceColumns;

          my $columnCount = 0;
          for (@columns) {
              $columnCount++;

              ## try to keep original indents on first column in order to retain
              ## original position of the passed block.
              
              unless ($columnCount == 1) {
                s/^\s*/ /;
                s/\s*$/ /;
                s/\s+/ /g;
              }

              my $justifyLength = $maxColumnLength{$lineGroupCount}{$columnCount};
              push @niceColumns, sprintf("%-${justifyLength}s", $_);
          }

          print join('|', @niceColumns) . "\n" if @niceColumns;
  }
}

sub getMaxColumnLength {
    my @lines = @_;

    my %maxColumnLength;

    ## for seperating Examples from different scenarios
    my $lineGroupCount = 0;
    for my $line (@lines) {

        my $isCommentLine = $line =~ /^\s*--/;
        my $isEmptyLine   = $line =~ /^\s*$/;
        my $isSectionLine = $line =~ /\[/;
        if ($isCommentLine || $isEmptyLine || $isSectionLine) {
          next;
        }

        my @columns = split '\|', $line;

        my $columnCount = 0;
        for (@columns) {
          $columnCount++;
          unless ($columnCount == 1) {
            s/^\s*/ /;
            s/\s*$/ /;
            s/\s+/ /g;
          }

          my $newColumnLength = length;
          my $currentColumnLength  = $maxColumnLength{$lineGroupCount}{$columnCount};

          if ($newColumnLength > $currentColumnLength) {
            $maxColumnLength{$lineGroupCount}{$columnCount} = $newColumnLength;
          }
        }
    }

    return %maxColumnLength;
}
