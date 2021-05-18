module Data.Enemy exposing
    ( Type(..)
    , actionPoints
    , addedSkillPercentages
    , aimedShotName
    , allTypes
    , criticalSpec
    , damageResistanceNormal
    , damageThresholdNormal
    , default
    , dropGenerator
    , dropSpec
    , encodeType
    , equippedArmor
    , forSmallChunk
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
import Data.Item as Item exposing (Item)
import Data.Map.Chunk as Chunk exposing (BigChunk(..), SmallChunk)
import Data.Skill exposing (Skill(..))
import Data.Special exposing (Special, Type(..))
import Data.Xp exposing (BaseXp(..))
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Maybe.Extra as Maybe
import NonemptyList exposing (NonemptyList)
import Random exposing (Generator)
import Random.Bool as Random
import Random.Extra as Random
import Random.FloatExtra as Random exposing (NormalIntSpec)



-- TODO criticalChance : Type -> Int
-- TODO carry weight
-- TODO all other kinds (plasma, ...) of damage threshold and resistance


type Type
    = --  -- Mantises: https://fallout.fandom.com/wiki/Mantis_(Fallout)
      --| Mantis
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
      -- Brahmins: https://fallout.fandom.com/wiki/Brahmin_(Fallout)
      Brahmin
    | AngryBrahmin
    | WeakBrahmin
    | WildBrahmin
    | GiantAnt
    | ToughGiantAnt
      -- Radscorpions: https://fallout.fandom.com/wiki/Radscorpion_(Fallout)
    | BlackRadscorpion
    | LesserBlackRadscorpion
    | LesserRadscorpion
    | Radscorpion


allTypes : List Type
allTypes =
    [ Brahmin
    , AngryBrahmin
    , WeakBrahmin
    , WildBrahmin
    , GiantAnt
    , ToughGiantAnt
    , LesserRadscorpion
    , Radscorpion
    , LesserBlackRadscorpion
    , BlackRadscorpion
    ]


{-| For now we're not doing things as granularly as the original game does.

We are splitting the map into five big chunks and only figuring out the
possible enemies based on those five chunks.

-}
forBigChunk : BigChunk -> List Type
forBigChunk bigChunk =
    -- TODO rebalance C4 and C5, add new tougher enemies?
    case bigChunk of
        C1 ->
            [ GiantAnt
            , ToughGiantAnt
            , LesserRadscorpion
            , Radscorpion -- dangerous
            ]

        C2 ->
            [ LesserRadscorpion
            , Radscorpion
            , Brahmin
            , AngryBrahmin -- dangerous
            , WeakBrahmin
            , WildBrahmin -- semi-dangerous
            ]

        C3 ->
            [ Brahmin
            , AngryBrahmin -- dangerous
            , WeakBrahmin
            , WildBrahmin
            , LesserBlackRadscorpion
            , BlackRadscorpion -- dangerous
            ]

        C4 ->
            [ AngryBrahmin -- dangerous
            , WildBrahmin
            , LesserBlackRadscorpion
            , BlackRadscorpion -- dangerous
            ]

        C5 ->
            [ AngryBrahmin -- dangerous
            , BlackRadscorpion -- dangerous
            ]


forSmallChunk : SmallChunk -> List Type
forSmallChunk smallChunk =
    let
        bigChunk : BigChunk
        bigChunk =
            Chunk.smallToBig smallChunk
    in
    forBigChunk bigChunk


xp : Type -> BaseXp
xp type_ =
    BaseXp <|
        case type_ of
            Brahmin ->
                80

            AngryBrahmin ->
                150

            WeakBrahmin ->
                40

            WildBrahmin ->
                120

            GiantAnt ->
                25

            ToughGiantAnt ->
                50

            LesserRadscorpion ->
                60

            Radscorpion ->
                110

            BlackRadscorpion ->
                220

            LesserBlackRadscorpion ->
                110


hp : Type -> Int
hp type_ =
    case type_ of
        Brahmin ->
            35

        AngryBrahmin ->
            70

        WeakBrahmin ->
            30

        WildBrahmin ->
            65

        GiantAnt ->
            6

        ToughGiantAnt ->
            12

        LesserRadscorpion ->
            10

        Radscorpion ->
            26

        BlackRadscorpion ->
            50

        LesserBlackRadscorpion ->
            26


naturalArmorClass : Type -> Int
naturalArmorClass type_ =
    case type_ of
        Brahmin ->
            4

        AngryBrahmin ->
            22

        WeakBrahmin ->
            1

        WildBrahmin ->
            21

        GiantAnt ->
            4

        ToughGiantAnt ->
            3

        LesserRadscorpion ->
            3

        Radscorpion ->
            5

        BlackRadscorpion ->
            5

        LesserBlackRadscorpion ->
            5


sequence : Type -> Int
sequence type_ =
    case type_ of
        Brahmin ->
            6

        AngryBrahmin ->
            10

        WeakBrahmin ->
            6

        WildBrahmin ->
            10

        GiantAnt ->
            9

        ToughGiantAnt ->
            9

        LesserRadscorpion ->
            4

        Radscorpion ->
            4

        BlackRadscorpion ->
            6

        LesserBlackRadscorpion ->
            4


actionPoints : Type -> Int
actionPoints type_ =
    case type_ of
        Brahmin ->
            7

        AngryBrahmin ->
            10

        WeakBrahmin ->
            6

        WildBrahmin ->
            10

        GiantAnt ->
            5

        ToughGiantAnt ->
            6

        LesserRadscorpion ->
            5

        Radscorpion ->
            7

        BlackRadscorpion ->
            5

        LesserBlackRadscorpion ->
            7


meleeDamageBonus : Type -> Int
meleeDamageBonus type_ =
    case type_ of
        Brahmin ->
            7

        AngryBrahmin ->
            4

        WeakBrahmin ->
            1

        WildBrahmin ->
            7

        GiantAnt ->
            2

        ToughGiantAnt ->
            4

        LesserRadscorpion ->
            4

        Radscorpion ->
            6

        BlackRadscorpion ->
            12

        LesserBlackRadscorpion ->
            10


damageThresholdNormal : Type -> Int
damageThresholdNormal type_ =
    case type_ of
        Brahmin ->
            0

        AngryBrahmin ->
            2

        WeakBrahmin ->
            0

        WildBrahmin ->
            2

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        BlackRadscorpion ->
            4

        LesserBlackRadscorpion ->
            2


damageResistanceNormal : Type -> Int
damageResistanceNormal type_ =
    case type_ of
        Brahmin ->
            20

        AngryBrahmin ->
            25

        WeakBrahmin ->
            20

        WildBrahmin ->
            25

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        LesserRadscorpion ->
            0

        Radscorpion ->
            0

        BlackRadscorpion ->
            10

        LesserBlackRadscorpion ->
            0


default : Type
default =
    GiantAnt


encodeType : Type -> JE.Value
encodeType type_ =
    JE.string <|
        case type_ of
            Brahmin ->
                "brahmin"

            AngryBrahmin ->
                "angry-brahmin"

            WeakBrahmin ->
                "weak-brahmin"

            WildBrahmin ->
                "wild-brahmin"

            GiantAnt ->
                "giant-ant"

            ToughGiantAnt ->
                "tough-giant-ant"

            LesserRadscorpion ->
                "lesser-radscorpion"

            Radscorpion ->
                "radscorpion"

            BlackRadscorpion ->
                "black-radscorpion"

            LesserBlackRadscorpion ->
                "lesser-black-radscorpion"


typeDecoder : Decoder Type
typeDecoder =
    JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "brahmin" ->
                        JD.succeed Brahmin

                    "angry-brahmin" ->
                        JD.succeed AngryBrahmin

                    "weak-brahmin" ->
                        JD.succeed WeakBrahmin

                    "wild-brahmin" ->
                        JD.succeed WildBrahmin

                    "giant-ant" ->
                        JD.succeed GiantAnt

                    "tough-giant-ant" ->
                        JD.succeed ToughGiantAnt

                    "lesser-radscorpion" ->
                        JD.succeed LesserRadscorpion

                    "radscorpion" ->
                        JD.succeed Radscorpion

                    "lesser-black-radscorpion" ->
                        JD.succeed LesserBlackRadscorpion

                    "black-radscorpion" ->
                        JD.succeed BlackRadscorpion

                    _ ->
                        JD.fail <| "Unknown Enemy.Type: '" ++ type_ ++ "'"
            )


name : Type -> String
name type_ =
    case type_ of
        Brahmin ->
            "Brahmin"

        AngryBrahmin ->
            "Angry Brahmin"

        WeakBrahmin ->
            "Weak Brahmin"

        WildBrahmin ->
            "Wild Brahmin"

        GiantAnt ->
            "Giant Ant"

        ToughGiantAnt ->
            "Tough Giant Ant"

        LesserRadscorpion ->
            "Lesser Radscorpion"

        Radscorpion ->
            "Radscorpion"

        LesserBlackRadscorpion ->
            "Lesser Black Radscorpion"

        BlackRadscorpion ->
            "Black Radscorpion"


special : Type -> Special
special type_ =
    case type_ of
        Brahmin ->
            Special 8 3 8 3 2 4 1

        AngryBrahmin ->
            Special 9 5 5 1 3 7 5

        WeakBrahmin ->
            Special 4 3 4 1 1 3 1

        WildBrahmin ->
            Special 8 5 5 1 3 6 5

        GiantAnt ->
            Special 1 2 1 1 1 4 1

        ToughGiantAnt ->
            Special 2 2 2 1 1 3 5

        LesserRadscorpion ->
            Special 5 2 6 1 1 3 2

        Radscorpion ->
            Special 7 2 6 1 1 5 2

        LesserBlackRadscorpion ->
            Special 5 2 6 1 1 5 2

        BlackRadscorpion ->
            Special 8 3 7 1 1 5 3


addedSkillPercentages : Type -> Dict_.Dict Skill Int
addedSkillPercentages type_ =
    case type_ of
        Brahmin ->
            Dict_.fromList
                [ ( Unarmed, 19 )
                ]

        AngryBrahmin ->
            Dict_.fromList
                [ ( Unarmed, 63 )
                , ( MeleeWeapons, 73 )
                ]

        WeakBrahmin ->
            Dict_.empty

        WildBrahmin ->
            Dict_.fromList
                [ ( Unarmed, 52 )
                , ( MeleeWeapons, 2 )
                ]

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

        LesserBlackRadscorpion ->
            Dict_.fromList
                [ ( Unarmed, 25 )
                ]

        BlackRadscorpion ->
            Dict_.fromList
                [ ( Unarmed, 54 )
                ]


equippedArmor : Type -> Maybe Item.Kind
equippedArmor type_ =
    case type_ of
        Brahmin ->
            Nothing

        AngryBrahmin ->
            Nothing

        WeakBrahmin ->
            Nothing

        WildBrahmin ->
            Nothing

        GiantAnt ->
            Nothing

        ToughGiantAnt ->
            Nothing

        LesserRadscorpion ->
            Nothing

        Radscorpion ->
            Nothing

        LesserBlackRadscorpion ->
            Nothing

        BlackRadscorpion ->
            Nothing


criticalSpec : Type -> AimedShot -> Critical.EffectCategory -> Critical.Spec
criticalSpec enemyType =
    -- https://falloutmods.fandom.com/wiki/Critical_hit_tables
    let
        brahmin aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 2
                            , failureEffect = Knockdown
                            , failureMessage = "knocking the big beast to the ground."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -1
                            , failureEffect = Knockdown
                            , failureMessage = "knocking the big beast to the ground."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout ]
                    , message = "stunning both brains and felling the giant animal."
                    , statCheck = Nothing
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "and the mutant cow gives a loud, startled cry."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftArm
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
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
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightArm
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightArm
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm ]
                    , message = "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm ]
                    , message = "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "seriously hurting the mutant cow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "seriously hurting the mutant cow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "seriously hurting the mutant cow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "easily penetrating the thick hide of the giant beast."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "easily penetrating the thick hide of the giant beast."
                    , statCheck = Nothing
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "penetrating straight through both hearts of the mutant cow."
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
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightLeg ]
                    , message = "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightLeg ]
                    , message = "breaking one of the Brahmin's legs."
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
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftLeg ]
                    , message = "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftLeg ]
                    , message = "breaking one of the Brahmin's legs."
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
                    , effects = [ BypassArmor ]
                    , message = "with no protection there, causing serious pain."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = "blinding both sets of eyes with a single blow."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = "with no protection there, causing serious pain."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = -3
                            , failureEffect = Blinded
                            , failureMessage = "blinding both sets of eyes with a single blow."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = [ Blinded, BypassArmor, LoseNextTurn ]
                    , message = "blinding both heads and stunning the mutant cow."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = [ Knockout, Blinded, BypassArmor ]
                    , message = "completely blinding the Brahmin and knocking it out."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = "and the large mutant bovine stumbles for a moment."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "and the Brahmin shakes with rage."
                    , statCheck = Nothing
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "and the Brahmin shakes with rage."
                    , statCheck = Nothing
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "and the Brahmin snorts with pain."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "and the Brahmin snorts with pain."
                    , statCheck = Nothing
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = "and the Brahmin is most upset with this udderly devastating attack."
                    , statCheck = Nothing
                    }

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
        Brahmin ->
            brahmin

        AngryBrahmin ->
            brahmin

        WeakBrahmin ->
            brahmin

        WildBrahmin ->
            brahmin

        GiantAnt ->
            giantAnt

        ToughGiantAnt ->
            giantAnt

        LesserRadscorpion ->
            radscorpion

        Radscorpion ->
            radscorpion

        LesserBlackRadscorpion ->
            radscorpion

        BlackRadscorpion ->
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
        brahmin aimedShot =
            case aimedShot of
                Head ->
                    "head"

                Torso ->
                    "torso"

                Eyes ->
                    "eyes"

                Groin ->
                    "groin"

                LeftArm ->
                    "left foreleg"

                RightArm ->
                    "right foreleg"

                LeftLeg ->
                    "left hindleg"

                RightLeg ->
                    "right hindleg"

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
        Brahmin ->
            brahmin

        AngryBrahmin ->
            brahmin

        WeakBrahmin ->
            brahmin

        WildBrahmin ->
            brahmin

        GiantAnt ->
            giantAnt

        ToughGiantAnt ->
            giantAnt

        LesserRadscorpion ->
            radscorpion

        Radscorpion ->
            radscorpion

        LesserBlackRadscorpion ->
            radscorpion

        BlackRadscorpion ->
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


type alias DropSpec =
    { caps : NonemptyList ( Float, Generator Int )
    , items : List ( Float, ItemDropSpec )
    }


type alias ItemDropSpec =
    { uniqueKey : Item.UniqueKey
    , count : NormalIntSpec
    }


dropSpec : Type -> DropSpec
dropSpec type_ =
    let
        commonCaps : NormalIntSpec -> NonemptyList ( Float, Generator Int )
        commonCaps r =
            ( ( 0.2, Random.constant 0 )
            , [ ( 0.8, Random.normallyDistributedInt r ) ]
            )

        item : Float -> Item.Kind -> NormalIntSpec -> ( Float, ItemDropSpec )
        item probability kind count =
            ( probability
            , { uniqueKey = { kind = kind }
              , count = count
              }
            )
    in
    case type_ of
        Brahmin ->
            { caps = commonCaps { average = 20, maxDeviation = 10 }
            , items = [ item 0.1 Item.Fruit { average = 1, maxDeviation = 1 } ]
            }

        AngryBrahmin ->
            { caps = commonCaps { average = 80, maxDeviation = 30 }
            , items =
                [ item 0.2 Item.Fruit { average = 2, maxDeviation = 2 }
                , item 0.1 Item.HealingPowder { average = 1, maxDeviation = 2 }
                , item 0.1 Item.Stimpak { average = 1, maxDeviation = 1 }
                ]
            }

        WeakBrahmin ->
            { caps = commonCaps { average = 15, maxDeviation = 8 }
            , items = [ item 0.1 Item.Fruit { average = 1, maxDeviation = 0 } ]
            }

        WildBrahmin ->
            { caps = commonCaps { average = 50, maxDeviation = 10 }
            , items =
                [ item 0.15 Item.Fruit { average = 2, maxDeviation = 1 }
                , item 0.1 Item.HealingPowder { average = 1, maxDeviation = 1 }
                , item 0.1 Item.Stimpak { average = 1, maxDeviation = 1 }
                ]
            }

        GiantAnt ->
            { caps = commonCaps { average = 10, maxDeviation = 5 }
            , items = [ item 0.1 Item.Fruit { average = 1, maxDeviation = 0 } ]
            }

        ToughGiantAnt ->
            { caps = commonCaps { average = 20, maxDeviation = 12 }
            , items =
                [ item 0.1 Item.Fruit { average = 1, maxDeviation = 0 }
                , item 0.1 Item.HealingPowder { average = 1, maxDeviation = 0 }
                ]
            }

        LesserRadscorpion ->
            { caps = commonCaps { average = 25, maxDeviation = 13 }
            , items =
                [ item 0.15 Item.Fruit { average = 2, maxDeviation = 1 }
                , item 0.1 Item.Stimpak { average = 1, maxDeviation = 0 }
                ]
            }

        Radscorpion ->
            { caps = commonCaps { average = 60, maxDeviation = 30 }
            , items =
                [ item 0.1 Item.HealingPowder { average = 2, maxDeviation = 1 }
                , item 0.1 Item.Stimpak { average = 1, maxDeviation = 1 }
                ]
            }

        LesserBlackRadscorpion ->
            { caps = commonCaps { average = 50, maxDeviation = 20 }
            , items =
                [ item 0.2 Item.Fruit { average = 2, maxDeviation = 2 }
                , item 0.1 Item.HealingPowder { average = 2, maxDeviation = 1 }
                , item 0.1 Item.Stimpak { average = 1, maxDeviation = 1 }
                ]
            }

        BlackRadscorpion ->
            { caps = commonCaps { average = 110, maxDeviation = 40 }
            , items =
                [ item 0.1 Item.Fruit { average = 2, maxDeviation = 3 }
                , item 0.2 Item.HealingPowder { average = 2, maxDeviation = 2 }
                , item 0.1 Item.Stimpak { average = 1, maxDeviation = 2 }
                ]
            }


dropGenerator :
    Int
    -> DropSpec
    -> Generator ( { caps : Int, items : List Item }, Int )
dropGenerator lastItemId dropSpec_ =
    Random.map2
        (\caps generatedItems ->
            let
                ( items, newLastId ) =
                    generatedItems
                        |> List.foldl
                            (\{ uniqueKey, count } ( accItems, accItemId ) ->
                                let
                                    ( item, incrementedId ) =
                                        Item.create
                                            { lastId = accItemId
                                            , uniqueKey = uniqueKey
                                            , count = count
                                            }
                                in
                                ( item :: accItems, incrementedId )
                            )
                            ( [], lastItemId )
            in
            ( { caps = caps
              , items = items
              }
            , newLastId
            )
        )
        (capsGenerator dropSpec_)
        (dropItemsGenerator dropSpec_)


capsGenerator : DropSpec -> Generator Int
capsGenerator { caps } =
    let
        ( c, cs ) =
            caps
    in
    Random.weighted c cs
        |> Random.andThen identity


dropItemsGenerator : DropSpec -> Generator (List { uniqueKey : Item.UniqueKey, count : Int })
dropItemsGenerator { items } =
    items
        |> List.map
            (\( float, itemSpec ) ->
                Random.weightedBool float
                    |> Random.andThen
                        (\bool ->
                            if bool then
                                itemSpec.count
                                    |> Random.normallyDistributedInt
                                    |> Random.map
                                        (\count ->
                                            if count <= 0 then
                                                Nothing

                                            else
                                                Just
                                                    { uniqueKey = itemSpec.uniqueKey
                                                    , count = count
                                                    }
                                        )

                            else
                                Random.constant Nothing
                        )
            )
        |> Random.sequence
        |> Random.map Maybe.values
