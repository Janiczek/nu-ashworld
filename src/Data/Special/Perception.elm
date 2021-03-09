module Data.Special.Perception exposing
    ( PerceptionLevel(..)
    , atLeast
    , label
    , level
    , tooltip
    )


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


toComparable : PerceptionLevel -> Int
toComparable level_ =
    case level_ of
        Atrocious ->
            1

        Bad ->
            2

        Good ->
            3

        Great ->
            4

        Perfect ->
            5


atLeast : PerceptionLevel -> Int -> Bool
atLeast neededLevel perception =
    toComparable (level perception) >= toComparable neededLevel


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
    [ healthPerceptionTooltip level_
    , mapMovementTooltip level_
    ]
        |> String.join " "


healthPerceptionTooltip : PerceptionLevel -> String
healthPerceptionTooltip level_ =
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


mapMovementTooltip : PerceptionLevel -> String
mapMovementTooltip level_ =
    let
        okayMovement : String
        okayMovement =
            "When planning longer route on the map you always go in a mostly efficient straight line but ignore terrain like mountains etc. You also see the AP cost of your route."

        inefficientMovement : String
        inefficientMovement =
            "When planning longer route on the map you always go in a (not very efficient) straight line but ignore terrain like mountains etc."
    in
    case level_ of
        Perfect ->
            okayMovement

        Great ->
            okayMovement

        Good ->
            okayMovement

        Bad ->
            inefficientMovement

        Atrocious ->
            inefficientMovement
