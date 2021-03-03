module Evergreen.V19.Data.Special exposing (..)


type alias Special =
    { strength : Int
    , perception : Int
    , endurance : Int
    , charisma : Int
    , intelligence : Int
    , agility : Int
    , luck : Int
    }


type SpecialType
    = Strength
    | Perception
    | Endurance
    | Charisma
    | Intelligence
    | Agility
    | Luck


init : Special
init =
    Special 5 5 5 5 5 5 5
