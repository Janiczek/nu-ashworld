module Data.FightStrategy.Named exposing
    ( all
    , custom
    , default
    , promoted
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


all : Dict String FightStrategy
all =
    Dict.fromList
        [ default
        , conservative
        , yolo
        ]


promoted : ( String, FightStrategy )
promoted =
    conservative


default : ( String, FightStrategy )
default =
    ( "1: Default"
    , Command DoWhatever
    )


conservative : ( String, FightStrategy )
conservative =
    ( "2: Conservative about Stimpaks"
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
    ( "3: YOLO about Stimpaks"
    , If
        { condition = Operator { value = Distance, op = GT_, number_ = 0 }
        , then_ = Command MoveForward
        , else_ =
            If
                { condition = Operator { value = MyHP, op = LT_, number_ = 500 }
                , then_ = Command (Heal Stimpak)
                , else_ = Command (Attack (AimedShot Eyes))
                }
        }
    )


custom : String
custom =
    "0: Custom"
