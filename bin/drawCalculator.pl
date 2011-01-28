#!/usr/bin/perl

if ($ARGV[0] == 'help') {
  print "./drawCalculator.pl <number of draw> <number of out>\n"; 
  exit(0);
}

use constant NUMBER_OF_DEAL => 1000000;
my $numberOfCards = $ARGV[0];
my $numberOfOuts  = $ARGV[1];

my $drawSuccess = 0;
for $deal (1 .. NUMBER_OF_DEAL) {
    @cards = deal();
    $drawSuccess++ if drawSuccess(@cards);
}

my $odd = ($drawSuccess / NUMBER_OF_DEAL) * 100;
print "Number of success draw: $drawSuccess\n";
print "Odd is: $odd \%\n";

sub deal {
  my @cards = ();
  for my $cardNo (0 .. $numberOfCards - 1) {
    push @cards, ($cardNo + int(rand(50 - $cardNo)));
  }

  return @cards;
}

sub drawSuccess {
  my (@cards) = @_;
  foreach my $card (@cards) {
    return 1 if ($card >= (50 - $numberOfOuts)); 
  }

  return 0;
}

sub printCards {
  my (@cards) = @_;
  foreach my $card (@cards) {
    print "$card ";
  }
  print "\n";
}
