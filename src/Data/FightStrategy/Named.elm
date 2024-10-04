module Data.FightStrategy.Named exposing
    ( all
    , default
    )

import Data.Fight.AttackStyle exposing (AttackStyle(..))
import Data.FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , Operator(..)
        , Value(..)
        )
import Data.Item exposing (Kind(..))


default : ( String, FightStrategy )
default =
    conservative


all : List ( String, FightStrategy )
all =
    [ dontCare
    , conservative
    ]


dontCare : ( String, FightStrategy )
dontCare =
    ( "Don't care"
    , Command DoWhatever
    )


conservative : ( String, FightStrategy )
conservative =
    ( "Conservative"
    , If
        { condition = Operator { lhs = Distance, op = GT_, rhs = Number 1 }
        , then_ = Command MoveForward
        , else_ =
            If
                { condition =
                    And
                        (Operator { lhs = MyHP, op = LT_, rhs = MyMaxHP })
                        (Operator { lhs = MyHealingItemCount, op = GT_, rhs = Number 0 })
                , then_ = Command HealWithAnything
                , else_ = Command (Attack UnarmedUnaimed)
                }
        }
    )
