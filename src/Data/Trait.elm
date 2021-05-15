module Data.Trait exposing
    ( Trait(..)
    , all
    , decoder
    , description
    , encode
    , isSelected
    , name
    )

import AssocSet as Set_
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE



{- TODO go through
   https://fallout.fandom.com/wiki/Fallout_2_traits
   and implement all missing and applicable
-}
-- TODO Small Frame - carry weight


type Trait
    = Kamikaze
    | Bruiser
    | Gifted
    | SmallFrame
    | Skilled
    | HeavyHanded
    | Finesse


all : List Trait
all =
    -- TODO sort them according to F2
    [ Bruiser
    , Kamikaze
    , Gifted
    , SmallFrame
    , Skilled
    , HeavyHanded
    , Finesse
    ]


name : Trait -> String
name trait =
    case trait of
        Kamikaze ->
            "Kamikaze"

        Bruiser ->
            "Bruiser"

        Gifted ->
            "Gifted"

        SmallFrame ->
            "Small Frame"

        Skilled ->
            "Skilled"

        HeavyHanded ->
            "Heavy Handed"

        Finesse ->
            "Finesse"


encode : Trait -> JE.Value
encode trait =
    JE.string <|
        case trait of
            Kamikaze ->
                "kamikaze"

            Bruiser ->
                "bruiser"

            Gifted ->
                "gifted"

            SmallFrame ->
                "small-frame"

            Skilled ->
                "skilled"

            HeavyHanded ->
                "heavy-handed"

            Finesse ->
                "finesse"


decoder : Decoder Trait
decoder =
    JD.string
        |> JD.andThen
            (\trait ->
                case trait of
                    "kamikaze" ->
                        JD.succeed Kamikaze

                    "bruiser" ->
                        JD.succeed Bruiser

                    "gifted" ->
                        JD.succeed Gifted

                    "small-frame" ->
                        JD.succeed SmallFrame

                    "skilled" ->
                        JD.succeed Skilled

                    "heavy-handed" ->
                        JD.succeed HeavyHanded

                    "finesse" ->
                        JD.succeed Finesse

                    _ ->
                        JD.fail <| "unknown Trait: '" ++ trait ++ "'"
            )


isSelected : Trait -> Set_.Set Trait -> Bool
isSelected trait traits =
    Set_.member trait traits


description : Trait -> String
description trait =
    case trait of
        Bruiser ->
            """A little slower, but a little bigger. You may not hit as often,
but they will feel it when you do! Your total action points are lowered, but
your Strength is increased.

* +2 Strength
* -2 Action Points
"""

        Kamikaze ->
            """By not paying attention to any threats, you can act a lot faster
in a turn. This lowers your Armor Class to just what you are wearing, but you
sequence much faster in a combat turn.

* +5 Sequence
* no natural Armor Class
"""

        Gifted ->
            """You have more innate abilities than most, so you have not spent
as much time honing your skills.

* +1 to all seven SPECIAL attributes
* -10% to all skills
* 5 less skill points per level
"""

        SmallFrame ->
            """You are not quite as big as other people, but that never slowed
you down. You can't carry as much, but you are more agile.

* +1 Agility
* Carry Weight reduced to 25 + (15 * Strength) -- not implemented yet
"""

        Skilled ->
            """Since you spend more time improving your skills than a normal
person, you gain more skill points. The tradeoff is that you do not gain as
many extra abilities. You will gain a perk every four levels. You will get an
additional 5 skill points per new experience level.

* +5 additional skill points per level
* gain a perk every 4 levels (instead of 3)
"""

        HeavyHanded ->
            """You swing harder, not better. Your attacks are very brutal, but
lack finesse. You rarely cause a good critical hit, but you always do more
melee damage.

* +4 melee damage
* Critical hits have a -30% modifier to the critical hit tables
"""

        Finesse ->
            """Your attacks show a lot of finesse. You don't do as much damage,
but you cause more critical hits.

* +10% critical chance
* -30% damage
"""
