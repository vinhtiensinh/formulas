#!/opt/local/bin/perl

use strict;
use warnings;

use Test::More qw(no_plan);

use FindBin;
use lib "$FindBin::Bin/../../lib";
use VPoker::Test::Table;
use VPoker::OpenHoldem::StrategyLoader;
use VPoker::Holdem::Strategy::RuleBased::Limit;


my $strategy_LeeJonesLowLimit = VPoker::Holdem::Strategy::RuleBased::Limit->new;
VPoker::OpenHoldem::StrategyLoader->strategy($strategy_LeeJonesLowLimit, "$FindBin::Bin");
VPoker::OpenHoldem::StrategyLoader->load_file($strategy_LeeJonesLowLimit, "$FindBin::Bin/../_LimitBetting.vpk");
$strategy_LeeJonesLowLimit->validate();

my $table = create_test_table(
   players      => 9,
   strategyType => 'limit',
);

sub test {
    my $test = shift;
    my %options = @_;
    $table->new_hand;
    $table->current_hand->small_blind(5);
    $table->current_hand->big_blind(10);
    $table->actions(
      'sblinder post 5',
      'bblinder post 10',
    );
    $table->actions(@{$options{'actions'}});

    my ($playerName, $action) = split(' ', $options{'expected'});
    my $player = $table->player($playerName);
    $strategy_LeeJonesLowLimit->player($player);
    $strategy_LeeJonesLowLimit->play;

    is($table->current_hand->last_action_of($player)->action, $action, $test); 
}
