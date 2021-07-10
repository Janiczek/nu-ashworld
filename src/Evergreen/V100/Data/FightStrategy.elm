module Evergreen.V100.Data.FightStrategy exposing (..)

import Evergreen.V100.Data.Fight.ShotType
import Evergreen.V100.Data.Item


type Operator
    = LT_
    | LTE
    | EQ_
    | NE
    | GTE
    | GT_


type Value
    = MyHP
    | MyAP
    | MyItemCount Evergreen.V100.Data.Item.Kind
    | ItemsUsed Evergreen.V100.Data.Item.Kind
    | TheirLevel
    | ChanceToHit Evergreen.V100.Data.Fight.ShotType.ShotType
    | Distance


type alias OperatorData =
    { op : Operator
    , value : Value
    , number_ : Float
    }


type Condition
    = Or Condition Condition
    | And Condition Condition
    | Not Condition
    | Operator OperatorData


type alias IfData =
    { condition : Condition
    , then_ : FightStrategy
    , else_ : FightStrategy
    }


type Command
    = Attack Evergreen.V100.Data.Fight.ShotType.ShotType
    | AttackRandomly
    | Heal Evergreen.V100.Data.Item.Kind
    | MoveForward
    | DoWhatever


type FightStrategy
    = If IfData
    | Command Command
