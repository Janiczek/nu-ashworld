module LogicTest exposing (test)

import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.Item as Item exposing (Kind(..))
import Data.Perk exposing (Perk)
import Data.Skill exposing (Skill(..))
import Data.Special as Special exposing (Special)
import Expect
import Fuzz exposing (Fuzzer)
import Logic
import SeqDict exposing (SeqDict)
import Test exposing (Test)
import TestHelpers


test : Test
test =
    Test.describe "Logic"
        [ Test.describe "chanceToHit" <|
            [ Test.fuzz chanceToHitArgsFuzzer "0..95" <|
                \args ->
                    Logic.chanceToHit args
                        |> Expect.all
                            [ Expect.atLeast 0
                            , Expect.atMost 95
                            ]
            , Test.fuzz2 chanceToHitArgsFuzzer (Fuzz.maybe TestHelpers.unarmedWeaponKindFuzzer) "Unarmed + good range: can hit" <|
                \args maybeWeapon ->
                    Logic.chanceToHit
                        { args
                            | attackStyle = AttackStyle.UnarmedUnaimed
                            , equippedWeapon = maybeWeapon
                            , distanceHexes = 1
                            , targetArmorClass = 0
                        }
                        |> Expect.greaterThan 0
            , Test.fuzz2 chanceToHitArgsFuzzer (Fuzz.maybe TestHelpers.unarmedWeaponKindFuzzer) "Unarmed outside range: cannot hit" <|
                \args maybeWeapon ->
                    Logic.chanceToHit
                        { args
                            | attackStyle = AttackStyle.UnarmedUnaimed
                            , equippedWeapon = maybeWeapon
                            , distanceHexes = args.distanceHexes + 1
                        }
                        |> Expect.equal 0
            , Test.fuzz2 chanceToHitArgsFuzzer TestHelpers.meleeWeaponKindFuzzer "Melee + good range: can hit" <|
                \args weapon ->
                    Logic.chanceToHit
                        { args
                            | attackStyle = AttackStyle.MeleeUnaimed
                            , equippedWeapon = Just weapon
                            , distanceHexes = 1
                            , targetArmorClass = 0
                        }
                        |> Expect.greaterThan 0
            , Test.fuzz2 chanceToHitArgsFuzzer TestHelpers.meleeWeaponKindFuzzer "Melee outside range: cannot hit" <|
                \args weapon ->
                    Logic.chanceToHit
                        { args
                            | attackStyle = AttackStyle.MeleeUnaimed
                            , equippedWeapon = Just weapon
                            , distanceHexes = args.distanceHexes + 2
                        }
                        |> Expect.equal 0
            , Test.fuzz2 chanceToHitArgsFuzzer TestHelpers.smallGunKindFuzzer "Ranged + good range: can hit" <|
                \args weapon ->
                    Logic.chanceToHit
                        { args
                            | attackStyle = AttackStyle.ShootSingleUnaimed
                            , attackerSpecial = args.attackerSpecial |> Special.set Special.Strength 10
                            , attackerAddedSkillPercentages =
                                args.attackerAddedSkillPercentages
                                    |> SeqDict.insert SmallGuns 20
                            , equippedWeapon = Just weapon
                            , distanceHexes = 1
                            , targetArmorClass = 0
                        }
                        |> Expect.greaterThan 0
            , Test.fuzz2 chanceToHitArgsFuzzer TestHelpers.gunKindFuzzer "Ranged outside range: cannot hit" <|
                \args weapon ->
                    Logic.chanceToHit
                        { args
                            | attackStyle = AttackStyle.ShootSingleUnaimed
                            , equippedWeapon = Just weapon
                            , distanceHexes = args.distanceHexes + 80
                        }
                        |> Expect.equal 0
            ]
        ]


chanceToHitArgsFuzzer :
    Fuzzer
        { attackerAddedSkillPercentages : SeqDict Skill Int
        , attackerPerks : SeqDict Perk Int
        , attackerSpecial : Special
        , distanceHexes : Int
        , equippedWeapon : Maybe Item.Kind
        , equippedAmmo : Maybe Item.Kind
        , targetArmorClass : Int
        , attackStyle : AttackStyle
        }
chanceToHitArgsFuzzer =
    Fuzz.map8
        (\attackerAddedSkillPercentages attackerPerks attackerSpecial distanceHexes equippedWeapon equippedAmmo targetArmorClass attackStyle ->
            { attackerAddedSkillPercentages = attackerAddedSkillPercentages
            , attackerPerks = attackerPerks
            , attackerSpecial = attackerSpecial
            , distanceHexes = distanceHexes
            , equippedWeapon = equippedWeapon
            , equippedAmmo = equippedAmmo
            , targetArmorClass = targetArmorClass
            , attackStyle = attackStyle
            }
        )
        TestHelpers.addedSkillPercentagesFuzzer
        TestHelpers.perksFuzzer
        TestHelpers.specialFuzzer
        TestHelpers.distanceFuzzer
        TestHelpers.equippedWeaponKindFuzzer
        TestHelpers.equippedAmmoKindFuzzer
        TestHelpers.armorClassFuzzer
        TestHelpers.attackStyleFuzzer
