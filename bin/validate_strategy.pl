#!/opt/local/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../vpoker/lib";
use lib "$FindBin::Bin/../../vpoker/vendor";
use VPoker::OpenHoldem::StrategyLoader;
use VPoker::Holdem::Strategy::RuleBased::Limit;

my $strategyName = shift;
my $strategyDir = "$FindBin::Bin/../$strategyName";
my $strategy = VPoker::Holdem::Strategy::RuleBased::Limit->new();
eval {
  VPoker::OpenHoldem::StrategyLoader->strategy($strategy, $strategyDir);
  VPoker::OpenHoldem::StrategyLoader->load_file($strategy, "$FindBin::Bin/../_LimitBetting.vpk");
  $strategy->validate();
};

if ($@) {
  my @lines = split("\n", $@);
  my $error = shift @lines;
  my $error_file;

  foreach my $line (@lines) {
    $error_file = $line if $line =~ /load_file/;
  }
  if ($error_file) {
    print "$error \n $error_file\n";
  }
  else {
    print $@;
  }
}
