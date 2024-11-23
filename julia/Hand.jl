include("Card.jl")

mutable struct Hand
    cards::Vector{Card}  # List of cards in the hand
    unsorted::Vector{Card}  # Unsorted list of cards
    hand_type::String  # Type of hand (e.g., "pair", "three of a kind", etc.)
    key_cards::Vector{Card}  # Key cards in the hand
    kickers::Vector{Card}  # Kicker cards

    # Constructor for Hand struct
    function Hand(cards::Vector{Card})
        # Initialize the Hand with unsorted, cards, empty hand type, and empty key cards/kickers
        hand = new(cards, cards, "", Card[], Card[])
        
        return hand  # Return the constructed hand
    end
end

# Function to initialize the hand after creation
function initialize_hand!(hand::Hand)
    # Call your other functions here
    separate_key_cards_and_kickers!(hand)  # Separate key cards and kickers
    sort_hand!(hand)  # Sort the hand by card values
    evaluate_hand!(hand)  # Evaluate the hand type
end

function set_unsorted!(hand::Hand, cardList::Vector{Card})
    # Copy the cardList into the unsorted field
    hand.unsorted = copy(cardList)
end

# Function to generate a string representation of the hand
function toString(hand::Hand)
    for card in hand.unsorted
        if card!=nothing
            print(toString(card))
        end
    end
end

# Additional Helper functions
# Function to check if the hand is a flush
function is_flush(hand::Hand)
    suit = hand.cards[1].suit
    for card in hand.cards
        if card.suit != suit
            return false
        end
    end
    return true
end

# Function to check if the hand is a straight
function is_straight(hand::Hand)
    values = sort([Int(faceValue(card)) for card in hand.cards])  # Sort the face values

    # Check for high Ace straight (10-J-Q-K-A)
    if values[1] == 2 && values[5] == 14 && all(values .== [2, 3, 4, 5, 14])
        return true
    end

    # Check for regular straight
    for i in 2:5
        if values[i] != values[i-1] + 1
            return false
        end
    end
    return true
end

# Function to evaluate the hand type and set the hand values of each card
function evaluate_hand!(hand::Hand)
    face_counts = zeros(Int, 15)  # Array to count occurrences of each face value (index 0 is unused)
    
    for card in hand.cards
        face_counts[Int(faceValue(card))] += 1
    end

    flush = is_flush(hand)
    straight = is_straight(hand)

    if flush && straight
        if face_counts[14] > 0 && face_counts[13] > 0  # Check for Ace and King (Royal Flush)
            hand.hand_type = "Royal Flush"
            set_hand_value_to_cards!(hand, Float64(9000))
        else
            hand.hand_type = "Straight Flush"
            set_hand_value_to_cards!(hand, Float64(8000))
        end
    elseif contains_n_of_a_kind(face_counts, 4)
        hand.hand_type = "Four of a Kind"
        set_hand_value_to_cards!(hand, Float64(7000))
    elseif contains_n_of_a_kind(face_counts, 3) && contains_n_of_a_kind(face_counts, 2)
        hand.hand_type = "Full House"
        set_hand_value_to_cards!(hand, Float64(6000))
    elseif flush
        hand.hand_type = "Flush"
        set_hand_value_to_cards!(hand, Float64(5000))
    elseif straight
        hand.hand_type = "Straight"
        set_hand_value_to_cards!(hand, Float64(4000))
    elseif contains_n_of_a_kind(face_counts, 3)
        hand.hand_type = "Three of a Kind"
        set_hand_value_to_cards!(hand, Float64(3000))
    elseif count_pairs(face_counts) == 2
        hand.hand_type = "Two Pair"
        set_hand_value_to_cards!(hand, Float64(2000))
    elseif contains_n_of_a_kind(face_counts, 2)
        hand.hand_type = "One Pair"
        set_hand_value_to_cards!(hand, Float64(1000))
    else
        hand.hand_type = "High Card"
        set_hand_value_to_cards!(hand, Float64(0))
    end

    # After determining the hand type, separate into key cards and kickers
    separate_key_cards_and_kickers!(hand)
end

# Function to set hand values to cards (based on the hand type)
function set_hand_value_to_cards!(hand::Hand, base_value::Float64)
    for card in hand.cards
        hand_value = base_value + faceValue(card) + suitValue(card)
        # For "One Pair" and "Two Pair", don't add suitValue
        if hand.hand_type in ["One Pair", "Two Pair"]
            hand_value = base_value + faceValue(card)
        end
        setHandValue!(card, Float64(hand_value))
    end
end

# Custom comparison function for Hand objects
function Base.isless(hand1::Hand, hand2::Hand)
    # Use compare_hands to compare the two hands
    return compare_hands!(hand1, hand2) == -1  # If hand1 < hand2, return true
end

# Function to compare two hands based on the card hand_values and suits for tie-breaking
function compare_hands!(hand1::Hand, hand2::Hand)
    # First, compare the key cards by their hand values
    for i in 1:length(hand1.key_cards)
        card_comparison = compare_card_values(hand1.cards[i], hand2.cards[i])
        if card_comparison != 0
            return card_comparison
        end
    end
    
    for i in 1:length(hand1.cards)
        setHandValue!(hand1.cards[i] , suitValue(hand1.cards[i]));
    end
    
    for i in 1:length(hand2.cards)
        setHandValue!(hand2.cards[i] , suitValue(hand2.cards[i]));
    end

    # If key cards are equal, compare kicker cards
    for i in length(hand1.key_cards)+1:length(hand1.cards)
        card_comparison = compare_card_values(hand1.cards[i], hand2.cards[i])
        if card_comparison != 0
            return card_comparison
        end
    end
    
    return 0  # If all cards are equal, the hands are considered equal
end

# Helper function to compare card values (hand_value + suit value for tie-breaking)
function compare_card_values(card1::Card, card2::Card)
    card_value1 = card1.handValue
    card_value2 = card2.handValue

    if card_value1 != card_value2
        return card_value1 > card_value2 ? 1 : -1
    end

    # If the hand_value is the same, compare suits
    return compare_suits(card1, card2)
end

# Function to compare suits for tie-breaking
function compare_suits(card1::Card, card2::Card)
    suit_value1 = suitValue(card1)
    suit_value2 = suitValue(card2)

    if suit_value1 != suit_value2
        return suit_value1 > suit_value2 ? 1 : -1
    end

    return 0  # If suits are the same, cards are considered equal
end

# Function to sort the hand (key cards first, then kickers)
function sort_hand!(hand::Hand)
    # Sort key cards and kickers by face value and suit value
    sort!(hand.key_cards, by = card -> faceValue(card) + suitValue(card), rev=true)
    sort!(hand.kickers, by = card -> faceValue(card) + suitValue(card), rev=true)

    # Combine the sorted cards
    hand.cards = vcat(hand.key_cards, hand.kickers)

    # Check for Ace-to-5 straight ("wheel") and adjust if needed
    if is_straight(hand) && faceValue(hand.cards[1]) == 14 && faceValue(hand.cards[end]) == 2
        # Move the Ace to the end of the list to form the low straight
        hand.cards = vcat(hand.cards[2:end], hand.cards[1])
    end
end

# Function to check if there are n of a kind in the face counts
function contains_n_of_a_kind(face_counts, n)
    return any(count -> count == n, face_counts)
end

# Function to count pairs in the hand
function count_pairs(face_counts)
    return count(count -> count == 2, face_counts)
end

# Function to separate key cards and kickers based on frequency of face values
function separate_key_cards_and_kickers!(hand::Hand)
    face_counts = zeros(Int, 15)
    for card in hand.cards
        face_counts[Int(faceValue(card))] += 1
    end

    key_cards = Card[]
    kickers = Card[]

    for card in hand.cards
        if face_counts[Int(faceValue(card))] > 1
            push!(key_cards, card)
        else
            push!(kickers, card)
        end
    end

    hand.key_cards = key_cards
    hand.kickers = kickers
end
