module Data.FightStrategy.ParserTest exposing (..)

import Data.Fight.ShotType exposing (AimedShot(..), ShotType(..))
import Data.FightStrategy
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
import Parser as P
import Test exposing (Test)
import TestHelpers exposing (multilineInput, parserTest)


value : Test
value =
    parserTest "FightStrategy.value"
        FightStrategy.value
        [ ( "my HP", "my HP", Just MyHP )
        , ( "my AP", "my AP", Just MyAP )
        , ( "their level", "opponent's level", Just TheirLevel )
        , ( "distance", "distance", Just Distance )
        , ( "item count Stimpak", "Stimpak in inventory", Just (MyItemCount Stimpak) )
        , ( "item count HealingPowder", "Healing Powder in inventory", Just (MyItemCount HealingPowder) )
        , ( "item count Metal Armor doesn't work", "Metal Armor in inventory", Nothing )
        , ( "used Stimpak", "used Stimpak", Just (ItemsUsed Stimpak) )
        , ( "used HealingPowder", "used Healing Powder", Just (ItemsUsed HealingPowder) )
        , ( "used Metal Armor doesn't work", "used Metal Armor", Nothing )
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
        , ( "heal Metal Armor", "heal (Metal Armor)", Nothing )
        ]


condition : Test
condition =
    parserTest "FightStrategy.condition"
        FightStrategy.condition
        [ ( "op: my HP < 50", "my HP < 50", Just (Operator { value = MyHP, op = LT_, number_ = 50 }) )
        , ( "op: my AP >= 3", "my AP >= 3", Just (Operator { value = MyAP, op = GTE, number_ = 3 }) )
        , ( "and"
          , "(my HP < 50 and my AP >= 3)"
          , Just
                (And
                    (Operator { value = MyHP, op = LT_, number_ = 50 })
                    (Operator { value = MyAP, op = GTE, number_ = 3 })
                )
          )
        , ( "or"
          , "(my HP < 50 or my AP >= 3)"
          , Just
                (Or
                    (Operator { value = MyHP, op = LT_, number_ = 50 })
                    (Operator { value = MyAP, op = GTE, number_ = 3 })
                )
          )
        , ( "or of ands"
          , "((my HP < 50 and my AP >= 3) or (my HP > 50 and my AP == 4))"
          , Just
                (Or
                    (And
                        (Operator { value = MyHP, op = LT_, number_ = 50 })
                        (Operator { value = MyAP, op = GTE, number_ = 3 })
                    )
                    (And
                        (Operator { value = MyHP, op = GT_, number_ = 50 })
                        (Operator { value = MyAP, op = EQ_, number_ = 4 })
                    )
                )
          )
        , ( "and of ors"
          , "((my HP < 50 or my AP >= 3) and (my HP > 50 or my AP == 4))"
          , Just
                (And
                    (Or
                        (Operator { value = MyHP, op = LT_, number_ = 50 })
                        (Operator { value = MyAP, op = GTE, number_ = 3 })
                    )
                    (Or
                        (Operator { value = MyHP, op = GT_, number_ = 50 })
                        (Operator { value = MyAP, op = EQ_, number_ = 4 })
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
                    { condition = Operator { value = MyHP, op = LT_, number_ = 10 }
                    , then_ = Command (Heal Fruit)
                    , else_ = Command DoWhatever
                    }
                )
          )
        , ( "nested if"
          , """
            if my HP < 10 then heal (Fruit) else
            if used Fruit > 200 then heal (Stimpak) else
            attack randomly
            """
                |> multilineInput
          , Just
                (If
                    { condition = Operator { value = MyHP, op = LT_, number_ = 10 }
                    , then_ = Command (Heal Fruit)
                    , else_ =
                        If
                            { condition = Operator { value = ItemsUsed Fruit, op = GT_, number_ = 200 }
                            , then_ = Command (Heal Stimpak)
                            , else_ = Command AttackRandomly
                            }
                    }
                )
          )
        ]
