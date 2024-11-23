#![allow(unused)]
use std::cmp::Ordering;
use std::env;
use std::fs::File;
use std::io::{self, BufRead};
//use std::path::Path;
use std::collections::HashSet;
use rand::seq::SliceRandom; // For shuffling
use rand::thread_rng;

#[derive(Debug, Clone)] // Add Clone so we can clone cards when needed
pub struct Card {
    pub face: String,
    pub suit: String,
    pub hand_value: f64,  // For sorting within the hand
}

impl Card {
    pub fn new(face: &str, suit: &str) -> Self {
        Card {
            face: face.to_string(),
            suit: suit.to_string(),
            hand_value: 0.0,  // Default value for hand_value
        }
    }

    pub fn to_string(&self) -> String {
        format!("{}{}", self.face, self.suit)  // Returns a string like "AS" for Ace of Spades
    }

    // For evaluating face value (2, 3, ..., Aces)
    pub fn face_value(&self) -> f64 {
        match self.face.as_str() {
            "2" => 2.0,
            "3" => 3.0,
            "4" => 4.0,
            "5" => 5.0,
            "6" => 6.0,
            "7" => 7.0,
            "8" => 8.0,
            "9" => 9.0,
            "10" => 10.0,
            "J" => 11.0,
            "Q" => 12.0,
            "K" => 13.0,
            "A" => 14.0,
            _ => 0.0,  // Default case (shouldn't happen with valid inputs)
        }
    }

    // Get the suit value (for comparison purposes)
    pub fn suit_value(&self) -> f64 {
        match self.suit.as_str() {
            "D" => 0.1, // Diamonds
            "C" => 0.2, // Clubs
            "H" => 0.3, // Hearts
            "S" => 0.4, // Spades
            _ => 0.0,
        }
    }

    // Get the hand value (used to compare cards and hands)
    pub fn get_hand_value(&self) -> f64 {
        self.hand_value
    }

    // Set the hand value
    pub fn set_hand_value(&mut self, value: f64) {
        self.hand_value +=value;
    }
}

pub trait ToStringCustom {
    fn to_string(&self) -> String;
}

impl ToStringCustom for Card {
    fn to_string(&self) -> String {
        format!("{} of {}", self.face, self.suit)
    }
}

pub struct Hand {
    cards: Vec<Card>,
    unsorted: Vec<Card>,
    hand_type: String,
    key_cards: Vec<Card>,
    kickers: Vec<Card>,
}

impl ToStringCustom for Hand {
    fn to_string(&self) -> String {
        self.cards.iter()
            .map(|card| card.to_string())
            .collect::<Vec<String>>()
            .join(", ")
    }
}

impl Hand {
    pub fn new(cards: Vec<Card>) -> Hand {
        let mut hand = Hand {
            cards: cards.clone(),
            unsorted: cards.clone(),
            hand_type: String::new(),
            key_cards: Vec::new(),
            kickers: Vec::new(),
        };
        hand.separate_key_cards_and_kickers();
        hand.sort_hand();
        hand.evaluate_hand();
        hand
    }

    pub fn to_string(&self) -> String {
        self.unsorted.iter()
            .map(|card| format!("{:<3}", card.to_string()))
            .collect::<Vec<String>>()
            .join(" ")
    }
    
    pub fn get_cards(&self) -> &Vec<Card> {
        &self.cards
    }

    pub fn get_unsorted_cards(&self) -> &Vec<Card> {
        &self.unsorted
    }

    pub fn set_unsorted(&mut self, card_list: Vec<Card>) {
        self.unsorted = card_list;
    }

    pub fn get_hand_type(&self) -> &str {
        &self.hand_type
    }

    fn evaluate_hand(&mut self) {
        let mut face_counts = vec![0; 15]; // To store count of face values
        for card in &self.cards {
            face_counts[card.face_value() as usize] += 1;
        }

        let is_flush = self.is_flush();
        let is_straight = self.is_straight();

        if is_flush && is_straight {
            if face_counts[14] > 0 && face_counts[13] > 0 {
                self.hand_type = "Royal Flush".to_string();
                self.set_hand_value_to_cards(1000.0);
            } else {
                self.hand_type = "Straight Flush".to_string();
                self.set_hand_value_to_cards(900.0);
            }
        } else if self.contains_n_of_a_kind(&face_counts, 4) {
            self.hand_type = "Four of a Kind".to_string();
            self.set_hand_value_to_cards(800.0);
        } else if self.contains_n_of_a_kind(&face_counts, 3) && self.contains_n_of_a_kind(&face_counts, 2) {
            self.hand_type = "Full House".to_string();
            self.set_hand_value_to_cards(700.0);
        } else if is_flush {
            self.hand_type = "Flush".to_string();
            self.set_hand_value_to_cards(600.0);
        } else if is_straight {
            self.hand_type = "Straight".to_string();
            self.set_hand_value_to_cards(500.0);
        } else if self.contains_n_of_a_kind(&face_counts, 3) {
            self.hand_type = "Three of a Kind".to_string();
            self.set_hand_value_to_cards(400.0);
        } else if self.count_pairs(&face_counts) == 2 {
            self.hand_type = "Two Pair".to_string();
            self.set_hand_value_to_cards(300.0);
        } else if self.contains_n_of_a_kind(&face_counts, 2) {
            self.hand_type = "One Pair".to_string();
            self.set_hand_value_to_cards(200.0);
        } else {
            self.hand_type = "High Card".to_string();
            self.set_hand_value_to_cards(100.0);
        }
    }

    fn set_hand_value_to_cards(&mut self, base_value: f64) {
        for card in &mut self.cards {
            let hand_value = if self.hand_type != "One Pair" && self.hand_type != "Two Pair" {
                base_value + card.face_value() + card.suit_value()
            } else {
                base_value + card.face_value()
            };
            card.set_hand_value(hand_value);
        }
    }

    fn is_flush(&self) -> bool {
        let suit = &self.cards[0].suit;
        self.cards.iter().all(|card| &card.suit == suit)
    }

    fn is_straight(&self) -> bool {
        let mut values: Vec<f64> = self.cards.iter().map(|card| card.face_value()).collect();
        values.sort_by(|a, b| a.partial_cmp(b).unwrap());

        if values[0] == 2.0 && values[4] == 14.0 && values[1] == 3.0 && values[2] == 4.0 && values[3] == 5.0 {
            return true;
        }

        values.windows(2).all(|w| w[0] + 1.0 == w[1])
    }

    fn contains_n_of_a_kind(&self, face_counts: &[usize], n: usize) -> bool {
        face_counts.iter().any(|&count| count == n)
    }

    fn count_pairs(&self, face_counts: &[usize]) -> usize {
        face_counts.iter().filter(|&&count| count == 2).count()
    }

    fn separate_key_cards_and_kickers(&mut self) {
        let mut face_counts = vec![0; 15];
        for card in &self.cards {
            face_counts[card.face_value() as usize] += 1;
        }

        for card in &self.cards {
            if face_counts[card.face_value() as usize] > 1 {
                self.key_cards.push(card.clone());
            } else {
                self.kickers.push(card.clone());
            }
        }
    }

    fn sort_hand(&mut self) {
        self.key_cards.sort_by(|a, b| (b.face_value() + b.suit_value()).partial_cmp(&(a.face_value() + a.suit_value())).unwrap());
        self.kickers.sort_by(|a, b| (b.face_value() + b.suit_value()).partial_cmp(&(a.face_value() + a.suit_value())).unwrap());

        self.cards.clear();
        self.cards.extend(self.key_cards.clone());
        self.cards.extend(self.kickers.clone());
    }

   pub fn compare_to(&mut self, other: &mut Self) -> Ordering {
        // Compare key cards by their hand values
        for i in 0..self.key_cards.len() {
            let card_comparison = self.cards[i].get_hand_value() - other.cards[i].get_hand_value();
            if card_comparison != 0.0 {
                return if card_comparison > 0.0 {
                    Ordering::Greater
                } else {
                    Ordering::Less
                };
            }
        }

        // Set hand values based on suit for both hands
        for card in &mut self.cards {
            card.set_hand_value(card.suit_value());
        }

        // Compare the remaining cards (kickers)
        for i in self.key_cards.len()..self.cards.len() {
            let card_comparison = self.cards[i].get_hand_value() - other.cards[i].get_hand_value();
            if card_comparison != 0.0 {
                return if card_comparison > 0.0 {
                    Ordering::Greater
                } else {
                    Ordering::Less
                };
            }
        }

        Ordering::Equal // If all cards are equal, the hands are considered equal
    }
}

fn main() {
    // Get the command-line arguments
    let args: Vec<String> = env::args().collect();
     if args.len() == 1 {
        // Initialize deck with ordered cards
        let mut deck = create_ordered_deck();
        let hand_types = vec![
        "High Card",
        "One Pair",
        "Two Pair",
        "Three of a Kind",
        "Straight",
        "Flush",
        "Full House",
        "Four of a Kind",
        "Straight Flush",
        "Royal Flush",
    ];
        // Shuffle the deck to randomize card order
        shuffle_deck(&mut deck);
        
        // Display introductory messages and the shuffled deck
        println!("*** P O K E R H A N D A N A L Y Z E R ***");
        println!();
        println!("*** USING RANDOMIZED DECK OF CARDS ***");
        println!();
        println!("*** Shuffled 52 card deck:");
        display_deck(&deck);
        
        // Display each hand
        println!();
        println!("*** Here are the six hands...");
        
        // Deal 6 hands of 5 cards each from the deck
        let hands = deal_hands(&mut deck);
        for hand in hands.iter() {
            println!("{}", hand.to_string());
        }
    
        // Sort hands based on their hand value
        let mut hands = hands; // Make a mutable copy since we need to sort
        //sort_hands(&mut hands);
        // Display sorted hands
        println!();
        println!("*** Here is what remains in the deck...");
        display_deck(&deck);
        println!();
        hands.sort_by(|a, b| {
        let a_index = hand_types.iter().position(|&s| s == a.get_hand_type()).unwrap();
        let b_index = hand_types.iter().position(|&s| s == b.get_hand_type()).unwrap();
        a_index.cmp(&b_index)
    });
        hands.reverse(); // Reverse the order to show the highest rank first
        println!("--- WINNING HAND ORDER ---");
        for hand in hands.iter() {
            println!("{} - {}", hand.to_string(),hand.get_hand_type());
        }
    }
    else {
        // Command-line argument is present, use test deck
        let file_path = &args[1];
        let hand_types = vec![
        "High Card",
        "One Pair",
        "Two Pair",
        "Three of a Kind",
        "Straight",
        "Flush",
        "Full House",
        "Four of a Kind",
        "Straight Flush",
        "Royal Flush",
    ];
        println!("*** P O K E R H A N D A N A L Y Z E R ***");
        println!();
        println!("*** USING TEST DECK ***");
        println!();
        println!("*** File: {}", file_path);

        // Open the file and read the contents
        if let Ok(file) = File::open(file_path) {
            let reader = io::BufReader::new(file);
            let mut hands = Vec::new();
            let mut seen_cards = HashSet::new();
            let mut has_duplicate = false;
            let mut duplicate_card = String::new();
            let mut hand_count = 0;

            // Read lines from the file
            for line in reader.lines() {
                if hand_count >= 6 {
                    break;
                }

                let line = line.unwrap(); // You could handle errors here with better granularity
                println!("{}" , line);
                let card_records: Vec<&str> = line.split(',').collect();
                let mut hand = Vec::new();

                // Process each card record in the line
                for card_record in card_records {
                    let card_value = card_record.trim();
                    if !card_value.is_empty() {
                        let card = card_value.to_string();

                        // Check for duplicates using HashSet
                        if seen_cards.contains(&card) {
                            has_duplicate = true;
                            duplicate_card = card.clone();
                        } else {
                            seen_cards.insert(card.clone());
                        }
                        hand.push(Card::new(&card_value[0..card_value.len() - 1], &card_value[card_value.len() - 1..]));
                    }
                }

                hands.push(hand);
                hand_count += 1;
            }

            // Check if any duplicates were found
            if has_duplicate {
                println!();
                println!("*** ERROR - DUPLICATED CARD FOUND IN DECK ***");
                println!();
                println!("*** DUPLICATE: {} ***", duplicate_card);
                return;
            }

            // Create Hand objects and display them
            let mut hands_list = Vec::new();
            for hand in hands {
                let h = Hand::new(hand);
                hands_list.push(h);
            }
            println!();
            // Print the hands
            println!("*** Here are the six hands...");
            for hand in &hands_list {
                println!("{}", hand.to_string());
            }

            println!();

            // Sort hands based on their hand value (we will just sort by hand type for now)
            hands_list.sort_by(|a, b| {
        let a_index = hand_types.iter().position(|&s| s == a.get_hand_type()).unwrap();
        let b_index = hand_types.iter().position(|&s| s == b.get_hand_type()).unwrap();
        a_index.cmp(&b_index)
    });
            hands_list.reverse(); // Reverse the order to show the highest rank first

            println!("--- WINNING HAND ORDER ---");
            for hand in hands_list {
                println!("{} - {}", hand.to_string(), hand.get_hand_type());
            }
        }
    }
}

// Helper function to create the ordered deck
fn create_ordered_deck() -> Vec<Card> {
    let faces = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"];
    let suits = ["D", "C", "H", "S"];
    let mut deck = Vec::new();
    
    for &suit in &suits {
        for &face in &faces {
            deck.push(Card::new(face, suit));
        }
    }
    deck
}

fn shuffle_deck(deck: &mut Vec<Card>) {
    let mut rng = thread_rng();
    deck.shuffle(&mut rng);
}

// Helper function to display the deck
fn display_deck(deck: &Vec<Card>) {
    for (index, card) in deck.iter().enumerate() {
        print!("{} ", card.to_string());

        // Print a newline after every 13 cards
        if (index + 1) % 13 == 0 {
            println!();
        }
    }

    // In case the last line has fewer than 13 cards, ensure the final newline is printed
    if deck.len() % 13 != 0 {
        println!();
    }
}

// Helper function to deal hands (6 hands, 5 cards each)
fn deal_hands(deck: &mut Vec<Card>) -> Vec<Hand> {
    let mut hands = Vec::new();
    
    for _ in 0..6 {
        let hand_cards: Vec<Card> = deck.drain(0..5).collect(); 
        let hand_obj = Hand::new(hand_cards);  
        hands.push(hand_obj);
    }
    
    hands
}

/*pub fn sort_hands(hands: &mut Vec<Hand>) {
    let mut n = hands.len();
    let mut swapped = true;

    // Bubble Sort
    while swapped {
        swapped = false;
        for i in 1..n {
             Instead of mutably borrowing both elements at once, extract them into variables
            let left = &mut hands[i - 1];
            let right = &mut hands[i];
            
            // Now perform the comparison
            if left.compare_to(right) == Ordering::Greater {
                hands.swap(i - 1, i);
                swapped = true;
            }
        }
        n -= 1; // Decrease the range of comparison as the largest element is sorted
    }
}*/