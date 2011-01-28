#!/opt/local/bin/perl

use strict;
use warnings;

use Test::More qw(no_plan);

use FindBin;
use lib "$FindBin::Bin/../../vpoker/lib";
use lib "$FindBin::Bin/../../vpoker/vendor";
use VPoker::Test::Table;
use VPoker::OpenHoldem::StrategyLoader;
use VPoker::Holdem::Strategy::RuleBased::Limit;


my $strategy_Pilot  = VPoker::Holdem::Strategy::RuleBased::Limit->new;
VPoker::OpenHoldem::StrategyLoader->strategy($strategy_Pilot, "$FindBin::Bin");
VPoker::OpenHoldem::StrategyLoader->load_file($strategy_Pilot, "$FindBin::Bin/../_LimitBetting.vpk");
$strategy_Pilot->validate();

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
    $strategy_Pilot->player($player);
    $strategy_Pilot->play;

    is($table->current_hand->last_action_of($player)->action, $action, $test); 
}

# ------------ Start testing -----------------
test('preflop AQ call bet from early position',
    actions => [
      'firster bet 20',
      'seconder cards Ac Qd',
    ],
    expected => 'seconder call',
);

test('preflop AQ call raise from middle and late position',
    actions => [
      'firster bet 20',
      'seconder cards Ac Qd',
      'seconder call',
      'thirder, fourther, fifther fold',
      'sixther bet',
      'sblinder, bblinder fold',
      'firster call',
    ],
    expected => 'seconder call',
);

test('flop AQ 2 pairs bet first',
    actions => [
      'firster bet 20',
      'seconder cards Ac Qd',
      'seconder call',
      'thirder, fourther, fifther fold',
      'sixther bet',
      'sblinder, bblinder fold',
      'firster call',
      'deal Ad Qc 3h',
      'firster check'
    ],
    expected => 'seconder bet',
);

test('flop set bet when there is possible straight',
    actions => [
      'firster call',
      'seconder cards Kc Kd',
      'seconder bet 20',
      'thirder, fourther, fifther fold',
      'sixther call',
      'sblinder, bblinder fold',
      'firster call',
      'deal Ks Qc Jh',
      'firster check'
    ],
    expected => 'seconder bet',
);

test('JT suited should call when small blind no raise',
    actions => [
      'firster call',
      'seconder thirder, fourther, fifther fold',
      'sixther call',
      'sblinder cards Th Jh'
    ],
    expected => 'sblinder call',
);

test('AJ suited should bet on dealer',
    actions => [
      'firster call',
      'seconder thirder, fourther, fifther fold',
      'sixther call',
      'dealer cards Ah Jh',
    ],
    expected => 'dealer bet',
);

test('when there was bet, raise preflop and check all the way to the river, shouldnt care about small one card straight, call bet with top pair or second pair kicker >= J',
    actions => [
      'firster, seconder, thirder, fourther fold',
      'fifther bet',
      'sixther call',
      'dealer fold',
      'sblinder cards 8h Jd',
      'sblinder call',
      'bblinder fold',
      'deal 4h 5d 8d',
      'sblinder, fifther, sixther check',
      'deal Th',
      'sblinder, fifther, sixther check',
      'deal 6s',
      'sblinder, fifther check',
      'sixther bet',
    ],
    expected => 'sblinder call',
);

test('AX should bet if on dealer and everyone fold to us',
    actions => [
      'firster, seconder, thirder, fourther, fifther, sixther fold',
      'dealer cards Ah 8d',
    ],
    expected => 'dealer bet',
);

test('other play top pair should bet if preflop bettor check',
    actions => [
        'firster bet',
        'seconder, thirder, fourther, fifther fold',
        'sixther cards Qs Td',
        'sixther call',
        'dealer fold',
        'sblinder, bblinder call',
        'deal 8s 9h Qh',
        'sblinder, bblinder, firster check',
    ],
    expected => 'sixther bet',
);

test('other play should bet with any top pair >= 9 if players is less than or equal 3',
    actions => [
        'firster, seconder, thirder, fourther, fifther fold',
        'sixther cards Js 9d',
        'sixther call',
        'dealer fold',
        'sblinder, bblinder call',
        'deal 9s 3h 4h',
        'sblinder, bblinder check',
    ],
    expected => 'sixther bet',
);

test('small pair should not play hard if there are a lot of over card',
    actions => [
        'firster, seconder, thirder, fourther, fifther fold',
        'sixther cards 2s 2d',
        'sixther call',
        'dealer fold',
        'sblinder, bblinder call',
        'deal 9s 3h 4h',
        'sblinder, bblinder check',
    ],
    expected => 'sixther check',
);

test('river top pair should bet if auto player lead previous round or no bet and on last position',
    actions => [
        'firster call',
        'seconder, thirder, fourther, fifther fold',
        'sixther call',
        'sixther cards Kc Td',
        'dealer fold',
        'sblinder, bblinder call',
        'deal Qs 3h 4h',
        'sblinder, bblinder, firster, sixther check',
        'deal Ks',
        'sblinder, bblinder, firster, sixther check',
        'deal 9s',
        'sblinder, bblinder, firster check',
    ],
    expected => 'sixther bet',
);

test('top pair river should call bet if someone else bet on the turn',
    actions => [
        'firster call',
        'seconder, thirder, fourther, fifther fold',
        'sixther call',
        'sixther cards Kc Td',
        'dealer fold',
        'sblinder, bblinder call',
        'deal Qs 3h 4h',
        'sblinder, bblinder, firster, sixther check',
        'deal Ks',
        'sblinder bet',
        'bblinder, firster fold',
        'sixther call',
        'deal Ts',
        'firster check',
    ],
    expected => 'sixther check',
);

TODO: {

    local $TODO = 'take time to fix this, leave it later';


    test('medium pair should not call a bet and a call preflop',
        actions => [
            'firster bet',
            'seconder, thirder, fourther fold',
            'fifther call',
            'sixther cards 5c 5d',
        ],
        expected => 'sixther fold',
    );

};

test('2 pairs on river, possible flush, should call bet late position',
    actions => [
        'firster call',
        'seconder, thirder, fourther, fifther fold',
        'sixther call',
        'sixther cards Kc Td',
        'dealer fold',
        'sblinder, bblinder call',
        'deal Qs 3h 4h',
        'sblinder, bblinder, firster, sixther check',
        'deal Ks',
        'sblinder, bblinder, firster, sixther check',
        'deal Ts',
        'sblinder, bblinder check',
        'firster bet',
    ],
    expected => 'sixther call',
);
test('2 pairs on river, possible straight, should bet first late position',
    actions => [
        'firster call',
        'seconder, thirder, fourther, fifther fold',
        'sixther call',
        'sixther cards Kc Td',
        'dealer fold',
        'sblinder, bblinder call',
        'deal Qs 3h 4h',
        'sblinder, bblinder, firster, sixther check',
        'deal Ks',
        'sblinder, bblinder, firster, sixther check',
        'deal Td',
        'sblinder, bblinder, firster check',
    ],
    expected => 'sixther bet',
);

test('AXs if there is only one bet and less than 3 callers, should not call',
    actions => [
        'firster bet',
        'seconder, thirder, fourther fold',
        'fifther call',
        'sixther cards Ac 3c',
    ],
    expected => 'sixther fold',
);

test('any pair should call if there is a bet and at least 3 callers',
    actions => [
        'firster bet',
        'seconder, thirder, fourther call',
        'fifther fold',
        'sixther cards 5c 5d',
    ],
    expected => 'sixther call',
);

test('straight to 5 on river should not fold',
    actions => [
        'firster bet',
        'seconder, thirder, fourther, fifther call',
        'sixther cards 2c 5d',
        'sixther call',
        'dealer, sblinder, bblinder call',
        'deal 3d 4s Th',
        'sblinder, bblinder, sixther, dealer check',
        'deal Kh',
        'sblinder, bblinder, sixther, dealer check',
        'deal Ah',
        'sblinder, bblinder check',
    ],
    expected => 'sixther bet',
);

test('1 card straight, straight to 5 on river should not fold',
    actions => [
        'firster bet',
        'seconder, thirder, fourther, fifther call',
        'sixther cards 2c 5d',
        'sixther call',
        'dealer, sblinder, bblinder call',
        'deal 3d 4s Th',
        'sblinder, bblinder, sixther, dealer check',
        'deal 2h',
        'sblinder, bblinder, sixther, dealer check',
        'deal Ah',
        'sblinder, bblinder check',
    ],
    expected => 'sixther bet',
);

test('second pair should not bet on flop if players >= 4',
    actions => [
        'firster, seconder, thirder fold',
        'fourther, fifther call',
        'sixther cards 8c 8d',
        'sixther call',
        'dealer, sblinder fold',
        'bblinder call',
        'deal 3d 4s Jh',
        'fourther, fifther check',
    ],
    expected => 'sixther check',
);

test('second pair should bet if players == 2',
    actions => [
        'firster, seconder, thirder, fourther, fifther fold',
        'sixther cards 8c 8d',
        'sixther bet',
        'dealer, sblinder fold',
        'bblinder call',
        'deal 3d 4s Jh',
        'bblinder check',
    ],
    expected => 'sixther bet',
);

test('over pair should call raise behind even if there are 3 cards over 9',
    actions => [
        'firster, seconder, thirder, fourther, fifther fold',
        'sixther cards Kc Kd',
        'sixther bet',
        'dealer, sblinder fold',
        'bblinder call',
        'deal 3d Ts Jh',
        'bblinder check',
        'sixther bet',
        'deal Qs',
        'bblinder check',
        'sixther bet',
        'bblinder bet',
    ],
    expected => 'sixther call',
);

test('AK should bet on last position if has straight draw even if the board pair high, just to know where we are',
    actions => [
        'firster, seconder, thirder, fourther, fifther fold',
        'sixther cards Ac Kd',
        'sixther bet',
        'dealer, sblinder fold',
        'bblinder call',
        'deal Td Qs Qh',
        'bblinder check',
        'sixther bet',
        'deal Qs',
        'bblinder check',
    ],
    expected => 'sixther bet',
);

test('AT on big blind should not fold 1 bet from middle position',
    actions => [
        'firster, seconder, thirder, fourther, fifther fold',
        'sixther bet',
        'dealer, sblinder fold',
        'bblinder cards Ad Tc',
    ],
    expected => 'bblinder call',
);

test('KQ second pair should not call one bet',
    actions => [
        'firster, seconder, thirder, fourther fold',
        'fifther bet',
        'sixther call',
        'dealer cards Kd Qd',
        'dealer call',
        'sblinder, bblinder fold',
        'deal Ad Qh 7h',
        'fifther check',
        'sixther bet',
    ],
    expected => 'dealer fold',
);

test('AX should bet if on dealer and everyone else fold',
    actions => [
        'firster, seconder, thirder, fourther, fifther, sixther fold',
        'dealer cards Ad 7h'
    ],
    expected => 'dealer bet',
);

test('AX should bet if on dealer and everyone else fold, call raise behind',
    actions => [
        'firster, seconder, thirder, fourther, fifther, sixther fold',
        'dealer cards Ad 7h',
        'dealer bet',
        'sblinder fold',
        'bblinder bet',
    ],
    expected => 'dealer call',
);

test('AJ should call bet from middle position',
    actions => [
        'firster, seconder, thirder, fourther fold',
        'fifther bet',
        'sixther cards Ad Jh',
    ],
    expected => 'sixther call',
);

test('9988 should not continue bet on 4 players',
    actions => [
        'firster, seconder, thirder fold',
        'fourther call',
        'fifther cards 8d 8c',
        'fifther bet',
        'dealer fold',
        'sblinder, bblinder, fourther call',
        'deal Jd 4h 3d',
        'fourther check',
    ],
    expected => 'fifther check',
);
