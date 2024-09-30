module Data.FightStrategy.Parser exposing
    ( command
    , condition
    , fightStrategy
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
    P.run parser string


parser : Parser FightStrategy
parser =
    P.succeed identity
        |= fightStrategy
        |. P.spaces
        |. P.end


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
        |. nonemptySpaces
        |= condition
        |. nonemptySpaces
        |. P.keyword "then"
        |. nonemptySpaces
        |= P.lazy (\_ -> fightStrategy)
        |. nonemptySpaces
        |. P.keyword "else"
        |. nonemptySpaces
        |= P.lazy (\_ -> fightStrategy)


command : Parser Command
command =
    P.oneOf
        [ P.map (\_ -> AttackRandomly) (P.keyword "attack randomly")
        , attack
        , heal
        , P.map (\_ -> MoveForward) (P.keyword "move forward")
        , P.map (\_ -> DoWhatever) (P.keyword "do whatever")
        , P.map (\_ -> SkipTurn) (P.keyword "skip turn")
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
        |= itemKind
        |. P.token ")"


itemKind : Parser Item.Kind
itemKind =
    Item.all
        |> List.map (\kind -> P.map (\_ -> kind) (P.keyword (Item.name kind)))
        |> P.oneOf


condition : Parser Condition
condition =
    P.oneOf
        [ binary
        , P.map (\_ -> OpponentIsPlayer) (P.keyword "opponent is player")
        , P.map (\_ -> OpponentIsNPC) (P.keyword "opponent is NPC")
        , operatorCondition
        ]


binary : Parser Condition
binary =
    P.succeed (\c1 op c2 -> op c1 c2)
        |. P.token "("
        |. P.spaces
        |= P.lazy (\_ -> condition)
        |. nonemptySpaces
        |= P.oneOf
            [ P.map (\_ -> Or) (P.keyword "or")
            , P.map (\_ -> And) (P.keyword "and")
            ]
        |. nonemptySpaces
        |= P.lazy (\_ -> condition)
        |. P.spaces
        |. P.token ")"


operatorCondition : Parser Condition
operatorCondition =
    P.succeed OperatorData
        |= value
        |. P.spaces
        |= operator
        |. P.spaces
        |= value
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
        , P.map (\_ -> MyMaxHP) (P.keyword "my max HP")
        , P.map (\_ -> MyAP) (P.keyword "my AP")
        , itemCount
        , itemsUsed
        , chanceToHit
        , P.map (\_ -> Distance) (P.keyword "distance")
        , P.map Number possiblyNegativeInt
        ]


itemCount : Parser Value
itemCount =
    P.succeed MyItemCount
        |. P.keyword "number of available"
        |. nonemptySpaces
        |= itemKind


itemsUsed : Parser Value
itemsUsed =
    P.succeed ItemsUsed
        |. P.keyword "number of used"
        |. nonemptySpaces
        |= itemKind


chanceToHit : Parser Value
chanceToHit =
    P.succeed ChanceToHit
        |. P.keyword "chance to hit"
        |. P.token " ("
        |= shotType
        |. P.token ")"


nonemptySpaces : Parser ()
nonemptySpaces =
    P.succeed ()
        |. singleNonemptySpace
        |. P.spaces


singleNonemptySpace : Parser ()
singleNonemptySpace =
    P.chompIf (\c -> c == ' ' || c == '\t' || c == '\n')
        |> P.getChompedString
        |> P.andThen
            (\string ->
                if String.isEmpty string then
                    P.problem "empty whitespace"

                else
                    P.succeed ()
            )
