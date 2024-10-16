module Data.Enemy exposing
    ( Type(..)
    , actionPoints
    , addedSkillPercentages
    , aimedShotName
    , all
    , criticalSpec
    , damageResistance
    , damageThreshold
    , default
    , dropGenerator
    , dropSpec
    , encodeType
    , equippedArmor
    , equippedWeapon
    , forSmallChunk
    , hp
    , humanAimedShotName
    , isLivingCreature
    , manCriticalSpec
    , name
    , naturalArmorClass
    , preferredAmmo
    , sequence
    , special
    , typeDecoder
    , unarmedDamageBonus
    , xpReward
    )

import Data.Fight.AimedShot exposing (AimedShot(..))
import Data.Fight.Critical as Critical exposing (Effect(..), EffectCategory(..))
import Data.Fight.DamageType exposing (DamageType(..))
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Map.BigChunk as BigChunk exposing (BigChunk(..))
import Data.Map.SmallChunk exposing (SmallChunk)
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
import SeqDict exposing (SeqDict)



-- TODO criticalChance : Type -> Int
-- TODO carry weight


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
      -- Geckos: https://fallout.fandom.com/wiki/Gecko_(Fallout_2)
      SilverGecko
    | ToughSilverGecko
    | GoldenGecko
    | ToughGoldenGecko
    | FireGecko -- TODO fire breath
    | ToughFireGecko -- TODO fire breath
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
    | Brahmin
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


all : List Type
all =
    [ SilverGecko
    , ToughSilverGecko
    , GoldenGecko
    , ToughGoldenGecko
    , FireGecko
    , ToughFireGecko
    , Brahmin
    , AngryBrahmin
    , WeakBrahmin
    , WildBrahmin
    , GiantAnt
    , ToughGiantAnt
    , BlackRadscorpion
    , LesserBlackRadscorpion
    , LesserRadscorpion
    , Radscorpion
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
            , SilverGecko
            , ToughSilverGecko
            ]

        C2 ->
            [ LesserRadscorpion
            , Radscorpion
            , Brahmin
            , AngryBrahmin -- dangerous
            , WeakBrahmin
            , WildBrahmin -- semi-dangerous
            , SilverGecko
            , ToughSilverGecko
            , GoldenGecko -- semi-dangerous
            , ToughGoldenGecko -- semi-dangerous
            ]

        C3 ->
            [ Brahmin
            , AngryBrahmin -- dangerous
            , WeakBrahmin
            , WildBrahmin
            , LesserBlackRadscorpion
            , BlackRadscorpion -- dangerous
            , GoldenGecko -- semi-dangerous
            , ToughGoldenGecko -- semi-dangerous
            ]

        C4 ->
            [ AngryBrahmin -- dangerous
            , WildBrahmin
            , LesserBlackRadscorpion
            , BlackRadscorpion -- dangerous
            , GoldenGecko -- semi-dangerous
            , ToughGoldenGecko -- semi-dangerous
            , FireGecko -- dangerous
            , ToughFireGecko -- dangerous
            ]

        C5 ->
            [ AngryBrahmin -- dangerous
            , BlackRadscorpion -- dangerous
            , FireGecko -- dangerous
            , ToughFireGecko -- dangerous
            ]


forSmallChunk : SmallChunk -> List Type
forSmallChunk smallChunk =
    let
        bigChunk : BigChunk
        bigChunk =
            BigChunk.fromSmallChunk smallChunk
    in
    forBigChunk bigChunk


xpReward : Type -> BaseXp
xpReward type_ =
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

            SilverGecko ->
                55

            ToughSilverGecko ->
                60

            GoldenGecko ->
                135

            ToughGoldenGecko ->
                210

            FireGecko ->
                250

            ToughFireGecko ->
                260


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

        SilverGecko ->
            25

        ToughSilverGecko ->
            45

        GoldenGecko ->
            45

        ToughGoldenGecko ->
            65

        FireGecko ->
            70

        ToughFireGecko ->
            80


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

        SilverGecko ->
            13

        ToughSilverGecko ->
            14

        GoldenGecko ->
            22

        ToughGoldenGecko ->
            23

        FireGecko ->
            28

        ToughFireGecko ->
            30


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

        SilverGecko ->
            6

        ToughSilverGecko ->
            6

        GoldenGecko ->
            6

        ToughGoldenGecko ->
            6

        FireGecko ->
            14

        ToughFireGecko ->
            16


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

        SilverGecko ->
            7

        ToughSilverGecko ->
            7

        GoldenGecko ->
            8

        ToughGoldenGecko ->
            10

        FireGecko ->
            9

        ToughFireGecko ->
            12


unarmedDamageBonus : Type -> Int
unarmedDamageBonus type_ =
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

        SilverGecko ->
            2

        ToughSilverGecko ->
            3

        GoldenGecko ->
            4

        ToughGoldenGecko ->
            7

        FireGecko ->
            12

        ToughFireGecko ->
            15


damageResistance : DamageType -> Type -> Int
damageResistance damageType type_ =
    case damageType of
        NormalDamage ->
            damageResistanceNormal type_

        Fire ->
            damageResistanceFire type_

        Plasma ->
            damageResistancePlasma type_

        Laser ->
            damageResistanceLaser type_

        Explosion ->
            damageResistanceExplosion type_

        Electrical ->
            damageResistanceElectrical type_

        EMP ->
            damageResistanceEMP type_


damageThreshold : DamageType -> Type -> Int
damageThreshold damageType type_ =
    case damageType of
        NormalDamage ->
            damageThresholdNormal type_

        Fire ->
            damageThresholdFire type_

        Plasma ->
            damageThresholdPlasma type_

        Laser ->
            damageThresholdLaser type_

        Explosion ->
            damageThresholdExplosion type_

        Electrical ->
            damageThresholdElectrical type_

        EMP ->
            damageThresholdEMP type_


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

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            2

        ToughGoldenGecko ->
            2

        FireGecko ->
            5

        ToughFireGecko ->
            5


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

        SilverGecko ->
            20

        ToughSilverGecko ->
            20

        GoldenGecko ->
            25

        ToughGoldenGecko ->
            25

        FireGecko ->
            40

        ToughFireGecko ->
            40


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

            SilverGecko ->
                "silver-gecko"

            ToughSilverGecko ->
                "tough-silver-gecko"

            GoldenGecko ->
                "golden-gecko"

            ToughGoldenGecko ->
                "tough-golden-gecko"

            FireGecko ->
                "fire-gecko"

            ToughFireGecko ->
                "tough-fire-gecko"


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

                    "silver-gecko" ->
                        JD.succeed SilverGecko

                    "tough-silver-gecko" ->
                        JD.succeed ToughSilverGecko

                    "golden-gecko" ->
                        JD.succeed GoldenGecko

                    "tough-golden-gecko" ->
                        JD.succeed ToughGoldenGecko

                    "fire-gecko" ->
                        JD.succeed FireGecko

                    "tough-fire-gecko" ->
                        JD.succeed ToughFireGecko

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

        SilverGecko ->
            "Silver Gecko"

        ToughSilverGecko ->
            "Tough Silver Gecko"

        GoldenGecko ->
            "Golden Gecko"

        ToughGoldenGecko ->
            "Tough Golden Gecko"

        FireGecko ->
            "Fire Gecko"

        ToughFireGecko ->
            "Tough Fire Gecko"


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

        SilverGecko ->
            Special 4 3 3 1 1 5 3

        ToughSilverGecko ->
            Special 5 3 3 1 1 6 4

        GoldenGecko ->
            Special 6 3 3 1 1 7 4

        ToughGoldenGecko ->
            Special 7 3 3 1 1 8 5

        FireGecko ->
            Special 7 7 4 1 1 8 6

        ToughFireGecko ->
            Special 8 8 5 1 1 10 8


addedSkillPercentages : Type -> SeqDict Skill Int
addedSkillPercentages type_ =
    case type_ of
        Brahmin ->
            SeqDict.fromList
                [ ( Unarmed, 19 )
                ]

        AngryBrahmin ->
            SeqDict.fromList
                [ ( Unarmed, 63 )
                , ( MeleeWeapons, 73 )
                ]

        WeakBrahmin ->
            SeqDict.empty

        WildBrahmin ->
            SeqDict.fromList
                [ ( Unarmed, 52 )
                , ( MeleeWeapons, 2 )
                ]

        GiantAnt ->
            SeqDict.fromList
                [ ( Unarmed, 25 )
                , ( MeleeWeapons, 35 )
                ]

        ToughGiantAnt ->
            SeqDict.fromList
                [ ( Unarmed, 40 )
                , ( MeleeWeapons, 50 )
                ]

        LesserRadscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 29 )
                ]

        Radscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 21 )
                ]

        LesserBlackRadscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 25 )
                ]

        BlackRadscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 54 )
                ]

        SilverGecko ->
            SeqDict.fromList
                [ ( Unarmed, 17 )
                ]

        ToughSilverGecko ->
            SeqDict.fromList
                [ ( Unarmed, 23 )
                ]

        GoldenGecko ->
            SeqDict.fromList
                [ ( Unarmed, 34 )
                ]

        ToughGoldenGecko ->
            SeqDict.fromList
                [ ( Unarmed, 40 )
                ]

        FireGecko ->
            SeqDict.fromList
                [ ( SmallGuns, 43 )
                , ( EnergyWeapons, 64 )
                , ( Unarmed, 60 )
                , ( MeleeWeapons, 50 )
                ]

        ToughFireGecko ->
            SeqDict.fromList
                [ ( SmallGuns, 55 )
                , ( EnergyWeapons, 80 )
                , ( Unarmed, 64 )
                , ( MeleeWeapons, 54 )
                ]


equippedArmor : Type -> Maybe ItemKind.Kind
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

        SilverGecko ->
            Nothing

        ToughSilverGecko ->
            Nothing

        GoldenGecko ->
            Nothing

        ToughGoldenGecko ->
            Nothing

        FireGecko ->
            Nothing

        ToughFireGecko ->
            Nothing


equippedWeapon : Type -> Maybe ItemKind.Kind
equippedWeapon type_ =
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

        SilverGecko ->
            Nothing

        ToughSilverGecko ->
            Nothing

        GoldenGecko ->
            Nothing

        ToughGoldenGecko ->
            Nothing

        FireGecko ->
            Nothing

        ToughFireGecko ->
            Nothing


preferredAmmo : Type -> Maybe ItemKind.Kind
preferredAmmo type_ =
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

        SilverGecko ->
            Nothing

        ToughSilverGecko ->
            Nothing

        GoldenGecko ->
            Nothing

        ToughGoldenGecko ->
            Nothing

        FireGecko ->
            Nothing

        ToughFireGecko ->
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

        gecko aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "tearing some of its slimy skin off."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = "breaking past the lizard's defenses."
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
                    , message = "breaking past the lizard's defenses."
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
                    , effects = [ BypassArmor ]
                    , message = "breaking past the lizard's defenses."
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
                    , message = "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = "the attack crushes the temple. Good night, Gracie."
                            }
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "breaking some of its digits."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftArm
                            , failureMessage = "cripling the left arm."
                            }
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "breaking some of its digits."
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
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "tearing some of its slimy skin off."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "tearing some of its slimy skin off."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = "knocking the stuffing out of it."
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
                            , failureMessage = "bowling him over and crippling that leg."
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
                            , failureMessage = "bowling him over and crippling that leg."
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
                            , failureMessage = "bowling him over and crippling that leg."
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
                            , failureMessage = "bowling him over and crippling that leg."
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

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = "breaking past the lizard's defenses."
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
                    , message = "breaking past the lizard's defenses."
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
                    , message = "breaking past the lizard's defenses."
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
                    , effects = [ BypassArmor, Blinded, LoseNextTurn ]
                    , message = "breaking past the lizard's defenses."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = [ Knockout, BypassArmor, Blinded, LoseNextTurn ]
                    , message = "breaking past the lizard's defenses."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = "breaking past the lizard's defenses."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = "damaging its breathing ability."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = "damaging its breathing ability."
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
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "damaging its breathing ability."
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
                    , message = "damaging its breathing ability."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = "damaging its breathing ability."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, BypassArmor ]
                    , message = "damaging its breathing ability."
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

        SilverGecko ->
            gecko

        ToughSilverGecko ->
            gecko

        GoldenGecko ->
            gecko

        ToughGoldenGecko ->
            gecko

        FireGecko ->
            gecko

        ToughFireGecko ->
            gecko


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

        gecko aimedShot =
            case aimedShot of
                Head ->
                    "head"

                Torso ->
                    "body"

                Eyes ->
                    "eyes"

                Groin ->
                    "groin"

                LeftArm ->
                    "left claw"

                RightArm ->
                    "right claw"

                LeftLeg ->
                    "left leg"

                RightLeg ->
                    "right leg"
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

        SilverGecko ->
            gecko

        ToughSilverGecko ->
            gecko

        GoldenGecko ->
            gecko

        ToughGoldenGecko ->
            gecko

        FireGecko ->
            gecko

        ToughFireGecko ->
            gecko


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

        item : Float -> ItemKind.Kind -> NormalIntSpec -> ( Float, ItemDropSpec )
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
            , items =
                [ item 0.1 ItemKind.Fruit { average = 1, maxDeviation = 1 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        AngryBrahmin ->
            { caps = commonCaps { average = 80, maxDeviation = 30 }
            , items =
                [ item 0.2 ItemKind.Fruit { average = 2, maxDeviation = 2 }
                , item 0.1 ItemKind.HealingPowder { average = 1, maxDeviation = 2 }
                , item 0.1 ItemKind.Stimpak { average = 1, maxDeviation = 1 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        WeakBrahmin ->
            { caps = commonCaps { average = 15, maxDeviation = 8 }
            , items = [ item 0.1 ItemKind.Fruit { average = 1, maxDeviation = 0 } ]
            }

        WildBrahmin ->
            { caps = commonCaps { average = 50, maxDeviation = 10 }
            , items =
                [ item 0.15 ItemKind.Fruit { average = 2, maxDeviation = 1 }
                , item 0.1 ItemKind.HealingPowder { average = 1, maxDeviation = 1 }
                , item 0.1 ItemKind.Stimpak { average = 1, maxDeviation = 1 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        GiantAnt ->
            { caps = commonCaps { average = 10, maxDeviation = 5 }
            , items = [ item 0.1 ItemKind.Fruit { average = 1, maxDeviation = 0 } ]
            }

        ToughGiantAnt ->
            { caps = commonCaps { average = 20, maxDeviation = 12 }
            , items =
                [ item 0.1 ItemKind.Fruit { average = 1, maxDeviation = 0 }
                , item 0.1 ItemKind.HealingPowder { average = 1, maxDeviation = 0 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        LesserRadscorpion ->
            { caps = commonCaps { average = 25, maxDeviation = 13 }
            , items =
                [ item 0.15 ItemKind.Fruit { average = 2, maxDeviation = 1 }
                , item 0.1 ItemKind.Stimpak { average = 1, maxDeviation = 0 }
                ]
            }

        Radscorpion ->
            { caps = commonCaps { average = 60, maxDeviation = 30 }
            , items =
                [ item 0.1 ItemKind.HealingPowder { average = 2, maxDeviation = 1 }
                , item 0.1 ItemKind.Stimpak { average = 1, maxDeviation = 1 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        LesserBlackRadscorpion ->
            { caps = commonCaps { average = 50, maxDeviation = 20 }
            , items =
                [ item 0.2 ItemKind.Fruit { average = 2, maxDeviation = 2 }
                , item 0.1 ItemKind.HealingPowder { average = 2, maxDeviation = 1 }
                , item 0.1 ItemKind.Stimpak { average = 1, maxDeviation = 1 }
                ]
            }

        BlackRadscorpion ->
            { caps = commonCaps { average = 110, maxDeviation = 40 }
            , items =
                [ item 0.1 ItemKind.Fruit { average = 2, maxDeviation = 3 }
                , item 0.2 ItemKind.HealingPowder { average = 2, maxDeviation = 2 }
                , item 0.1 ItemKind.Stimpak { average = 1, maxDeviation = 2 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        SilverGecko ->
            { caps = commonCaps { average = 50, maxDeviation = 20 }
            , items =
                [ item 0.2 ItemKind.Fruit { average = 1, maxDeviation = 2 }
                , item 0.1 ItemKind.HealingPowder { average = 1, maxDeviation = 1 }
                ]
            }

        ToughSilverGecko ->
            { caps = commonCaps { average = 60, maxDeviation = 30 }
            , items =
                [ item 0.25 ItemKind.Fruit { average = 2, maxDeviation = 2 }
                , item 0.15 ItemKind.HealingPowder { average = 2, maxDeviation = 1 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        GoldenGecko ->
            { caps = commonCaps { average = 100, maxDeviation = 40 }
            , items =
                [ item 0.1 ItemKind.Fruit { average = 2, maxDeviation = 2 }
                , item 0.15 ItemKind.HealingPowder { average = 1, maxDeviation = 1 }
                , item 0.05 ItemKind.Stimpak { average = 1, maxDeviation = 2 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        ToughGoldenGecko ->
            { caps = commonCaps { average = 130, maxDeviation = 40 }
            , items =
                [ item 0.05 ItemKind.Fruit { average = 3, maxDeviation = 2 }
                , item 0.15 ItemKind.HealingPowder { average = 2, maxDeviation = 2 }
                , item 0.1 ItemKind.Stimpak { average = 2, maxDeviation = 2 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        FireGecko ->
            { caps = commonCaps { average = 150, maxDeviation = 50 }
            , items =
                [ item 0.2 ItemKind.HealingPowder { average = 2, maxDeviation = 2 }
                , item 0.2 ItemKind.Stimpak { average = 2, maxDeviation = 2 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
                ]
            }

        ToughFireGecko ->
            { caps = commonCaps { average = 200, maxDeviation = 60 }
            , items =
                [ item 0.1 ItemKind.HealingPowder { average = 2, maxDeviation = 3 }
                , item 0.3 ItemKind.Stimpak { average = 2, maxDeviation = 3 }
                , item 0.1 ItemKind.Knife { average = 1, maxDeviation = 0 }
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


isLivingCreature : Type -> Bool
isLivingCreature type_ =
    case type_ of
        SilverGecko ->
            True

        ToughSilverGecko ->
            True

        GoldenGecko ->
            True

        ToughGoldenGecko ->
            True

        FireGecko ->
            True

        ToughFireGecko ->
            True

        Brahmin ->
            True

        AngryBrahmin ->
            True

        WeakBrahmin ->
            True

        WildBrahmin ->
            True

        GiantAnt ->
            True

        ToughGiantAnt ->
            True

        BlackRadscorpion ->
            True

        LesserBlackRadscorpion ->
            True

        LesserRadscorpion ->
            True

        Radscorpion ->
            True


damageResistanceEMP : Type -> Int
damageResistanceEMP type_ =
    case type_ of
        SilverGecko ->
            500

        ToughSilverGecko ->
            500

        GoldenGecko ->
            500

        ToughGoldenGecko ->
            500

        FireGecko ->
            500

        ToughFireGecko ->
            500

        Brahmin ->
            500

        AngryBrahmin ->
            500

        WeakBrahmin ->
            500

        WildBrahmin ->
            500

        GiantAnt ->
            500

        ToughGiantAnt ->
            500

        BlackRadscorpion ->
            500

        LesserBlackRadscorpion ->
            500

        LesserRadscorpion ->
            500

        Radscorpion ->
            500


damageThresholdEMP : Type -> Int
damageThresholdEMP type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            0

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            0

        ToughFireGecko ->
            0

        LesserBlackRadscorpion ->
            0

        BlackRadscorpion ->
            0

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceElectrical : Type -> Int
damageResistanceElectrical type_ =
    case type_ of
        LesserRadscorpion ->
            15

        Radscorpion ->
            30

        Brahmin ->
            30

        SilverGecko ->
            30

        ToughSilverGecko ->
            30

        GoldenGecko ->
            30

        ToughGoldenGecko ->
            30

        WeakBrahmin ->
            30

        WildBrahmin ->
            30

        FireGecko ->
            50

        ToughFireGecko ->
            50

        LesserBlackRadscorpion ->
            30

        BlackRadscorpion ->
            35

        GiantAnt ->
            0

        ToughGiantAnt ->
            10

        AngryBrahmin ->
            30


damageThresholdElectrical : Type -> Int
damageThresholdElectrical type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            0

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            2

        ToughFireGecko ->
            2

        LesserBlackRadscorpion ->
            0

        BlackRadscorpion ->
            0

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceExplosion : Type -> Int
damageResistanceExplosion type_ =
    case type_ of
        LesserRadscorpion ->
            10

        Radscorpion ->
            20

        Brahmin ->
            10

        SilverGecko ->
            20

        ToughSilverGecko ->
            20

        GoldenGecko ->
            20

        ToughGoldenGecko ->
            20

        WeakBrahmin ->
            10

        WildBrahmin ->
            20

        FireGecko ->
            40

        ToughFireGecko ->
            40

        LesserBlackRadscorpion ->
            20

        BlackRadscorpion ->
            30

        GiantAnt ->
            0

        ToughGiantAnt ->
            10

        AngryBrahmin ->
            20


damageThresholdExplosion : Type -> Int
damageThresholdExplosion type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            6

        ToughFireGecko ->
            6

        LesserBlackRadscorpion ->
            0

        BlackRadscorpion ->
            0

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceFire : Type -> Int
damageResistanceFire type_ =
    case type_ of
        LesserRadscorpion ->
            10

        Radscorpion ->
            10

        Brahmin ->
            20

        SilverGecko ->
            10

        ToughSilverGecko ->
            10

        GoldenGecko ->
            20

        ToughGoldenGecko ->
            20

        WeakBrahmin ->
            20

        WildBrahmin ->
            20

        FireGecko ->
            500

        ToughFireGecko ->
            500

        LesserBlackRadscorpion ->
            10

        BlackRadscorpion ->
            20

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            20


damageThresholdFire : Type -> Int
damageThresholdFire type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            20

        ToughFireGecko ->
            20

        LesserBlackRadscorpion ->
            2

        BlackRadscorpion ->
            3

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceLaser : Type -> Int
damageResistanceLaser type_ =
    case type_ of
        LesserRadscorpion ->
            30

        Radscorpion ->
            50

        Brahmin ->
            20

        SilverGecko ->
            20

        ToughSilverGecko ->
            20

        GoldenGecko ->
            20

        ToughGoldenGecko ->
            20

        WeakBrahmin ->
            20

        WildBrahmin ->
            20

        FireGecko ->
            60

        ToughFireGecko ->
            60

        LesserBlackRadscorpion ->
            50

        BlackRadscorpion ->
            60

        GiantAnt ->
            0

        ToughGiantAnt ->
            10

        AngryBrahmin ->
            20


damageThresholdLaser : Type -> Int
damageThresholdLaser type_ =
    case type_ of
        LesserRadscorpion ->
            2

        Radscorpion ->
            4

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            8

        ToughFireGecko ->
            8

        LesserBlackRadscorpion ->
            4

        BlackRadscorpion ->
            5

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistancePlasma : Type -> Int
damageResistancePlasma type_ =
    case type_ of
        LesserRadscorpion ->
            10

        Radscorpion ->
            10

        Brahmin ->
            10

        SilverGecko ->
            10

        ToughSilverGecko ->
            10

        GoldenGecko ->
            10

        ToughGoldenGecko ->
            10

        WeakBrahmin ->
            10

        WildBrahmin ->
            10

        FireGecko ->
            50

        ToughFireGecko ->
            50

        LesserBlackRadscorpion ->
            10

        BlackRadscorpion ->
            20

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            10


damageThresholdPlasma : Type -> Int
damageThresholdPlasma type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            4

        ToughFireGecko ->
            4

        LesserBlackRadscorpion ->
            2

        BlackRadscorpion ->
            3

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0
