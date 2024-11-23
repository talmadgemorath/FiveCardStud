

mutable struct Card
    face::String
    suit::String
    handValue::Float64

    function Card(face::String, suit::String)
        new(face, suit, 0.0)
    end
end

function faceValue(card::Card)
    face = card.face
    if face == "2"
        return 2
    elseif face == "3"
        return 3
    elseif face == "4"
        return 4
    elseif face == "5"
        return 5
    elseif face == "6"
        return 6
    elseif face == "7"
        return 7
    elseif face == "8"
        return 8
    elseif face == "9"
        return 9
    elseif face == "10"
        return 10
    elseif face == "J"
        return 11
    elseif face == "Q"
        return 12
    elseif face == "K"
        return 13
    elseif face == "A"
        return 14
    else
        return 0
    end
end

function suitValue(card::Card)
    suit = card.suit
    if suit == "D"
        return 0.1
    elseif suit == "C"
        return 0.2
    elseif suit == "H"
        return 0.3
    elseif suit == "S"
        return 0.4
    else
        return 0
    end
end

function setHandValue!(card::Card, value::Float64)
    card.handValue = card.handValue + value
end

function getHandValue(card::Card)
    return card.handValue
end

function toString(card::Card)
    return card.face * card.suit * " "
end
