package Java;
import java.util.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class FiveCard {

    public static void main(String[] args) {
        if (args.length == 0) {
            // Initialize deck with ordered cards
            List<Card> deck = createOrderedDeck();
            // Shuffle the deck to randomize card order
            Collections.shuffle(deck);

            // Display introductory messages and the shuffled deck
            System.out.println("*** P O K E R H A N D A N A L Y Z E R ***");
            System.out.println();
            System.out.println("*** USING RANDOMIZED DECK OF CARDS ***");
            System.out.println();
            System.out.println("*** Shuffled 52 card deck:");
            displayDeck(deck);
            
            // Display each hand
            System.out.println("*** Here are the six hands...");
            
            for (int i = 0; i < 6; i++) {
              // Extract 5 cards for the current hand from the deck
              List<Card> handCards = new ArrayList<>(deck.subList(i * 5, i * 5 + 5));
              for (int j = 0; j < handCards.size(); j++){
                System.out.print(handCards.get(j) + " ");
              }
              System.out.println();
            }

            // Deal six hands of poker from the shuffled deck
            List<Hand> hands = dealHands(deck);

            System.out.println();
            // Display remaining cards in the deck
            System.out.println("*** Here is what remains in the deck...");
            displayDeck(deck);
            System.out.println();

            // Sort hands based on their poker rank
            Collections.sort(hands);

            // Reverse the order of hands to show the highest rank first
            Collections.reverse(hands);
            System.out.println("--- WINNING HAND ORDER ---");

            // Display each hand with its rank name
            for (Hand hand : hands) {
                System.out.println(String.format("%s - %s", hand, hand.getHandType())); //got .format from chatGPT
            }
        } 
        else {
            String filePath = args[0];
            System.out.println("*** P O K E R H A N D A N A L Y Z E R ***");
            System.out.println();
            System.out.println("*** USING TEST DECK ***");
            System.out.println();
            System.out.println("*** File: " + filePath);

            // Display the contents of the file
            try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
              String line;
              while ((line = reader.readLine()) != null) {
                  System.out.println(line);
              }
              // Reset the reader to the beginning of the file
              reader.close();
              System.out.println();
            }catch (IOException e) {
                  e.printStackTrace();
              }

            try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
              List<List<Card>> hands = new ArrayList<>();
              List<String> seenCards = new ArrayList<>();
              boolean hasDuplicate = false;
              String duplicateCard = null;
              String line;
              int handCount = 0;
          
              while ((line = reader.readLine()) != null && handCount < 6) {
                  // Split the line by commas
                  String[] cardRecords = line.split(",");
                  List<Card> hand = new ArrayList<>();
          
                  // Process each card record
                  for (String cardRecord : cardRecords) {
                      // Trim spaces and create a Card object
                      String cardValue = cardRecord.trim();
                      if (!cardValue.isEmpty()) {
                          String card = cardValue.substring(0, cardValue.length() - 1) + cardValue.substring(cardValue.length() - 1);
                          
                          // Check for duplicates using the List
                          if (seenCards.contains(card)) {
                              hasDuplicate = true;
                              duplicateCard = card;
                          }
                          seenCards.add(card);
                          hand.add(new Card(cardValue.substring(0, cardValue.length() - 1), cardValue.substring(cardValue.length() - 1)));
                          
                      }
                  }
                  hands.add(hand);
                  handCount++;
                }
                  List<Hand> handsList = new ArrayList<>();
                  for (List<Card> cardList : hands) {
                      Hand hand = new Hand(cardList);
                      hand.setUnsorted(cardList);
                      handsList.add(hand);
                  }
              
                  // Print the hands to verify
                  System.out.println("*** Here are the six hands...");
                  for (Hand hand : handsList) {
                      displayHand(hand);
                  }
              
                  System.out.println();
              
                  // If a duplicate was found, print the error and exit
                  if (hasDuplicate) {
                      System.out.println("*** ERROR - DUPLICATED CARD FOUND IN DECK ***");
                      System.out.println();
                      System.out.println("*** DUPLICATE: " + duplicateCard + " ***");
                      return;
                  }
              
                  // Sort hands based on their hand value
                  Collections.sort(handsList);
              
                  // Reverse the order of hands to show the highest rank first
                  Collections.reverse(handsList);
                  System.out.println("--- WINNING HAND ORDER ---");
              
                  // Display each hand with its rank name
                  for (Hand hand : handsList) {
                      System.out.println(String.format("%s - %s", hand, hand.getHandType()));
                  }
              
              } catch (IOException e) {
                  e.printStackTrace();
    }
  }
}

    // Create and return a standard ordered deck of 52 cards
    private static List<Card> createOrderedDeck() {
        List<Card> deck = new ArrayList<>();
        // Suits and face values for cards
        String[] suits = {"D", "C", "H", "S"};  // D: Diamonds, C: Clubs, H: Hearts, S: Spades
        String[] faces = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"};

        // Generate cards for each combination of suit and face
        for (String suit : suits) {
            for (String face : faces) {
                deck.add(new Card(face, suit));
            }
        }

        return deck;
    }

    // Display the cards in the deck
    private static void displayDeck(List<Card> deck) {
        for (int i = 0; i < deck.size(); i++) {
            // Print each card
            System.out.print(String.format("%3s", deck.get(i)) + " ");
            // Print a newline after every 13 cards to format deck into 4 rows
            if ((i + 1) % 13 == 0) {
                System.out.println();
            }
        }
        System.out.println(); 
    }

    // Deal 6 hands of 5 cards each from the deck
    private static List<Hand> dealHands(List<Card> deck) {
        List<Hand> hands = new ArrayList<>();
        // Create 6 hands, each containing 5 cards
        for (int i = 0; i < 6; i++) {
            // Extract 5 cards for the current hand from the deck
            List<Card> handCards = new ArrayList<>(deck.subList(i * 5, i * 5 + 5));
            hands.add(new Hand(handCards));
            hands.get(i).setUnsorted(deck.subList(i * 5, i * 5 + 5));
        }

        // Remove the dealt cards from the deck
        deck.subList(0, 30).clear();  // 6 hands * 5 cards each = 30 cards

        return hands;
    }

    // Display a single hand of cards
    private static void displayHand(Hand hand) {
        for (Card card : hand.getCards()) {
            // Print each card in the hand
            System.out.print(String.format("%3s", card) + " ");
        }
        System.out.println(); 
    }
}