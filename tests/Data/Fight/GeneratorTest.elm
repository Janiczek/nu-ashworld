module Data.Fight.GeneratorTest exposing (suite)

import Data.Fight as Fight exposing (Opponent)
import Data.Fight.AimedShot as AimedShot
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle)
import Data.Fight.Generator as FightGen exposing (Fight, OngoingFight)
import Data.Fight.OpponentType as OpponentType
import Data.FightStrategy as FightStrategy exposing (..)
import Data.Item.Kind as ItemKind
import Data.Skill as Skill
import Data.Special as Special
import Dict
import Expect
import Fuzz exposing (Fuzzer)
import List.Extra
import Random
import SeqDict
import SeqSet
import Test exposing (Test)
import TestHelpers exposing (..)
import Time


suite : Test
suite =
    Test.describe "Data.Fight.Generator"
        [ Test.describe "generator"
            [ damageNeverNegative
            , meleeUnaimedStrategyResultsInMeleeUnaimedAttacks
            , fightEndsIfOnlyRunningAway
            , fightEndsIfOnlyMovingForward
            , fightEndsIfOnlyMovingForwardAndRunningAway
            , aimedRangedAttackIsLogged
            , skipTurnSkipsTurn
            , showsOriginalWeaponWithNoUsableAmmo
            ]
        , Test.describe "attack_"
            [ meleeAttackSucceedsAtDistance2WithRange2
            , meleeAttackFailsAtDistance2WithRange1
            , rangedAttackFailsWithoutAmmoAndOutOfRange
            , rangedAttackSucceedsAtDistance15WithRange30
            , rangedAttackSucceedsWithWrongPreferredAmmo
            , rangedAttackUsesPreferredAmmo
            , rangedAttackUsesOnlyOnePieceOfAmmo
            , rangedAttackFailsAtDistance30WithRange7
            , unarmedAttackUsedWhenNoAmmoAndInRange
            , thrownAttackUsesUpWeapon
            , canBurstAttackWithLessThanDesignatedAmmoAmount
            , burstAttackUsesDesignatedAmmoAmount
            , burstAttackCanCauseDamage
            , burstAttackCanBeCritical
            ]
        ]


baseOpponent : Opponent
baseOpponent =
    { type_ = OpponentType.Player { name = "Opponent", xp = 0 }
    , hp = 100
    , maxHp = 100
    , maxAp = 10
    , sequence = 5
    , traits = SeqSet.empty
    , perks = SeqDict.empty
    , caps = 50
    , items = Dict.empty
    , drops = []
    , level = 1
    , equippedArmor = Nothing
    , equippedWeapon = Nothing
    , preferredAmmo = Nothing
    , naturalArmorClass = 5
    , addedSkillPercentages = SeqDict.empty
    , unarmedDamageBonus = 0
    , special = Special.init
    , fightStrategy = Command DoWhatever
    , crippledLeftLeg = False
    , crippledRightLeg = False
    , crippledLeftArm = False
    , crippledRightArm = False
    , knockedOutTurns = 0
    , isKnockedDown = False
    , losesNextTurn = False
    }


baseOngoingFight : Opponent -> FightGen.OngoingFight
baseOngoingFight opponent =
    { distanceHexes = 1
    , attacker = opponent
    , attackerAp = 10
    , attackerItemsUsed = SeqDict.empty
    , target = opponent
    , targetAp = 10
    , targetItemsUsed = SeqDict.empty
    , reverseLog = []
    , actionsTaken = 0
    }


damageNeverNegative : Test
damageNeverNegative =
    Test.fuzz randomFightFuzzer "Damage in fight should never be negative" <|
        \fight ->
            fight.fightInfoForAttacker.log
                |> List.map (Tuple.second >> Fight.attackDamage)
                |> List.filter (\damage -> damage < 0)
                |> List.isEmpty
                |> Expect.equal True
                |> Expect.onFail "Expected the list of negative damage actions in a fight to be empty"


fightEndsIfOnlyRunningAway : Test
fightEndsIfOnlyRunningAway =
    Test.fuzz
        (fightFuzzer
            { attacker = opponentFuzzer |> Fuzz.map (\opp -> { opp | fightStrategy = Command RunAway })
            , target = opponentFuzzer |> Fuzz.map (\opp -> { opp | fightStrategy = Command RunAway })
            }
        )
        "Fight ends if only running away (no infinite loops)"
    <|
        \fight ->
            fight.fightInfoForAttacker.result
                |> Expect.equal Fight.NobodyDeadGivenUp
                |> Expect.onFail "Expected damage-less run-only fight to end (NobodyDeadGivenUp)"


fightEndsIfOnlyMovingForward : Test
fightEndsIfOnlyMovingForward =
    Test.fuzz
        (fightFuzzer
            { attacker = opponentFuzzer |> Fuzz.map (\opp -> { opp | fightStrategy = Command MoveForward })
            , target = opponentFuzzer |> Fuzz.map (\opp -> { opp | fightStrategy = Command MoveForward })
            }
        )
        "Fight ends if only moving forward (no infinite loops)"
    <|
        \fight ->
            fight.fightInfoForAttacker.result
                |> Expect.equal Fight.NobodyDeadGivenUp
                |> Expect.onFail "Expected damage-less run-only fight to end (NobodyDeadGivenUp)"


fightEndsIfOnlyMovingForwardAndRunningAway : Test
fightEndsIfOnlyMovingForwardAndRunningAway =
    Test.fuzz
        (fightFuzzer
            { attacker = opponentFuzzer |> Fuzz.map (\opp -> { opp | fightStrategy = Command RunAway })
            , target = opponentFuzzer |> Fuzz.map (\opp -> { opp | fightStrategy = Command MoveForward })
            }
        )
        "Fight ends if only moving forward and running away (no infinite loops)"
    <|
        \fight ->
            fight.fightInfoForAttacker.result
                |> Expect.equal Fight.NobodyDeadGivenUp
                |> Expect.onFail "Expected damage-less run-only fight to end (NobodyDeadGivenUp)"


meleeAttackSucceedsAtDistance2WithRange2 : Test
meleeAttackSucceedsAtDistance2WithRange2 =
    Test.test "Melee combat at distance 2 with weapon with range 2 should work" <|
        \() ->
            let
                opponent =
                    { baseOpponent | equippedWeapon = Just ItemKind.SuperSledge }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 2 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.MeleeUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


meleeUnaimedStrategyResultsInMeleeUnaimedAttacks : Test
meleeUnaimedStrategyResultsInMeleeUnaimedAttacks =
    Test.test "Melee unaimed strategy results in melee unaimed attacks" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.Knife
                        , fightStrategy =
                            FightStrategy.If
                                { condition =
                                    FightStrategy.Operator
                                        { lhs = FightStrategy.Distance
                                        , op = FightStrategy.GT_
                                        , rhs = FightStrategy.Number 1
                                        }
                                , then_ = FightStrategy.Command FightStrategy.MoveForward
                                , else_ = FightStrategy.Command <| FightStrategy.Attack AttackStyle.MeleeUnaimed
                                }
                    }

                fight =
                    Random.step
                        (FightGen.generator
                            { attacker = opponent
                            , target = opponent
                            , currentTime = Time.millisToPosix 0
                            }
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            fight.fightInfoForAttacker.log
                |> List.all
                    (\( _, action ) ->
                        case action of
                            Fight.Attack r ->
                                r.attackStyle == AttackStyle.MeleeUnaimed

                            _ ->
                                True
                    )
                |> Expect.equal True
                |> Expect.onFail "Expected all attacks to be melee unaimed"


meleeAttackFailsAtDistance2WithRange1 : Test
meleeAttackFailsAtDistance2WithRange1 =
    Test.test "Melee combat at distance 2 with weapon with range 1 shouldn't work" <|
        \() ->
            let
                opponent =
                    { baseOpponent | equippedWeapon = Just ItemKind.Wakizashi }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 2 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.MeleeUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal False
                |> Expect.onFail "Expected the attack to fail"


rangedAttackFailsWithoutAmmoAndOutOfRange : Test
rangedAttackFailsWithoutAmmoAndOutOfRange =
    Test.test "Ranged attack fails without ammo and out of range" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , preferredAmmo = Nothing
                        , items = Dict.empty
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal False
                |> Expect.onFail "Expected the attack to fail"


rangedAttackSucceedsAtDistance15WithRange30 : Test
rangedAttackSucceedsAtDistance15WithRange30 =
    Test.test "Ranged attack succeeds at distance 15 with range 30" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , preferredAmmo = Nothing
                        , items = Dict.singleton 1 { id = 1, kind = ItemKind.BBAmmo, count = 1 }
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


aimedRangedAttackIsLogged : Test
aimedRangedAttackIsLogged =
    Test.fuzz
        (fightFuzzer
            { attacker =
                Fuzz.constant
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , fightStrategy = Command <| Attack <| AttackStyle.ShootSingleAimed AimedShot.Eyes
                        , special = Special.fromList (List.repeat 7 10) |> Maybe.withDefault Special.init
                        , addedSkillPercentages = SeqDict.singleton Skill.SmallGuns 300
                        , items =
                            Dict.singleton 1
                                { id = 1
                                , kind = ItemKind.BBAmmo
                                , count = 1
                                }
                    }
            , target = Fuzz.constant baseOpponent
            }
        )
        "Aimed ranged attack is logged"
    <|
        \fight ->
            fight.fightInfoForAttacker.log
                |> List.any (\( _, action ) -> Fight.attackStyle action == Just (AttackStyle.ShootSingleAimed AimedShot.Eyes))
                |> Expect.equal True
                |> Expect.onFail "Expected the aimed ranged attack to be logged"


skipTurnSkipsTurn : Test
skipTurnSkipsTurn =
    Test.fuzz
        (fightFuzzer
            { attacker = Fuzz.constant { baseOpponent | fightStrategy = Command SkipTurn }
            , target = Fuzz.constant baseOpponent
            }
        )
        "Command 'Skip turn' skips the turn"
    <|
        \fight ->
            fight.fightInfoForAttacker.log
                |> List.Extra.groupWhile (\( _, action1 ) ( _, action2 ) -> Fight.isSkipTurn action1 && Fight.isSkipTurn action2)
                |> List.filterMap
                    (\( ( _, x ), xs ) ->
                        case x of
                            Fight.SkipTurn _ ->
                                Just (List.length xs + 1)

                            _ ->
                                Nothing
                    )
                |> List.all (\len -> len == 1)
                |> Expect.equal True
                |> Expect.onFail "Expected 'Skip turn' to skip a turn"


showsOriginalWeaponWithNoUsableAmmo : Test
showsOriginalWeaponWithNoUsableAmmo =
    Test.fuzz
        (fightFuzzer
            { attacker =
                Fuzz.constant
                    { baseOpponent
                        | fightStrategy = Command <| Attack AttackStyle.ShootSingleUnaimed
                        , equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , items = Dict.empty
                    }
            , target = Fuzz.constant baseOpponent
            }
        )
        "Final log shows original weapon even when there's no usable ammo"
    <|
        \fight ->
            case fight.fightInfoForAttacker.attackerEquipment of
                Nothing ->
                    Expect.fail "Expected the attacker equipment to be always Just if we're the attacker"

                Just equipment ->
                    equipment.weapon
                        |> Expect.equal (Just ItemKind.RedRyderLEBBGun)
                        |> Expect.onFail "Expected the final log to show the original weapon even when there's no usable ammo"


rangedAttackFailsAtDistance30WithRange7 : Test
rangedAttackFailsAtDistance30WithRange7 =
    Test.test "Ranged attack fails at distance 30 with range 7" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.SawedOffShotgun
                        , preferredAmmo = Nothing
                        , items = Dict.singleton 1 { id = 1, kind = ItemKind.ShotgunShell, count = 1 }
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 30 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal False
                |> Expect.onFail "Expected the attack to fail"


unarmedAttackUsedWhenNoAmmoAndInRange : Test
unarmedAttackUsedWhenNoAmmoAndInRange =
    Test.test "Unarmed attack used when no ammo and in range" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.SawedOffShotgun
                        , preferredAmmo = Nothing
                        , items = Dict.empty
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 1 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


thrownAttackUsesUpWeapon : Test
thrownAttackUsesUpWeapon =
    Test.test "Thrown attack uses up weapon" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.FragGrenade
                        , preferredAmmo = Nothing
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.FragGrenade, count = 1 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 10 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.Throw
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.ranCommandSuccessfully
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to succeed"
                    , \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.member ItemKind.FragGrenade
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to add the thrown weapon to attackerItemsUsed"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ItemKind.FragGrenade)
                            |> Dict.isEmpty
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to result in FragGrenade not being in attacker's inventory"
                    ]


canBurstAttackWithLessThanDesignatedAmmoAmount : Test
canBurstAttackWithLessThanDesignatedAmmoAmount =
    Test.test "Can burst attack with less than designated ammo amount" <|
        \() ->
            let
                weapon =
                    ItemKind.Bozar

                ammo =
                    ItemKind.Fmj223

                designatedAmmoAmount =
                    ItemKind.shotsPerBurst weapon
                        |> Maybe.withDefault 0

                usedAmmoAmount =
                    designatedAmmoAmount - 1

                opponent =
                    { baseOpponent
                        | equippedWeapon = Just weapon
                        , preferredAmmo = Nothing
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ammo, count = usedAmmoAmount } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 10 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootBurst
                            6
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.ranCommandSuccessfully
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to succeed"
                    , \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.get ammo
                            |> Expect.equal (Just usedAmmoAmount)
                            |> Expect.onFail "Expected the attack to use only the owned ammo amount, not more"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ammo)
                            |> Dict.isEmpty
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to result in ammo not being in attacker's inventory"
                    ]


burstAttackUsesDesignatedAmmoAmount : Test
burstAttackUsesDesignatedAmmoAmount =
    Test.test "Burst attack uses designated ammo amount" <|
        \() ->
            let
                weapon =
                    ItemKind.Bozar

                ammo =
                    ItemKind.Fmj223

                designatedAmmoAmount =
                    ItemKind.shotsPerBurst weapon
                        |> Maybe.withDefault 0

                ownedAmmoAmount =
                    designatedAmmoAmount * 2

                opponent =
                    { baseOpponent
                        | equippedWeapon = Just weapon
                        , preferredAmmo = Nothing
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ammo, count = ownedAmmoAmount } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 10 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootBurst
                            6
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.ranCommandSuccessfully
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to succeed"
                    , \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.get ammo
                            |> Expect.equal (Just designatedAmmoAmount)
                            |> Expect.onFail "Expected the attack to use only the designated ammo amount, not more"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ammo)
                            |> Dict.isEmpty
                            |> Expect.equal False
                            |> Expect.onFail "Expected the attack to result in ammo still being in attacker's inventory"
                    ]


burstAttackCanCauseDamage : Test
burstAttackCanCauseDamage =
    Test.test "Burst attack can cause damage" <|
        \() ->
            let
                attackFuzzer_ =
                    attackFuzzer
                        (\opponent ->
                            { opponent
                                | equippedWeapon = Just ItemKind.Bozar
                                , preferredAmmo = Just ItemKind.Fmj223
                                , items = Dict.singleton 1 { id = 1, kind = ItemKind.Fmj223, count = 100 }
                            }
                        )
                        (Fuzz.constant AttackStyle.ShootBurst)

                test result =
                    result.nextOngoing.reverseLog
                        |> List.any
                            (\( _, action ) ->
                                (Fight.attackStyle action == Just AttackStyle.ShootBurst)
                                    && (Fight.attackDamage action > 0)
                            )
            in
            canPass attackFuzzer_ test


burstAttackCanBeCritical : Test
burstAttackCanBeCritical =
    Test.test "Burst attack can be critical" <|
        \() ->
            let
                attackFuzzer_ =
                    attackFuzzer
                        (\opponent ->
                            { opponent
                                | equippedWeapon = Just ItemKind.Bozar
                                , preferredAmmo = Just ItemKind.Fmj223
                                , items = Dict.singleton 1 { id = 1, kind = ItemKind.Fmj223, count = 100 }
                            }
                        )
                        (Fuzz.constant AttackStyle.ShootBurst)

                test result =
                    result.nextOngoing.reverseLog
                        |> List.any
                            (\( _, action ) ->
                                case action of
                                    Fight.Attack r ->
                                        r.critical /= Nothing

                                    _ ->
                                        False
                            )
            in
            canPass attackFuzzer_ test


rangedAttackSucceedsWithWrongPreferredAmmo : Test
rangedAttackSucceedsWithWrongPreferredAmmo =
    Test.test "Ranged attack succeeds with wrong preferred ammo" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.RedRyderLEBBGun
                        , preferredAmmo = Just ItemKind.Ap10mm -- This shouldn't ever happen in game but let's test it anyway
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.BBAmmo, count = 1 } )
                                , ( 2, { id = 2, kind = ItemKind.Ap10mm, count = 1 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


rangedAttackUsesPreferredAmmo : Test
rangedAttackUsesPreferredAmmo =
    Test.test "Ranged attack uses the preferred ammo" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.Smg10mm
                        , preferredAmmo = Just ItemKind.Ap10mm
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.Jhp10mm, count = 1 } )
                                , ( 2, { id = 2, kind = ItemKind.Ap10mm, count = 1 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.member ItemKind.Ap10mm
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to add the preferred ammo to attackerItemsUsed"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ItemKind.Ap10mm)
                            |> Dict.isEmpty
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to result in Ap10mm not being in attacker's inventory"
                    , \r ->
                        r.nextOngoing.attacker.preferredAmmo
                            |> Expect.equal Nothing
                            |> Expect.onFail "Expected the preferred ammo to be unset after it's used up"
                    ]


rangedAttackUsesOnlyOnePieceOfAmmo : Test
rangedAttackUsesOnlyOnePieceOfAmmo =
    Test.test "Ranged attack uses only one piece of ammo" <|
        \() ->
            let
                opponent =
                    { baseOpponent
                        | equippedWeapon = Just ItemKind.Smg10mm
                        , preferredAmmo = Just ItemKind.Jhp10mm
                        , items =
                            Dict.fromList
                                [ ( 1, { id = 1, kind = ItemKind.Jhp10mm, count = 5 } )
                                ]
                    }

                baseOngoingFight_ =
                    baseOngoingFight opponent

                ongoingFight =
                    { baseOngoingFight_ | distanceHexes = 15 }

                result =
                    Random.step
                        (FightGen.attack_
                            Fight.Attacker
                            ongoingFight
                            AttackStyle.ShootSingleUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result
                |> Expect.all
                    [ \r ->
                        r.nextOngoing.attackerItemsUsed
                            |> SeqDict.member ItemKind.Jhp10mm
                            |> Expect.equal True
                            |> Expect.onFail "Expected the attack to add the preferred ammo to attackerItemsUsed"
                    , \r ->
                        r.nextOngoing.attacker.items
                            |> Dict.filter (\_ { kind } -> kind == ItemKind.Jhp10mm)
                            |> Dict.values
                            |> Expect.equal [ { id = 1, kind = ItemKind.Jhp10mm, count = 4 } ]
                            |> Expect.onFail "Expected the attack to result in Jhp10mm still being in attacker's inventory, just one less"
                    , \r ->
                        r.nextOngoing.attacker.preferredAmmo
                            |> Expect.equal (Just ItemKind.Jhp10mm)
                            |> Expect.onFail "Expected the preferred ammo still be set if we still have some in the inventory"
                    ]


fightFuzzer :
    { attacker : Fuzzer Opponent
    , target : Fuzzer Opponent
    }
    -> Fuzzer Fight
fightFuzzer r =
    Fuzz.constant
        (\a t currentTime seed ->
            Random.step
                (FightGen.generator
                    { attacker = a
                    , target = t
                    , currentTime = currentTime
                    }
                )
                seed
        )
        |> Fuzz.andMap r.attacker
        |> Fuzz.andMap r.target
        |> Fuzz.andMap posixFuzzer
        |> Fuzz.andMap randomSeedFuzzer
        |> Fuzz.map Tuple.first


randomFightFuzzer : Fuzzer Fight
randomFightFuzzer =
    fightFuzzer
        { attacker = opponentFuzzer
        , target = opponentFuzzer
        }


attackFuzzer : (Opponent -> Opponent) -> Fuzzer AttackStyle -> Fuzzer { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
attackFuzzer fixOpponent attackStyleFuzzer =
    Fuzz.map4
        (\opponent attackStyle ap seed ->
            let
                fixedOpponent =
                    fixOpponent opponent

                ongoingFight =
                    { distanceHexes = 1
                    , attacker = fixedOpponent
                    , attackerAp = 10
                    , attackerItemsUsed = SeqDict.empty
                    , target = fixedOpponent
                    , targetAp = 10
                    , targetItemsUsed = SeqDict.empty
                    , reverseLog = []
                    , actionsTaken = 0
                    }
            in
            Random.step
                (FightGen.attack_
                    Fight.Attacker
                    ongoingFight
                    attackStyle
                    ap
                )
                seed
                |> Tuple.first
        )
        opponentFuzzer
        attackStyleFuzzer
        (Fuzz.intRange 1 10)
        randomSeedFuzzer
