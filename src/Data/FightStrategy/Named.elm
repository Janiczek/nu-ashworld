module Data.FightStrategy.Named exposing
    ( all
    , default
    , guideExample
    )

import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , Operator(..)
        , Value(..)
        )


default : ( String, FightStrategy )
default =
    conservative


all : List ( String, FightStrategy )
all =
    [ dontCare
    , conservative
    , smart
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


smart : ( String, FightStrategy )
smart =
    ( "Smart"
    , If
        { condition =
            And (Operator { lhs = MyAmmoCount, op = GT_, rhs = Number 0 })
                (Operator { lhs = ChanceToHit AttackStyle.ShootSingleUnaimed, op = GT_, rhs = Number 50 })
        , then_ = Command (Attack ShootSingleUnaimed)
        , else_ =
            If
                { condition = Operator { lhs = Distance, op = GT_, rhs = Number 1 }
                , then_ = Command MoveForward
                , else_ = Command (Attack UnarmedUnaimed)
                }
        }
    )


guideExample : FightStrategy
guideExample =
    If
        { condition = Operator { lhs = MyAmmoCount, op = GT_, rhs = Number 0 }
        , then_ = Command (Attack ShootSingleUnaimed)
        , else_ =
            If
                { condition = Operator { lhs = Distance, op = GT_, rhs = Number 1 }
                , then_ = Command MoveForward
                , else_ = Command (Attack UnarmedUnaimed)
                }
        }
