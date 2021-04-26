module Data.Enemy exposing
    ( Type(..)
    , actionPoints
    , addedSkillPercentages
    , armorClass
    , caps
    , damageResistanceNormal
    , damageThresholdNormal
    , default
    , encodeType
    , forChunk
    , hp
    , meleeDamageBonus
    , name
    , sequence
    , special
    , typeDecoder
    , xp
    )

import AssocList as Dict_
import Data.Map.Chunk as Chunk exposing (Chunk)
import Data.Skill exposing (Skill(..))
import Data.Special exposing (Special)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random exposing (Generator)
import Random.Extra
import Random.FloatExtra as Random



-- TODO criticalChance : Type -> Int
-- TODO carry weight
-- TODO all other kinds (plasma, ...) of damage threshold and resistance


type Type
    = --  -- Mantises: https://fallout.fandom.com/wiki/Mantis_(Fallout)
      --| Mantis
      --  -- Brahmins: https://fallout.fandom.com/wiki/Brahmin_(Fallout)
      --| Brahmin
      --| AngryBrahmin
      --| WeakBrahmin
      --| WildBrahmin
      --  -- Dogs: https://fallout.fandom.com/wiki/Dog_(Fallout)
      --| Dog
      --| WildDog
      --  -- Rats: https://fallout.fandom.com/wiki/Rat_(Fallout)
      --| Rat
      --| MutatedRat
      --  -- Mole Rats: https://fallout.fandom.com/wiki/Mole_rat_(Fallout)
      --| MoleRat
      --| GreaterMoleRat
      --| MutatedMoleRat
      --  -- Pig Rats: https://fallout.fandom.com/wiki/Pig_rat
      --| PigRat
      --| ToughPigRat
      --| MutatedPigRat
      --  -- Deathclaws: https://fallout.fandom.com/wiki/Deathclaw_(Fallout)
      --| Deathclaw1
      --| Deathclaw2
      --| SmallToughDeathclaw
      --| ToughDeathclaw
      --  -- Geckos: https://fallout.fandom.com/wiki/Gecko_(Fallout_2)
      --| SilverGecko
      --| ToughSilverGecko
      --| GoldenGecko
      --| ToughGoldenGecko
      --  -- TODO | FireGecko -- has a fire breath, let's skip this for now
      --  -- TODO | ToughFireGecko -- has a fire breath, let's skip this for now
      --  -- Centaurs: https://fallout.fandom.com/wiki/Centaur_(Fallout)
      --| Centaur
      --| MeanCentaur
      --  -- Floaters: https://fallout.fandom.com/wiki/Floater_(Fallout)
      --| Floater
      --| NastyFloater
      --  -- TODO Cut enemies:
      --  -- TODO | SporePlant -- has a ranged projectile, let's skip this for now
      --  -- TODO | SuperMutant
      --  -- TODO | Ghoul
      --  -- TODO | Cannibal
      --  -- TODO | Nomad
      --  -- TODO | Outcast
      --  -- TODO | Slave
      --  -- and many others...
      --  -- Wanamingos: https://fallout.fandom.com/wiki/Wanamingo
      --| Wanamingo
      --| ToughWanamingo
      -- Giant Ants: https://fallout.fandom.com/wiki/Giant_ant_(Fallout_2)
      GiantAnt
    | ToughGiantAnt
      -- Radscorpions: https://fallout.fandom.com/wiki/Radscorpion_(Fallout)
      --| TODO BlackRadscorpion
      --| TODO LesserBlackRadscorpion
    | LesserRadscorpion
    | Radscorpion


forChunk : Chunk -> List Type
forChunk chunk =
    {- TODO later let's do this based on worldmap.txt
       (non-public/map-encounters.json), but for now let's
       have Ants eeeEEEEeeeverywhere.
    -}
    [ GiantAnt
    , ToughGiantAnt
    , LesserRadscorpion
    , Radscorpion
    ]


xp : Type -> Int
xp type_ =
    case type_ of
        GiantAnt ->
            25

        ToughGiantAnt ->
            50

        LesserRadscorpion ->
            60

        Radscorpion ->
            110


hp : Type -> Int
hp type_ =
    case type_ of
        GiantAnt ->
            6

        ToughGiantAnt ->
            12

        LesserRadscorpion ->
            10

        Radscorpion ->
            26


armorClass : Type -> Int
armorClass type_ =
    case type_ of
        GiantAnt ->
            4

        ToughGiantAnt ->
            3

        LesserRadscorpion ->
            3

        Radscorpion ->
            5


sequence : Type -> Int
sequence type_ =
    case type_ of
        GiantAnt ->
            9

        ToughGiantAnt ->
            9

        LesserRadscorpion ->
            4

        Radscorpion ->
            4


actionPoints : Type -> Int
actionPoints type_ =
    case type_ of
        GiantAnt ->
            5

        ToughGiantAnt ->
            6

        LesserRadscorpion ->
            5

        Radscorpion ->
            7


meleeDamageBonus : Type -> Int
meleeDamageBonus type_ =
    case type_ of
        GiantAnt ->
            2

        ToughGiantAnt ->
            4

        LesserRadscorpion ->
            4

        Radscorpion ->
            6


damageThresholdNormal : Type -> Int
damageThresholdNormal type_ =
    case type_ of
        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        LesserRadscorpion ->
            0

        Radscorpion ->
            2


damageResistanceNormal : Type -> Int
damageResistanceNormal type_ =
    case type_ of
        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        LesserRadscorpion ->
            0

        Radscorpion ->
            0


default : Type
default =
    GiantAnt


encodeType : Type -> JE.Value
encodeType type_ =
    JE.string <|
        case type_ of
            GiantAnt ->
                "giant-ant"

            ToughGiantAnt ->
                "tough-giant-ant"

            LesserRadscorpion ->
                "lesser-radscorpion"

            Radscorpion ->
                "radscorpion"


typeDecoder : Decoder Type
typeDecoder =
    JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "giant-ant" ->
                        JD.succeed GiantAnt

                    "tough-giant-ant" ->
                        JD.succeed ToughGiantAnt

                    "lesser-radscorpion" ->
                        JD.succeed LesserRadscorpion

                    "radscorpion" ->
                        JD.succeed Radscorpion

                    _ ->
                        JD.fail <| "Unknown Enemy.Type: '" ++ type_ ++ "'"
            )


name : Type -> String
name type_ =
    case type_ of
        GiantAnt ->
            "Giant Ant"

        ToughGiantAnt ->
            "Tough Giant Ant"

        LesserRadscorpion ->
            "Lesser Radscorpion"

        Radscorpion ->
            "Radscorpion"


special : Type -> Special
special type_ =
    case type_ of
        GiantAnt ->
            Special 1 2 1 1 1 4 1

        ToughGiantAnt ->
            Special 2 2 2 1 1 3 5

        LesserRadscorpion ->
            Special 5 2 6 1 1 3 2

        Radscorpion ->
            Special 7 2 6 1 1 5 2


addedSkillPercentages : Type -> Dict_.Dict Skill Int
addedSkillPercentages type_ =
    case type_ of
        GiantAnt ->
            Dict_.fromList
                [ ( Unarmed, 25 )
                , ( MeleeWeapons, 35 )
                ]

        ToughGiantAnt ->
            Dict_.fromList
                [ ( Unarmed, 40 )
                , ( MeleeWeapons, 50 )
                ]

        LesserRadscorpion ->
            Dict_.fromList
                [ ( Unarmed, 29 )
                ]

        Radscorpion ->
            Dict_.fromList
                [ ( Unarmed, 21 )
                ]


caps : Type -> Generator Int
caps type_ =
    let
        common : { average : Float, maxDeviation : Float } -> Generator Int
        common r =
            Random.Extra.frequency
                ( 0.2, Random.constant 0 )
                [ ( 0.8, Random.normallyDistributed r |> Random.map round ) ]
    in
    case type_ of
        GiantAnt ->
            common { average = 30, maxDeviation = 25 }

        ToughGiantAnt ->
            common { average = 60, maxDeviation = 40 }

        LesserRadscorpion ->
            common { average = 50, maxDeviation = 30 }

        Radscorpion ->
            common { average = 100, maxDeviation = 70 }
