#include <iostream>
#include <vector>
#include <algorithm> // For std::sort
#include "Card.h"
#include "Hand.h"

using namespace std;

// Constructor that initializes the hand and evaluates its type
Hand::Hand(vector<Card> cards) {
    this->cards = cards; // Directly initialize the vector
    separateKeyCardsAndKickers(); // Separate key cards from kickers
    sortHand(); // Sort the cards based on hand value
    evaluateHand(); // Determine the type of hand and assign values
}

// Get the list of cards in the hand
vector<Card> Hand::getCards() const {
    return cards;
}

vector<Card> Hand::getUnsortedCards() const {
    return unsorted;
}

void Hand::setUnsorted(vector<Card> cardList) {
    this->unsorted = cardList; // Directly initialize the vector
}

// Get the type of the hand (e.g "pair", "three of a kind")
string Hand::getHandType() {
    return handType;
}

// Generate a string representation of the hand
string Hand::toString() const {
    string result = "";
    for (const Card& card : unsorted) {
        result += card.toString() + " "; // Format each card in the hand
    }
    return result;
}

std::ostream& operator<<(std::ostream& os, const Hand& hand){
    os << hand.toString(); // Use the toString method for output
    return os;
}

// Evaluate the type of hand (e.g., "flush", "straight", etc.)
void Hand::evaluateHand() {
    // Vector to count occurrences of each face value (index 0 is unused)
    vector<int> faceCounts(15, 0);
    for (const Card& card : cards) {
        faceCounts[(int)(card.faceValue())]++;
    }

    // Check if the hand is a flush 
    bool isFlush = this -> isFlush();
    // Check if the hand is a straight 
    bool isStraight = this -> isStraight();

    // Determine hand type and assign a base value to each card
    if (isFlush && isStraight) {
        int a = 0;
        if (faceCounts[14] > 0 && faceCounts[13] > 0) { // if it includes the Ace and King
            handType = "Royal Flush";
            a += 1000;
        } else {
            handType = "Straight Flush"; 
        }
        a += 9000;
        setHandValueToCards(a);
    } else if (containsNOfAKind(faceCounts, 4)) {
        handType = "Four of a Kind";
        setHandValueToCards(8000); 
    } else if (containsNOfAKind(faceCounts, 3) && containsNOfAKind(faceCounts, 2)) {
        handType = "Full House";
        setHandValueToCards(7000); 
    } else if (isFlush) {
        handType = "Flush";
        setHandValueToCards(6000); 
    } else if (isStraight) {
        handType = "Straight";
        setHandValueToCards(5000); 
    } else if (containsNOfAKind(faceCounts, 3)) {
        handType = "Three of a Kind";
        setHandValueToCards(4000); 
    } else if (countPairs(faceCounts) == 2) {
        handType = "Two Pair";
        setHandValueToCards(3000); 
    } else if (containsNOfAKind(faceCounts, 2)) {
        handType = "One Pair";
        setHandValueToCards(2000); 
    } else {
        handType = "High Card";
        setHandValueToCards(1000);
    }
}

void Hand::setHandValueToCards(double baseValue) {
    for (Card& card : cards) {
        double handValue;
        if (handType != "One Pair" && handType != "Two Pair") {
            handValue = baseValue + card.faceValue() + card.suitValue();
            //cout << baseValue << card.faceValue()<<card.suitValue()<<endl;
        } else {
            handValue = baseValue + card.faceValue();
        }
        card.setHandValue(handValue);
    }
}

// Check if all cards in the hand have the same suit
bool Hand::isFlush() {
    string suit = cards[0].getSuit();
    for (const Card& card : cards) {
        if (card.getSuit() != suit) {
            return false;
        }
    }
    return true;
}

// Check if the cards form a straight
bool Hand::isStraight() {
    vector<int> values;
    for (const Card& card : cards) {
        values.push_back(static_cast<int>(card.faceValue()));
    }
    sort(values.begin(), values.end());

    // Check for high Ace straight (10-J-Q-K-A)
    if (values[0] == 2 && values[4] == 14 && values[1] == 3 &&
        values[2] == 4 && values[3] == 5) {
        return true;
    }

    for (size_t i = 1; i < values.size(); i++) {
        if (values[i] != values[i - 1] + 1) {
            return false;
        }
    }
    return true;
}

// Check if there's a card value with exactly n occurrences
bool Hand::containsNOfAKind(const vector<int>& faceCounts, int n) {
    for (int count : faceCounts) {
        if (count == n) {
            return true;
        }
    }
    return false;
}

// Count the number of pairs in the hand
int Hand::countPairs(const vector<int>& faceCounts) {
    int pairs = 0;
    for (int count : faceCounts) {
        if (count == 2) {
            pairs++;
        }
    }
    return pairs;
}

// Separate cards into key cards (cards forming the hand) and kickers (remaining cards)
void Hand::separateKeyCardsAndKickers() {
    keyCards.clear();
    kickers.clear();

    vector<int> faceCounts(15, 0);
    for (const Card& card : cards) {
        faceCounts[static_cast<int>(card.faceValue())]++;
    }

    // Add key cards to keyCards and remaining cards to kickers
    for (const Card& card : cards) {
        if (faceCounts[static_cast<int>(card.faceValue())] > 1) {
            keyCards.push_back(card);
        } else {
            kickers.push_back(card);
        }
    }
}

// Sort key cards and kickers by their hand values
void Hand::sortHand() {
    // Sort key cards and kickers in descending order of face value
    sort(keyCards.begin(), keyCards.end(), [](const Card& a, const Card& b) {
        return b.faceValue() + b.suitValue()< a.faceValue() + b.suitValue();
    });
    sort(kickers.begin(), kickers.end(), [](const Card& a, const Card& b) {
        return b.faceValue() +b.suitValue()< a.faceValue()+a.suitValue();
    });

    // Combine key cards and kickers into the final sorted hand
    cards.clear();
    cards.insert(cards.end(), keyCards.begin(), keyCards.end()); // Add key cards first
    cards.insert(cards.end(), kickers.begin(), kickers.end());   // Add kickers after key cards

    // Adjust for high Ace straight
    if (isStraight() && static_cast<int>(cards[0].faceValue()) == 14 && 
        static_cast<int>(cards[4].faceValue()) == 2) {
        cards.push_back(cards[0]);
        cards.erase(cards.begin()); // Remove the first element
    }
}

// Compare this hand to another hand based on card values
double Hand::compareTo(Hand& other) {
    for (size_t i = 0; i < this-> keyCards.size(); i++) {
        double cardComparison = this->cards[i].getHandValue() - other.cards[i].getHandValue();
        
        if (cardComparison != 0) {
            return cardComparison;
        }
    }
    for (Card& card : cards) { // If the hands are the same, take suit into account
        card.setHandValue(card.suitValue());
    }
    for (size_t i = this -> keyCards.size(); i < cards.size(); i++) {
        double cardComparison = this->cards[i].getHandValue() - other.cards[i].getHandValue();
        
        if (cardComparison != 0) {
            return cardComparison;
        }
    }
    return 0; // Hands are equal if all card comparisons are equal
}

// Overload the < operator
    bool Hand::operator<(Hand& other){
        return compareTo(other) < 0; // Less than zero indicates this is less than 'other'
    }
    