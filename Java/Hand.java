package Java;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Hand implements Comparable<Hand> {
    private List<Card> cards;  // List of cards in the hand
    private List<Card> unsorted; // List of cards in the hand unsorted
    private String handType;   // Type of hand (e.g., "pair", "three of a kind", etc.)
    private List<Card> keyCards;  // Cards that form the key part of the hand
    private List<Card> kickers;   // Remaining cards in the hand

    // Constructor that initializes the hand and evaluates its type
    public Hand(List<Card> cards) {
        this.cards = new ArrayList<>(cards);
        separateKeyCardsAndKickers(); // Separate key cards from kickers
        sortHand(); // Sort the cards based on hand value
        evaluateHand(); // Determine the type of hand and assign values
    }

    // Get the list of cards in the hand
    public List<Card> getCards() {
        return cards;
    }
    
    public List<Card> getUnsortedCards(){
        return unsorted;
    }
    
    public void setUnsorted(List<Card> cardList){
      this.unsorted = new ArrayList<>(cardList);
    }

    // Get the type of the hand (e.g "pair","three of a kind")
    public String getHandType() {
        return handType;
    }

    // Generate a string representation of the hand
    @Override
    public String toString() {
        String result = "";
        for (Card card : unsorted) {
            result += String.format("%3s", card) + " "; // Format each card in the hand
        }
        return result;
    }

    // Evaluate the type of hand (e.g., "flush", "straight", etc.)
    private void evaluateHand() {
        // Array to count occurrences of each face value (index 0 is unused)
        int[] faceCounts = new int[15];
        for (Card card : cards) {
            faceCounts[(int) card.faceValue()]++;
        }

        // Check if the hand is a flush 
        boolean isFlush = isFlush();
        // Check if the hand is a straight 
        boolean isStraight = isStraight();

        

        // Determine hand type and assign a base value to each card
        if (isFlush && isStraight) {
            int a=0;
            if(faceCounts[14] > 0 && faceCounts[13]>0){ //if it includes the Ace and King
               handType = "Royal Flush";
               a+=1000;
            }
            else{
               handType = "Straight Flush"; 
            }
            a+=9000;
            setHandValueToCards(a);
        } else if (containsNOfAKind(faceCounts, 4)) {
            handType = "Four of a Kind";
            setHandValueToCards(8000); 
        } else if (containsNOfAKind(faceCounts, 3) && containsNOfAKind(faceCounts, 2)) {
            handType = "Full House";
            setHandValueToCards(7000); 
        } else if (isFlush) {
            handType = "Flush";
            setHandValueToCards(6000); 
        } else if (isStraight) {
            handType = "Straight";
            setHandValueToCards(5000); 
        } else if (containsNOfAKind(faceCounts, 3)) {
            handType = "Three of a Kind";
            setHandValueToCards(4000); 
        } else if (countPairs(faceCounts) == 2) {
            handType = "Two Pair";
            setHandValueToCards(3000); 
        } else if (containsNOfAKind(faceCounts, 2)) {
            handType = "One Pair";
            setHandValueToCards(2000); 
        } else {
            handType = "High Card";
            setHandValueToCards(1000);
        }
    }

    private void setHandValueToCards(int baseValue) {
      for(Card card: cards){
                double handValue;
                if(!handType.equals("One Pair")&&!handType.equals("Two Pair")){
                  handValue = baseValue + card.faceValue() + card.suitValue();
                }
                else{
                  handValue = baseValue + card.faceValue();
                }
                card.setHandValue(handValue);
        }
      
    }

    // Check if all cards in the hand have the same suit
    private boolean isFlush() {
        String suit = cards.get(0).getSuit();
        for (Card card : cards) {
            if (!card.getSuit().equals(suit)) {
                return false;
            }
        }
        return true;
    }

    // Check if the cards form a straight
    private boolean isStraight() {
        List<Integer> values = new ArrayList<>();
        for (Card card : cards) {
            values.add((int) card.faceValue());
        }
        Collections.sort(values);
        
         // Check for high Ace straight (10-J-Q-K-A)
          if (values.get(0) == 2 && values.get(4) == 14 &&
              values.get(1) == 3 && values.get(2) == 4 &&
              values.get(3) == 5) {
              return true;
          }

        for (int i = 1; i < values.size(); i++) {
            if ((int)values.get(i) != (int)values.get(i - 1) + 1) {
                return false;
            }
        }
        return true;
    }

    // Check if there's a card value with exactly n occurrences
    private boolean containsNOfAKind(int[] faceCounts, int n) {
        for (int count : faceCounts) {
            if (count == n) {
                return true;
            }
        }
        return false;
    }

    // Count the number of pairs in the hand
    private int countPairs(int[] faceCounts) {
        int pairs = 0;
        for (int count : faceCounts) {
            if (count == 2) {
                pairs++;
            }
        }
        return pairs;
    }

    // Separate cards into key cards (cards forming the hand) and kickers (remaining cards)
    private void separateKeyCardsAndKickers() {
        keyCards = new ArrayList<>();
        kickers = new ArrayList<>();

        int[] faceCounts = new int[15];
        for (Card card : cards) {
            faceCounts[(int) card.faceValue()]++;
        }

        // Add key cards to keyCards and remaining cards to kickers
        for (Card card : cards) {
            if (faceCounts[(int) card.faceValue()] > 1) {
                keyCards.add(card);
            } else {
                kickers.add(card);
            }
        }
    }

    // Sort key cards and kickers by their hand values
    private void sortHand() {
        // Sort key cards and kickers in descending order of hand value (chatGPT gave me Collections.sort)
        Collections.sort(keyCards, (a, b) -> Double.compare(b.faceValue()+b.suitValue(), a.faceValue()+a.suitValue()));
        Collections.sort(kickers, (a, b) -> Double.compare(b.faceValue()+b.suitValue(), a.faceValue()+a.suitValue()));

        // Combine key cards and kickers into the final sorted hand
        cards.clear();
        
        // Array to count occurrences of each face value (index 0 is unused)
        int[] faceCounts = new int[15];
        for (Card card : cards) {
            faceCounts[(int) card.faceValue()]++;
        }
        
              cards.addAll(keyCards); // Add key cards first (for other types)
              cards.addAll(kickers);  // Add kickers after key cards

        if(isStraight() && (int)(cards.get(0).faceValue()) == 14 && (int)(cards.get(4).faceValue())==2){
          cards.add(cards.get(0));
          
          cards.remove(0);
        }
        
    }

    // Compare this hand to another hand based on card values
    @Override
    public int compareTo(Hand other) {
        for (int i = 0; i < this.keyCards.size(); i++) {
            int cardComparison = Double.compare(this.cards.get(i).getHandValue(), other.cards.get(i).getHandValue());
            if (cardComparison != 0) {
                return cardComparison;
            }
        }
        for(Card card: cards){ // If the hands are the same, take suit into account
          card.setHandValue(card.suitValue());
        }
        for(int i=this.keyCards.size();i<cards.size();i++){
           int cardComparison = Double.compare(this.cards.get(i).getHandValue(), other.cards.get(i).getHandValue()); 
           //Double.compare method given by ChatGPT
            if (cardComparison != 0) {
                return cardComparison;
            }
        }
        return 0; // Hands are equal if all card comparisons are equal (impossible here)
    }
}
    