package main

import (
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"
 "sort"
 "bufio"
)

// CreateOrderedDeck creates a standard ordered deck of 52 cards.
func CreateOrderedDeck() []Card {
	suits := []string{"D", "C", "H", "S"} // D: Diamonds, C: Clubs, H: Hearts, S: Spades
	faces := []string{"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

	var deck []Card
	for _, suit := range suits {
		for _, face := range faces {
			deck = append(deck, *NewCard(face, suit))
		}
	}

	return deck
}

// DisplayDeck prints the cards in the deck.
func DisplayDeck(deck []Card) {
	for i, card := range deck {
		fmt.Printf("%3s", card.String())
		if (i+1)%13 == 0 {
			fmt.Println()
		} else {
			fmt.Print(" ")
		}
	}
	fmt.Println()
}

// DealHands deals 6 hands of 5 cards each from the deck.
func DealHands(deck []Card) ([]*Hand, []Card) {
    var hands []*Hand // A slice of pointers to Hand
    // Deal 6 hands, each containing 5 cards
    for i := 0; i < 6; i++ {
        var handCards []*Card
        // Create a copy of each card when appending to the hand
        for _, card := range deck[i*5 : (i+1)*5] {
            copiedCard := card // Create a copy of the card
            handCards = append(handCards, &copiedCard) // Append a pointer to the copied card
        }
        // Create a Hand using the NewHand constructor (which returns *Hand)
        hand := NewHand(handCards) // hand is already a *Hand (pointer to Hand)
        hands = append(hands, hand) // Append the pointer (not a pointer to a pointer)
    }
    // Remove the dealt cards from the deck
    remainingDeck := deck[30:] // 6 hands * 5 cards = 30 cards dealt
    return hands, remainingDeck
}

// ShuffleDeck shuffles the deck of cards.
func ShuffleDeck(deck []Card) []Card {
	rand.Seed(time.Now().UnixNano())
	shuffledDeck := make([]Card, len(deck))
	copy(shuffledDeck, deck)
	rand.Shuffle(len(shuffledDeck), func(i, j int) {
		shuffledDeck[i], shuffledDeck[j] = shuffledDeck[j], shuffledDeck[i]
	})
	return shuffledDeck
}

func main() {
	// Check if command line arguments were passed
	if len(os.Args) <= 1 {
		// Initialize deck with ordered cards
		deck := CreateOrderedDeck()

		// Shuffle the deck to randomize card order
		deck = ShuffleDeck(deck)

		// Display introductory messages and the shuffled deck
		fmt.Println("*** P O K E R H A N D A N A L Y Z E R ***")
		fmt.Println()
		fmt.Println("*** USING RANDOMIZED DECK OF CARDS ***")
		fmt.Println()
		fmt.Println("*** Shuffled 52 card deck:")
		DisplayDeck(deck)

		// Display each hand
		fmt.Println("*** Here are the six hands...")

		// Deal six hands of poker from the shuffled deck
		hands, remainingDeck := DealHands(deck)

		// Display each hand
		for _, hand := range hands {
			for _, card := range hand.unsorted {
				fmt.Print(card.String() + " ")
			}
			fmt.Println()
		}

		// Display remaining cards in the deck
		fmt.Println()
		fmt.Println("*** Here is what remains in the deck...")
		DisplayDeck(remainingDeck)
    fmt.Println()

		sort.Sort(HandSlice(hands))
   // Manually reverse the slice
    for i, j := 0, len(hands)-1; i < j; i, j = i+1, j-1 {
        hands[i], hands[j] = hands[j], hands[i]
    }

		// Display winning hand order
		fmt.Println("--- WINNING HAND ORDER ---")
   for _, hand := range hands {
		fmt.Printf("%s - %s\n", hand.ToString(), hand.GetHandType())
	}

	} else {
		// Handle the case when a file path is provided in the arguments
  	filePath := os.Args[1]
	fmt.Println("*** P O K E R H A N D A N A L Y Z E R ***")
	fmt.Println()
	fmt.Println("*** USING TEST DECK ***")
	fmt.Println()
	fmt.Println("*** File: " + filePath)

	// Open the file
	file, err := os.Open(filePath)
	if err != nil {
		// Handle error if file cannot be opened
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close() // Make sure to close the file when done

	// Create a new scanner to read the file line by line
	scanner := bufio.NewScanner(file)

	var hands []*Hand
	seenCards := make(map[string]bool)
	hasDuplicate := false
	var duplicateCard string
	handCount := 0

	// Read the file line by line
	for scanner.Scan() {
		// Stop reading if we already have 6 hands
		if handCount >= 6 {
			break
		}

		// Read the line from the file and trim spaces
		line := strings.TrimSpace(scanner.Text())
    fmt.Println(line)
		cardRecords := strings.Split(line, ",")

		var handCards []*Card // This should be a slice of pointers to Card

		// Process each card in the line
		for _, cardRecord := range cardRecords {
			cardValue := strings.TrimSpace(cardRecord)
				if _, exists := seenCards[cardValue]; exists {
					hasDuplicate = true
					duplicateCard = cardValue
					break
				}

				seenCards[cardValue] = true
        var rank, suit string
        if len(cardValue) == 3 && cardValue[0] == '1' && cardValue[1] == '0' {
            // Special case for '10' as the rank
            rank = "10"
            suit = string(cardValue[2])  // The third character is the suit
        } else {
            // Single character rank
            rank = string(cardValue[0])
            suit = string(cardValue[1])
        }
				// Create a pointer to Card and append it
				newCard := NewCard(rank, suit) // Create the card as a pointer
				handCards = append(handCards, newCard) // Append pointer to the hand
			}
		

		// Add the hand to the hands slice
		hand := NewHand(handCards) // Create a new Hand pointer
		hands = append(hands, hand)

		handCount++

		// Exit early if a duplicate card was found
		if hasDuplicate {
			break
		}
	}

	// If a duplicate was found, print the error and exit
	if hasDuplicate {
		fmt.Println()
    fmt.Println("*** ERROR - DUPLICATED CARD FOUND IN DECK ***")
    fmt.Println()
		fmt.Println("*** DUPLICATE: " + duplicateCard + " ***")
		return
	}

	// Print the hands to verify
 fmt.Println()
	fmt.Println("*** Here are the six hands...")
	for _, hand := range hands {
		fmt.Println(hand.ToString())
	}

	// Sort hands based on their hand type (example, modify sorting logic as needed)
	sort.Sort(HandSlice(hands))

	// Manually reverse the slice to have the highest rank first
	for i, j := 0, len(hands)-1; i < j; i, j = i+1, j-1 {
		hands[i], hands[j] = hands[j], hands[i]
	}

	// Print the sorted hands
	fmt.Println()
	fmt.Println("--- WINNING HAND ORDER ---")
	for _, hand := range hands {
		fmt.Print(hand.ToString())
    fmt.Print(" - ")
    fmt.Print(hand.handType)
    fmt.Println()
	}
	}
}