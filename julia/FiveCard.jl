#!/usr2/local/julia-1.10.4/bin/julia

# FiveCard.jl
include("Card.jl")
include("Hand.jl")

using Random
using Printf

function create_ordered_deck()
    suits = ["D", "C", "H", "S"]  # D: Diamonds, C: Clubs, H: Hearts, S: Spades
    faces = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    deck = Card[]

    for suit in suits
        for face in faces
            push!(deck, Card(face, suit))
        end
    end
    return deck
end

function display_deck(deck::Vector{Card})
    for (i, card) in enumerate(deck)
        if card!=nothing
            print(toString(card))
        end
        if i % 13 == 0
            println()
        end
    end
end

function deal_hands(deck::Vector{Card})
    hands = Hand[]
    for i in 1:6
        hand_cards = deck[(i-1)*5 + 1:i*5]
        hand = Hand(hand_cards)
        initialize_hand!(hand)
        push!(hands, hand)
        set_unsorted!(hands[i] , deck[(i-1)*5 + 1:i*5])
    end
    for i in 1:30
        popfirst!(deck)
    end
    return hands
end

function five_card_poker()
    deck = create_ordered_deck()
    shuffle!(deck)  # Shuffle the deck
    
    println("*** P O K E R H A N D A N A L Y Z E R ***\n")
    println("*** USING RANDOMIZED DECK OF CARDS ***\n")
    println("*** Shuffled 52 card deck:")
    display_deck(deck)
    println()
    
    println("*** Here are the six hands...")
    hands = deal_hands(deck)
    for hand in hands
        toString(hand)
        println()
    end
    println()
    
    println("*** Here is what remains in the deck...")
    display_deck(deck)
    println()
    println()
    # Sort hands based on poker hand type (use sorting logic implemented in Hand module)
    sort!(hands)
    reverse!(hands)
    println("--- WINNING HAND ORDER ---")
    for hand in hands
        toString(hand)
        print( " - " )
        print(hand.hand_type)
        println()
    end
end

# Main function for processing the file and evaluating hands
function poker_hand_analyzer(file_path::String)
    # Open the file to read
    f = open(file_path, "r")

    # Read the entire content of the file into a single string
    allhands = read(f, String)

    # Close the file after reading
    close(f)

    # Print the content of the file to verify
    println("*** P O K E R H A N D A N A L Y Z E R ***")
    println("\n*** USING TEST DECK ***")
    println("\n*** File: $file_path ***")
    println(allhands)

    # Tokenize the hands by splitting the string based on commas and newlines
    cards = split(allhands, [',', '\n'], keepempty=false)

    # Now process the cards into hands
    hands = []  # Array to store hands
    seen_cards = Set()  # To track duplicates
    has_duplicate = false
    duplicate_card = ""

    # Process each line of tokens (hands)
    hand_count = 0
    hand = Card[]
    for card_token in cards
        card_value = strip(card_token)
        if !isempty(card_value)
            # Ensure that we only process valid card formats
            if length(card_value) >= 2
                card = Card(String(card_value[1:length(card_value)-1]),String(card_value[length(card_value):length(card_value)]))  # Create a card object

                # Check for duplicates
                card_str = toString(card)
                if in(card_str, seen_cards)
                    has_duplicate = true
                    duplicate_card = card_str
                end
                push!(seen_cards, card_str)
                push!(hand, card)
            end

            # Once we have 5 cards in a hand, add the hand to the list
            if length(hand) == 5
                push!(hands,hand)
                hand_count += 1
                hand = Card[]  # Reset hand for next 5 cards
            end
        end
    end

    # If a duplicate was found, print the error and exit
    if has_duplicate
        println()
        println("*** ERROR - DUPLICATED CARD FOUND IN DECK ***")
        println("\n*** DUPLICATE: $duplicate_card ***")
        return
    end

  
    hands_list = [Hand(hand) for hand in hands]  # Assuming `Hand` struct is defined
    for i in 1:length(hands_list)
        set_unsorted!(hands_list[i] , hands[i])
        initialize_hand!(hands_list[i])
    end
    println("\n*** Here are the six hands: ***")
    for hand in hands_list
        toString(hand)
        println()
    end
    
    println()
    
    sort!(hands_list)  # Sort based on custom rules
    reverse!(hands_list)
    # Reverse to display highest to lowest
    println("--- WINNING HAND ORDER ---")
    for hand in hands_list
        toString(hand)
        print( " - " )
        print(hand.hand_type)
        println()
    end
end

# Main entry point
if length(ARGS) == 0
    five_card_poker()
else
    file_path = ARGS[1]
    poker_hand_analyzer(file_path)
end
