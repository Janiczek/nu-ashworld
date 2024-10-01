module Data.FightStrategy.ParserTest exposing (..)

import Data.Fight.ShotType exposing (AimedShot(..), ShotType(..))
import Data.FightStrategy as FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , Operator(..)
        , Value(..)
        )
import Data.FightStrategy.Parser as FightStrategy
import Data.Item exposing (Kind(..))
import Expect
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
        [ ( "my HP", "my HP", Just MyHP )
        , ( "my max HP", "my max HP", Just MyMaxHP )
        , ( "my AP", "my AP", Just MyAP )
        , ( "distance", "distance", Just Distance )
        , ( "item count Stimpak", "number of available Stimpak", Just (MyItemCount Stimpak) )
        , ( "item count HealingPowder", "number of available Healing Powder", Just (MyItemCount HealingPowder) )
        , ( "item count - non-healing item also works", "number of available Metal Armor", Just (MyItemCount MetalArmor) )
        , ( "used Stimpak", "number of used Stimpak", Just (ItemsUsed Stimpak) )
        , ( "used HealingPowder", "number of used Healing Powder", Just (ItemsUsed HealingPowder) )
        , ( "used - non-healing item also works", "number of used Metal Armor", Just (ItemsUsed MetalArmor) )
        , ( "chance to hit NormalShot", "chance to hit (unaimed)", Just (ChanceToHit NormalShot) )
        , ( "chance to hit AimedShot Head", "chance to hit (head)", Just (ChanceToHit (AimedShot Head)) )
        , ( "chance to hit AimedShot LeftArm", "chance to hit (left arm)", Just (ChanceToHit (AimedShot LeftArm)) )
        , ( "chance to hit AimedShot LeftLeg", "chance to hit (left leg)", Just (ChanceToHit (AimedShot LeftLeg)) )
        ]


shotType : Test
shotType =
    parserTest "FightStrategy.shotType"
        FightStrategy.shotType
        [ ( "NormalShot", "unaimed", Just NormalShot )
        , ( "Head", "head", Just (AimedShot Head) )
        , ( "Torso", "torso", Just (AimedShot Torso) )
        , ( "Eyes", "eyes", Just (AimedShot Eyes) )
        , ( "Groin", "groin", Just (AimedShot Groin) )
        , ( "LeftArm", "left arm", Just (AimedShot LeftArm) )
        , ( "RightArm", "right arm", Just (AimedShot RightArm) )
        , ( "LeftLeg", "left leg", Just (AimedShot LeftLeg) )
        , ( "RightLeg", "right leg", Just (AimedShot RightLeg) )
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
        [ ( "attack randomly", "attack randomly", Just AttackRandomly )
        , ( "move forward", "move forward", Just MoveForward )
        , ( "do whatever", "do whatever", Just DoWhatever )
        , ( "attack unaimed", "attack (unaimed)", Just (Attack NormalShot) )
        , ( "attack eyes", "attack (eyes)", Just (Attack (AimedShot Eyes)) )
        , ( "heal Stimpak", "heal (Stimpak)", Just (Heal Stimpak) )
        , ( "heal Healing Powder", "heal (Healing Powder)", Just (Heal HealingPowder) )
        , ( "heal - non-healing item", "heal (Metal Armor)", Just (Heal MetalArmor) )
        , ( "heal with anything", "heal with anything", Just HealWithAnything )
        , ( "skip turn", "skip turn", Just SkipTurn )
        ]


condition : Test
condition =
    parserTest "FightStrategy.condition"
        FightStrategy.condition
        [ ( "op: my HP < 50", "my HP < 50", Just (Operator { lhs = MyHP, op = LT_, rhs = Number 50 }) )
        , ( "op: my AP >= 3", "my AP >= 3", Just (Operator { lhs = MyAP, op = GTE, rhs = Number 3 }) )
        , ( "op: my HP < my max HP", "my HP < my max HP", Just (Operator { lhs = MyHP, op = LT_, rhs = MyMaxHP }) )
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
                        (Operator { lhs = ItemsUsed Stimpak, op = LT_, rhs = Number 50 })
                        (Or
                            (Operator { lhs = ItemsUsed HealingPowder, op = LT_, rhs = Number 50 })
                            (Operator { lhs = ItemsUsed Fruit, op = LT_, rhs = Number 50 })
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
                    , then_ = Command (Heal Fruit)
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
                    , then_ = Command (Heal Fruit)
                    , else_ =
                        If
                            { condition = Operator { lhs = ItemsUsed Fruit, op = GT_, rhs = Number 200 }
                            , then_ = Command (Heal Stimpak)
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
