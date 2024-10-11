using System;
using System.Collections.Generic; // For collections like List<T>
using System.IO; // For file operations
using MyGame;

public class FiveCard {

    public static void Main(string[] args) {
        if (args.Length == 0) {
            // Initialize deck with ordered cards
            List<Card> deck = createOrderedDeck();
            // Shuffle the deck to randomize card order
            Shuffle(deck);

            // Display introductory messages and the shuffled deck
            Console.WriteLine("*** P O K E R H A N D A N A L Y Z E R ***");
            Console.WriteLine();
            Console.WriteLine("*** USING RANDOMIZED DECK OF CARDS ***");
            Console.WriteLine();
            Console.WriteLine("*** Shuffled 52 card deck:");
            displayDeck(deck);
            
            // Display each hand
            Console.WriteLine("*** Here are the six hands...");
            
            for (int i = 0; i < 6; i++) {
                // Extract 5 cards for the current hand from the deck
                List<Card> handCards = deck.GetRange(i * 5, 5);
                foreach (Card card in handCards) {
                    Console.Write(card + " ");
                }
                Console.WriteLine();
            }

            // Deal six hands of poker from the shuffled deck
            List<Hand> hands = new List<Hand>(dealHands(deck));
            
            //Console.WriteLine(hands[0].ToString());

            Console.WriteLine();
            // Display remaining cards in the deck
            Console.WriteLine("*** Here is what remains in the deck...");
            displayDeck(deck);
            Console.WriteLine();

            // Sort hands based on their poker rank
            SortHands(hands);

            // Reverse the order of hands to show the highest rank first
            hands.Reverse();
            Console.WriteLine("--- WINNING HAND ORDER ---");

            // Display each hand with its rank name
            foreach (Hand hand in hands) {
                Console.WriteLine($"{hand} - {hand.GetHandType()}");
            }
        } 
        else {
            string filePath = args[0];
            Console.WriteLine("*** P O K E R H A N D A N A L Y Z E R ***");
            Console.WriteLine();
            Console.WriteLine("*** USING TEST DECK ***");
            Console.WriteLine();
            Console.WriteLine("*** File: " + filePath);

            // Display the contents of the file
            try {
                using (StreamReader reader = new StreamReader(filePath)) {
                    string line;
                    while ((line = reader.ReadLine()) != null) {
                        Console.WriteLine(line);
                    }
                    Console.WriteLine();
                }
            } catch (IOException e) {
                Console.WriteLine(e.Message);
            }

            try {
                using (StreamReader reader = new StreamReader(filePath)) {
                    List<List<Card>> hands = new List<List<Card>>();
                    List<string> seenCards = new List<string>();
                    bool hasDuplicate = false;
                    string duplicateCard = null;
                    string line;
                    int handCount = 0;

                    while ((line = reader.ReadLine()) != null && handCount < 6) {
                        // Split the line by commas
                        string[] cardRecords = line.Split(',');
                        List<Card> hand = new List<Card>();

                        // Process each card record
                        foreach (string cardRecord in cardRecords) {
                            // Trim spaces and create a Card object
                            string cardValue = cardRecord.Trim();
                            if (!string.IsNullOrEmpty(cardValue)) {
                                string card = cardValue.Substring(0, cardValue.Length - 1) + cardValue.Substring(cardValue.Length - 1);

                                // Check for duplicates using the List
                                if (seenCards.Contains(card)) {
                                    hasDuplicate = true;
                                    duplicateCard = card;
                                }
                                seenCards.Add(card);
                                hand.Add(new Card(cardValue.Substring(0, cardValue.Length - 1), cardValue.Substring(cardValue.Length - 1)));
                            }
                        }
                        hands.Add(hand);
                        handCount++;
                    }

                    List<Hand> handsList = new List<Hand>();
                    foreach (List<Card> cardList in hands) {
                        Hand hand = new Hand(cardList);
                        hand.SetUnsorted(cardList);
                        handsList.Add(hand);
                    }
                    
                    // Print the hands to verify
                    Console.WriteLine("*** Here are the six hands...");
                    foreach (Hand hand in handsList) {
                        Console.WriteLine(hand);
                    }
                    
                    Console.WriteLine();
                    
                    // If a duplicate was found, print the error and exit
                    if (hasDuplicate) {
                        Console.WriteLine("*** ERROR - DUPLICATED CARD FOUND IN DECK ***");
                        Console.WriteLine();
                        Console.WriteLine("*** DUPLICATE: " + duplicateCard + " ***");
                        return;
                    }

                    // Sort hands based on their hand value
                    handsList.Sort();
                    
                    // Reverse the order of hands to show the highest rank first
                    handsList.Reverse();
                    Console.WriteLine("--- WINNING HAND ORDER ---");

                    // Display each hand with its rank name
                    foreach (Hand hand in handsList) {
                        Console.WriteLine($"{hand} - {hand.GetHandType()}");
                    }
                }
            } catch (IOException e) {
                Console.WriteLine(e.Message);
            }
        }
    }

    // Create and return a standard ordered deck of 52 cards
    private static List<Card> createOrderedDeck() {
        List<Card> deck = new List<Card>();
        // Suits and face values for cards
        string[] suits = {"D", "C", "H", "S"};  // D: Diamonds, C: Clubs, H: Hearts, S: Spades
        string[] faces = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"};

        // Generate cards for each combination of suit and face
        foreach (string suit in suits) {
            foreach (string face in faces) {
                deck.Add(new Card(face, suit));
            }
        }

        return deck;
    }

    // Display the cards in the deck
    private static void displayDeck(List<Card> deck) {
        for (int i = 0; i < deck.Count; i++) {
            // Print each card
            Console.Write($"{deck[i],3} ");
            // Print a newline after every 13 cards to format deck into 4 rows
            if ((i + 1) % 13 == 0) {
                Console.WriteLine();
            }
        }
        Console.WriteLine(); 
    }
    
    private static void Shuffle(List<Card> deck) {//Fisher-Yates algorithm given by chatGPT
    Random rng = new Random();
    int n = deck.Count;
    while (n > 1) {
        int k = rng.Next(n--);
        Card temp = deck[n];
        deck[n] = deck[k];
        deck[k] = temp;
    }
}

    // Deal 6 hands of 5 cards each from the deck
    private static List<Hand> dealHands(List<Card> deck) {
        List<Hand> hands = new List<Hand>();
        // Create 6 hands, each containing 5 cards
        for (int i = 0; i < 6; i++) {
            // Extract 5 cards for the current hand from the deck
            List<Card> handCards = deck.GetRange(i * 5, 5);
            hands.Add(new Hand(handCards));
            hands[i].SetUnsorted(deck.GetRange(i * 5, 5));
        }

        // Remove the dealt cards from the deck
        deck.RemoveRange(0, 30);  // 6 hands * 5 cards each = 30 cards

        return hands;
    }

    // Display a single hand of cards
    private static void displayHand(Hand hand) {
        foreach (Card card in hand.GetCards()) {
            // Print each card in the hand
            Console.Write($"{card,3} ");
        }
        Console.WriteLine(); 
    }
    
    private static void SortHands(List<Hand> hands){
       //Console.WriteLine("Starting the sort...");
       
        int n = hands.Count;
        bool swapped;
    
        // Outer loop for each pass
        for (int i = 0; i < n - 1; i++)
        {
            swapped = false;
    
            // Inner loop for comparing adjacent elements
            for (int j = 0; j < n - i - 1; j++)
            {
                // Use the CompareTo method to determine the order
                if (hands[j].CompareTo(hands[j + 1]) > 0)
                {
                    // Swap if they are in the wrong order
                    Hand temp = hands[j];
                    hands[j] = hands[j + 1];
                    hands[j + 1] = temp;
    
                    swapped = true; // Mark that a swap has occurred
                }
            }
    
            // If no swaps occurred, the list is already sorted
            if (!swapped){
                break;
            }
        }
    }
    
}