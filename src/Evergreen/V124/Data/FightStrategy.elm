module Evergreen.V124.Data.FightStrategy exposing (..)

import Evergreen.V124.Data.Fight.AttackStyle
import Evergreen.V124.Data.Item.Kind


type Value
    = MyHP
    | MyMaxHP
    | MyAP
    | MyItemCount Evergreen.V124.Data.Item.Kind.Kind
    | MyHealingItemCount
    | MyAmmoCount
    | ItemsUsed Evergreen.V124.Data.Item.Kind.Kind
    | HealingItemsUsed
    | AmmoUsed
    | ChanceToHit Evergreen.V124.Data.Fight.AttackStyle.AttackStyle
    | RangeNeeded Evergreen.V124.Data.Fight.AttackStyle.AttackStyle
    | Distance
    | Number Int


type Operator
    = LT_
    | LTE
    | EQ_
    | NE
    | GTE
    | GT_


type alias OperatorData =
    { lhs : Value
    , op : Operator
    , rhs : Value
    }


type Condition
    = Or Condition Condition
    | And Condition Condition
    | Operator OperatorData
    | OpponentIsPlayer
    | OpponentIsNPC


type alias IfData =
    { condition : Condition
    , then_ : FightStrategy
    , else_ : FightStrategy
    }


type Command
    = Attack Evergreen.V124.Data.Fight.AttackStyle.AttackStyle
    | AttackRandomly
    | Heal Evergreen.V124.Data.Item.Kind.Kind
    | HealWithAnything
    | MoveForward
    | DoWhatever
    | SkipTurn


type FightStrategy
    = If IfData
    | Command Command
