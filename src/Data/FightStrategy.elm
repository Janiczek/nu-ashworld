module Data.FightStrategy exposing
    ( Command(..)
    , Condition(..)
    , FightStrategy(..)
    , IfData
    , Operator(..)
    , OperatorData
    , ValidationWarning(..)
    , Value(..)
    , codec
    , doWhatever
    , toString
    , warnings
    )

import Codec exposing (Codec)
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle)
import Data.Item.Kind as ItemKind
import Data.Trait as Trait exposing (Trait)
import List.ExtraExtra as List
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
    | MyLevel
    | TheirLevel
    | MyItemCount ItemKind.Kind
    | MyHealingItemCount
    | MyAmmoCount
    | ItemsUsed ItemKind.Kind
    | HealingItemsUsed
    | AmmoUsed
    | ChanceToHit AttackStyle
    | RangeNeeded AttackStyle
    | Distance
    | Number Int


type Command
    = Attack AttackStyle
    | AttackRandomly
    | Heal ItemKind.Kind
    | HealWithAnything
    | MoveForward
    | RunAway
    | DoWhatever
      -- Reload; note we promise in Laser Rifle Ext Cap that it is 2x as effective, we should make sure we do that.
    | SkipTurn


codec : Codec FightStrategy
codec =
    Codec.custom
        (\ifEncoder commandEncoder value ->
            case value of
                If arg0 ->
                    ifEncoder arg0

                Command arg0 ->
                    commandEncoder arg0
        )
        |> Codec.variant1 "If" If ifDataCodec
        |> Codec.variant1 "Command" Command commandCodec
        |> Codec.buildCustom


ifDataCodec : Codec IfData
ifDataCodec =
    Codec.object IfData
        |> Codec.field "condition" .condition conditionCodec
        |> Codec.field "then_" .then_ (Codec.lazy (\() -> codec))
        |> Codec.field "else_" .else_ (Codec.lazy (\() -> codec))
        |> Codec.buildObject


conditionCodec : Codec Condition
conditionCodec =
    Codec.custom
        (\orEncoder andEncoder operatorEncoder opponentIsPlayerEncoder opponentIsNPCEncoder value ->
            case value of
                Or arg0 arg1 ->
                    orEncoder arg0 arg1

                And arg0 arg1 ->
                    andEncoder arg0 arg1

                Operator arg0 ->
                    operatorEncoder arg0

                OpponentIsPlayer ->
                    opponentIsPlayerEncoder

                OpponentIsNPC ->
                    opponentIsNPCEncoder
        )
        |> Codec.variant2 "Or" Or (Codec.lazy (\() -> conditionCodec)) (Codec.lazy (\() -> conditionCodec))
        |> Codec.variant2 "And" And (Codec.lazy (\() -> conditionCodec)) (Codec.lazy (\() -> conditionCodec))
        |> Codec.variant1 "Operator" Operator operatorDataCodec
        |> Codec.variant0 "OpponentIsPlayer" OpponentIsPlayer
        |> Codec.variant0 "OpponentIsNPC" OpponentIsNPC
        |> Codec.buildCustom


operatorDataCodec : Codec OperatorData
operatorDataCodec =
    Codec.object OperatorData
        |> Codec.field "lhs" .lhs valueCodec
        |> Codec.field "op" .op operatorCodec
        |> Codec.field "rhs" .rhs valueCodec
        |> Codec.buildObject


valueCodec : Codec Value
valueCodec =
    Codec.custom
        (\myHPEncoder myMaxHPEncoder myAPEncoder myItemCountEncoder myHealingItemCountEncoder myAmmoCountEncoder itemsUsedEncoder healingItemsUsedEncoder ammoUsedEncoder chanceToHitEncoder rangeNeededEncoder distanceEncoder numberEncoder myLevelEncoder theirLevelEncoder value ->
            case value of
                MyHP ->
                    myHPEncoder

                MyMaxHP ->
                    myMaxHPEncoder

                MyAP ->
                    myAPEncoder

                MyLevel ->
                    myLevelEncoder

                TheirLevel ->
                    theirLevelEncoder

                MyItemCount arg0 ->
                    myItemCountEncoder arg0

                MyHealingItemCount ->
                    myHealingItemCountEncoder

                MyAmmoCount ->
                    myAmmoCountEncoder

                ItemsUsed arg0 ->
                    itemsUsedEncoder arg0

                HealingItemsUsed ->
                    healingItemsUsedEncoder

                AmmoUsed ->
                    ammoUsedEncoder

                ChanceToHit arg0 ->
                    chanceToHitEncoder arg0

                RangeNeeded arg0 ->
                    rangeNeededEncoder arg0

                Distance ->
                    distanceEncoder

                Number arg0 ->
                    numberEncoder arg0
        )
        |> Codec.variant0 "MyHP" MyHP
        |> Codec.variant0 "MyMaxHP" MyMaxHP
        |> Codec.variant0 "MyAP" MyAP
        |> Codec.variant1 "MyItemCount" MyItemCount ItemKind.codec
        |> Codec.variant0 "MyHealingItemCount" MyHealingItemCount
        |> Codec.variant0 "MyAmmoCount" MyAmmoCount
        |> Codec.variant1 "ItemsUsed" ItemsUsed ItemKind.codec
        |> Codec.variant0 "HealingItemsUsed" HealingItemsUsed
        |> Codec.variant0 "AmmoUsed" AmmoUsed
        |> Codec.variant1 "ChanceToHit" ChanceToHit AttackStyle.codec
        |> Codec.variant1 "RangeNeeded" RangeNeeded AttackStyle.codec
        |> Codec.variant0 "Distance" Distance
        |> Codec.variant1 "Number" Number Codec.int
        |> Codec.variant0 "MyLevel" MyLevel
        |> Codec.variant0 "TheirLevel" TheirLevel
        |> Codec.buildCustom


operatorCodec : Codec Operator
operatorCodec =
    Codec.enum Codec.string
        [ ( "LT_", LT_ )
        , ( "LTE", LTE )
        , ( "EQ_", EQ_ )
        , ( "NE", NE )
        , ( "GTE", GTE )
        , ( "GT_", GT_ )
        ]


commandCodec : Codec Command
commandCodec =
    Codec.custom
        (\attackEncoder attackRandomlyEncoder healEncoder healWithAnythingEncoder moveForwardEncoder runAwayEncoder doWhateverEncoder skipTurnEncoder value ->
            case value of
                Attack arg0 ->
                    attackEncoder arg0

                AttackRandomly ->
                    attackRandomlyEncoder

                Heal arg0 ->
                    healEncoder arg0

                HealWithAnything ->
                    healWithAnythingEncoder

                MoveForward ->
                    moveForwardEncoder

                RunAway ->
                    runAwayEncoder

                DoWhatever ->
                    doWhateverEncoder

                SkipTurn ->
                    skipTurnEncoder
        )
        |> Codec.variant1 "Attack" Attack AttackStyle.codec
        |> Codec.variant0 "AttackRandomly" AttackRandomly
        |> Codec.variant1 "Heal" Heal ItemKind.codec
        |> Codec.variant0 "HealWithAnything" HealWithAnything
        |> Codec.variant0 "MoveForward" MoveForward
        |> Codec.variant0 "RunAway" RunAway
        |> Codec.variant0 "DoWhatever" DoWhatever
        |> Codec.variant0 "SkipTurn" SkipTurn
        |> Codec.buildCustom


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
                    "heal (" ++ ItemKind.name itemKind ++ ")"

                HealWithAnything ->
                    "heal with anything"

                MoveForward ->
                    "move forward"

                RunAway ->
                    "run away"

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

        MyLevel ->
            "my level"

        TheirLevel ->
            "their level"

        MyItemCount kind ->
            "number of available "
                ++ ItemKind.name kind

        MyHealingItemCount ->
            "number of available healing items"

        MyAmmoCount ->
            "number of available ammo"

        ItemsUsed kind ->
            "number of used "
                ++ ItemKind.name kind

        HealingItemsUsed ->
            "number of used healing items"

        AmmoUsed ->
            "number of used ammo"

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


doWhatever : FightStrategy
doWhatever =
    If
        { condition = Operator { lhs = Distance, op = GT_, rhs = Number 1 }
        , then_ = Command MoveForward
        , else_ = Command AttackRandomly
        }


type ValidationWarning
    = ItemDoesntHeal ItemKind.Kind
    | YouCantUseAimedShots
    | MinDistanceIs1


warnings : SeqSet Trait -> FightStrategy -> List ValidationWarning
warnings traits strategy =
    List.fastConcat
        [ healingWithNonHealingItemsWarnings strategy
        , youCantUseAimedShots traits strategy
        , minDistanceIs1 strategy
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
        |> List.filter (not << ItemKind.isHealing)
        |> List.map ItemDoesntHeal


minDistanceIs1 : FightStrategy -> List ValidationWarning
minDistanceIs1 strategy =
    if anyCondition isInvalidDistanceCondition strategy then
        [ MinDistanceIs1 ]

    else
        []


isInvalidDistanceCondition : Condition -> Bool
isInvalidDistanceCondition condition =
    case condition of
        Operator { lhs, op, rhs } ->
            case ( lhs, rhs ) of
                ( Distance, Number n ) ->
                    case op of
                        LT_ ->
                            -- distance < 1: always false
                            -- distance < 2: not always
                            n <= 1

                        LTE ->
                            -- distance <= 0: always false
                            -- distance <= 1: not always
                            n <= 0

                        EQ_ ->
                            -- distance == 0: always false
                            -- distance == 1: not always
                            n <= 0

                        NE ->
                            -- distance /= 0: always true
                            -- distance /= 1: not always
                            n <= 0

                        GTE ->
                            -- distance >= 1: always true
                            -- distance >= 2: not always
                            n <= 1

                        GT_ ->
                            -- distance > 0: always true
                            -- distance > 1: not always
                            n <= 0

                ( Number n, Distance ) ->
                    case op of
                        GT_ ->
                            -- 0 > distance: always true
                            -- 1 > distance: not always
                            n <= 0

                        GTE ->
                            -- 1 >= distance: always true
                            -- 2 >= distance: not always
                            n <= 1

                        NE ->
                            -- 0 != distance: always true
                            -- 1 != distance: not always
                            n <= 0

                        EQ_ ->
                            -- 0 == distance: always false
                            -- 1 == distance: not always
                            n <= 0

                        LTE ->
                            -- 0 <= distance: always true
                            -- 1 <= distance: not always
                            n <= 0

                        LT_ ->
                            -- 1 < distance: always false
                            -- 2 < distance: not always
                            n <= 1

                _ ->
                    False

        Or c1 c2 ->
            isInvalidDistanceCondition c1 || isInvalidDistanceCondition c2

        And c1 c2 ->
            isInvalidDistanceCondition c1 || isInvalidDistanceCondition c2

        OpponentIsNPC ->
            False

        OpponentIsPlayer ->
            False


anyCommand : (Command -> Bool) -> FightStrategy -> Bool
anyCommand predicate strategy =
    case strategy of
        If { then_, else_ } ->
            anyCommand predicate then_ || anyCommand predicate else_

        Command command ->
            predicate command


anyCondition : (Condition -> Bool) -> FightStrategy -> Bool
anyCondition predicate strategy =
    case strategy of
        If { condition, then_, else_ } ->
            predicate condition || anyCondition predicate then_ || anyCondition predicate else_

        Command _ ->
            False


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

        RunAway ->
            False

        DoWhatever ->
            False

        SkipTurn ->
            False


extractItemsUsedForHealing : FightStrategy -> List ItemKind.Kind
extractItemsUsedForHealing strategy =
    let
        fromCommand : Command -> List ItemKind.Kind
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

                RunAway ->
                    []

                DoWhatever ->
                    []

                SkipTurn ->
                    []

        fromCondition : Condition -> List ItemKind.Kind
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
