module Data.Enemy exposing
    ( aimedShotName
    , criticalSpec
    , dropGenerator
    , dropSpec
    , forSmallChunk
    , humanAimedShotName
    , playerCriticalSpec
    )

import Data.Enemy.Type exposing (EnemyType(..))
import Data.Fight.AimedShot exposing (AimedShot(..))
import Data.Fight.Critical as Critical exposing (Effect(..), EffectCategory(..), Message(..))
import Data.Fight.DamageType exposing (DamageType(..))
import Data.Fight.OpponentType exposing (OpponentType(..))
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Map.BigChunk as BigChunk exposing (BigChunk(..))
import Data.Map.SmallChunk exposing (SmallChunk)
import Data.Skill exposing (Skill(..))
import Data.Special exposing (Type(..))
import Maybe.Extra as Maybe
import NonemptyList exposing (NonemptyList)
import Random exposing (Generator)
import Random.Bool as Random
import Random.Extra as Random
import Random.FloatExtra as Random exposing (NormalIntSpec)



-- TODO criticalChance : EnemyType -> Int
-- TODO carry weight


{-| For now we're not doing things as granularly as the original game does.

We are splitting the map into five big chunks and only figuring out the
possible enemies based on those five chunks.

-}
forBigChunk : BigChunk -> List EnemyType
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


forSmallChunk : SmallChunk -> List EnemyType
forSmallChunk smallChunk =
    let
        bigChunk : BigChunk
        bigChunk =
            BigChunk.fromSmallChunk smallChunk
    in
    forBigChunk bigChunk


criticalSpec : EnemyType -> AimedShot -> Critical.EffectCategory -> Critical.Spec
criticalSpec enemyType =
    -- https://falloutmods.fandom.com/wiki/Critical_hit_tables
    let
        brahmin aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 2
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "knocking the big beast to the ground."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -1
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "knocking the big beast to the ground."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout ]
                    , message = OtherMessage "stunning both brains and felling the giant animal."
                    , statCheck = Nothing
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "and the mutant cow gives a loud, startled cry."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftArm
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftArm
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "and a serious wound is inflicted."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightArm
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightArm
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "seriously hurting the mutant cow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "seriously hurting the mutant cow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "seriously hurting the mutant cow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "easily penetrating the thick hide of the giant beast."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "easily penetrating the thick hide of the giant beast."
                    , statCheck = Nothing
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "penetrating straight through both hearts of the mutant cow."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightLeg ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightLeg ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "breaking one of the Brahmin's legs."
                            }
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftLeg ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftLeg ]
                    , message = OtherMessage "breaking one of the Brahmin's legs."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "with no protection there, causing serious pain."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "blinding both sets of eyes with a single blow."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "with no protection there, causing serious pain."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = -3
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "blinding both sets of eyes with a single blow."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = [ Blinded, BypassArmor, LoseNextTurn ]
                    , message = OtherMessage "blinding both heads and stunning the mutant cow."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = [ Knockout, Blinded, BypassArmor ]
                    , message = OtherMessage "completely blinding the Brahmin and knocking it out."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = OtherMessage "and the large mutant bovine stumbles for a moment."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "and the Brahmin shakes with rage."
                    , statCheck = Nothing
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "and the Brahmin shakes with rage."
                    , statCheck = Nothing
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "and the Brahmin snorts with pain."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "and the Brahmin snorts with pain."
                    , statCheck = Nothing
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "and the Brahmin is most upset with this udderly devastating attack."
                    , statCheck = Nothing
                    }

        giantAnt aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "ripping some of its antennae off."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "knocking him unconscious."
                            }
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking some of its feelers."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "knocking him unconscious."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "breaking some of its feelers."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "knocking him unconscious."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout, BypassArmor ]
                    , message = OtherMessage "breaking some of its feelers."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "crushing the temple. Good night, Gracie."
                            }
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "breaking some of its feelers."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftArm
                            , failureMessage = OtherMessage "crippling the left arm."
                            }
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledRightArm
                            , failureMessage = OtherMessage "which really hurts."
                            }
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "breaking past the ant's defenses."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the ant's defenses."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout, BypassArmor ]
                    , message = OtherMessage "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "knocking it around a bit."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "bowling him over and cripples that leg."
                            }
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "bowling him over and cripples that leg."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "and the intense pain of having a leg removed causes him to quit."
                            }
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "bowling him over and cripples that leg."
                            }
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "bowling him over and cripples that leg."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "and the intense pain of having a leg removed causes him to quit."
                            }
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "breaking past the ant's defenses."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 4
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "damaging some of its exoskeleton."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 3
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "ripping some of its antennae off."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 2
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = [ Blinded, BypassArmor, LoseNextTurn ]
                    , message = OtherMessage "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = [ Knockout, Blinded, BypassArmor ]
                    , message = OtherMessage "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = OtherMessage "ripping some of its antennae off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "breaking past the ant's defenses."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the ant's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "and without protection he falls over, groaning in agony."
                            }
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "breaking past the ant's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockout ]
                    , message = OtherMessage "damaging its health."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "damaging its health."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, BypassArmor ]
                    , message = OtherMessage "damaging its health."
                    , statCheck = Nothing
                    }

        radscorpion aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 3
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "and the attack sends the radscorpion flying on its back."
                            }
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "and the attack sends the radscorpion flying on its back."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "and the attack sends the radscorpion flying on its back."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockdown ]
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "separating the head from the carapace."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftArm
                            , failureMessage = OtherMessage "seriously damaging the tail."
                            }
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = OtherMessage "seriously damaging the tail."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm ]
                    , message = OtherMessage "seriously damaging the tail."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 2
                            , failureEffect = CrippledRightArm
                            , failureMessage = OtherMessage "putting a major hurt on its claws."
                            }
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightArm
                            , failureMessage = OtherMessage "putting a major hurt on its claws."
                            }
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm ]
                    , message = OtherMessage "putting a major hurt on its claws."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "making the blow slip between the cracks of the radscorpion's tough carapace."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "striking through the tough carapace without pausing."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "striking through the tough carapace without pausing."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 0
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "passing through the natural armor and knocking the radscorpion over."
                            }
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Death ]
                    , message = OtherMessage "and the radscorpion cannot cope with a new sensation, like missing internal organs."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 2
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "sending the radscorpion flying on its back."
                            }
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = OtherMessage "sending the radscorpion flying on its back."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "crippling some of its legs."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "cutting through an unprotected joint on the leg, severing it."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 2
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "sending the radscorpion flying on its back."
                            }
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "sending the radscorpion flying on its back."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "crippling some of its legs."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "cutting through an unprotected joint on the leg, severing it."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "sending the radscorpion flying and crippling some of its legs."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "inflicting a serious wound."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 3
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "seriously wounding and blinding the mutant creature."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "seriously wounding and blinding the mutant creature."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = []
                    , message = OtherMessage "in a forceful blow."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = -3
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "seriously wounding and blinding the mutant creature."
                            }
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = []
                    , message = OtherMessage "penetrating almost to the brain. Talk about squashing a bug."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = -3
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "almost penetrating to the brain, but blinding the creature instead."
                            }
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = OtherMessage "in a fiendish attack, far too sophisticated for this simple creature."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "and if it was human, you would swear it's pretty pissed off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "and if it was human, you would swear it's pretty pissed off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "and if it was human, you would swear it's pretty pissed off."
                    , statCheck = Nothing
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout ]
                    , message = OtherMessage "knocking the poor creature senseless."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout ]
                    , message = OtherMessage "knocking the poor creature senseless."
                    , statCheck = Nothing
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Death ]
                    , message = OtherMessage "spiking the brain to the floor."
                    , statCheck = Nothing
                    }

        gecko aimedShot effectCategory =
            case ( aimedShot, effectCategory ) of
                ( Head, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "tearing some of its slimy skin off."
                    , statCheck = Nothing
                    }

                ( Head, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "knocking him unconscious."
                            }
                    }

                ( Head, Effect3 ) ->
                    { damageMultiplier = 5
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "knocking him unconscious."
                            }
                    }

                ( Head, Effect4 ) ->
                    { damageMultiplier = 5
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "knocking him unconscious."
                            }
                    }

                ( Head, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockout, BypassArmor ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Agility
                            , modifier = 0
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "the attack crushes the temple. Good night, Gracie."
                            }
                    }

                ( Head, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftArm
                            , failureMessage = OtherMessage "cripling the left arm."
                            }
                    }

                ( LeftArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( LeftArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledLeftArm, BypassArmor ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ LoseNextTurn ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledRightArm
                            , failureMessage = OtherMessage "which really hurts."
                            }
                    }

                ( RightArm, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( RightArm, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ CrippledRightArm, BypassArmor ]
                    , message = OtherMessage "breaking some of its digits."
                    , statCheck = Nothing
                    }

                ( Torso, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "tearing some of its slimy skin off."
                    , statCheck = Nothing
                    }

                ( Torso, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "tearing some of its slimy skin off."
                    , statCheck = Nothing
                    }

                ( Torso, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( Torso, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( Torso, Effect5 ) ->
                    { damageMultiplier = 6
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( Torso, Effect6 ) ->
                    { damageMultiplier = 6
                    , effects = [ Death ]
                    , message = OtherMessage "knocking the stuffing out of it."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "bowling him over and crippling that leg."
                            }
                    }

                ( LeftLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledLeftLeg
                            , failureMessage = OtherMessage "bowling him over and crippling that leg."
                            }
                    }

                ( LeftLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( LeftLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "and the intense pain of having a leg removed causes him to quit."
                            }
                    }

                ( LeftLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, CrippledLeftLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "bowling him over and crippling that leg."
                            }
                    }

                ( RightLeg, Effect3 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = CrippledRightLeg
                            , failureMessage = OtherMessage "bowling him over and crippling that leg."
                            }
                    }

                ( RightLeg, Effect4 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( RightLeg, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = 0
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "and the intense pain of having a leg removed causes him to quit."
                            }
                    }

                ( RightLeg, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, CrippledRightLeg, BypassArmor ]
                    , message = OtherMessage "almost tipping it over."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect1 ) ->
                    { damageMultiplier = 4
                    , effects = []
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 4
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect2 ) ->
                    { damageMultiplier = 4
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 3
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect3 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck =
                        Just
                            { stat = Luck
                            , modifier = 2
                            , failureEffect = Blinded
                            , failureMessage = OtherMessage "causing blindness, unluckily for him."
                            }
                    }

                ( Eyes, Effect4 ) ->
                    { damageMultiplier = 6
                    , effects = [ BypassArmor, Blinded, LoseNextTurn ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect5 ) ->
                    { damageMultiplier = 8
                    , effects = [ Knockout, BypassArmor, Blinded, LoseNextTurn ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck = Nothing
                    }

                ( Eyes, Effect6 ) ->
                    { damageMultiplier = 8
                    , effects = [ Death ]
                    , message = OtherMessage "breaking past the lizard's defenses."
                    , statCheck = Nothing
                    }

                ( Groin, Effect1 ) ->
                    { damageMultiplier = 3
                    , effects = []
                    , message = OtherMessage "damaging its breathing ability."
                    , statCheck = Nothing
                    }

                ( Groin, Effect2 ) ->
                    { damageMultiplier = 3
                    , effects = [ BypassArmor ]
                    , message = OtherMessage "damaging its breathing ability."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockdown
                            , failureMessage = OtherMessage "and without protection, he falls over, groaning in agony."
                            }
                    }

                ( Groin, Effect3 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "damaging its breathing ability."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect4 ) ->
                    { damageMultiplier = 3
                    , effects = [ Knockout ]
                    , message = OtherMessage "damaging its breathing ability."
                    , statCheck = Nothing
                    }

                ( Groin, Effect5 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockdown, BypassArmor ]
                    , message = OtherMessage "damaging its breathing ability."
                    , statCheck =
                        Just
                            { stat = Endurance
                            , modifier = -3
                            , failureEffect = Knockout
                            , failureMessage = OtherMessage "the pain is too much for him and he collapses like a rag."
                            }
                    }

                ( Groin, Effect6 ) ->
                    { damageMultiplier = 4
                    , effects = [ Knockout, BypassArmor ]
                    , message = OtherMessage "damaging its breathing ability."
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


aimedShotName : EnemyType -> AimedShot -> String
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


playerCriticalSpec : AimedShot -> Critical.EffectCategory -> Critical.Spec
playerCriticalSpec aimedShot effectCategory =
    -- TODO woman critical spec? https://falloutmods.fandom.com/wiki/Critical_hit_tables#Women
    case ( aimedShot, effectCategory ) of
        ( Head, Effect1 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = OtherMessage "inflicting a serious wound."
            , statCheck = Nothing
            }

        ( Head, Effect2 ) ->
            { damageMultiplier = 4
            , effects = [ BypassArmor ]
            , message = OtherMessage "bypassing the armor defenses."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "knocking you unconscious."
                            , them = "knocking them unconscious."
                            }
                    }
            }

        ( Head, Effect3 ) ->
            { damageMultiplier = 5
            , effects = [ Knockout ]
            , message = OtherMessage "bypassing the armor defenses."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "knocking you unconscious."
                            , them = "knocking them unconscious."
                            }
                    }
            }

        ( Head, Effect4 ) ->
            { damageMultiplier = 5
            , effects = [ Knockdown, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground."
                    , them = "knocking them to the ground."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "knocking you unconscious."
                            , them = "knocking them unconscious."
                            }
                    }
            }

        ( Head, Effect5 ) ->
            { damageMultiplier = 6
            , effects = [ Knockout, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "and the strong blow to the head knocks you out."
                    , them = "and the strong blow to the head knocks them out."
                    }
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 0
                    , failureEffect = Blinded
                    , failureMessage = OtherMessage "and the attack crushes the temple. Good night, Gracie."
                    }
            }

        ( Head, Effect6 ) ->
            { damageMultiplier = 6
            , effects = [ Death ]
            , message = OtherMessage "resulting in instantaneous death."
            , statCheck = Nothing
            }

        ( LeftArm, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = OtherMessage "causing severe tennis elbow."
            , statCheck = Nothing
            }

        ( LeftArm, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ LoseNextTurn ]
            , message = OtherMessage "pushing the arm out of the way."
            , statCheck = Nothing
            }

        ( LeftArm, Effect3 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = OtherMessage "leaving a big bruise."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledLeftArm
                    , failureMessage = OtherMessage "crippling the left arm."
                    }
            }

        ( LeftArm, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledLeftArm, BypassArmor ]
            , message = OtherMessage "leaving the left arm dangling by the skin."
            , statCheck = Nothing
            }

        ( LeftArm, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledLeftArm, BypassArmor ]
            , message = OtherMessage "leaving the left arm dangling by the skin."
            , statCheck = Nothing
            }

        ( LeftArm, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledLeftArm, BypassArmor ]
            , message = OtherMessage "leaving the left arm looking like a bloody stump."
            , statCheck = Nothing
            }

        ( RightArm, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = OtherMessage "causing severe tennis elbow."
            , statCheck = Nothing
            }

        ( RightArm, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ LoseNextTurn ]
            , message = OtherMessage "pushing the arm out of the way."
            , statCheck = Nothing
            }

        ( RightArm, Effect3 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = OtherMessage "which really hurts."
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledRightArm
                    , failureMessage = OtherMessage "leaving a crippled right arm."
                    }
            }

        ( RightArm, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledRightArm, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "pulverizing your right arm by this powerful blow."
                    , them = "pulverizing their right arm by this powerful blow."
                    }
            , statCheck = Nothing
            }

        ( RightArm, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledRightArm, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "pulverizing your right arm by this powerful blow."
                    , them = "pulverizing their right arm by this powerful blow."
                    }
            , statCheck = Nothing
            }

        ( RightArm, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ CrippledRightArm, BypassArmor ]
            , message = OtherMessage "leaving the right arm looking like a bloody stump."
            , statCheck = Nothing
            }

        ( Torso, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = OtherMessage "in a forceful blow."
            , statCheck = Nothing
            }

        ( Torso, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ BypassArmor ]
            , message = OtherMessage "blowing through the armor."
            , statCheck = Nothing
            }

        ( Torso, Effect3 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "bypassing the armor, knocking you to the ground."
                    , them = "bypassing the armor, knocking the combatant to the ground."
                    }
            , statCheck = Nothing
            }

        ( Torso, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "bypassing the armor, knocking you to the ground."
                    , them = "bypassing the armor, knocking the combatant to the ground."
                    }
            , statCheck = Nothing
            }

        ( Torso, Effect5 ) ->
            { damageMultiplier = 6
            , effects = [ Knockout, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "knocking the air out, and you slump to the ground out of the fight."
                    , them = "knocking the air out, and they slump to the ground out of the fight."
                    }
            , statCheck = Nothing
            }

        ( Torso, Effect6 ) ->
            { damageMultiplier = 6
            , effects = [ Death ]
            , message =
                PlayerMessage
                    { you = "and unfortunately your spine is now clearly visible from the front."
                    , them = "and unfortunately their spine is now clearly visible from the front."
                    }
            , statCheck = Nothing
            }

        ( RightLeg, Effect1 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground like a bowling pin in a league game."
                    , them = "knocking them to the ground like a bowling pin in a league game."
                    }
            , statCheck = Nothing
            }

        ( RightLeg, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground like a bowling pin in a league game."
                    , them = "knocking them to the ground like a bowling pin in a league game."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = CrippledRightLeg
                    , failureMessage =
                        PlayerMessage
                            { you = "bowling you over and crippling that leg."
                            , them = "bowling them over and crippling that leg."
                            }
                    }
            }

        ( RightLeg, Effect3 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground like a bowling pin in a league game."
                    , them = "knocking them to the ground like a bowling pin in a league game."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledRightLeg
                    , failureMessage =
                        PlayerMessage
                            { you = "bowling you over and crippling that leg."
                            , them = "bowling them over and crippling that leg."
                            }
                    }
            }

        ( RightLeg, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "smashing the knee into the next town. You fall."
                    , them = "smashing the knee into the next town. They fall."
                    }
            , statCheck = Nothing
            }

        ( RightLeg, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledRightLeg, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "smashing the knee into the next town. You fall."
                    , them = "smashing the knee into the next town. They fall."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "and the intense pain of having a leg removed causes you to quit."
                            , them = "and the intense pain of having a leg removed causes them to quit."
                            }
                    }
            }

        ( RightLeg, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ Knockout, CrippledRightLeg, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "and the intense pain of having a leg removed causes you to quit."
                    , them = "and the intense pain of having a leg removed causes them to quit."
                    }
            , statCheck = Nothing
            }

        ( LeftLeg, Effect1 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground like a bowling pin in a league game."
                    , them = "knocking them to the ground like a bowling pin in a league game."
                    }
            , statCheck = Nothing
            }

        ( LeftLeg, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground like a bowling pin in a league game."
                    , them = "knocking them to the ground like a bowling pin in a league game."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = CrippledLeftLeg
                    , failureMessage =
                        PlayerMessage
                            { you = "bowling you over and crippling that leg."
                            , them = "bowling them over and crippling that leg."
                            }
                    }
            }

        ( LeftLeg, Effect3 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "knocking you to the ground like a bowling pin in a league game."
                    , them = "knocking them to the ground like a bowling pin in a league game."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = CrippledLeftLeg
                    , failureMessage =
                        PlayerMessage
                            { you = "bowling you over and crippling that leg."
                            , them = "bowling them over and crippling that leg."
                            }
                    }
            }

        ( LeftLeg, Effect4 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "smashing the knee into the next town. You fall."
                    , them = "smashing the knee into the next town. They fall."
                    }
            , statCheck = Nothing
            }

        ( LeftLeg, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, CrippledLeftLeg, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "smashing the knee into the next town. You fall."
                    , them = "smashing the knee into the next town. They fall."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "and the intense pain of having a leg removed causes you to quit."
                            , them = "and the intense pain of having a leg removed causes them to quit."
                            }
                    }
            }

        ( LeftLeg, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ Knockout, CrippledLeftLeg, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "and the intense pain of having a leg removed causes you to quit."
                    , them = "and the intense pain of having a leg removed causes them to quit."
                    }
            , statCheck = Nothing
            }

        ( Eyes, Effect1 ) ->
            { damageMultiplier = 4
            , effects = []
            , message = OtherMessage "inflicting some extra pain."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 4
                    , failureEffect = Blinded
                    , failureMessage =
                        PlayerMessage
                            { you = "causing blindness, unluckily for you."
                            , them = "causing blindness, unluckily for them."
                            }
                    }
            }

        ( Eyes, Effect2 ) ->
            { damageMultiplier = 4
            , effects = [ BypassArmor ]
            , message = OtherMessage "with no protection there, causing serious pain."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 3
                    , failureEffect = Blinded
                    , failureMessage =
                        PlayerMessage
                            { you = "causing blindness, unluckily for you."
                            , them = "causing blindness, unluckily for them."
                            }
                    }
            }

        ( Eyes, Effect3 ) ->
            { damageMultiplier = 6
            , effects = [ BypassArmor ]
            , message = OtherMessage "with no protection there, causing serious pain."
            , statCheck =
                Just
                    { stat = Luck
                    , modifier = 2
                    , failureEffect = Blinded
                    , failureMessage =
                        PlayerMessage
                            { you = "causing blindness, unluckily for you."
                            , them = "causing blindness, unluckily for them."
                            }
                    }
            }

        ( Eyes, Effect4 ) ->
            { damageMultiplier = 6
            , effects = [ Blinded, BypassArmor, LoseNextTurn ]
            , message =
                PlayerMessage
                    { you = "blinding you with a stunning blow."
                    , them = "blinding them with a stunning blow."
                    }
            , statCheck = Nothing
            }

        ( Eyes, Effect5 ) ->
            { damageMultiplier = 8
            , effects = [ Knockout, Blinded, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "the loss of an eye is too much for you, and you fall to the ground."
                    , them = "the loss of an eye is too much for them, and they fall to the ground."
                    }
            , statCheck = Nothing
            }

        ( Eyes, Effect6 ) ->
            { damageMultiplier = 8
            , effects = [ Death ]
            , message =
                PlayerMessage
                    { you = "and sadly you are too busy feeling the rush of air on the brain to notice death approaching."
                    , them = "and sadly they are too busy feeling the rush of air on the brain to notice death approaching."
                    }
            , statCheck = Nothing
            }

        ( Groin, Effect1 ) ->
            { damageMultiplier = 3
            , effects = []
            , message = OtherMessage "which had to hurt."
            , statCheck = Nothing
            }

        ( Groin, Effect2 ) ->
            { damageMultiplier = 3
            , effects = [ BypassArmor ]
            , message =
                PlayerMessage
                    { you = "and you are not wearing a cup, either."
                    , them = "and they are not wearing a cup, either."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockdown
                    , failureMessage =
                        PlayerMessage
                            { you = "and without protection, you fall over, groaning in agony."
                            , them = "and without protection, they fall over, groaning in agony."
                            }
                    }
            }

        ( Groin, Effect3 ) ->
            { damageMultiplier = 3
            , effects = [ Knockdown ]
            , message =
                PlayerMessage
                    { you = "and without protection, you fall over, groaning in agony."
                    , them = "and without protection, they fall over, groaning in agony."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = -3
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "the pain is too much for you and you collapse like a rag."
                            , them = "the pain is too much for them and they collapse like a rag."
                            }
                    }
            }

        ( Groin, Effect4 ) ->
            { damageMultiplier = 3
            , effects = [ Knockout ]
            , message =
                PlayerMessage
                    { you = "the pain is too much for you and you collapse like a rag."
                    , them = "the pain is too much for them and they collapse like a rag."
                    }
            , statCheck = Nothing
            }

        ( Groin, Effect5 ) ->
            { damageMultiplier = 4
            , effects = [ Knockdown, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "and without protection, you fall over, groaning in agony."
                    , them = "and without protection, they fall over, groaning in agony."
                    }
            , statCheck =
                Just
                    { stat = Endurance
                    , modifier = 0
                    , failureEffect = Knockout
                    , failureMessage =
                        PlayerMessage
                            { you = "the pain is too much for you and you collapse like a rag."
                            , them = "the pain is too much for them and they collapse like a rag."
                            }
                    }
            }

        ( Groin, Effect6 ) ->
            { damageMultiplier = 4
            , effects = [ Knockout, BypassArmor ]
            , message =
                PlayerMessage
                    { you = "you mumble 'Mother', as your eyes roll into the back of your head."
                    , them = "they mumble 'Mother', as their eyes roll into the back of their head."
                    }
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


dropSpec : EnemyType -> DropSpec
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
