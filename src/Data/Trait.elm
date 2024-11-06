module Data.Trait exposing
    ( Trait(..)
    , all
    , codec
    , description
    , isSelected
    , name
    )

import Codec exposing (Codec)
import List.ExtraExtra as List
import SeqSet exposing (SeqSet)


type Trait
    = -- Bloody Mess
      Bruiser
      -- Chem Reliant
      -- Chem Resistant
      -- Fast Metabolism
    | FastShot
    | Finesse
    | Gifted
      -- Good Natured
    | HeavyHanded
      -- Jinxed
    | Kamikaze
    | OneHander
      -- Sex Appeal
    | Skilled
    | SmallFrame


{-| Ordered to resemble Fallout 2 char creation screen
-}
all : List Trait
all =
    [ [ Bruiser, Skilled ]
    , [ SmallFrame, Gifted ]
    , [ OneHander, Finesse ]
    , [ HeavyHanded, FastShot ]
    , [ Kamikaze ]
    ]
        |> List.fastConcat


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

        FastShot ->
            "Fast Shot"

        OneHander ->
            "One Hander"


codec : Codec Trait
codec =
    Codec.enum Codec.string
        [ ( "Bruiser", Bruiser )
        , ( "FastShot", FastShot )
        , ( "Finesse", Finesse )
        , ( "Gifted", Gifted )
        , ( "HeavyHanded", HeavyHanded )
        , ( "Kamikaze", Kamikaze )
        , ( "OneHander", OneHander )
        , ( "Skilled", Skilled )
        , ( "SmallFrame", SmallFrame )
        ]


isSelected : Trait -> SeqSet Trait -> Bool
isSelected trait traits =
    SeqSet.member trait traits


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

        OneHander ->
            """One of your hands is very dominant. You excel with single-handed weapons, but two-handed weapons cause a problem.

* +20% chance to hit with one-handed weapons
* -40% chance to hit with two-handed weapons"""

        SmallFrame ->
            -- TODO Carry Weight reduced to 25 + (15 * Strength) -- not implemented yet
            """You are not quite as big as other people, but that never slowed
you down. You can't carry as much, but you are more agile.

* +1 Agility
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

        FastShot ->
            """You don't have time to aim for a targeted attack, because you attack
faster than normal people. It costs you one less action point for guns and
thrown weapons.

* All gun and thrown weapon attacks cost 1 less AP
* Unable to aim attacks
"""
