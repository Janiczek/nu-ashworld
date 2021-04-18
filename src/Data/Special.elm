module Data.Special exposing
    ( Special
    , SpecialType(..)
    , all
    , canDecrement
    , canIncrement
    , decoder
    , decrement
    , encode
    , get
    , increment
    , init
    , isInRange
    , isValueInRange
    , label
    , map
    , mapWithoutClamp
    )

import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
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
    mapWithoutClamp (\x -> x + 1)


decrement : SpecialType -> Special -> Special
decrement =
    mapWithoutClamp (\x -> x - 1)


mapWithoutClamp : (Int -> Int) -> SpecialType -> Special -> Special
mapWithoutClamp =
    map_ False


map : (Int -> Int) -> SpecialType -> Special -> Special
map =
    map_ True


map_ : Bool -> (Int -> Int) -> SpecialType -> Special -> Special
map_ shouldClamp fn type_ special =
    let
        clampedFn : Int -> Int
        clampedFn =
            if shouldClamp then
                clamp 1 10 << fn

            else
                fn
    in
    case type_ of
        Strength ->
            { special | strength = clampedFn special.strength }

        Perception ->
            { special | perception = clampedFn special.perception }

        Endurance ->
            { special | endurance = clampedFn special.endurance }

        Charisma ->
            { special | charisma = clampedFn special.charisma }

        Intelligence ->
            { special | intelligence = clampedFn special.intelligence }

        Agility ->
            { special | agility = clampedFn special.agility }

        Luck ->
            { special | luck = clampedFn special.luck }


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


decoder : Decoder Special
decoder =
    JD.succeed Special
        |> JD.andMap (JD.field "strength" JD.int)
        |> JD.andMap (JD.field "perception" JD.int)
        |> JD.andMap (JD.field "endurance" JD.int)
        |> JD.andMap (JD.field "charisma" JD.int)
        |> JD.andMap (JD.field "intelligence" JD.int)
        |> JD.andMap (JD.field "agility" JD.int)
        |> JD.andMap (JD.field "luck" JD.int)


isInRange : Special -> Bool
isInRange special =
    let
        isTypeInRange : SpecialType -> Bool
        isTypeInRange type_ =
            let
                value : Int
                value =
                    get type_ special
            in
            isValueInRange value
    in
    List.all isTypeInRange all


isValueInRange : Int -> Bool
isValueInRange value =
    value >= 1 && value <= 10
