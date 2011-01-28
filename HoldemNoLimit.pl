use strict;
use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../vendor";
use VPoker::Debugger;

BEGIN { log_file("$FindBin::Bin/../botlog.log"); }

use VPoker::PerlOHInteraction;
use VPoker::OpenHoldem;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::Strategy::RuleBased::RuleTable;

$SIG{__WARN__} = sub {
    debug_message(@_);
};

my $strategy  = VPoker::Holdem::Strategy::RuleBased->new;
my $ruleTable = VPoker::Holdem::Strategy::RuleBased::RuleTable->new(
    strategy => $strategy,
    file     => "$FindBin::Bin/../strategy.csv",
);
$strategy->decision('master' => $ruleTable);
use_strategy($strategy);
