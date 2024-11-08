module Data.FightStrategy.ParserTest exposing (..)

import Data.Fight.AimedShot exposing (AimedShot(..))
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.FightStrategy as FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , Operator(..)
        , Value(..)
        )
import Data.FightStrategy.Parser as FightStrategy
import Data.Item.Kind as ItemKind
import Expect
import List.ExtraExtra as List
import Test exposing (Test)
import TestHelpers
    exposing
        ( fightStrategyFuzzer
        , multilineInput
        , parserTest
        )


value : Test
value =
    parserTest "FightStrategy.value"
        FightStrategy.value
        (List.fastConcat
            [ [ ( "my HP", "my HP", Just MyHP )
              , ( "my max HP", "my max HP", Just MyMaxHP )
              , ( "my AP", "my AP", Just MyAP )
              , ( "my level", "my level", Just MyLevel )
              , ( "their level", "their level", Just TheirLevel )
              , ( "distance", "distance", Just Distance )
              , ( "item count Stimpak", "number of available Stimpak", Just (MyItemCount ItemKind.Stimpak) )
              , ( "item count HealingPowder", "number of available Healing Powder", Just (MyItemCount ItemKind.HealingPowder) )
              , ( "item count - non-healing item also works", "number of available Metal Armor", Just (MyItemCount ItemKind.MetalArmor) )
              , ( "healing item count", "number of available healing items", Just MyHealingItemCount )
              , ( "used Stimpak", "number of used Stimpak", Just (ItemsUsed ItemKind.Stimpak) )
              , ( "used HealingPowder", "number of used Healing Powder", Just (ItemsUsed ItemKind.HealingPowder) )
              , ( "used - non-healing item also works", "number of used Metal Armor", Just (ItemsUsed ItemKind.MetalArmor) )
              , ( "used healing items", "number of used healing items", Just HealingItemsUsed )
              , ( "item count - ammo", "number of available ammo", Just MyAmmoCount )
              , ( "used ammo", "number of used ammo", Just AmmoUsed )
              ]
            , AttackStyle.all
                |> List.fastConcatMap
                    (\style ->
                        [ ( "chance to hit " ++ Debug.toString style
                          , "chance to hit (" ++ AttackStyle.toString style ++ ")"
                          , Just (ChanceToHit style)
                          )
                        , ( "range needed " ++ Debug.toString style
                          , "range needed (" ++ AttackStyle.toString style ++ ")"
                          , Just (RangeNeeded style)
                          )
                        ]
                    )
            ]
        )


attackStyle : Test
attackStyle =
    parserTest "FightStrategy.attackStyle"
        FightStrategy.attackStyle
        [ ( "UnarmedUnaimed", "unarmed", Just UnarmedUnaimed )
        , ( "UnarmedAimed Head", "unarmed, head", Just (UnarmedAimed Head) )
        , ( "UnarmedAimed Torso", "unarmed, torso", Just (UnarmedAimed Torso) )
        , ( "UnarmedAimed Eyes", "unarmed, eyes", Just (UnarmedAimed Eyes) )
        , ( "UnarmedAimed Groin", "unarmed, groin", Just (UnarmedAimed Groin) )
        , ( "UnarmedAimed LeftArm", "unarmed, left arm", Just (UnarmedAimed LeftArm) )
        , ( "UnarmedAimed RightArm", "unarmed, right arm", Just (UnarmedAimed RightArm) )
        , ( "UnarmedAimed LeftLeg", "unarmed, left leg", Just (UnarmedAimed LeftLeg) )
        , ( "UnarmedAimed RightLeg", "unarmed, right leg", Just (UnarmedAimed RightLeg) )
        , ( "MeleeUnaimed", "melee", Just MeleeUnaimed )
        , ( "MeleeAimed Head", "melee, head", Just (MeleeAimed Head) )
        , ( "MeleeAimed Torso", "melee, torso", Just (MeleeAimed Torso) )
        , ( "MeleeAimed Eyes", "melee, eyes", Just (MeleeAimed Eyes) )
        , ( "MeleeAimed Groin", "melee, groin", Just (MeleeAimed Groin) )
        , ( "MeleeAimed LeftArm", "melee, left arm", Just (MeleeAimed LeftArm) )
        , ( "MeleeAimed RightArm", "melee, right arm", Just (MeleeAimed RightArm) )
        , ( "MeleeAimed LeftLeg", "melee, left leg", Just (MeleeAimed LeftLeg) )
        , ( "MeleeAimed RightLeg", "melee, right leg", Just (MeleeAimed RightLeg) )
        , ( "Throw", "throw", Just Throw )
        , ( "ShootSingleUnaimed", "shoot", Just ShootSingleUnaimed )
        , ( "ShootSingleAimed Head", "shoot, head", Just (ShootSingleAimed Head) )
        , ( "ShootSingleAimed Torso", "shoot, torso", Just (ShootSingleAimed Torso) )
        , ( "ShootSingleAimed Eyes", "shoot, eyes", Just (ShootSingleAimed Eyes) )
        , ( "ShootSingleAimed Groin", "shoot, groin", Just (ShootSingleAimed Groin) )
        , ( "ShootSingleAimed LeftArm", "shoot, left arm", Just (ShootSingleAimed LeftArm) )
        , ( "ShootSingleAimed RightArm", "shoot, right arm", Just (ShootSingleAimed RightArm) )
        , ( "ShootSingleAimed LeftLeg", "shoot, left leg", Just (ShootSingleAimed LeftLeg) )
        , ( "ShootSingleAimed RightLeg", "shoot, right leg", Just (ShootSingleAimed RightLeg) )
        , ( "ShootBurst", "burst", Just ShootBurst )
        ]


operator : Test
operator =
    parserTest "FightStrategy.operator"
        FightStrategy.operator
        [ ( "<", "<", Just LT_ )
        , ( "<=", "<=", Just LTE )
        , ( "==", "==", Just EQ_ )
        , ( "!=", "!=", Just NE )
        , ( ">=", ">=", Just GTE )
        , ( ">", ">", Just GT_ )
        ]


command : Test
command =
    parserTest "FightStrategy.command"
        FightStrategy.command
        (List.fastConcat
            [ [ ( "attack randomly", "attack randomly", Just AttackRandomly )
              , ( "move forward", "move forward", Just MoveForward )
              , ( "run away", "run away", Just RunAway )
              , ( "do whatever", "do whatever", Just DoWhatever )
              , ( "heal Stimpak", "heal (Stimpak)", Just (Heal ItemKind.Stimpak) )
              , ( "heal Healing Powder", "heal (Healing Powder)", Just (Heal ItemKind.HealingPowder) )
              , ( "heal - non-healing item", "heal (Metal Armor)", Just (Heal ItemKind.MetalArmor) )
              , ( "heal with anything", "heal with anything", Just HealWithAnything )
              , ( "skip turn", "skip turn", Just SkipTurn )
              ]
            , AttackStyle.all
                |> List.map
                    (\style ->
                        ( "attack " ++ Debug.toString style
                        , "attack (" ++ AttackStyle.toString style ++ ")"
                        , Just (Attack style)
                        )
                    )
            ]
        )


condition : Test
condition =
    parserTest "FightStrategy.condition"
        FightStrategy.condition
        [ ( "op: my HP < 50", "my HP < 50", Just (Operator { lhs = MyHP, op = LT_, rhs = Number 50 }) )
        , ( "op: my AP >= 3", "my AP >= 3", Just (Operator { lhs = MyAP, op = GTE, rhs = Number 3 }) )
        , ( "op: my HP < my max HP", "my HP < my max HP", Just (Operator { lhs = MyHP, op = LT_, rhs = MyMaxHP }) )
        , ( "op: my level < their level", "my level < their level", Just (Operator { lhs = MyLevel, op = LT_, rhs = TheirLevel }) )
        , ( "opponent is player", "opponent is player", Just OpponentIsPlayer )
        , ( "opponent is NPC", "opponent is NPC", Just OpponentIsNPC )
        , ( "and"
          , "(my HP < 50 and my AP >= 3)"
          , Just
                (And
                    (Operator { lhs = MyHP, op = LT_, rhs = Number 50 })
                    (Operator { lhs = MyAP, op = GTE, rhs = Number 3 })
                )
          )
        , ( "or"
          , "(my HP < 50 or my AP >= 3)"
          , Just
                (Or
                    (Operator { lhs = MyHP, op = LT_, rhs = Number 50 })
                    (Operator { lhs = MyAP, op = GTE, rhs = Number 3 })
                )
          )
        , ( "or of ands"
          , "((my HP < 50 and my AP >= 3) or (my HP > 50 and my AP == 4))"
          , Just
                (Or
                    (And
                        (Operator { lhs = MyHP, op = LT_, rhs = Number 50 })
                        (Operator { lhs = MyAP, op = GTE, rhs = Number 3 })
                    )
                    (And
                        (Operator { lhs = MyHP, op = GT_, rhs = Number 50 })
                        (Operator { lhs = MyAP, op = EQ_, rhs = Number 4 })
                    )
                )
          )
        , ( "and of ors"
          , "((my HP < 50 or my AP >= 3) and (my HP > 50 or my AP == 4))"
          , Just
                (And
                    (Or
                        (Operator { lhs = MyHP, op = LT_, rhs = Number 50 })
                        (Operator { lhs = MyAP, op = GTE, rhs = Number 3 })
                    )
                    (Or
                        (Operator { lhs = MyHP, op = GT_, rhs = Number 50 })
                        (Operator { lhs = MyAP, op = EQ_, rhs = Number 4 })
                    )
                )
          )
        , ( "multiline"
          , """
            (my HP < 100
              and (number of used Stimpak < 50
              and (number of used Healing Powder < 50
              or   number of used Fruit < 50)))
            """
                |> multilineInput
          , Just
                (And
                    (Operator { lhs = MyHP, op = LT_, rhs = Number 100 })
                    (And
                        (Operator { lhs = ItemsUsed ItemKind.Stimpak, op = LT_, rhs = Number 50 })
                        (Or
                            (Operator { lhs = ItemsUsed ItemKind.HealingPowder, op = LT_, rhs = Number 50 })
                            (Operator { lhs = ItemsUsed ItemKind.Fruit, op = LT_, rhs = Number 50 })
                        )
                    )
                )
          )
        ]


fightStrategy : Test
fightStrategy =
    parserTest "FightStrategy.fightStrategy"
        FightStrategy.fightStrategy
        [ ( "simplest", "do whatever", Just (Command DoWhatever) )
        , ( "if"
          , "if my HP < 10 then heal (Fruit) else do whatever"
          , Just
                (If
                    { condition = Operator { lhs = MyHP, op = LT_, rhs = Number 10 }
                    , then_ = Command (Heal ItemKind.Fruit)
                    , else_ = Command DoWhatever
                    }
                )
          )
        , ( "nested if"
          , """
            if my HP < 10 then heal (Fruit) else
            if number of used Fruit > 200 then heal (Stimpak) else
            attack randomly
            """
                |> multilineInput
          , Just
                (If
                    { condition = Operator { lhs = MyHP, op = LT_, rhs = Number 10 }
                    , then_ = Command (Heal ItemKind.Fruit)
                    , else_ =
                        If
                            { condition = Operator { lhs = ItemsUsed ItemKind.Fruit, op = GT_, rhs = Number 200 }
                            , then_ = Command (Heal ItemKind.Stimpak)
                            , else_ = Command AttackRandomly
                            }
                    }
                )
          )
        ]


roundtrip : Test
roundtrip =
    Test.fuzz
        (fightStrategyFuzzer { maxDepth = 5 })
        "(strategy |> toString |> parse) == strategy"
    <|
        \strategy ->
            strategy
                |> FightStrategy.toString
                |> FightStrategy.parse
                |> Expect.equal (Ok strategy)
