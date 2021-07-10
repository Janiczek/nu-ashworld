module Data.FightStrategy.Named exposing
    ( NamedStrategy
    , all
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


type alias NamedStrategy =
    { name : String
    , strategy : FightStrategy
    }


all : List NamedStrategy
all =
    [ default
    , conservative
    , yolo
    ]


default : NamedStrategy
default =
    { name = "Default"
    , strategy = Command DoWhatever
    }


conservative : NamedStrategy
conservative =
    { name = "Conservative about Stimpaks"
    , strategy =
        If
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
    }


yolo : NamedStrategy
yolo =
    { name = "YOLO about Stimpaks"
    , strategy =
        If
            { condition = Operator { value = Distance, op = GT_, number_ = 0 }
            , then_ = Command MoveForward
            , else_ =
                If
                    { condition = Operator { value = MyHP, op = LT_, number_ = 500 }
                    , then_ = Command (Heal Stimpak)
                    , else_ = Command (Attack (AimedShot Eyes))
                    }
            }
    }
