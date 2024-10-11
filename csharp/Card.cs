using System;

namespace MyGame
{
    public class Card
    {
        private readonly string face;
        private readonly string suit;
        private double handValue; // For sorting within the hand

        public Card(string face, string suit)
        {
            this.face = face;
            this.suit = suit;
            this.handValue = 0.0;
        }

        public string GetFace(){
           return face;
         }

        public string GetSuit(){
           return suit;
         }

        public double FaceValue()
        {
            switch (face)
            {
                case "2": return 2;
                case "3": return 3;
                case "4": return 4;
                case "5": return 5;
                case "6": return 6;
                case "7": return 7;
                case "8": return 8;
                case "9": return 9;
                case "10": return 10;
                case "J": return 11;
                case "Q": return 12;
                case "K": return 13;
                case "A": return 14;
                default: return 0;
            }
        }

        public double SuitValue()
        {
            switch (suit)
            {
                case "D": return 0.1;
                case "C": return 0.2;
                case "H": return 0.3;
                case "S": return 0.4;
                default: return 0;
            }
        }

        public void SetHandValue(double handValue)
        {
            this.handValue += handValue;
        }

        public double GetHandValue(){
           return handValue;
         }

        public override string ToString(){
           return face + suit;
         }
    }
}