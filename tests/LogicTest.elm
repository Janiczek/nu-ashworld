module LogicTest exposing (test)

import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Perk as Perk exposing (Perk)
import Data.Skill as Skill exposing (Skill(..))
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Dict exposing (Dict)
import Expect
import Fuzz exposing (Fuzzer)
import Logic
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
import Test exposing (Test)
import TestHelpers


test : Test
test =
    Test.describe "Logic"
        [ chanceToHitSuite
        , attackStatsSuite
        ]


attackStatsSuite : Test
attackStatsSuite =
    Test.describe "attackStats"
        [ Test.fuzz attackStatsArgsFuzzer "Don't use ranged dmg range when using fallback unarmed attack when no ammo" <|
            \args ->
                Logic.attackStats
                    { args
                        | equippedWeapon = Just ItemKind.Bozar
                        , items = args.items |> Dict.filter (\_ { kind } -> not (ItemKind.isAmmo kind))
                    }
                    |> Expect.equal
                        (Logic.attackStats
                            { args
                                | equippedWeapon = Nothing
                            }
                        )
        , Test.test "Melee weapon (knife) gets perk+trait bonus but not the 'named attack' bonus nor unarmedDamageBonus" <|
            \() ->
                Logic.attackStats
                    { special = Special.Special 10 5 5 5 5 6 5
                    , addedSkillPercentages = SeqDict.singleton Skill.Unarmed 55
                    , traits = SeqSet.singleton Trait.HeavyHanded
                    , perks = SeqDict.singleton Perk.BonusHthDamage 2
                    , level = 1
                    , equippedWeapon = Just ItemKind.Knife
                    , preferredAmmo = Nothing
                    , items = Dict.singleton 1 { id = 1, kind = ItemKind.Knife, count = 1 }
                    , unarmedDamageBonus = 10
                    , attackStyle = MeleeUnaimed
                    }
                    |> Expect.equal
                        { minDamage = {- knife -} 1
                        , maxDamage =
                            0
                                + {- knife -} 6
                                + {- Melee Damage (strengh-based) -} 5
                                + {- Heavy Handed -} 4
                                + {- Bonus HtH Damage -} 4
                        , criticalChanceBonus = 0
                        }
        , Test.test "Unarmed weapon (power fist) gets perk+trait bonus but not the 'named attack' bonus nor unarmedDamageBonus" <|
            \() ->
                Logic.attackStats
                    { special = Special.Special 10 5 5 5 5 6 5
                    , addedSkillPercentages = SeqDict.singleton Skill.Unarmed 55
                    , traits = SeqSet.singleton Trait.HeavyHanded
                    , perks = SeqDict.singleton Perk.BonusHthDamage 2
                    , level = 1
                    , equippedWeapon = Just ItemKind.PowerFist
                    , preferredAmmo = Nothing
                    , items =
                        Dict.fromList
                            [ ( 1, { id = 1, kind = ItemKind.PowerFist, count = 1 } )
                            , ( 2, { id = 2, kind = ItemKind.SmallEnergyCell, count = 1 } )
                            ]
                    , unarmedDamageBonus = 10
                    , attackStyle = UnarmedUnaimed
                    }
                    |> Expect.equal
                        { minDamage = {- power fist -} 12
                        , maxDamage =
                            0
                                + {- power fist -} 24
                                + {- Melee Damage (strengh-based) -} 5
                                + {- Heavy Handed -} 4
                                + {- Bonus HtH Damage -} 4
                        , criticalChanceBonus = 0
                        }
        , Test.test "Unarmed attack without a weapon gets 'named attack' bonus" <|
            \() ->
                Logic.attackStats
                    { special = Special.Special 10 5 5 5 5 6 5
                    , addedSkillPercentages = SeqDict.singleton Skill.Unarmed 55
                    , traits = SeqSet.singleton Trait.HeavyHanded
                    , perks = SeqDict.singleton Perk.BonusHthDamage 2
                    , level = 1
                    , equippedWeapon = Nothing
                    , preferredAmmo = Nothing
                    , items = Dict.empty
                    , unarmedDamageBonus = 10
                    , attackStyle = UnarmedUnaimed
                    }
                    |> Expect.equal
                        { minDamage =
                            0
                                + {- basic unarmed attack -} 1
                                + {- named attack bonus -} 3
                        , maxDamage =
                            0
                                + {- basic unarmed attack -} 1
                                + {- Melee Damage (strengh-based) -} 5
                                + {- Heavy Handed -} 4
                                + {- Bonus HtH Damage -} 4
                                + {- unarmedDamageBonus -} 10
                                + {- named attack bonus -} 3
                        , criticalChanceBonus = 0
                        }
        ]


chanceToHitSuite : Test
chanceToHitSuite =
    Test.describe "chanceToHit"
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
        , Test.fuzz2 chanceToHitArgsFuzzer TestHelpers.aimedAttackStyleFuzzer "FastShot + aimed attack: cannot hit" <|
            \args attackStyle ->
                Logic.chanceToHit
                    { args
                        | attackStyle = attackStyle
                        , attackerTraits = args.attackerTraits |> SeqSet.insert Trait.FastShot
                    }
                    |> Expect.equal 0
        ]


attackStatsArgsFuzzer :
    Fuzzer
        { special : Special
        , addedSkillPercentages : SeqDict Skill Int
        , traits : SeqSet Trait
        , perks : SeqDict Perk Int
        , level : Int
        , equippedWeapon : Maybe ItemKind.Kind
        , preferredAmmo : Maybe ItemKind.Kind
        , items : Dict Item.Id Item
        , unarmedDamageBonus : Int
        , attackStyle : AttackStyle
        }
attackStatsArgsFuzzer =
    Fuzz.constant
        (\special addedSkillPercentages traits perks level equippedWeapon preferredAmmo items unarmedDamageBonus attackStyle ->
            { special = special
            , addedSkillPercentages = addedSkillPercentages
            , traits = traits
            , perks = perks
            , level = level
            , equippedWeapon = equippedWeapon
            , preferredAmmo = preferredAmmo
            , items = items
            , unarmedDamageBonus = unarmedDamageBonus
            , attackStyle = attackStyle
            }
        )
        |> Fuzz.andMap TestHelpers.specialFuzzer
        |> Fuzz.andMap TestHelpers.addedSkillPercentagesFuzzer
        |> Fuzz.andMap TestHelpers.traitsFuzzer
        |> Fuzz.andMap TestHelpers.perksFuzzer
        |> Fuzz.andMap (Fuzz.intRange 1 99)
        |> Fuzz.andMap TestHelpers.equippedWeaponKindFuzzer
        |> Fuzz.andMap TestHelpers.preferredAmmoKindFuzzer
        |> Fuzz.andMap TestHelpers.itemsFuzzer
        |> Fuzz.andMap (Fuzz.intRange 0 10)
        |> Fuzz.andMap TestHelpers.attackStyleFuzzer


chanceToHitArgsFuzzer :
    Fuzzer
        { attackerAddedSkillPercentages : SeqDict Skill Int
        , attackerPerks : SeqDict Perk Int
        , attackerSpecial : Special
        , attackerTraits : SeqSet Trait
        , distanceHexes : Int
        , equippedWeapon : Maybe ItemKind.Kind
        , preferredAmmo : Maybe ItemKind.Kind
        , targetArmorClass : Int
        , attackStyle : AttackStyle
        }
chanceToHitArgsFuzzer =
    Fuzz.constant
        (\attackerAddedSkillPercentages attackerPerks attackerSpecial attackerTraits distanceHexes equippedWeapon preferredAmmo targetArmorClass attackStyle ->
            { attackerAddedSkillPercentages = attackerAddedSkillPercentages
            , attackerPerks = attackerPerks
            , attackerSpecial = attackerSpecial
            , attackerTraits = attackerTraits
            , distanceHexes = distanceHexes
            , equippedWeapon = equippedWeapon
            , preferredAmmo = preferredAmmo
            , targetArmorClass = targetArmorClass
            , attackStyle = attackStyle
            }
        )
        |> Fuzz.andMap TestHelpers.addedSkillPercentagesFuzzer
        |> Fuzz.andMap TestHelpers.perksFuzzer
        |> Fuzz.andMap TestHelpers.specialFuzzer
        |> Fuzz.andMap TestHelpers.traitsFuzzer
        |> Fuzz.andMap TestHelpers.distanceFuzzer
        |> Fuzz.andMap TestHelpers.equippedWeaponKindFuzzer
        |> Fuzz.andMap TestHelpers.preferredAmmoKindFuzzer
        |> Fuzz.andMap TestHelpers.armorClassFuzzer
        |> Fuzz.andMap TestHelpers.attackStyleFuzzer
