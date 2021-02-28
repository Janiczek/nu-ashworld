module Data.Special exposing
    ( Special
    , SpecialType(..)
    , all
    , canIncrement
    , get
    , increment
    , label
    )


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


increment : SpecialType -> Special -> Special
increment type_ special =
    case type_ of
        Strength ->
            { special | strength = special.strength + 1 }

        Perception ->
            { special | perception = special.perception + 1 }

        Endurance ->
            { special | endurance = special.endurance + 1 }

        Charisma ->
            { special | charisma = special.charisma + 1 }

        Intelligence ->
            { special | intelligence = special.intelligence + 1 }

        Agility ->
            { special | agility = special.agility + 1 }

        Luck ->
            { special | luck = special.luck + 1 }
