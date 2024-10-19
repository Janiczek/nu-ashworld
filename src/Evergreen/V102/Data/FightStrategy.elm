module Evergreen.V102.Data.FightStrategy exposing (..)

import Evergreen.V102.Data.Fight.ShotType
import Evergreen.V102.Data.Item


type Value
    = MyHP
    | MyAP
    | MyItemCount Evergreen.V102.Data.Item.Kind
    | ItemsUsed Evergreen.V102.Data.Item.Kind
    | ChanceToHit Evergreen.V102.Data.Fight.ShotType.ShotType
    | Distance


type Operator
    = LT_
    | LTE
    | EQ_
    | NE
    | GTE
    | GT_


type alias OperatorData =
    { value : Value
    , op : Operator
    , number_ : Int
    }


type Condition
    = Or Condition Condition
    | And Condition Condition
    | Operator OperatorData
    | OpponentIsPlayer


type alias IfData =
    { condition : Condition
    , then_ : FightStrategy
    , else_ : FightStrategy
    }


type Command
    = Attack Evergreen.V102.Data.Fight.ShotType.ShotType
    | AttackRandomly
    | Heal Evergreen.V102.Data.Item.Kind
    | MoveForward
    | DoWhatever


type FightStrategy
    = If IfData
    | Command Command
