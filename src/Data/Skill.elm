module Data.Skill exposing
    ( Skill(..)
    , all
    , codec
    , combatSkills
    , description
    , get
    , isUseful
    , name
    )

import Codec exposing (Codec)
import Data.Special exposing (Special)
import SeqDict exposing (SeqDict)


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


codec : Codec Skill
codec =
    Codec.enum Codec.string
        [ ( "SmallGuns", SmallGuns )
        , ( "BigGuns", BigGuns )
        , ( "EnergyWeapons", EnergyWeapons )
        , ( "Unarmed", Unarmed )
        , ( "MeleeWeapons", MeleeWeapons )
        , ( "Throwing", Throwing )
        , ( "FirstAid", FirstAid )
        , ( "Doctor", Doctor )
        , ( "Sneak", Sneak )
        , ( "Lockpick", Lockpick )
        , ( "Steal", Steal )
        , ( "Traps", Traps )
        , ( "Science", Science )
        , ( "Repair", Repair )
        , ( "Speech", Speech )
        , ( "Barter", Barter )
        , ( "Gambling", Gambling )
        , ( "Outdoorsman", Outdoorsman )
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


get : Special -> SeqDict Skill Int -> Skill -> Int
get finalSpecial addedPercentages skill =
    let
        added : Int
        added =
            addedPercentages
                |> SeqDict.get skill
                |> Maybe.withDefault 0

        viaSpecial : Int
        viaSpecial =
            specialPercentage skill finalSpecial
    in
    min maxPct <| added + viaSpecial


isUseful : Skill -> Bool
isUseful skill =
    case skill of
        SmallGuns ->
            True

        BigGuns ->
            True

        EnergyWeapons ->
            True

        Unarmed ->
            True

        MeleeWeapons ->
            True

        Throwing ->
            True

        FirstAid ->
            True

        Doctor ->
            True

        Sneak ->
            True

        Lockpick ->
            True

        Steal ->
            True

        Traps ->
            True

        Science ->
            True

        Repair ->
            True

        Speech ->
            True

        Barter ->
            True

        Gambling ->
            False

        Outdoorsman ->
            True


description : Skill -> String
description skill =
    case skill of
        SmallGuns ->
            "The use, care and general knowledge of small firearms - pistols, SMGs and rifles."

        BigGuns ->
            "The operation and maintenance of really big guns - miniguns, rocket launchers, flamethrowers and such."

        EnergyWeapons ->
            "The care and feeding of energy-based weapons. How to arm and operate weapons that use laser or plasma technology."

        Unarmed ->
            "A combination of martial arts, boxing and other hand-to-hand martial arts. Combat with your hands and feet."

        MeleeWeapons ->
            "Using non-ranged weapons in hand-to-hand, or melee combat - knives, sledgehammers, spears, clubs and so on."

        Throwing ->
            "The skill of muscle-propelled ranged weapons, such as throwing knives, spears and grenades."

        FirstAid ->
            "General healing skill. Used to heal small cuts, abrasions and other minor ills. Increases the percentage of HP healed over time (when you receive a new tick)."

        Doctor ->
            "The healing of major wounds and crippled limbs. Increases the percentage of HP healed when you use ticks to heal."

        Sneak ->
            "Quiet movement, and the ability to remain unnoticed. If successful, you will be much harder to locate. You cannot run and sneak at the same time."

        Lockpick ->
            "The skill of opening locks without the proper key. The use of lockpicks or electronic lockpicks will greatly enhance this skill."

        Steal ->
            "The ability to make the things of others your own. Can be used to steal from people or places."

        Traps ->
            "The finding and removal of traps. Also the setting of explosives for demolition purposes."

        Science ->
            "Covers a variety of high technology skills, such as computers, biology, physics and geology."

        Repair ->
            "The practical application of the Science skill for fixing broken equipment, machinery and electronics."

        Speech ->
            "The ability to communicate in a practical and efficient manner. The skill of convincing others that your position is correct. The ability to lie and not get caught."

        Barter ->
            "Trading and trade-related tasks. The ability to get lower prices for items you buy."

        Gambling ->
            "The knowledge and practical skills related to wagering. The skill at cards, dice and other games."

        Outdoorsman ->
            "Practical knowledge of the outdoors, and the ability to live off the land. The knowledge of plants and animals."


combatSkills : List Skill
combatSkills =
    [ SmallGuns
    , BigGuns
    , EnergyWeapons
    , Throwing
    , Unarmed
    , MeleeWeapons

    -- TODO traps?
    ]


maxPct : Int
maxPct =
    300
