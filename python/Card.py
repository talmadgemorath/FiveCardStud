class Card:
    def __init__(self, face, suit):
        self.face = face
        self.suit = suit
        self.hand_value = 0.0  # For sorting within the hand

    def get_face(self):
        return self.face

    def get_suit(self):
        return self.suit

    def face_value(self):
        face_values = {
            "2": 2, "3": 3, "4": 4, "5": 5,
            "6": 6, "7": 7, "8": 8, "9": 9,
            "10": 10, "J": 11, "Q": 12, "K": 13, "A": 14
        }
        return face_values.get(self.face, 0)

    def suit_value(self):
        suit_values = {
            "D": 0.1, "C": 0.2, "H": 0.3, "S": 0.4
        }
        return suit_values.get(self.suit, 0)

    def set_hand_value(self, hand_value):
        self.hand_value += hand_value

    def get_hand_value(self):
        return self.hand_value

    def __str__(self):
        return f"{self.face}{self.suit}"