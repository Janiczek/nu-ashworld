module Data.FightStrategy.Named exposing
    ( all
    , default
    )

import Data.Fight.ShotType exposing (AimedShot(..), ShotType(..))
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
        { condition = Operator { lhs = Distance, op = GT_, rhs = Number 0 }
        , then_ = Command MoveForward
        , else_ =
            If
                { condition =
                    And
                        (Operator { lhs = MyHP, op = LT_, rhs = MyMaxHP })
                        (Operator { lhs = ItemsUsed Stimpak, op = LT_, rhs = Number 10 })
                , then_ = Command (Heal Stimpak)
                , else_ = Command (Attack (AimedShot Eyes))
                }
        }
    )
