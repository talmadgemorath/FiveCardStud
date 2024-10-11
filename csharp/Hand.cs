using System;
using System.Collections.Generic;
using MyGame;

namespace MyGame
{
    public class Hand : IComparable<Hand>
    {
        private List<Card> cards; // List of cards in the hand
        private List<Card> unsorted; // List of cards in the hand unsorted
        private string handType; // Type of hand (e.g., "pair", "three of a kind", etc.)
        private List<Card> keyCards; // Cards that form the key part of the hand
        private List<Card> kickers; // Remaining cards in the hand

        // Constructor that initializes the hand and evaluates its type
        public Hand(List<Card> cards)
        {
            this.cards = new List<Card>(cards);
            this.unsorted = new List<Card>(cards); // Initialize unsorted list
            SeparateKeyCardsAndKickers(); // Separate key cards from kickers
            SortHand(); // Sort the cards based on hand value
            EvaluateHand(); // Determine the type of hand and assign values
        }

        // Get the list of cards in the hand
        public List<Card> GetCards(){
          return cards;
        }

        public List<Card> GetUnsortedCards(){
          return unsorted;
        }

        public void SetUnsorted(List<Card> cardList)
        {
            this.unsorted = new List<Card>(cardList);
        }

        // Get the type of the hand (e.g "pair", "three of a kind")
        public string GetHandType(){
          return handType;
        }

        // Generate a string representation of the hand
        public override string ToString()
        {
            string result = "";
            foreach (Card card in unsorted)
            {
                result += string.Format("{0,3}", card) + " "; // Format each card in the hand
            }
            return result.Trim(); // Trim to remove trailing space
        }

        // Evaluate the type of hand (e.g., "flush", "straight", etc.)
        private void EvaluateHand()
        {
            int[] faceCounts = new int[15]; // Array to count occurrences of each face value
            foreach (Card card in cards)
            {
                faceCounts[(int)card.FaceValue()]++;
            }

            bool isFlush = IsFlush();
            bool isStraight = IsStraight();

            // Determine hand type and assign a base value to each card
            if (isFlush && isStraight)
            {
                if (faceCounts[14] > 0 && faceCounts[13] > 0) // if it includes the Ace and King
                {
                    handType = "Royal Flush";
                    SetHandValueToCards(10000);
                }
                else
                {
                    handType = "Straight Flush";
                    SetHandValueToCards(9000);
                }
            }
            else if (ContainsNOfAKind(faceCounts, 4))
            {
                handType = "Four of a Kind";
                SetHandValueToCards(8000);
            }
            else if (ContainsNOfAKind(faceCounts, 3) && ContainsNOfAKind(faceCounts, 2))
            {
                handType = "Full House";
                SetHandValueToCards(7000);
            }
            else if (isFlush)
            {
                handType = "Flush";
                SetHandValueToCards(6000);
            }
            else if (isStraight)
            {
                handType = "Straight";
                SetHandValueToCards(5000);
            }
            else if (ContainsNOfAKind(faceCounts, 3))
            {
                handType = "Three of a Kind";
                SetHandValueToCards(4000);
            }
            else if (CountPairs(faceCounts) == 2)
            {
                handType = "Two Pair";
                SetHandValueToCards(3000);
            }
            else if (ContainsNOfAKind(faceCounts, 2))
            {
                handType = "One Pair";
                SetHandValueToCards(2000);
            }
            else
            {
                handType = "High Card";
                SetHandValueToCards(1000);
            }
        }

        private void SetHandValueToCards(int baseValue)
        {
            foreach (Card card in cards)
            {
                double handValue;
                if (handType != "One Pair" && handType != "Two Pair")
                {
                    handValue = baseValue + card.FaceValue() + card.SuitValue();
                }
                else
                {
                    handValue = baseValue + card.FaceValue();
                }
                card.SetHandValue(handValue);
            }
        }

        // Check if all cards in the hand have the same suit
        private bool IsFlush()
        {
            string suit = cards[0].GetSuit();
            foreach (Card card in cards)
            {
                if (card.GetSuit() != suit)
                {
                    return false;
                }
            }
            return true;
        }

        // Check if the cards form a straight
        private bool IsStraight()
        {
            List<int> values = new List<int>();
            foreach (Card card in cards)
            {
                values.Add((int)card.FaceValue());
            }
            values.Sort();

            // Check for high Ace straight (10-J-Q-K-A)
            if (values[0] == 2 && values[4] == 14 &&
                values[1] == 3 && values[2] == 4 &&
                values[3] == 5)
            {
                return true;
            }

            for (int i = 1; i < values.Count; i++)
            {
                if (values[i] != values[i - 1] + 1)
                {
                    return false;
                }
            }
            return true;
        }

        // Check if there's a card value with exactly n occurrences
        private bool ContainsNOfAKind(int[] faceCounts, int n)
        {
            foreach (int count in faceCounts)
            {
                if (count == n)
                {
                    return true;
                }
            }
            return false;
        }

        // Count the number of pairs in the hand
        private int CountPairs(int[] faceCounts)
        {
            int pairs = 0;
            foreach (int count in faceCounts)
            {
                if (count == 2)
                {
                    pairs++;
                }
            }
            return pairs;
        }

        // Separate cards into key cards (cards forming the hand) and kickers (remaining cards)
        private void SeparateKeyCardsAndKickers()
        {
            keyCards = new List<Card>();
            kickers = new List<Card>();

            int[] faceCounts = new int[15];
            foreach (Card card in cards)
            {
                faceCounts[(int)card.FaceValue()]++;
            }

            // Add key cards to keyCards and remaining cards to kickers
            foreach (Card card in cards)
            {
                if (faceCounts[(int)card.FaceValue()] > 1)
                {
                    keyCards.Add(card);
                }
                else
                {
                    kickers.Add(card);
                }
            }
        }

        // Sort key cards and kickers by their hand values
        private void SortHand()
        {
            keyCards.Sort((a, b) => (b.FaceValue()+b.SuitValue()).CompareTo(a.FaceValue()+a.SuitValue()));
            kickers.Sort((a, b) => (b.FaceValue()+b.SuitValue()).CompareTo(a.FaceValue()+a.SuitValue()));
            // Combine key cards and kickers into the final sorted hand
            cards.Clear();
            
            cards.AddRange(keyCards);
            cards.AddRange(kickers);
            
            if(IsStraight() && (int)(cards[0].FaceValue()) == 14 && (int)(cards[4].FaceValue())==2){
                cards.Add(cards[0]);
                
                cards.RemoveAt(0);
              }
            
        }

        // Compare this hand to another hand based on card values
        public int CompareTo(Hand other) 
        {
            for (int i = 0; i < this.keyCards.Count; i++)
            {
                int cardComparison = this.cards[i].GetHandValue().CompareTo(other.cards[i].GetHandValue());
                
                if (cardComparison != 0)
                {
                    return cardComparison;
                }
            }
            
            foreach(Card card in cards){ // If the hands are the same, take suit into account
              card.SetHandValue(card.SuitValue());
            }
        
        for (int i=this.keyCards.Count;i<cards.Count; i++)
            {
                int cardComparison = this.cards[i].GetHandValue().CompareTo(other.cards[i].GetHandValue());
                if (cardComparison != 0)
                {
                    return cardComparison;
                }
            }
            
            return 0;
        }
        
        
        
    }
}