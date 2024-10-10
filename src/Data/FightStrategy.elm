module Data.FightStrategy exposing
    ( Command(..)
    , Condition(..)
    , FightStrategy(..)
    , IfData
    , Operator(..)
    , OperatorData
    , ValidationWarning(..)
    , Value(..)
    , decoder
    , doWhatever
    , encode
    , toString
    , warnings
    )

import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.Item as Item
import Data.Trait as Trait exposing (Trait)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import SeqSet exposing (SeqSet)


type FightStrategy
    = If IfData
    | Command Command


type alias IfData =
    { condition : Condition
    , then_ : FightStrategy
    , else_ : FightStrategy
    }


type Operator
    = LT_
    | LTE
    | EQ_
    | NE
    | GTE
    | GT_


type Condition
    = Or Condition Condition
    | And Condition Condition
    | Operator OperatorData
    | OpponentIsPlayer
    | OpponentIsNPC


type alias OperatorData =
    { lhs : Value
    , op : Operator
    , rhs : Value
    }


type Value
    = MyHP
    | MyMaxHP
    | MyAP
    | MyItemCount Item.Kind
    | MyHealingItemCount
    | ItemsUsed Item.Kind
    | HealingItemsUsed
    | ChanceToHit AttackStyle
    | RangeNeeded AttackStyle
    | Distance
    | Number Int


type Command
    = Attack AttackStyle
    | AttackRandomly
    | Heal Item.Kind
    | HealWithAnything
    | MoveForward
    | DoWhatever
    | SkipTurn


indent : String -> String
indent string =
    string
        |> String.lines
        |> List.map (\s -> "  " ++ s)
        |> String.join "\n"


toString : FightStrategy -> String
toString strategy =
    case strategy of
        If { condition, then_, else_ } ->
            "if "
                ++ conditionToString condition
                ++ " then\n"
                ++ indent (toString then_)
                ++ "\n\nelse\n"
                ++ indent (toString else_)

        Command command ->
            case command of
                Attack attackStyle ->
                    "attack (" ++ AttackStyle.toString attackStyle ++ ")"

                AttackRandomly ->
                    "attack randomly"

                Heal itemKind ->
                    "heal (" ++ Item.name itemKind ++ ")"

                HealWithAnything ->
                    "heal with anything"

                MoveForward ->
                    "move forward"

                DoWhatever ->
                    "do whatever"

                SkipTurn ->
                    "skip turn"


conditionToString : Condition -> String
conditionToString condition =
    case condition of
        Or c1 c2 ->
            "("
                ++ conditionToString c1
                ++ " or "
                ++ conditionToString c2
                ++ ")"

        And c1 c2 ->
            "("
                ++ conditionToString c1
                ++ " and "
                ++ conditionToString c2
                ++ ")"

        OpponentIsPlayer ->
            "opponent is player"

        OpponentIsNPC ->
            "opponent is NPC"

        Operator { lhs, op, rhs } ->
            valueToString lhs
                ++ " "
                ++ operatorToString op
                ++ " "
                ++ valueToString rhs


valueToString : Value -> String
valueToString value =
    case value of
        MyHP ->
            "my HP"

        MyMaxHP ->
            "my max HP"

        MyAP ->
            "my AP"

        MyItemCount kind ->
            "number of available "
                ++ Item.name kind

        MyHealingItemCount ->
            "number of available healing items"

        ItemsUsed kind ->
            "number of used "
                ++ Item.name kind

        HealingItemsUsed ->
            "number of used healing items"

        ChanceToHit attackStyle ->
            "chance to hit ("
                ++ AttackStyle.toString attackStyle
                ++ ")"

        RangeNeeded attackStyle ->
            "range needed ("
                ++ AttackStyle.toString attackStyle
                ++ ")"

        Distance ->
            "distance"

        Number n ->
            String.fromInt n


operatorToString : Operator -> String
operatorToString operator =
    case operator of
        LT_ ->
            "<"

        LTE ->
            "<="

        EQ_ ->
            "=="

        NE ->
            "!="

        GTE ->
            ">="

        GT_ ->
            ">"


encode : FightStrategy -> JE.Value
encode strategy =
    case strategy of
        If { condition, then_, else_ } ->
            JE.object
                [ ( "type", JE.string "If" )
                , ( "condition", encodeCondition condition )
                , ( "then", encode then_ )
                , ( "else", encode else_ )
                ]

        Command command ->
            JE.object
                [ ( "type", JE.string "Command" )
                , ( "command", encodeCommand command )
                ]


encodeCommand : Command -> JE.Value
encodeCommand command =
    case command of
        Attack attackStyle ->
            JE.object
                [ ( "type", JE.string "Attack" )
                , ( "attackStyle", AttackStyle.encode attackStyle )
                ]

        AttackRandomly ->
            JE.object
                [ ( "type", JE.string "AttackRandomly" )
                ]

        Heal itemKind ->
            JE.object
                [ ( "type", JE.string "Heal" )
                , ( "itemKind", Item.encodeKind itemKind )
                ]

        HealWithAnything ->
            JE.object
                [ ( "type", JE.string "HealWithAnything" )
                ]

        MoveForward ->
            JE.object
                [ ( "type", JE.string "MoveForward" )
                ]

        DoWhatever ->
            JE.object
                [ ( "type", JE.string "DoWhatever" )
                ]

        SkipTurn ->
            JE.object
                [ ( "type", JE.string "SkipTurn" )
                ]


encodeCondition : Condition -> JE.Value
encodeCondition condition =
    case condition of
        Or c1 c2 ->
            JE.object
                [ ( "type", JE.string "Or" )
                , ( "c1", encodeCondition c1 )
                , ( "c2", encodeCondition c2 )
                ]

        And c1 c2 ->
            JE.object
                [ ( "type", JE.string "And" )
                , ( "c1", encodeCondition c1 )
                , ( "c2", encodeCondition c2 )
                ]

        OpponentIsPlayer ->
            JE.object
                [ ( "type", JE.string "OpponentIsPlayer" )
                ]

        OpponentIsNPC ->
            JE.object
                [ ( "type", JE.string "OpponentIsNPC" )
                ]

        Operator { lhs, op, rhs } ->
            JE.object
                [ ( "type", JE.string "Operator" )
                , ( "operator", encodeOperator op )
                , ( "lhs", encodeValue lhs )
                , ( "rhs", encodeValue rhs )
                ]


encodeOperator : Operator -> JE.Value
encodeOperator op =
    JE.string <|
        case op of
            LT_ ->
                "LT_"

            LTE ->
                "LTE"

            EQ_ ->
                "EQ_"

            NE ->
                "NE"

            GTE ->
                "GTE"

            GT_ ->
                "GT_"


encodeValue : Value -> JE.Value
encodeValue value =
    case value of
        MyHP ->
            JE.object
                [ ( "type", JE.string "MyHP" )
                ]

        MyMaxHP ->
            JE.object
                [ ( "type", JE.string "MyMaxHP" )
                ]

        MyAP ->
            JE.object
                [ ( "type", JE.string "MyAP" )
                ]

        MyItemCount itemKind ->
            JE.object
                [ ( "type", JE.string "MyItemCount" )
                , ( "item", Item.encodeKind itemKind )
                ]

        MyHealingItemCount ->
            JE.object
                [ ( "type", JE.string "MyHealingItemCount" )
                ]

        ItemsUsed itemKind ->
            JE.object
                [ ( "type", JE.string "ItemsUsed" )
                , ( "item", Item.encodeKind itemKind )
                ]

        HealingItemsUsed ->
            JE.object
                [ ( "type", JE.string "HealingItemsUsed" )
                ]

        ChanceToHit attackStyle ->
            JE.object
                [ ( "type", JE.string "ChanceToHit" )
                , ( "attackStyle", AttackStyle.encode attackStyle )
                ]

        RangeNeeded attackStyle ->
            JE.object
                [ ( "type", JE.string "RangeNeeded" )
                , ( "attackStyle", AttackStyle.encode attackStyle )
                ]

        Distance ->
            JE.object
                [ ( "type", JE.string "Distance" )
                ]

        Number n ->
            JE.object
                [ ( "type", JE.string "Number" )
                , ( "value", JE.int n )
                ]


decoder : Decoder FightStrategy
decoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "If" ->
                        JD.succeed IfData
                            |> JD.andMap (JD.field "condition" conditionDecoder)
                            |> JD.andMap (JD.field "then" decoder)
                            |> JD.andMap (JD.field "else" decoder)
                            |> JD.map If

                    "Command" ->
                        JD.succeed Command
                            |> JD.andMap (JD.field "command" commandDecoder)

                    _ ->
                        JD.fail <| "Unknown FightStrategy type: " ++ type_
            )


conditionDecoder : Decoder Condition
conditionDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "Or" ->
                        JD.succeed Or
                            |> JD.andMap (JD.field "c1" conditionDecoder)
                            |> JD.andMap (JD.field "c2" conditionDecoder)

                    "And" ->
                        JD.succeed And
                            |> JD.andMap (JD.field "c1" conditionDecoder)
                            |> JD.andMap (JD.field "c2" conditionDecoder)

                    "OpponentIsPlayer" ->
                        JD.succeed OpponentIsPlayer

                    "OpponentIsNPC" ->
                        JD.succeed OpponentIsNPC

                    "Operator" ->
                        JD.succeed OperatorData
                            |> JD.andMap (JD.field "lhs" valueDecoder)
                            |> JD.andMap (JD.field "operator" operatorDecoder)
                            |> JD.andMap (JD.field "rhs" valueDecoder)
                            |> JD.map Operator

                    _ ->
                        JD.fail <| "Unknown Condition type: " ++ type_
            )


valueDecoder : Decoder Value
valueDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "MyHP" ->
                        JD.succeed MyHP

                    "MyMaxHP" ->
                        JD.succeed MyMaxHP

                    "MyAP" ->
                        JD.succeed MyAP

                    "MyItemCount" ->
                        JD.succeed MyItemCount
                            |> JD.andMap (JD.field "item" Item.kindDecoder)

                    "MyHealingItemCount" ->
                        JD.succeed MyHealingItemCount

                    "ItemsUsed" ->
                        JD.succeed ItemsUsed
                            |> JD.andMap (JD.field "item" Item.kindDecoder)

                    "HealingItemsUsed" ->
                        JD.succeed HealingItemsUsed

                    "ChanceToHit" ->
                        JD.succeed ChanceToHit
                            |> JD.andMap (JD.field "attackStyle" AttackStyle.decoder)

                    "RangeNeeded" ->
                        JD.succeed RangeNeeded
                            |> JD.andMap (JD.field "attackStyle" AttackStyle.decoder)

                    "Distance" ->
                        JD.succeed Distance

                    "Number" ->
                        JD.map Number JD.int

                    _ ->
                        JD.fail <| "Unknown Value type: " ++ type_
            )


commandDecoder : Decoder Command
commandDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "Attack" ->
                        JD.succeed Attack
                            |> JD.andMap (JD.field "attackStyle" AttackStyle.decoder)

                    "AttackRandomly" ->
                        JD.succeed AttackRandomly

                    "Heal" ->
                        JD.succeed Heal
                            |> JD.andMap (JD.field "itemKind" Item.kindDecoder)

                    "HealWithAnything" ->
                        JD.succeed HealWithAnything

                    "MoveForward" ->
                        JD.succeed MoveForward

                    "DoWhatever" ->
                        JD.succeed DoWhatever

                    "SkipTurn" ->
                        JD.succeed SkipTurn

                    _ ->
                        JD.fail <| "Unknown Command type: " ++ type_
            )


operatorDecoder : Decoder Operator
operatorDecoder =
    JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "LT_" ->
                        JD.succeed LT_

                    "LTE" ->
                        JD.succeed LTE

                    "EQ_" ->
                        JD.succeed EQ_

                    "NE" ->
                        JD.succeed NE

                    "GTE" ->
                        JD.succeed GTE

                    "GT_" ->
                        JD.succeed GT_

                    _ ->
                        JD.fail <| "Unknown Operator type: " ++ type_
            )


doWhatever : FightStrategy
doWhatever =
    If
        { condition = Operator { lhs = Distance, op = GT_, rhs = Number 1 }
        , then_ = Command MoveForward
        , else_ = Command AttackRandomly
        }


type ValidationWarning
    = ItemDoesntHeal Item.Kind
    | YouCantUseAimedShots


warnings : SeqSet Trait -> FightStrategy -> List ValidationWarning
warnings traits strategy =
    List.concat
        [ healingWithNonHealingItemsWarnings strategy
        , youCantUseAimedShots traits strategy
        ]


youCantUseAimedShots : SeqSet Trait -> FightStrategy -> List ValidationWarning
youCantUseAimedShots traits strategy =
    if
        SeqSet.member Trait.FastShot traits
            && anyCommand isAimedCommand strategy
    then
        [ YouCantUseAimedShots ]

    else
        []


healingWithNonHealingItemsWarnings : FightStrategy -> List ValidationWarning
healingWithNonHealingItemsWarnings strategy =
    strategy
        |> extractItemsUsedForHealing
        |> List.filter (not << Item.isHealing)
        |> List.map ItemDoesntHeal


anyCommand : (Command -> Bool) -> FightStrategy -> Bool
anyCommand predicate strategy =
    case strategy of
        If { then_, else_ } ->
            anyCommand predicate then_ || anyCommand predicate else_

        Command command ->
            predicate command


isAimedCommand : Command -> Bool
isAimedCommand command =
    case command of
        Attack attackStyle ->
            AttackStyle.isAimed attackStyle

        AttackRandomly ->
            False

        Heal _ ->
            False

        HealWithAnything ->
            False

        MoveForward ->
            False

        DoWhatever ->
            False

        SkipTurn ->
            False


extractItemsUsedForHealing : FightStrategy -> List Item.Kind
extractItemsUsedForHealing strategy =
    let
        fromCommand : Command -> List Item.Kind
        fromCommand command =
            case command of
                Attack _ ->
                    []

                AttackRandomly ->
                    []

                Heal kind ->
                    [ kind ]

                HealWithAnything ->
                    []

                MoveForward ->
                    []

                DoWhatever ->
                    []

                SkipTurn ->
                    []

        fromCondition : Condition -> List Item.Kind
        fromCondition condition =
            case condition of
                Or c1 c2 ->
                    fromCondition c1 ++ fromCondition c2

                And c1 c2 ->
                    fromCondition c1 ++ fromCondition c2

                OpponentIsPlayer ->
                    []

                OpponentIsNPC ->
                    []

                Operator _ ->
                    []
    in
    case strategy of
        Command command ->
            fromCommand command

        If { condition, then_, else_ } ->
            fromCondition condition
                ++ extractItemsUsedForHealing then_
                ++ extractItemsUsedForHealing else_
