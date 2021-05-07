module Data.Enemy exposing
    ( Type(..)
    , actionPoints
    , addedSkillPercentages
    , aimedShotName
    , allTypes
    , caps
    , criticalSpec
    , damageResistanceNormal
    , damageThresholdNormal
    , default
    , encodeType
    , equippedArmor
    , forChunk
    , hp
    , humanAimedShotName
    , manCriticalSpec
    , meleeDamageBonus
    , name
    , naturalArmorClass
    , sequence
    , special
    , typeDecoder
    , xp
    )

import AssocList as Dict_
import Data.Fight.Critical as Critical exposing (Effect(..), EffectCategory(..))
import Data.Fight.ShotType exposing (AimedShot(..))
import Data.Item as Item
import Data.Map.Chunk exposing (Chunk)
import Data.Skill exposing (Skill(..))
import Data.Special exposing (Special, Type(..))
import Data.Xp exposing (BaseXp(..))
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Random exposing (Generator)
import Random.Extra
import Random.FloatExtra as Random exposing (NormalIntSpec)



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


allTypes : List Type
allTypes =
    [ GiantAnt
    , ToughGiantAnt
    , LesserRadscorpion
    , Radscorpion
    ]


forChunk : Chunk -> List Type
forChunk _ =
    {- TODO later let's do this based on worldmap.txt
       (non-public/map-encounters.json), but for now let's
       have Ants eeeEEEEeeeverywhere.
    -}
    [ GiantAnt
    , ToughGiantAnt
    , LesserRadscorpion
    , Radscorpion
    ]


xp : Type -> BaseXp
xp type_ =
    BaseXp <|
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


naturalArmorClass : Type -> Int
naturalArmorClass type_ =
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
        common : NormalIntSpec -> Generator Int
        common r =
            Random.Extra.frequency
                ( 0.2, Random.constant 0 )
                [ ( 0.8, Random.normallyDistributedInt r ) ]
    in
    case type_ of
        GiantAnt ->
            common { average = 10, maxDeviation = 5 }

        ToughGiantAnt ->
            common { average = 20, maxDeviation = 12 }

        LesserRadscorpion ->
            common { average = 25, maxDeviation = 13 }

        Radscorpion ->
            common { average = 60, maxDeviation = 30 }


equippedArmor : Type -> Maybe Item.Kind
equippedArmor type_ =
    case type_ of
        GiantAnt ->
            Nothing

        ToughGiantAnt ->
            Nothing

        LesserRadscorpion ->
            Nothing

        Radscorpion ->
            Nothing


criticalSpec : Type -> AimedShot -> Critical.EffectCategory -> Critical.Spec
criticalSpec enemyType =
    -- https://falloutmods.fandom.com/wiki/Critical_hit_tables
    let
        giantAnt aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "ripping some of its antennae off."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = "knocking him unconscious."
                            }
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = [ BypassArmor ]
                    , message = "breaking some of its feelers."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = "knocking him unconscious."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "breaking some of its feelers."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = "knocking him unconscious."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout, BypassArmor ]
                    , message = "breaking some of its feelers."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = "crushing the temple. Good night, Gracie."
                            }
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "breaking some of its feelers."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "damaging some of its exoskeleton."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftArm
                            , failureMessage = "crippling the left arm."
                            }
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "damaging some of its exoskeleton."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledRightArm
                            , failureMessage = "which really hurts."
                            }
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "breaking past the ant's defenses."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "breaking past the ant's defenses."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout, BypassArmor ]
                    , message = "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = "bowling him over and cripples that leg."
                            }
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledRightLeg
                            , failureMessage = "bowling him over and cripples that leg."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = "and the intense pain of having a leg removed causes him to quit."
                            }
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, CrippledRightLeg, BypassArmor ]
                    , message = "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = "bowling him over and cripples that leg."
                            }
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = "bowling him over and cripples that leg."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = "and the intense pain of having a leg removed causes him to quit."
                            }
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, CrippledLeftLeg, BypassArmor ]
                    , message = "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "breaking past the ant's defenses."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 4
                            , failureEffect = Blinded
                            , failureMessage = "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "damaging some of its exoskeleton."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 3
                            , failureEffect = Blinded
                            , failureMessage = "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = "ripping some of its antennae off."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 2
                            , failureEffect = Blinded
                            , failureMessage = "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = [ Blinded, BypassArmor, LoseNextTurn ]
                    , message = "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = [ Knockout, Blinded, BypassArmor ]
                    , message = "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "breaking past the ant's defenses."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "breaking past the ant's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockdown
                            , failureMessage = "and without protection he falls over, groaning in agony."
                            }
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = "breaking past the ant's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockout ]
                    , message = "damaging its health."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "damaging its health."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, BypassArmor ]
                    , message = "damaging its health."
                    , statCheck = Nothing
                    }

        radscorpion aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 3
                            , failureEffect = Knockdown
                            , failureMessage = "and the attack sends the radscorpion flying on its back."
                            }
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockdown
                            , failureMessage = "and the attack sends the radscorpion flying on its back."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockdown
                            , failureMessage = "and the attack sends the radscorpion flying on its back."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockdown ]
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "separating the head from the carapace."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftArm
                            , failureMessage = "seriously damaging the tail."
                            }
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = "seriously damaging the tail."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = "seriously damaging the tail."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 2
                            , failureEffect = CrippledRightArm
                            , failureMessage = "putting a major hurt on its claws."
                            }
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightArm
                            , failureMessage = "putting a major hurt on its claws."
                            }
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm ]
                    , message = "putting a major hurt on its claws."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "making the blow slip between the cracks of the radscorpion's tough carapace."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "striking through the tough carapace without pausing."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "striking through the tough carapace without pausing."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 0
                            , failureEffect = Knockdown
                            , failureMessage = "passing through the natural armor and knocking the radscorpion over."
                            }
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Death ]
                    , message = "and the radscorpion cannot cope with a new sensation, like missing internal organs."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 2
                            , failureEffect = Knockdown
                            , failureMessage = "sending the radscorpion flying on its back."
                            }
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = "sending the radscorpion flying on its back."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = "crippling some of its legs."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightLeg, BypassArmor ]
                    , message = "cutting through an unprotected joint on the leg, severing it."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 2
                            , failureEffect = Knockdown
                            , failureMessage = "sending the radscorpion flying on its back."
                            }
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "sending the radscorpion flying on its back."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = "crippling some of its legs."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftLeg, BypassArmor ]
                    , message = "cutting through an unprotected joint on the leg, severing it."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 3
                            , failureEffect = Blinded
                            , failureMessage = "seriously wounding and blinding the mutant creature."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = "seriously wounding and blinding the mutant creature."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = -3
                            , failureEffect = Blinded
                            , failureMessage = "seriously wounding and blinding the mutant creature."
                            }
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = []
                    , message = "penetrating almost to the brain. Talk about squashing a bug."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = -3
                            , failureEffect = Blinded
                            , failureMessage = "almost penetrating to the brain, but blinding the creature instead."
                            }
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = "in a fiendish attack, far too sophisticated for this simple creature."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "and if it was human, you would swear it's pretty pissed off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "and if it was human, you would swear it's pretty pissed off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "and if it was human, you would swear it's pretty pissed off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout ]
                    , message = "knocking the poor creature senseless."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout ]
                    , message = "knocking the poor creature senseless."
                    , statCheck = Nothing
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Death ]
                    , message = "spiking the brain to the floor."
                    , statCheck = Nothing
                    }
    in
    case enemyType of
        GiantAnt ->
            giantAnt

        ToughGiantAnt ->
            giantAnt

        LesserRadscorpion ->
            radscorpion

        Radscorpion ->
            radscorpion


humanAimedShotName : AimedShot -> String
humanAimedShotName shot =
    case shot of
        Head ->
            "head"

        Torso ->
            "torso"

        Eyes ->
            "eyes"

        Groin ->
            "groin"

        LeftArm ->
            "left arm"

        RightArm ->
            "right arm"

        LeftLeg ->
            "left leg"

        RightLeg ->
            "right leg"


aimedShotName : Type -> AimedShot -> String
aimedShotName enemyType =
    let
        giantAnt aimedShot =
            case aimedShot of
                Head ->
                    "head"

                Torso ->
                    "abdomen"

                Eyes ->
                    "feelers"

                Groin ->
                    "metathorax"

                LeftArm ->
                    "left foreleg"

                RightArm ->
                    "right foreleg"

                LeftLeg ->
                    "left hindleg"

                RightLeg ->
                    "right hindleg"

        radscorpion aimedShot =
            case aimedShot of
                Head ->
                    "head"

                Torso ->
                    "carapace"

                Eyes ->
                    "eyes"

                Groin ->
                    "brain"

                LeftArm ->
                    "tail"

                RightArm ->
                    "claw"

                LeftLeg ->
                    "hindlegs"

                RightLeg ->
                    "forelegs"
    in
    case enemyType of
        GiantAnt ->
            giantAnt

        ToughGiantAnt ->
            giantAnt

        LesserRadscorpion ->
            radscorpion

        Radscorpion ->
            radscorpion


manCriticalSpec : AimedShot -> Critical.EffectCategory -> Critical.Spec
manCriticalSpec aimedShot effectCategory =
    -- TODO woman critical spec? https://falloutmods.fandom.com/wiki/Critical_hit_tables#Women
    case ( aimedShot, effectCategory ) of
        ( Head, Effect1 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = "inflicting a serious wound."
            , statCheck = Nothing
            }

        ( Head, Effect2 ) ->
            { damageMultiplier = 4
            , effects = [ BypassArmor ]
            , message = "bypassing the armor defenses."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage = "knocking him unconscious."
                    }
            }

        ( Head, Effect3 ) ->
            { damageMultiplier = 5
            , effects = [ Knockout ]
            , message = "bypassing the armor defenses."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockout
                    , failureMessage = "knocking him unconscious."
                    }
            }

        ( Head, Effect4 ) ->
            { damageMultiplier = 5
            , effects = [ Knockdown, BypassArmor ]
            , message = "knocking him to the ground."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockout
                    , failureMessage = "knocking him unconscious."
                    }
            }

        ( Head, Effect5 ) ->
            { damageMultiplier = 6
            , effects = [ Knockout, BypassArmor ]
            , message = "and the strong blow to the head knocks him out."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 0
                    , failureEffect = Blinded
                    , failureMessage = "and the attack crushes the temple. Good night, Gracie."
                    }
            }

        ( Head, Effect6 ) ->
            { damageMultiplier = 6
            , effects = [ Death ]
            , message = "resulting in instantaneous death."
            , statCheck = Nothing
            }

        ( LeftArm, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = "causing severe tennis elbow."
            , statCheck = Nothing
            }

        ( LeftArm, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ LoseNextTurn ]
            , message = "pushing the arm out of the way."
            , statCheck = Nothing
            }

        ( LeftArm, Effect3 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = "leaving a big bruise."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledLeftArm
                    , failureMessage = "crippling the left arm."
                    }
            }

        ( LeftArm, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledLeftArm, BypassArmor ]
            , message = "leaving the left arm dangling by the skin."
            , statCheck = Nothing
            }

        ( LeftArm, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledLeftArm, BypassArmor ]
            , message = "leaving the left arm dangling by the skin."
            , statCheck = Nothing
            }

        ( LeftArm, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledLeftArm, BypassArmor ]
            , message = "leaving the left arm looking like a bloody stump."
            , statCheck = Nothing
            }

        ( RightArm, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = "causing severe tennis elbow."
            , statCheck = Nothing
            }

        ( RightArm, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ LoseNextTurn ]
            , message = "pushing the arm out of the way."
            , statCheck = Nothing
            }

        ( RightArm, Effect3 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = "which really hurts."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledRightArm
                    , failureMessage = "leaving a crippled right arm."
                    }
            }

        ( RightArm, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledRightArm, BypassArmor ]
            , message = "pulverizing his right arm by this powerful blow."
            , statCheck = Nothing
            }

        ( RightArm, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledRightArm, BypassArmor ]
            , message = "pulverizing his right arm by this powerful blow."
            , statCheck = Nothing
            }

        ( RightArm, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledRightArm, BypassArmor ]
            , message = "leaving the right arm looking like a bloody stump."
            , statCheck = Nothing
            }

        ( Torso, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = "in a forceful blow."
            , statCheck = Nothing
            }

        ( Torso, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ BypassArmor ]
            , message = "blowing through the armor."
            , statCheck = Nothing
            }

        ( Torso, Effect3 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, BypassArmor ]
            , message = "bypassing the armor, knocking the combatant to the ground."
            , statCheck = Nothing
            }

        ( Torso, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, BypassArmor ]
            , message = "bypassing the armor, knocking the combatant to the ground."
            , statCheck = Nothing
            }

        ( Torso, Effect5 ) ->
            { damageMultiplier = 6
            , effects = [ Knockout, BypassArmor ]
            , message = "knocking the air out, and he slumps to the ground out of the fight."
            , statCheck = Nothing
            }

        ( Torso, Effect6 ) ->
            { damageMultiplier = 6
            , effects = [ Death ]
            , message = "and unfortunately his spine is now clearly visible from the front."
            , statCheck = Nothing
            }

        ( RightLeg, Effect1 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message = "knocking him to the ground like a bowling pin in a league game."
            , statCheck = Nothing
            }

        ( RightLeg, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message = "knocking him to the ground like a bowling pin in a league game."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = CrippledRightLeg
                    , failureMessage = "bowling him over and crippling that leg."
                    }
            }

        ( RightLeg, Effect3 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown ]
            , message = "knocking him to the ground like a bowling pin in a league game."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledRightLeg
                    , failureMessage = "bowling him over and crippling that leg."
                    }
            }

        ( RightLeg, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
            , message = "smashing the knee into the next town. He falls."
            , statCheck = Nothing
            }

        ( RightLeg, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
            , message = "smashing the knee into the next town. He falls."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage = "and the intense pain of having a leg removed causes him to quit."
                    }
            }

        ( RightLeg, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ Knockout, CrippledRightLeg, BypassArmor ]
            , message = "and the intense pain of having a leg removed causes him to quit."
            , statCheck = Nothing
            }

        ( LeftLeg, Effect1 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message = "knocking him to the ground like a bowling pin in a league game."
            , statCheck = Nothing
            }

        ( LeftLeg, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message = "knocking him to the ground like a bowling pin in a league game."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = CrippledLeftLeg
                    , failureMessage = "bowling him over and crippling that leg."
                    }
            }

        ( LeftLeg, Effect3 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown ]
            , message = "knocking him to the ground like a bowling pin in a league game."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledLeftLeg
                    , failureMessage = "bowling him over and crippling that leg."
                    }
            }

        ( LeftLeg, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
            , message = "smashing the knee into the next town. He falls."
            , statCheck = Nothing
            }

        ( LeftLeg, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
            , message = "smashing the knee into the next town. He falls."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage = "and the intense pain of having a leg removed causes him to quit."
                    }
            }

        ( LeftLeg, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ Knockout, CrippledLeftLeg, BypassArmor ]
            , message = "and the intense pain of having a leg removed causes him to quit."
            , statCheck = Nothing
            }

        ( Eyes, Effect1 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = "inflicting some extra pain."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 4
                    , failureEffect = Blinded
                    , failureMessage = "causing blindness, unluckily for him."
                    }
            }

        ( Eyes, Effect2 ) ->
            { damageMultiplier = 4
            , effects = [ BypassArmor ]
            , message = "with no protection there, causing serious pain."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 3
                    , failureEffect = Blinded
                    , failureMessage = "causing blindness, unluckily for him."
                    }
            }

        ( Eyes, Effect3 ) ->
            { damageMultiplier = 6
            , effects = [ BypassArmor ]
            , message = "with no protection there, causing serious pain."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 2
                    , failureEffect = Blinded
                    , failureMessage = "causing blindness, unluckily for him."
                    }
            }

        ( Eyes, Effect4 ) ->
            { damageMultiplier = 6
            , effects = [ Blinded, BypassArmor, LoseNextTurn ]
            , message = "blinding him with a stunning blow."
            , statCheck = Nothing
            }

        ( Eyes, Effect5 ) ->
            { damageMultiplier = 8
            , effects = [ Knockout, Blinded, BypassArmor ]
            , message = "the loss of an eye is too much for him, and he falls to the ground."
            , statCheck = Nothing
            }

        ( Eyes, Effect6 ) ->
            { damageMultiplier = 8
            , effects = [ Death ]
            , message = "and sadly he is too busy feeling the rush of air on the brain to notice death approaching."
            , statCheck = Nothing
            }

        ( Groin, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = "which had to hurt."
            , statCheck = Nothing
            }

        ( Groin, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ BypassArmor ]
            , message = "and he's not wearing a cup, either."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockdown
                    , failureMessage = "and without protection, he falls over, groaning in agony."
                    }
            }

        ( Groin, Effect3 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message = "and without protection, he falls over, groaning in agony."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockout
                    , failureMessage = "the pain is too much for him and he collapses like a rag."
                    }
            }

        ( Groin, Effect4 ) ->
            { damageMultiplier = 3
            , effects = [ Knockout ]
            , message = "the pain is too much for him and he collapses like a rag."
            , statCheck = Nothing
            }

        ( Groin, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, BypassArmor ]
            , message = "and without protection, he falls over, groaning in agony."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage = "the pain is too much for him and he collapses like a rag."
                    }
            }

        ( Groin, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ Knockout, BypassArmor ]
            , message = "he mumbles 'Mother', as his eyes roll into the back of his head."
            , statCheck = Nothing
            }
