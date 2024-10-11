from typing import List
from Card import *

class Hand:
    def __init__(self, cards: List['Card']):
        self.cards = list(cards)  # List of cards in the hand
        self.unsorted = []  # List of cards in the hand unsorted
        self.hand_type = ""  # Type of hand (e.g., "pair", "three of a kind", etc.)
        self.key_cards = []  # Cards that form the key part of the hand
        self.kickers = []  # Remaining cards in the hand
        self.separate_key_cards_and_kickers()  # Separate key cards from kickers
        self.evaluate_hand()  # Determine the type of hand and assign values
        self.sort_hand()  # Sort the cards based on hand value

    def get_cards(self):
        return self.cards

    def get_unsorted_cards(self):
        return self.unsorted

    def set_unsorted(self, card_list: List['Card']):
        self.unsorted = list(card_list)

    def get_hand_type(self):
        return self.hand_type

    def __str__(self):
        return ' '.join(str(card).rjust(3) for card in self.unsorted)  
        # Format each card in the hand

    def evaluate_hand(self):
        face_counts = [0] * 15  # Array to count occurrences of each face value
        for card in self.cards:
            face_counts[int(card.face_value())] += 1

        is_flush = self.is_flush()  # Check if the hand is a flush
        is_straight = self.is_straight()  # Check if the hand is a straight

        # Determine hand type and assign a base value to each card
        if is_flush and is_straight:
            if face_counts[14] > 0 and face_counts[13] > 0:  # Includes Ace and King
                self.hand_type = "Royal Flush"
                base_value = 10000
            else:
                self.hand_type = "Straight Flush"
                base_value = 9000
            self.set_hand_value_to_cards(base_value)
        elif self.contains_n_of_a_kind(face_counts, 4):
            self.hand_type = "Four of a Kind"
            self.set_hand_value_to_cards(8000)
        elif self.contains_n_of_a_kind(face_counts, 3) and self.contains_n_of_a_kind(face_counts, 2):
            self.hand_type = "Full House"
            self.set_hand_value_to_cards(7000)
        elif is_flush:
            self.hand_type = "Flush"
            self.set_hand_value_to_cards(6000)
        elif is_straight:
            self.hand_type = "Straight"
            self.set_hand_value_to_cards(5000)
        elif self.contains_n_of_a_kind(face_counts, 3):
            self.hand_type = "Three of a Kind"
            self.set_hand_value_to_cards(4000)
        elif self.count_pairs(face_counts) == 2:
            self.hand_type = "Two Pair"
            self.set_hand_value_to_cards(3000)
        elif self.contains_n_of_a_kind(face_counts, 2):
            self.hand_type = "One Pair"
            self.set_hand_value_to_cards(2000)
        else:
            self.hand_type = "High Card"
            self.set_hand_value_to_cards(1000)

    def set_hand_value_to_cards(self, base_value):
        for card in self.cards:
            if self.hand_type not in ["One Pair", "Two Pair"]:
                hand_value = base_value + card.face_value() + card.suit_value()
            else:
                hand_value = base_value + card.face_value()
            card.set_hand_value(hand_value)

    def is_flush(self):
        suit = self.cards[0].get_suit()
        return all(card.get_suit() == suit for card in self.cards)

    def is_straight(self):
        values = sorted(int(card.face_value()) for card in self.cards)
        
        # Check for high Ace straight (10-J-Q-K-A)
        if values[0] == 2 and values[4] == 14 and values[1] == 3 and values[2] == 4 and values[3] == 5:
            return True

        return all(values[i] == values[i - 1] + 1 for i in range(1, len(values)))

    def contains_n_of_a_kind(self, face_counts, n):
        return any(count == n for count in face_counts)

    def count_pairs(self, face_counts):
        return sum(1 for count in face_counts if count == 2)

    def separate_key_cards_and_kickers(self):
        self.key_cards = []
        self.kickers = []
        face_counts = [0] * 15

        for card in self.cards:
            face_counts[int(card.face_value())] += 1

        for card in self.cards:
            if face_counts[int(card.face_value())] > 1:
                self.key_cards.append(card)
            else:
                self.kickers.append(card)

    def sort_hand(self):
        self.key_cards.sort(key=lambda card: card.face_value()+card.suit_value(), reverse=True)
        self.kickers.sort(key=lambda card: card.face_value()+card.suit_value(), reverse=True)

        self.cards.clear()
        self.cards.extend(self.key_cards)  # Add key cards first (for other types)
        self.cards.extend(self.kickers)  # Add kickers after key cards

        if self.is_straight() and int(self.cards[0].face_value()) == 14 and int(self.cards[4].face_value()) == 2:
            self.cards.append(self.cards[0])
            self.cards.pop(0)

    def compare_to(self, other):
        for i in range(len(self.key_cards)):
            card_comparison = (self.cards[i].get_hand_value() > other.cards[i].get_hand_value()) - (self.cards[i].get_hand_value() < other.cards[i].get_hand_value())
            if card_comparison != 0:
                return card_comparison

        for card in self.cards:  # If the hands are the same, take suit into account
            card.set_hand_value(card.suit_value())

        for i in range(len(self.key_cards), len(self.cards)):
            card_comparison = (self.cards[i].get_hand_value() > other.cards[i].get_hand_value()) - (self.cards[i].get_hand_value() < other.cards[i].get_hand_value())
            if card_comparison != 0:
                return card_comparison

        return 0  # Hands are equal if all card comparisons are equal (impossible here)
    def __lt__(self, other):
        return self.compare_to(other) < 0