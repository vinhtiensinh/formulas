use strict;
use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin/../vpoker/lib";
use lib "$FindBin::Bin/../vpoker/vendor";
use VPoker::OpenHoldem::StrategyLoader;
use VPoker::Holdem::Strategy::RuleBased::Limit;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::Strategy::RuleBased::RuleTable;

use VPoker::OpenHoldem;
use VPoker::Debugger;

BEGIN { log_file("$FindBin::Bin/../botlog-" . time . ".log"); }

use VPoker::PerlOHInteraction;
$SIG{__WARN__} = sub {
    debug_message(@_);
};

my $strategy  = VPoker::Holdem::Strategy::RuleBased::Limit->new;
VPoker::OpenHoldem::StrategyLoader->strategy($strategy, "$FindBin::Bin/Pilot");
VPoker::OpenHoldem::StrategyLoader->load_file($strategy, "$FindBin::Bin/_LimitBetting.vpk");
$strategy->validate();
use_strategy($strategy);
