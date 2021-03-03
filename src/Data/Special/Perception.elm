module Data.Special.Perception exposing (PerceptionLevel(..), label, level, tooltip)


type PerceptionLevel
    = Perfect
    | Great
    | Good
    | Bad
    | Atrocious


level : Int -> PerceptionLevel
level perception =
    if perception >= 10 then
        Perfect

    else if perception >= 7 then
        Great

    else if perception >= 5 then
        Good

    else if perception >= 2 then
        Bad

    else
        Atrocious


label : PerceptionLevel -> String
label level_ =
    case level_ of
        Perfect ->
            "Perfect"

        Great ->
            "Great"

        Good ->
            "Good"

        Bad ->
            "Bad"

        Atrocious ->
            "Atrocious"


tooltip : PerceptionLevel -> String
tooltip level_ =
    case level_ of
        Perfect ->
            "You see everybody's exact HP and max HP."

        Great ->
            "You see others' HP in range of (Unhurt, Slightly Wounded, Wounded, Severely Wounded, Almost Dead, Dead)."

        Good ->
            "You see others' HP in range of (Unhurt, Wounded, Severely Wounded, Almost Dead, Dead)."

        Bad ->
            "You see others' HP in range of (Alive, Dead)."

        Atrocious ->
            "You have no idea if others are even alive or not."
