#include <iostream>
#include <vector>
#include <string>
#include <utility> // For std::swap
#include <algorithm>
#include <fstream>
#include <chrono> // For getting the current time
#include <sstream>
#include <iomanip>
#include <random>
#include "Card.h"
#include "Hand.h"

using namespace std;

// Create and return a standard ordered deck of 52 cards
vector<Card> createOrderedDeck() {
    vector<Card> deck;
    // Suits and face values for cards
    string suits[] = {"D", "C", "H", "S"};  // D: Diamonds, C: Clubs, H: Hearts, S: Spades
    string faces[] = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"};

    // Generate cards for each combination of suit and face
    for (const string& suit : suits) {
        for (const string& face : faces) {
            deck.push_back(Card(face, suit));
        }
    }

    return deck;
}

// Display the cards in the deck
void displayDeck(const vector<Card>& deck) {
    for (size_t i = 0; i < deck.size(); i++) {
        // Print each card (setw() was given by chatGPT)
        cout << setw(3) << deck[i] << " ";
        // Print a newline after every 13 cards to format deck into 4 rows
        if ((i + 1) % 13 == 0) {
            cout << endl;
        }
    }
    cout << endl; 
}

// Deal 6 hands of 5 cards each from the deck
vector<Hand> dealHands(vector<Card>& deck) {
    vector<Hand> hands;
    // Create 6 hands, each containing 5 cards
    for (int i = 0; i < 6; i++) {
        // Extract 5 cards for the current hand from the deck
        vector<Card> handCards(deck.begin() + i * 5, deck.begin() + i * 5 + 5);
        hands.push_back(Hand(handCards));
        hands[i].setUnsorted(vector<Card>(deck.begin() + i * 5, deck.begin() + i * 5 + 5));
    }

    // Remove the dealt cards from the deck
    deck.erase(deck.begin(), deck.begin() + 30);  // 6 hands * 5 cards each = 30 cards

    return hands;
}

// Display a single hand of cards
void displayHand(const Hand& hand) {
    for (const Card& card : hand.getCards()) {
        // Print each card in the hand
        cout << setw(3) << card << " ";
    }
    cout << endl; 
}

// Simple trim function
std::string trim(const std::string& str) {
    // Remove leading whitespace
    size_t start = str.find_first_not_of(" \t\n\r\f\v");
    // Remove trailing whitespace
    size_t end = str.find_last_not_of(" \t\n\r\f\v");

    // If the string is empty after trimming
    if (start == std::string::npos) {
        return ""; // or return str if you want to keep original for empty strings
    }

    // Return the trimmed substring
    return str.substr(start, end - start + 1);
}



int main(int argc, char* argv[]) {
    if (argc == 1) {
        // Initialize deck with ordered cards
        vector<Card> deck = createOrderedDeck();
        // Shuffle the deck to randomize card order
        // Seed the random number generator with the current time (given by chatGPT)
        unsigned seed = chrono::system_clock::now().time_since_epoch().count();
        shuffle(deck.begin(), deck.end(), std::default_random_engine(seed));

        // Display introductory messages and the shuffled deck
        cout << "*** P O K E R H A N D A N A L Y Z E R ***" << endl;
        cout << endl;
        cout << "*** USING RANDOMIZED DECK OF CARDS ***" << endl;
        cout << endl;
        cout << "*** Shuffled 52 card deck:" << endl;
        displayDeck(deck);
        
        // Display each hand
        cout << "*** Here are the six hands..." << endl;
        
        for (int i = 0; i < 6; i++) {
            // Extract 5 cards for the current hand from the deck
            vector<Card> handCards(deck.begin() + i * 5, deck.begin() + i * 5 + 5);
            for (size_t j = 0; j < handCards.size(); j++) {
                cout << handCards[j] << " ";
            }
            cout << endl;
        }

        // Deal six hands of poker from the shuffled deck
        vector<Hand> hands = dealHands(deck);

        cout << endl;
        // Display remaining cards in the deck
        cout << "*** Here is what remains in the deck..." << endl;
        displayDeck(deck);
        cout << endl;

        // Sort hands based on their poker rank
        sort(hands.begin(), hands.end());

        // Reverse the order of hands to show the highest rank first
        reverse(hands.begin(), hands.end());
        cout << "--- WINNING HAND ORDER ---" << endl;

        // Display each hand with its rank name
        for (Hand& hand : hands) {
            cout << hand << " - " << hand.getHandType() << endl; // Format each hand
        }
    } else {
        string filePath = argv[1];
        cout << "*** P O K E R H A N D A N A L Y Z E R ***" << endl;
        cout << endl;
        cout << "*** USING TEST DECK ***" << endl;
        cout << endl;
        cout << "*** File: " << filePath << endl;

        // Display the contents of the file
        ifstream reader(filePath);
        string line;
        while (getline(reader, line)) {
            cout << line << endl;
        }
        reader.close();
        cout << endl;

        ifstream reader2(filePath);
        vector<vector<Card>> hands;
        vector<string> seenCards;
        bool hasDuplicate = false;
        string duplicateCard;
        int handCount = 0;

        while (getline(reader2, line) && handCount < 6) {
            // Split the line by commas
            stringstream ss(line);
            string cardRecord;
            vector<Card> hand;

            // Process each card record
            while (getline(ss, cardRecord, ',')) {
                string cardValue = cardRecord;
                if (!cardValue.empty()) {
                    cardValue = trim(cardValue.substr(0, cardValue.size() - 1)) + trim(cardValue.substr(cardValue.size() - 1));
                    
                    // Check for duplicates using the vector
                    if (find(seenCards.begin(), seenCards.end(), cardValue) != seenCards.end()) {
                        hasDuplicate = true;
                        duplicateCard = cardValue;
                    }
                    seenCards.push_back(cardValue);
                    hand.push_back(Card(cardValue.substr(0, cardValue.size() - 1), cardValue.substr(cardValue.size() - 1)));
                }
            }
            hands.push_back(hand);
            handCount++;
        }
        vector<Hand> handsList;
        for (vector<Card>& cardList : hands) {
            vector <Card> unsortedVector;
            for(int i=0;i<cardList.size();i++){
              unsortedVector.push_back(cardList[i]);
            }
            Hand hand(cardList);
            hand.setUnsorted(unsortedVector);
            handsList.push_back(hand);
        }
    
        // Print the hands to verify
        cout << "*** Here are the six hands..." << endl;
        for (Hand& hand : handsList) {
            cout << hand << endl;
        }
    
        cout << endl;
    
        // If a duplicate was found, print the error and exit
        if (hasDuplicate) {
            cout << "*** ERROR - DUPLICATED CARD FOUND IN DECK ***" << endl;
            cout << endl;
            cout << "*** DUPLICATE: " << duplicateCard << " ***" << endl;
            return 0;
        }
    
    
        // Sort hands based on their hand value
        sort(handsList.begin(), handsList.end());
    
    
        // Reverse the order of hands to show the highest rank first
        reverse(handsList.begin(), handsList.end());
        cout << "--- WINNING HAND ORDER ---" << endl;
    
        // Display each hand with its rank name
        for (Hand& hand : handsList) {
            cout << hand;
            cout << " - ";
            cout << hand.getHandType() << endl;
        }
    }

    return 0;
}