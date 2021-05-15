module Data.Special exposing
    ( Special
    , Type(..)
    , all
    , canDecrement
    , canIncrement
    , decoder
    , decrement
    , decrementNewChar
    , description
    , encode
    , get
    , increment
    , init
    , isInRange
    , isValueInRange
    , label
    , mapWithoutClamp
    , sum
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


type Type
    = Strength
    | Perception
    | Endurance
    | Charisma
    | Intelligence
    | Agility
    | Luck


label : Type -> String
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


all : List Type
all =
    [ Strength
    , Perception
    , Endurance
    , Charisma
    , Intelligence
    , Agility
    , Luck
    ]


get : Type -> (Special -> Int)
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


canIncrement : Int -> Type -> Special -> Bool
canIncrement availablePoints type_ special =
    availablePoints > 0 && get type_ special < 10


canDecrement : Type -> Special -> Bool
canDecrement type_ special =
    get type_ special > 1


increment : Type -> Special -> Special
increment =
    map (\x -> x + 1)


decrement : Type -> Special -> Special
decrement =
    map (\x -> x - 1)


{-| NewChar Special can go below 0.
Imagine this sequence:

  - Select traits Bruiser and Gifted (= +3 Strength)
  - decrement Strength so that after traits it's 1
  - it's "real" value is -2

-}
decrementNewChar : Type -> Special -> Special
decrementNewChar =
    mapWithoutClamp (\x -> x - 1)


mapWithoutClamp : (Int -> Int) -> Type -> Special -> Special
mapWithoutClamp =
    map_ { shouldClamp = False }


map : (Int -> Int) -> Type -> Special -> Special
map =
    map_ { shouldClamp = True }


map_ : { shouldClamp : Bool } -> (Int -> Int) -> Type -> Special -> Special
map_ { shouldClamp } fn type_ special =
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
        isTypeInRange : Type -> Bool
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


sum : Special -> Int
sum special =
    List.sum <| List.map (\t -> get t special) all


description : Type -> String
description type_ =
    case type_ of
        Strength ->
            "Raw physical strength. A high Strength is good for physical characters."

        Perception ->
            "The ability to see, hear, taste and notice unusual things. A high Perception is important for a sharpshooter."

        Endurance ->
            "Stamina and physical toughness. A character with a high Endurance will survive where others may not."

        Charisma ->
            "A combination of appearance and charm. A high Charisma is important for characters that want to influence people with words."

        Intelligence ->
            "Knowledge, wisdom and the ability to think quickly. A high Intelligence is important for any character."

        Agility ->
            "Coordination and the ability to move well. A high Agility is important for any active character."

        Luck ->
            "Fate. Karma. An extremely high or low Luck will affect the character - somehow. Events and situations will be changed by how lucky (or unlucky) your character is."
