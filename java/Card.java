public class Card {
    private final String face;
    private final String suit;
    private double handValue; // For sorting within the hand

    public Card(String face, String suit) {
        this.face = face;
        this.suit = suit;
        this.handValue=0.0;
    }

    public String getFace() {
        return face;
    }

    public String getSuit() {
        return suit;
    }

    public double faceValue() {
        switch (face) {
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
    
    public double suitValue(){
        switch (suit){
            case "D": return .1;
            case "C": return .2;
            case "H": return .3;
            case "S": return .4;
            default: return 0;
        }
    }

    public void setHandValue(double handValue) {
        this.handValue += handValue;
    }

    public double getHandValue() {
        return handValue;
    }

    @Override
    public String toString() {
        return face + suit;
    }
}