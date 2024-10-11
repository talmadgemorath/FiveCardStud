#include <iostream>
#include <vector>
#include <algorithm> // For std::sort

using namespace std;

class Hand {
private:
    vector<Card> cards;      // Vector of cards in the hand
    vector<Card> unsorted;   // Vector of cards in the hand unsorted
    string handType;         // Type of hand (e.g., "pair", "three of a kind", etc.)
    vector<Card> keyCards;   // Cards that form the key part of the hand
    vector<Card> kickers;    // Remaining cards in the hand

    // Class methods
    void evaluateHand();
    void setHandValueToCards(double baseValue);
    bool isFlush();
    bool isStraight();
    bool containsNOfAKind(const vector<int>& faceCounts, int n);
    int countPairs(const vector<int>& faceCounts);
    void separateKeyCardsAndKickers();
    void sortHand();

public:
    // Constructor
    Hand(vector<Card> cards);

    // Class methods
    vector<Card> getCards() const;
    vector<Card> getUnsortedCards() const;
    void setUnsorted(vector<Card> cardList);
    string getHandType();
    string toString() const;
    double compareTo(Hand& other) ;
    bool operator<(Hand& other) ;
    friend std::ostream& operator<<(std::ostream& os, const Hand& hand);
};