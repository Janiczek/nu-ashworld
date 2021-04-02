module Data.Special exposing
    ( Special
    , SpecialType(..)
    , all
    , canDecrement
    , canIncrement
    , decrement
    , encode
    , get
    , increment
    , init
    , isUseful
    , label
    )

import Json.Encode as JE


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


isUseful : SpecialType -> Bool
isUseful type_ =
    case type_ of
        Strength ->
            True

        Perception ->
            True

        Endurance ->
            True

        Charisma ->
            False

        Intelligence ->
            False

        Agility ->
            True

        Luck ->
            False


label : SpecialType -> String
label type_ =
    case type_ of
        Strength ->
            "Strength"

        Perception ->
            "Perception"

        Endurance ->
            "Endurance"

        Charisma ->
            "Charisma"

        Intelligence ->
            "Intelligence"

        Agility ->
            "Agility"

        Luck ->
            "Luck"


all : List SpecialType
all =
    [ Strength
    , Perception
    , Endurance
    , Charisma
    , Intelligence
    , Agility
    , Luck
    ]


get : SpecialType -> (Special -> Int)
get type_ =
    case type_ of
        Strength ->
            .strength

        Perception ->
            .perception

        Endurance ->
            .endurance

        Charisma ->
            .charisma

        Intelligence ->
            .intelligence

        Agility ->
            .agility

        Luck ->
            .luck


canIncrement : Int -> SpecialType -> Special -> Bool
canIncrement availablePoints type_ special =
    availablePoints > 0 && get type_ special < 10


canDecrement : SpecialType -> Special -> Bool
canDecrement type_ special =
    get type_ special > 1


increment : SpecialType -> Special -> Special
increment =
    map (\x -> x + 1)


decrement : SpecialType -> Special -> Special
decrement =
    map (\x -> x - 1)


map : (Int -> Int) -> SpecialType -> Special -> Special
map fn type_ special =
    case type_ of
        Strength ->
            { special | strength = fn special.strength }

        Perception ->
            { special | perception = fn special.perception }

        Endurance ->
            { special | endurance = fn special.endurance }

        Charisma ->
            { special | charisma = fn special.charisma }

        Intelligence ->
            { special | intelligence = fn special.intelligence }

        Agility ->
            { special | agility = fn special.agility }

        Luck ->
            { special | luck = fn special.luck }


init : Special
init =
    Special 5 5 5 5 5 5 5


encode : Special -> JE.Value
encode special =
    JE.object
        [ ( "strength", JE.int special.strength )
        , ( "perception", JE.int special.perception )
        , ( "endurance", JE.int special.endurance )
        , ( "charisma", JE.int special.charisma )
        , ( "intelligence", JE.int special.intelligence )
        , ( "agility", JE.int special.agility )
        , ( "luck", JE.int special.luck )
        ]
