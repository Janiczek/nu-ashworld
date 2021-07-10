module Data.FightStrategy.Parser exposing
    ( command
    , condition
    , fightStrategy
    , ifData
    , operator
    , parse
    , shotType
    , value
    )

import Data.Fight.ShotType
    exposing
        ( AimedShot(..)
        , ShotType(..)
        )
import Data.FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , IfData
        , Operator(..)
        , OperatorData
        , Value(..)
        )
import Data.Item as Item
import Parser as P exposing ((|.), (|=), Parser)


parse : String -> Result (List P.DeadEnd) FightStrategy
parse string =
    P.run fightStrategy string


fightStrategy : Parser FightStrategy
fightStrategy =
    P.oneOf
        [ P.map If ifData
        , P.map Command command
        ]


ifData : Parser IfData
ifData =
    P.succeed IfData
        |. P.keyword "if"
        |. P.spaces
        |= condition
        |. P.spaces
        |. P.keyword "then"
        |. P.spaces
        |= P.lazy (\_ -> fightStrategy)
        |. P.spaces
        |. P.keyword "else"
        |. P.spaces
        |= P.lazy (\_ -> fightStrategy)


command : Parser Command
command =
    P.oneOf
        [ P.map (\_ -> AttackRandomly) (P.keyword "attack randomly")
        , attack
        , heal
        , P.map (\_ -> MoveForward) (P.keyword "move forward")
        , P.map (\_ -> DoWhatever) (P.keyword "do whatever")
        ]


attack : Parser Command
attack =
    P.succeed Attack
        |. P.keyword "attack"
        |. P.token " ("
        |= shotType
        |. P.token ")"


shotType : Parser ShotType
shotType =
    P.oneOf
        [ P.map (\_ -> NormalShot) (P.keyword "unaimed")
        , P.map AimedShot <|
            P.oneOf
                [ P.map (\_ -> Head) (P.keyword "head")
                , P.map (\_ -> Torso) (P.keyword "torso")
                , P.map (\_ -> Eyes) (P.keyword "eyes")
                , P.map (\_ -> Groin) (P.keyword "groin")
                , P.map (\_ -> LeftArm) (P.keyword "left arm")
                , P.map (\_ -> RightArm) (P.keyword "right arm")
                , P.map (\_ -> LeftLeg) (P.keyword "left leg")
                , P.map (\_ -> RightLeg) (P.keyword "right leg")
                ]
        ]


heal : Parser Command
heal =
    P.succeed Heal
        |. P.keyword "heal"
        |. P.token " ("
        |= healingItemKind
        |. P.token ")"


healingItemKind : Parser Item.Kind
healingItemKind =
    Item.allHealing
        |> List.map (\kind -> P.map (\_ -> kind) (P.keyword (Item.name kind)))
        |> P.oneOf


condition : Parser Condition
condition =
    P.oneOf
        [ binary
        , operatorCondition
        ]


binary : Parser Condition
binary =
    P.succeed (\c1 op c2 -> op c1 c2)
        |. P.token "("
        |= P.lazy (\_ -> condition)
        |. P.token " "
        |= P.oneOf
            [ P.map (\_ -> Or) (P.keyword "or")
            , P.map (\_ -> And) (P.keyword "and")
            ]
        |. P.token " "
        |= P.lazy (\_ -> condition)
        |. P.token ")"


operatorCondition : Parser Condition
operatorCondition =
    P.succeed OperatorData
        |= value
        |. P.token " "
        |= operator
        |. P.token " "
        |= possiblyNegativeInt
        |> P.map Operator


possiblyNegativeInt : Parser Int
possiblyNegativeInt =
    P.oneOf
        [ P.succeed negate
            |. P.symbol "-"
            |= P.int
        , P.int
        ]


operator : Parser Operator
operator =
    P.oneOf
        [ P.map (\_ -> LTE) (P.symbol "<=")
        , P.map (\_ -> LT_) (P.symbol "<")
        , P.map (\_ -> NE) (P.symbol "!=")
        , P.map (\_ -> EQ_) (P.symbol "==")
        , P.map (\_ -> GTE) (P.symbol ">=")
        , P.map (\_ -> GT_) (P.symbol ">")
        ]


value : Parser Value
value =
    P.oneOf
        [ P.map (\_ -> MyHP) (P.keyword "my HP")
        , P.map (\_ -> MyAP) (P.keyword "my AP")
        , itemCount
        , itemsUsed
        , P.map (\_ -> TheirLevel) (P.keyword "opponent's level")
        , chanceToHit
        , P.map (\_ -> Distance) (P.keyword "distance")
        ]


itemCount : Parser Value
itemCount =
    P.succeed MyItemCount
        |= healingItemKind
        |. P.token " "
        |. P.keyword "in inventory"


itemsUsed : Parser Value
itemsUsed =
    P.succeed ItemsUsed
        |. P.keyword "used"
        |. P.token " "
        |= healingItemKind


chanceToHit : Parser Value
chanceToHit =
    P.succeed ChanceToHit
        |. P.keyword "chance to hit"
        |. P.token " ("
        |= shotType
        |. P.token ")"
