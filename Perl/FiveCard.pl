#!/usr/bin/perl
# FiveCard.pm
package FiveCard;
use lib '.';
use lib './Perl';
use strict;
use warnings;
use Card;
use Hand;
use List::Util 'shuffle';  # Import shuffle function


# Read the file and tokenize the cards
sub processFile {
    my $file_path = $ARGV[0];
    open my $fh, '<', $file_path or die "Could not open file '$file_path': $!\n";
    
    my @deck;  # Create an empty array to hold all the cards in the deck
    my %seen_cards;
    my $has_duplicate = 0;
    my $duplicate_card;

    # Read each line of the file and tokenize the cards
    while (my $line = <$fh>) {
        print $line;  # Display the line from the file
        chomp $line;
        my @card_records = split(',', $line);  # Tokenizing by commas
        
        foreach my $card_str (@card_records) {
    
    # Check if the last character is a newline and remove it if present
    if (substr($card_str, -1) eq "\n") {
        $card_str = substr($card_str, 0, length($card_str) - 1);
    }
    
    # Define a valid character set (letters and digits)
    my $valid_characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    # Get the last character (card suit) from the card string
    my $card_suit = substr($card_str, length($card_str) - 1, 1);
    
    # Check if the last character is valid (in the valid character set)
    if (index($valid_characters, $card_suit) == -1) {
        # If not valid, remove the last character
        $card_str = substr($card_str, 0, length($card_str) - 1);
        
        # Update the card suit
        $card_suit = substr($card_str, length($card_str) - 1, 1);
    }
    
    # Now extract the card face (everything except the suit)
    my $card_face = trim(substr($card_str, 0, length($card_str) - 1));
    
    # Create the Card object
    my $card = Card->new($card_face, $card_suit);

    # Check for duplicates
    if ($seen_cards{$card->toString()}) {
        $has_duplicate = 1;
        $duplicate_card = $card->toString();
        last;
    }
    
    $seen_cards{$card->toString()} = 1;
    
    push @deck, $card;  # Add the card to the deck
}

        last if $has_duplicate;  # Stop processing the file if duplicate found
    }

    close $fh;

    # Check if a duplicate card was found
    if ($has_duplicate) {
        print "\n\n";
        print "*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n";
        print "\n*** DUPLICATE: $duplicate_card ***\n";
        return;
    }

    # Now, we have the exact deck as it was in the file.
    # No shuffling is needed, just proceed to deal the hands.

    # Deal hands from the deck (without shuffling)
    my $hands = dealHands(\@deck);
    print "\n";
    print "\n*** Here are the six hands...\n";
    for my $hand (@$hands) {
        print $hand->toString() . "\n";
    }

    # Sort hands based on their hand value (or a custom comparison logic)
    my @sorted_hands = sort { $b->compareTo($a) } @$hands;
    
    # Display sorted hands
    print "\n--- WINNING HAND ORDER ---\n";
    for my $hand (@sorted_hands) {
        print $hand->toString();
        print " - ";
        print $hand->{handType};
        print "\n";
    }
}

# Deal 6 hands of 5 cards each from the deck
sub dealHands {
    my ($deck) = @_;
    my @hands;

    # Create 6 hands, each containing 5 cards
    for my $i (0 .. 5) {
        # Extract 5 cards for the current hand from the deck
        my @hand_cards = @$deck[$i * 5 .. $i * 5 + 4];
        
        # Create a new Hand object and add it to the hands array
        my $hand = Hand->new(\@hand_cards);  # Pass array reference
        $hand->setUnsorted([@hand_cards]);  # Store unsorted cards in the hand object
        push @hands, $hand;
    }

    # Remove the dealt cards from the deck
    splice @$deck, 0, 30;  # Remove first 30 cards (6 hands * 5 cards)

    return \@hands;
}

sub trim {
    my $str = shift;  # Take the input string
    $str =~ s/^\s+|\s+$//g;  # Remove leading and trailing whitespace
    return $str;  # Return the trimmed string
}

# Create and return a standard ordered deck of 52 cards
sub createOrderedDeck {
    my ($deck) = @_;
    my @suits = ("D", "C", "H", "S");  # D: Diamonds, C: Clubs, H: Hearts, S: Spades
    my @faces = ("2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A");
    
    # Generate cards for each combination of suit and face
    foreach my $suit (@suits) {
        foreach my $face (@faces) {
            my $card = Card->new($face, $suit);  # Create new Card object
            push @$deck, $card;  # Add the card to the deck
        }
    }

    return \@$deck;  # Return the deck as a reference to an array of Card objects
}

# Display a single hand of cards
sub displayDeck {
    my ($deck) = @_;
    my $counter=0;
    foreach my $card (@$deck) {
        print $card->toString();
        $counter++;
        print " ";
        if($counter==13){
            print "\n";
            $counter=0;
        }
    }
    print "\n";
}

# Fisher-Yates Shuffle Algorithm
sub shuffle_deck {
    my ($deck) = @_;
    
    # Get the size of the deck (number of elements in the array)
    my $deck_size = @$deck;
    
    # Loop from the last element down to the second element
    for my $i (reverse 1..$deck_size-1) {
        # Pick a random index between 0 and i
        my $j = int(rand($i + 1));  # Random index between 0 and i
        
        # Swap the elements at indices i and j
        @$deck[$i, $j] = @$deck[$j, $i];
    }
}

# Main logic for FiveCard
    my $file_path = $ARGV[0];  # Get the file path from the command line argument

if (!$file_path) {
    # Initialize deck with ordered cards
    my $deck=[];
    $deck = createOrderedDeck($deck);
    
    # Shuffle the deck to randomize card order
    shuffle_deck($deck);
    
    # Display introductory messages
    print "*** P O K E R H A N D A N A L Y Z E R ***\n\n";
    print "*** USING RANDOMIZED DECK OF CARDS ***\n\n";
    print "*** Shuffled 52 card deck:\n";
    displayDeck($deck);
    
    # Display each hand
    print "*** Here are the six hands...\n";
    my $hands = dealHands($deck);
    for my $hand (@$hands) {
        print $hand->toString() . "\n";
    }
    print "\n";
    # Display remaining cards in the deck
    print "*** Here is what remains in the deck...\n";
    displayDeck($deck);
    print "\n";
    # Sort hands based on some criteria (here it's simply alphabetic by string representation)
    my @sorted_hands = sort { $b->compareTo($a) } @$hands;
    
    # Reverse the order of hands to show the highest rank first (if necessary)
    print "--- WINNING HAND ORDER ---\n";
    for my $hand (@sorted_hands) {
        print $hand->toString();
        print " - ";
        print $hand->{handType};
        print "\n";
    }
} else {
    # Process the file containing the hands
    print "*** P O K E R H A N D A N A L Y Z E R ***\n\n";
    print "*** USING TEST DECK ***\n\n";
    print "*** File: $file_path\n";
    
    processFile($file_path);
}

1;  # End of FiveCard package