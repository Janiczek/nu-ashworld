module Data.Skill exposing
    ( Skill(..)
    , all
    , decoder
    , encode
    , get
    , isUseful
    , name
    )

import AssocList as Dict_
import Data.Special exposing (Special)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


type Skill
    = SmallGuns
    | BigGuns
    | EnergyWeapons
    | Unarmed
    | MeleeWeapons
    | Throwing
    | FirstAid
    | Doctor
    | Sneak
    | Lockpick
    | Steal
    | Traps
    | Science
    | Repair
    | Speech
    | Barter
    | Gambling
    | Outdoorsman


all : List Skill
all =
    [ SmallGuns
    , BigGuns
    , EnergyWeapons
    , Unarmed
    , MeleeWeapons
    , Throwing
    , FirstAid
    , Doctor
    , Sneak
    , Lockpick
    , Steal
    , Traps
    , Science
    , Repair
    , Speech
    , Barter
    , Gambling
    , Outdoorsman
    ]


name : Skill -> String
name skill =
    case skill of
        SmallGuns ->
            "Small Guns"

        BigGuns ->
            "Big Guns"

        EnergyWeapons ->
            "Energy Weapons"

        Unarmed ->
            "Unarmed"

        MeleeWeapons ->
            "Melee Weapons"

        Throwing ->
            "Throwing"

        FirstAid ->
            "First Aid"

        Doctor ->
            "Doctor"

        Sneak ->
            "Sneak"

        Lockpick ->
            "Lockpick"

        Steal ->
            "Steal"

        Traps ->
            "Traps"

        Science ->
            "Science"

        Repair ->
            "Repair"

        Speech ->
            "Speech"

        Barter ->
            "Barter"

        Gambling ->
            "Gambling"

        Outdoorsman ->
            "Outdoorsman"


specialPercentage : Skill -> Special -> Int
specialPercentage skill s =
    case skill of
        SmallGuns ->
            5 + (4 * s.agility)

        BigGuns ->
            2 * s.agility

        EnergyWeapons ->
            2 * s.agility

        Unarmed ->
            30 + 2 * (s.strength + s.agility)

        MeleeWeapons ->
            55 + ((s.strength + s.agility) // 2)

        Throwing ->
            4 * s.agility

        FirstAid ->
            30 + ((s.perception + s.intelligence) // 2)

        Doctor ->
            15 + ((s.perception + s.intelligence) // 2)

        Sneak ->
            25 + s.agility

        Lockpick ->
            20 + ((s.perception + s.agility) // 2)

        Steal ->
            20 + s.agility

        Traps ->
            20 + ((s.perception + s.agility) // 2)

        Science ->
            4 * s.intelligence

        Repair ->
            20 + s.intelligence

        Speech ->
            5 * s.charisma

        Barter ->
            4 * s.charisma

        Gambling ->
            5 * s.luck

        Outdoorsman ->
            2 * (s.intelligence + s.endurance)


get : Special -> Dict_.Dict Skill Int -> Skill -> Int
get finalSpecial addedPercentages skill =
    let
        added : Int
        added =
            addedPercentages
                |> Dict_.get skill
                |> Maybe.withDefault 0

        viaSpecial : Int
        viaSpecial =
            specialPercentage skill finalSpecial
    in
    min 300 <| added + viaSpecial


encode : Skill -> JE.Value
encode skill =
    JE.string <|
        case skill of
            SmallGuns ->
                "small_guns"

            BigGuns ->
                "big_guns"

            EnergyWeapons ->
                "energy_weapons"

            Unarmed ->
                "unarmed"

            MeleeWeapons ->
                "melee_weapons"

            Throwing ->
                "throwing"

            FirstAid ->
                "first_aid"

            Doctor ->
                "doctor"

            Sneak ->
                "sneak"

            Lockpick ->
                "lockpick"

            Steal ->
                "steal"

            Traps ->
                "traps"

            Science ->
                "science"

            Repair ->
                "repair"

            Speech ->
                "speech"

            Barter ->
                "barter"

            Gambling ->
                "gambling"

            Outdoorsman ->
                "outdoorsman"


decoder : Decoder Skill
decoder =
    JD.string
        |> JD.andThen
            (\skill ->
                case skill of
                    "small_guns" ->
                        JD.succeed SmallGuns

                    "big_guns" ->
                        JD.succeed BigGuns

                    "energy_weapons" ->
                        JD.succeed EnergyWeapons

                    "unarmed" ->
                        JD.succeed Unarmed

                    "melee_weapons" ->
                        JD.succeed MeleeWeapons

                    "throwing" ->
                        JD.succeed Throwing

                    "first_aid" ->
                        JD.succeed FirstAid

                    "doctor" ->
                        JD.succeed Doctor

                    "sneak" ->
                        JD.succeed Sneak

                    "lockpick" ->
                        JD.succeed Lockpick

                    "steal" ->
                        JD.succeed Steal

                    "traps" ->
                        JD.succeed Traps

                    "science" ->
                        JD.succeed Science

                    "repair" ->
                        JD.succeed Repair

                    "speech" ->
                        JD.succeed Speech

                    "barter" ->
                        JD.succeed Barter

                    "gambling" ->
                        JD.succeed Gambling

                    "outdoorsman" ->
                        JD.succeed Outdoorsman

                    _ ->
                        JD.fail <| "unknown Skill: '" ++ skill ++ "'"
            )


isUseful : Skill -> Bool
isUseful skill =
    case skill of
        SmallGuns ->
            False

        BigGuns ->
            False

        EnergyWeapons ->
            False

        Unarmed ->
            True

        MeleeWeapons ->
            False

        Throwing ->
            False

        FirstAid ->
            False

        Doctor ->
            False

        Sneak ->
            False

        Lockpick ->
            False

        Steal ->
            False

        Traps ->
            False

        Science ->
            False

        Repair ->
            False

        Speech ->
            False

        Barter ->
            True

        Gambling ->
            False

        Outdoorsman ->
            False
