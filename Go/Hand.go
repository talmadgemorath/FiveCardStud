package main

import (
	"fmt"
	"sort"
)

// Hand represents a poker hand, containing 5 cards
type Hand struct {
	cards       []*Card       // List of cards in the hand
	unsorted    []*Card       // Original unsorted list of cards
	handType    string        // Type of the hand (e.g., "Pair", "Full House")
	keyCards    []*Card       // Key cards that define the hand (e.g., the pair in a "One Pair")
	kickers     []*Card       // Remaining cards in the hand that don't contribute to the hand type
}

// NewHand creates a new hand from a list of cards
func NewHand(cards []*Card) *Hand {
	hand := &Hand{
		cards:    append([]*Card{}, cards...),
		unsorted: append([]*Card{}, cards...),
	}
	hand.separateKeyCardsAndKickers()
	hand.sortHand()
	hand.evaluateHand()
	return hand
}

// Create a custom type for a slice of *Hand pointers
type HandSlice []*Hand

// Implement sort.Interface for HandSlice
func (h HandSlice) Len() int {
	return len(h)
}

func (h HandSlice) Swap(i, j int) {
	h[i], h[j] = h[j], h[i]
}

func (h HandSlice) Less(i, j int) bool {
	// Sort hands by rank (ascending order)
	// Change the comparison to "<" to reverse the order (descending)
	return h[i].CompareTo(h[j]) < 0
}

// GetCards returns the cards in the hand
func (h *Hand) GetCards() []*Card {
	return h.cards
}

// GetUnsortedCards returns the unsorted cards in the hand
func (h *Hand) GetUnsortedCards() []*Card {
	return h.unsorted
}

// SetUnsorted sets the unsorted list of cards for the hand
func (h *Hand) SetUnsorted(cards []*Card) {
	h.unsorted = append([]*Card{}, cards...)
}

// GetHandType returns the type of the hand (e.g., "Pair", "Straight")
func (h *Hand) GetHandType() string {
	return h.handType
}

// ToString returns a string representation of the hand
func (h *Hand) ToString() string {
	var result string
	for _, card := range h.unsorted {
		result += fmt.Sprintf("%3s ", card.String()) // Format each card in the hand
	}
	return result
}

// EvaluateHand determines the type of the hand (e.g., "Flush", "Straight", etc.)
func (h *Hand) evaluateHand() {
	// Initialize an array to count the occurrences of each face value
	faceCounts := make([]int, 15)
	for _, card := range h.cards {
		faceCounts[int(card.FaceValueNumeric())]++
	}

	// Check if the hand is a flush and/or a straight
	isFlush := h.isFlush()
	isStraight := h.isStraight()

	// Determine hand type and assign base value to each card
	if isFlush && isStraight {
		if faceCounts[14] > 0 && faceCounts[13] > 0 {
			h.handType = "Royal Flush"
			h.setHandValueToCards(1000)
		} else {
			h.handType = "Straight Flush"
			h.setHandValueToCards(900)
		}
	} else if h.containsNOfAKind(faceCounts, 4) {
		h.handType = "Four of a Kind"
		h.setHandValueToCards(800)
	} else if h.containsNOfAKind(faceCounts, 3) && h.containsNOfAKind(faceCounts, 2) {
		h.handType = "Full House"
		h.setHandValueToCards(700)
	} else if isFlush {
		h.handType = "Flush"
		h.setHandValueToCards(600)
	} else if isStraight {
		h.handType = "Straight"
		h.setHandValueToCards(500)
	} else if h.containsNOfAKind(faceCounts, 3) {
		h.handType = "Three of a Kind"
		h.setHandValueToCards(400)
	} else if h.countPairs(faceCounts) == 2 {
		h.handType = "Two Pair"
		h.setHandValueToCards(300)
	} else if h.containsNOfAKind(faceCounts, 2) {
		h.handType = "One Pair"
		h.setHandValueToCards(200)
	} else {
		h.handType = "High Card"
		h.setHandValueToCards(100)
	}
}

// SetHandValueToCards assigns a value to each card based on the hand type
func (h *Hand) setHandValueToCards(baseValue int) {
	for _, card := range h.cards {
		var handValue float64
		if h.handType != "One Pair" && h.handType != "Two Pair" {
			handValue = float64(baseValue) + card.FaceValueNumeric() + card.SuitValueNumeric()
		} else {
			handValue = float64(baseValue) + card.FaceValueNumeric()
		}
		card.SetHandValue(handValue)
	}
}

// IsFlush checks if the hand is a flush (all cards have the same suit)
func (h *Hand) isFlush() bool {
	suit := h.cards[0].Suit
	for _, card := range h.cards {
		if card.Suit != suit {
			return false
		}
	}
	return true
}

// IsStraight checks if the hand is a straight (cards form a sequence)
func (h *Hand) isStraight() bool {
	var values []int
	for _, card := range h.cards {
		values = append(values, int(card.FaceValueNumeric()))
	}
	sort.Ints(values)

	// Check for Ace-low straight (A-2-3-4-5)
	if(len(values)>=5){
    if values[0] == 2 && values[4] == 14 && values[1] == 3 && values[2] == 4 && values[3] == 5 {
  		return true
  	}
 }

	// Check for regular straight
 
	for i := 1; i < len(values); i++ {
		if values[i] != values[i-1]+1 {
			return false
		}
	}
	return true
}

// ContainsNOfAKind checks if the hand contains a certain number of cards with the same face value
func (h *Hand) containsNOfAKind(faceCounts []int, n int) bool {
	for _, count := range faceCounts {
		if count == n {
			return true
		}
	}
	return false
}

// CountPairs counts how many pairs are in the hand
func (h *Hand) countPairs(faceCounts []int) int {
	pairs := 0
	for _, count := range faceCounts {
		if count == 2 {
			pairs++
		}
	}
	return pairs
}

// SeparateKeyCardsAndKickers separates cards into key cards and kickers
func (h *Hand) separateKeyCardsAndKickers() {
	h.keyCards = []*Card{}
	h.kickers = []*Card{}

	faceCounts := make([]int, 15)
	for _, card := range h.cards {
		faceCounts[int(card.FaceValueNumeric())]++
	}

	for _, card := range h.cards {
		if faceCounts[int(card.FaceValueNumeric())] > 1 {
			h.keyCards = append(h.keyCards, card)
		} else {
			h.kickers = append(h.kickers, card)
		}
	}
}

// SortHand sorts the hand based on hand values and priority of key cards
func (h *Hand) sortHand() {
	// Sort key cards and kickers in descending order of hand value
	sort.Slice(h.keyCards, func(i, j int) bool {
		return h.keyCards[i].HandValue > h.keyCards[j].HandValue
	})
	sort.Slice(h.kickers, func(i, j int) bool {
		return h.kickers[i].HandValue > h.kickers[j].HandValue
	})

	// Combine the sorted key cards and kickers into the final hand
	h.cards = append(h.keyCards, h.kickers...)

	// Handle Ace-low straight (Ace used as low card in A-2-3-4-5)
	if h.isStraight() && h.cards[0].FaceValueNumeric() == 14 && h.cards[4].FaceValueNumeric() == 2 {
		h.cards = append(h.cards[1:], h.cards[0])
	}
}

// CompareTo compares this hand with another hand
func (h *Hand) CompareTo(other *Hand) int {
	for i := 0; i < len(h.keyCards); i++ {
		cardComparison := h.cards[i].HandValue - other.cards[i].HandValue
		if cardComparison != 0 {
			if cardComparison > 0 {
				return 1
			}
			return -1
		}
	}
 
 for i := range h.cards {
		h.cards[i].SetHandValue(h.cards[i].SuitValueNumeric()) // Modify HandValue using suitValue
	}
 
	// Compare remaining cards (kickers)
	for i := len(h.keyCards); i < len(h.cards); i++ {
		cardComparison := h.cards[i].HandValue - other.cards[i].HandValue
		if cardComparison != 0 {
			if cardComparison > 0 {
				return 1
			}
			return -1
		}
	}
	return 0 // Hands are equal if all comparisons are equal
}

