#!/usr/bin/perl
package Card;
use lib '.';

# Constructor
sub new {
    my ($class, $face, $suit) = @_;
    my $self = {
        face     => $face,
        suit     => $suit,
        handValue => 0.0,
    };
    bless $self, $class;  # Bless the hash into the Card package
    return $self;
}

# Getter for face
sub getFace {
    my ($self) = @_;
    return $self->{face};
}

# Getter for suit
sub getSuit {
    my ($self) = @_;
    return $self->{suit};
}

# Calculate the face value
sub faceValue {
    my ($self) = @_;
    
    if ($self->{face} eq "2") {
        return 2;
    } elsif ($self->{face} eq "3") {
        return 3;
    } elsif ($self->{face} eq "4") {
        return 4;
    } elsif ($self->{face} eq "5") {
        return 5;
    } elsif ($self->{face} eq "6") {
        return 6;
    } elsif ($self->{face} eq "7") {
        return 7;
    } elsif ($self->{face} eq "8") {
        return 8;
    } elsif ($self->{face} eq "9") {
        return 9;
    } elsif ($self->{face} eq "10") {
        return 10;
    } elsif ($self->{face} eq "J") {
        return 11;
    } elsif ($self->{face} eq "Q") {
        return 12;
    } elsif ($self->{face} eq "K") {
        return 13;
    } elsif ($self->{face} eq "A") {
        return 14;
    } else {
        return 0;  # Default return value for invalid face
    }
}

# Calculate the suit value
sub suitValue {
    my ($self) = @_;
    
    if ($self->{suit} eq "D") {
        return 0.1;
    } elsif ($self->{suit} eq "C") {
        return 0.2;
    } elsif ($self->{suit} eq "H") {
        return 0.3;
    } elsif ($self->{suit} eq "S") {
        return 0.4;
    } else {
        return 0;  # Default return value for invalid suit
    }
}

# Set the hand value
sub setHandValue {
    my ($self, $handValue) = @_;
    $self->{handValue} += $handValue;
}

# Get the hand value
sub getHandValue {
    my ($self) = @_;
    return $self->{handValue};
}

# To string (string representation of the card)
sub toString {
    my ($self) = @_;
    return $self->{face} . $self->{suit};
}

1;  # End of Card package