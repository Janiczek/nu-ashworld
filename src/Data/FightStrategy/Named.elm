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
import Dict exposing (Dict)


all : List ( String, FightStrategy )
all =
    [ default
    , conservative
    , yolo
    ]


default : ( String, FightStrategy )
default =
    ( "Default"
    , Command DoWhatever
    )


conservative : ( String, FightStrategy )
conservative =
    ( "Conservative"
    , If
        { condition = Operator { value = Distance, op = GT_, number_ = 0 }
        , then_ = Command MoveForward
        , else_ =
            If
                { condition =
                    And
                        (Operator { value = MyHP, op = LT_, number_ = 80 })
                        (Operator { value = ItemsUsed Stimpak, op = LT_, number_ = 10 })
                , then_ = Command (Heal Stimpak)
                , else_ = Command (Attack (AimedShot Eyes))
                }
        }
    )


yolo : ( String, FightStrategy )
yolo =
    ( "YOLO"
    , If
        { condition = Operator { value = Distance, op = GT_, number_ = 0 }
        , then_ = Command MoveForward
        , else_ =
            If
                { condition = Operator { value = MyHP, op = LT_, number_ = 80 }
                , then_ = Command (Heal Stimpak)
                , else_ = Command (Attack (AimedShot Eyes))
                }
        }
    )
