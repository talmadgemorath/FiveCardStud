#ifndef CARD_H
#define CARD_H

#include <iostream>
#include <string>

using namespace std; 

class Card {
private:
    string face;
    string suit;
    double handValue; // For sorting within the hand

public:
    // Constructor
    Card(string face, string suit);
    

    // Class methods
    string getFace() const;
    string getSuit() const;
    double faceValue() const;
    double suitValue() const;
    void setHandValue(double handValue);
    double getHandValue() const;
    string toString() const;
    friend ostream& operator<<(ostream& os, const Card& card);
};

#endif // CARD_H