module Data.FightStrategy exposing
    ( Command(..)
    , Condition(..)
    , FightStrategy(..)
    , Operator(..)
    , Value(..)
    , decoder
    , doWhatever
    , encode
    , toString
    )

import Data.Fight.ShotType as ShotType exposing (AimedShot(..), ShotType(..))
import Data.Item as Item
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE


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
    = True_
    | False_
    | Or Condition Condition
    | And Condition Condition
    | Not Condition
    | Operator OperatorData


type alias OperatorData =
    { op : Operator
    , value : Value
    , number_ : Float
    }


type Value
    = MyHP
    | MyAP
    | MyItemCount Item.Kind
    | ItemsUsed Item.Kind
    | TheirLevel
    | ChanceToHit ShotType
    | Distance


type Command
    = Attack ShotType
    | AttackRandomly
    | Heal Item.Kind
    | MoveForward
    | DoWhatever


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
                ++ "\nelse\n"
                ++ indent (toString else_)

        Command command ->
            case command of
                Attack shotType ->
                    "attack (" ++ shotTypeToString shotType ++ ")"

                AttackRandomly ->
                    "attack randomly"

                Heal itemKind ->
                    "heal (" ++ Item.name itemKind ++ ")"

                MoveForward ->
                    "move forward"

                DoWhatever ->
                    "do whatever:\n\n" ++ toString doWhatever


conditionToString : Condition -> String
conditionToString condition =
    case condition of
        True_ ->
            "true"

        False_ ->
            "false"

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

        Not c ->
            "not " ++ conditionToString c

        Operator { op, value, number_ } ->
            valueToString value
                ++ " "
                ++ operatorToString op
                ++ " "
                ++ String.fromFloat number_


valueToString : Value -> String
valueToString value =
    case value of
        MyHP ->
            "my HP"

        MyAP ->
            "my AP"

        MyItemCount kind ->
            Item.name kind
                ++ " in inventory"

        ItemsUsed kind ->
            Item.name kind
                ++ " used in this fight"

        TheirLevel ->
            "opponent's level"

        ChanceToHit shotType ->
            "chance to hit ("
                ++ shotTypeToString shotType
                ++ ")"

        Distance ->
            "distance"


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


shotTypeToString : ShotType -> String
shotTypeToString shotType =
    case shotType of
        NormalShot ->
            "unaimed"

        AimedShot aimedShot ->
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
                    "left arm"

                RightArm ->
                    "right arm"

                LeftLeg ->
                    "left leg"

                RightLeg ->
                    "right leg"


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
        Attack shotType ->
            JE.object
                [ ( "type", JE.string "Attack" )
                , ( "shotType", ShotType.encode shotType )
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

        MoveForward ->
            JE.object
                [ ( "type", JE.string "MoveForward" )
                ]

        DoWhatever ->
            JE.object
                [ ( "type", JE.string "DoWhatever" )
                ]


encodeCondition : Condition -> JE.Value
encodeCondition condition =
    case condition of
        True_ ->
            JE.object
                [ ( "type", JE.string "True_" )
                ]

        False_ ->
            JE.object
                [ ( "type", JE.string "False_" )
                ]

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

        Not c ->
            JE.object
                [ ( "type", JE.string "Not" )
                , ( "c", encodeCondition c )
                ]

        Operator { op, value, number_ } ->
            JE.object
                [ ( "type", JE.string "Operator" )
                , ( "operator", encodeOperator op )
                , ( "value", encodeValue value )
                , ( "number", JE.float number_ )
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

        MyAP ->
            JE.object
                [ ( "type", JE.string "MyAP" )
                ]

        MyItemCount itemKind ->
            JE.object
                [ ( "type", JE.string "MyItemCount" )
                , ( "item", Item.encodeKind itemKind )
                ]

        ItemsUsed itemKind ->
            JE.object
                [ ( "type", JE.string "ItemsUsed" )
                , ( "item", Item.encodeKind itemKind )
                ]

        TheirLevel ->
            JE.object
                [ ( "type", JE.string "TheirLevel" )
                ]

        ChanceToHit shotType ->
            JE.object
                [ ( "type", JE.string "ChanceToHit" )
                , ( "shotType", ShotType.encode shotType )
                ]

        Distance ->
            JE.object
                [ ( "type", JE.string "Distance" )
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
                    "True_" ->
                        JD.succeed True_

                    "False_" ->
                        JD.succeed False_

                    "Or" ->
                        JD.succeed Or
                            |> JD.andMap (JD.field "c1" conditionDecoder)
                            |> JD.andMap (JD.field "c2" conditionDecoder)

                    "And" ->
                        JD.succeed And
                            |> JD.andMap (JD.field "c1" conditionDecoder)
                            |> JD.andMap (JD.field "c2" conditionDecoder)

                    "Not" ->
                        JD.map Not (JD.field "c" conditionDecoder)

                    "Operator" ->
                        JD.succeed OperatorData
                            |> JD.andMap (JD.field "operator" operatorDecoder)
                            |> JD.andMap (JD.field "value" valueDecoder)
                            |> JD.andMap (JD.field "number" JD.float)
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

                    "MyAP" ->
                        JD.succeed MyAP

                    "MyItemCount" ->
                        JD.succeed MyItemCount
                            |> JD.andMap (JD.field "item" Item.kindDecoder)

                    "ItemsUsed" ->
                        JD.succeed ItemsUsed
                            |> JD.andMap (JD.field "item" Item.kindDecoder)

                    "TheirLevel" ->
                        JD.succeed TheirLevel

                    "ChanceToHit" ->
                        JD.succeed ChanceToHit
                            |> JD.andMap (JD.field "shotType" ShotType.decoder)

                    "Distance" ->
                        JD.succeed Distance

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
                            |> JD.andMap (JD.field "shotType" ShotType.decoder)

                    "AttackRandomly" ->
                        JD.succeed AttackRandomly

                    "Heal" ->
                        JD.succeed Heal
                            |> JD.andMap (JD.field "itemKind" Item.kindDecoder)

                    "MoveForward" ->
                        JD.succeed MoveForward

                    "DoWhatever" ->
                        JD.succeed DoWhatever

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
        { condition = Operator { value = Distance, op = GT_, number_ = 0 }
        , then_ = Command MoveForward
        , else_ = Command AttackRandomly
        }
