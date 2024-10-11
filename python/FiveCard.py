import random
import sys
from Card import *
from Hand import *

class FiveCard:

    @staticmethod
    def create_ordered_deck():
        deck = []
        # Suits and face values for cards
        suits = ["D", "C", "H", "S"]  # D: Diamonds, C: Clubs, H: Hearts, S: Spades
        faces = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

        # Generate cards for each combination of suit and face
        for suit in suits:
            for face in faces:
                deck.append(Card(face, suit))

        return deck

    @staticmethod
    def display_deck(deck):
        for i, card in enumerate(deck):
            print(str(card).rjust(3), end=" ")
            # Print a newline after every 13 cards to format deck into 4 rows
            if (i + 1) % 13 == 0:
                print()
        print()

    @staticmethod
    def deal_hands(deck):
        hands = []
        # Create 6 hands, each containing 5 cards
        for i in range(6):
            # Extract 5 cards for the current hand from the deck
            hand_cards = deck[i * 5:(i + 1) * 5]
            hands.append(Hand(hand_cards))
            hands[i].set_unsorted(hand_cards)

        # Remove the dealt cards from the deck
        del deck[:30]  # 6 hands * 5 cards each = 30 cards

        return hands

    @staticmethod
    def display_hand(hand):
        for card in hand.get_unsorted_cards():
            print(str(card).rjust(3), end=" ")
        print()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        # Initialize deck with ordered cards
        deck = FiveCard.create_ordered_deck()  # Use class method
        # Shuffle the deck to randomize card order
        random.shuffle(deck)

        # Display introductory messages and the shuffled deck
        print("*** P O K E R H A N D A N A L Y Z E R ***\n")
        print("*** USING RANDOMIZED DECK OF CARDS ***\n")
        print("*** Shuffled 52 card deck:")
        FiveCard.display_deck(deck)

        # Display each hand
        print("*** Here are the six hands...")
        for i in range(6):
            # Extract 5 cards for the current hand from the deck
            hand_cards = deck[i * 5:(i + 1) * 5]
            for card in hand_cards:
                print(card, end=" ")
            print()

        # Deal six hands of poker from the shuffled deck
        hands = FiveCard.deal_hands(deck)

        print("\n*** Here is what remains in the deck...")
        FiveCard.display_deck(deck)
        print()

        # Sort hands based on their poker rank
        hands.sort()

        # Reverse the order of hands to show the highest rank first
        hands.reverse()
        print("--- WINNING HAND ORDER ---")

        # Display each hand with its rank name
        for hand in hands:
            print(hand.__str__() + " - " + hand.get_hand_type())
            #print(f"{hand} - {hand.get_hand_type()}")
    else:
        file_path = sys.argv[1]
        print("*** P O K E R H A N D A N A L Y Z E R ***\n")
        print("*** USING TEST DECK ***\n")
        print(f"*** File: {file_path}")

        # Display the contents of the file
        try:
            with open(file_path, 'r') as reader:
                for line in reader:
                    print(line.strip())
            print()
        except IOError as e:
            print(e)

        try:
            with open(file_path, 'r') as reader:
                hands = []
                seen_cards = []
                has_duplicate = False
                duplicate_card = None
                hand_count = 0

                for line in reader:
                    if hand_count >= 6:
                        break
                    # Split the line by commas
                    card_records = line.strip().split(",")
                    hand = []

                    # Process each card record
                    for card_record in card_records:
                        card_value = card_record.strip()
                        if card_value:
                            card_face = card_value[:-1]
                            card_suit = card_value[-1]
                            card = f"{card_face}{card_suit}"

                            # Check for duplicates using the List
                            if card in seen_cards:
                                has_duplicate = True
                                duplicate_card = card
                            seen_cards.append(card)
                            hand.append(Card(card_face, card_suit))

                    hands.append(hand)
                    hand_count += 1

                hands_list = []
                for card_list in hands:
                    hand = Hand(card_list)
                    hand.set_unsorted(card_list)
                    hands_list.append(hand)

                # Print the hands to verify
                print("*** Here are the six hands...")
                for hand in hands_list:
                    FiveCard.display_hand(hand)

                print()

                # If a duplicate was found, print the error and exit
                if has_duplicate:
                    print("*** ERROR - DUPLICATED CARD FOUND IN DECK ***")
                    print()
                    print(f"*** DUPLICATE: {duplicate_card} ***")
                    sys.exit(1)  # Exit the program

                # Sort hands based on their hand value
                hands_list.sort()

                # Reverse the order of hands to show the highest rank first
                hands_list.reverse()
                print("--- WINNING HAND ORDER ---")

                # Display each hand with its rank name
                for hand in hands_list:
                    print(f"{hand} - {hand.get_hand_type()}")

        except IOError as e:
            print(e)