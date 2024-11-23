package main

import (
	//"fmt"
	"math"
)

// Card represents a playing card with a face and a suit, including hand value for sorting.
type Card struct {
	// Class variables
	FaceValue   string
	SuitValue   string
	HandValue   float64

	// Instance variables
	Face        string
	Suit        string
}

// NewCard creates a new Card object with a specified face and suit.
func NewCard(face, suit string) *Card {
	return &Card{
		Face:      face,
		Suit:      suit,
		FaceValue: face,
		SuitValue: suit,
		HandValue: 0.0,
	}
}

// NewCardWithValues creates a new Card object with a specified face and suit, with hand value set directly.
func NewCardWithValues(face, suit string, handValue float64) *Card {
	return &Card{
		Face:      face,
		Suit:      suit,
		FaceValue: face,
		SuitValue: suit,
		HandValue: handValue,
	}
}

// FaceValueNumeric returns the numeric value of the card face for comparison or sorting.
func (c *Card) FaceValueNumeric() float64 {
	switch c.Face {
	case "2":
		return 2
	case "3":
		return 3
	case "4":
		return 4
	case "5":
		return 5
	case "6":
		return 6
	case "7":
		return 7
	case "8":
		return 8
	case "9":
		return 9
	case "10":
		return 10
	case "J":
		return 11
	case "Q":
		return 12
	case "K":
		return 13
	case "A":
		return 14
	default:
		return 0
	}
}

// SuitValueNumeric returns the numeric value associated with the card's suit.
func (c *Card) SuitValueNumeric() float64 {
	switch c.Suit {
	case "D":
		return 0.1
	case "C":
		return 0.2
	case "H":
		return 0.3
	case "S":
		return 0.4
	default:
		return 0
	}
}

// SetHandValue updates the hand value of the card, used for sorting.
func (c *Card) SetHandValue(handValue float64) {
	c.HandValue += handValue
}

// GetHandValue retrieves the current hand value of the card.
func (c *Card) GetHandValue() float64 {
	return math.Round(c.HandValue*100.0) / 100.0
}

// String returns the string representation of the card, e.g., "2H", "JS".
func (c *Card) String() string {
	return c.Face + c.Suit
}