#include "Card.h"
#include <iostream>
#include <math.h>

     Card::Card(string face, string suit) {
        this -> face = face;
        this -> suit = suit;
        this -> handValue=0.0;
    }

    string Card::getFace() const{
        return face;
    }

    string Card::getSuit() const{
        return suit;
    }

    double Card::faceValue() const {
        if (face == "2") {
            return 2.0;
        } else if (face == "3") {
            return 3.0;
        } else if (face == "4") {
            return 4.0;
        } else if (face == "5") {
            return 5.0;
        } else if (face == "6") {
            return 6.0;
        } else if (face == "7") {
            return 7.0;
        } else if (face == "8") {
            return 8.0;
        } else if (face == "9") {
            return 9.0;
        } else if (face == "10") {
            return 10.0;
        } else if (face == "J") {
            return 11.0;
        } else if (face == "Q") {
            return 12.0;
        } else if (face == "K") {
            return 13.0;
        } else if (face == "A") {
            return 14.0;
        } else {
            return 0.0; 
        }
    }

double Card::suitValue() const {
    if (suit == "D") {
        return 0.1;
    } else if (suit == "C") {
        return 0.2;
    } else if (suit == "H") {
        return 0.3;
    } else if (suit == "S") {
        return 0.4;
    } else {
        return 0.0; 
    }
}

    void Card::setHandValue(double handValue2) {
        this -> handValue = this-> handValue + handValue2;
    }

    double Card::getHandValue() const{
        return handValue;
    }

    string Card::toString() const{
        return face + suit;
    }
    
    std::ostream& operator<<(std::ostream& os, const Card& card){
        os << card.toString(); // Use the toString method for output
        return os;
    }
