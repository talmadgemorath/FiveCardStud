#!/usr/bin/perl
# Hand.pm
package Hand;
use lib '.';
use lib './Perl';
use Card;


# Constructor
sub new {
    my ($class, $cards) = @_;
    my $self = {
        cards     => [ @$cards ],     # List of cards in the hand
        unsorted  => [ @$cards ],     # Unsorted list of cards
        handType  => "",               # Type of hand
        keyCards  => [],               # Key cards
        kickers   => [],               # Kicker cards
    };
    bless $self, $class;
    $self->separateKeyCardsAndKickers();  # Separate key cards and kickers
    $self->sortHand();                   # Sort cards based on hand value
    $self->evaluateHand();               # Evaluate the hand type
    return $self;
}

# Getter for cards
sub getCards {
    my ($self) = @_;
    return $self->{cards};
}

# Getter for unsorted cards
sub getUnsortedCards {
    my ($self) = @_;
    return $self->{unsorted};
}

# Setter for unsorted cards
sub setUnsorted {
    my ($self, $card_list) = @_;
    $self->{unsorted} = [ @$card_list ];
}

# Getter for hand type (e.g., "pair", "three of a kind", etc.)
sub getHandType {
    my ($self) = @_;
    return $self->{handType};
}

# String representation of the hand
sub toString {
    my ($self) = @_;
    my $result = "";
    foreach my $card (@{ $self->{unsorted} }) {
        $result .= sprintf("%3s", $card->toString()) . " ";  # Format each card
    }
    return $result;
}

# Evaluate the hand type
sub evaluateHand {
    my ($self) = @_;
    
    # Array to count occurrences of each face value (index 0 is unused)
    my @faceCounts = (0) x 15;  # Index 0 is unused
    for my $card (@{$self->{cards}}) {
        $faceCounts[$card->faceValue()]++;
    }

    # Check if the hand is a flush
    my $isFlush = $self->isFlush();

    # Check if the hand is a straight
    my $isStraight = $self->isStraight();

    # Determine hand type and assign a base value to each card
    if ($isFlush && $isStraight) {
        my $a = 0;
        if ($faceCounts[14] > 0 && $faceCounts[13] > 0) {  # If it includes Ace and King
            $self->{handType} = "Royal Flush";
            $a += 1000;
        } else {
            $self->{handType} = "Straight Flush";
        }
        $a += 9000;
        $self->setHandValueToCards($a);
    } elsif ($self->containsNOfAKind(\@faceCounts, 4)) {
        $self->{handType} = "Four of a Kind";
        $self->setHandValueToCards(8000);
    } elsif ($self->containsNOfAKind(\@faceCounts, 3) && $self->containsNOfAKind(\@faceCounts, 2)) {
        $self->{handType} = "Full House";
        $self->setHandValueToCards(7000);
    } elsif ($isFlush) {
        $self->{handType} = "Flush";
        $self->setHandValueToCards(6000);
    } elsif ($isStraight) {
        $self->{handType} = "Straight";
        $self->setHandValueToCards(5000);
    } elsif ($self->containsNOfAKind(\@faceCounts, 3)) {
        $self->{handType} = "Three of a Kind";
        $self->setHandValueToCards(4000);
    } elsif ($self->countPairs(\@faceCounts) == 2) {
        $self->{handType} = "Two Pair";
        $self->setHandValueToCards(3000);
    } elsif ($self->containsNOfAKind(\@faceCounts, 2)) {
        $self->{handType} = "One Pair";
        $self->setHandValueToCards(2000);
    } else {
        $self->{handType} = "High Card";
        $self->setHandValueToCards(1000);
    }
}

# Set hand value to cards
sub setHandValueToCards {
    my ($self, $baseValue) = @_;
    foreach my $card (@{ $self->{cards} }) {
        my $handValue = $baseValue + $card->faceValue() + $card->suitValue();
        $card->setHandValue($handValue);
    }
}

# Check if there's a card value with exactly n occurrences
sub containsNOfAKind {
    my ($self, $face_counts, $n) = @_;  # Get face_counts array reference and the value of n

    # Iterate over the array of face counts
    foreach my $count (@$face_counts) {
        if ($count == $n) {
            return 1;  # Return true (1) if we find exactly n occurrences
        }
    }
    return 0;  # Return false (0) if no such occurrence is found
}

sub countPairs {
    my ($self, $faceCounts) = @_;  # $faceCounts is the array reference passed to the method
    my $pairs = 0;  # Initialize pair count
    
    # Loop through the array to count pairs
    foreach my $count (@$faceCounts) {  # Dereference the array reference
        if ($count == 2) {
            $pairs++;  # Increment pair count when a 2 is found
        }
    }
    
    return $pairs;  # Return the total number of pairs
}

# Check if hand is a flush (all cards same suit)
sub isFlush {
    my ($self) = @_;
    my $suit = $self->{cards}[0]->getSuit();
    foreach my $card (@{ $self->{cards} }) {
        if ($card->getSuit() ne $suit) {
            return 0;  # False if any card doesn't match
        }
    }
    return 1;  # True if all cards match
}

# Check if hand is a straight
sub isStraight {
    my ($self) = @_;
    my @values;

    # Add the face values of each card to the values array
    foreach my $card (@{ $self->{cards} }) {
        push @values, $card->faceValue();
    }

    # Sort the values in ascending order
    @values = sort { $a <=> $b } @values;

    # Check for Ace-low straight
    if ($values[0] == 2 && $values[4] == 14 &&
        $values[1] == 3 && $values[2] == 4 && $values[3] == 5) {
        return 1;
    }

    # Check if all values are consecutive
    for my $i (1 .. $#values) {
        if ($values[$i] != $values[$i-1] + 1) {
            return 0;
        }
    }

    return 1;
}

# Separate key cards from kickers
sub separateKeyCardsAndKickers {
    my ($self) = @_;
    my $index;
    my @faceCounts = (0) x 15;
    foreach my $card (@{ $self->{cards} }) {
        $index = $card->faceValue();
        $faceCounts[$index]++;
    }

    foreach my $card (@{ $self->{cards} }) {
        $index = $card->faceValue();
        if ($faceCounts[$index] > 1) {
            push @{ $self->{keyCards} }, $card;
        } else {
            push @{ $self->{kickers} }, $card;
        }
    }
}

# Sort hand (key cards and kickers)
sub sortHand {
    my ($self) = @_;

    # Sort key cards and kickers by hand value
    @{ $self->{keyCards} } = sort { $b->faceValue() + $b->suitValue() <=> $a->faceValue() + $a->suitValue() } @{ $self->{keyCards} };
    @{ $self->{kickers} } = sort { $b->faceValue() + $b->suitValue() <=> $a->faceValue() + $a->suitValue() } @{ $self->{kickers} };

    # Combine key cards and kickers into sorted hand
    @{ $self->{cards} } = ( @{ $self->{keyCards} }, @{ $self->{kickers} } );
}

# Compare hands
sub compareTo {
    my ($self, $other) = @_;
    for my $i (0 .. $#{ $self->{keyCards} }) {
        my $cardComparison = $self->{cards}[$i]->getHandValue() <=> $other->{cards}[$i]->getHandValue();
        return $cardComparison if $cardComparison != 0;
    }
    
    foreach my $card (@{$self->{cards}}) {
        # Set the hand value to be the suit value
        $card->setHandValue($card->suitValue());
    }
    
    foreach my $card (@{$other->{cards}}) {
        # Set the hand value to be the suit value
        $card->setHandValue($card->suitValue());
    }

    # Additional tie-breaking logic (compare suit value or kicker cards)
    for my $i ($#{ $self->{keyCards} } .. $#{ $self->{cards} }) {
        my $cardComparison = $self->{cards}[$i]->getHandValue() <=> $other->{cards}[$i]->getHandValue();
        return $cardComparison if $cardComparison != 0;
    }
    return 0;  # Hands are equal
}

1;  # End of Hand package
