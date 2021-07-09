module Data.FightStrategy.Named exposing
    ( NamedStrategy
    , all
    , default
    , mjaniczek
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
    , mjaniczek
    ]


default : NamedStrategy
default =
    { name = "Default"
    , strategy = Command DoWhatever
    }


mjaniczek : NamedStrategy
mjaniczek =
    { name = "Somewhat intelligent"
    , strategy =
        If
            { condition = Operator { value = Distance, op = GT_, number_ = 0 }
            , then_ = Command MoveForward
            , else_ =
                If
                    { condition =
                        And
                            (Operator { value = MyHP, op = LT_, number_ = 40 })
                            (Operator { value = ItemsUsed Stimpak, op = LT_, number_ = 10 })
                    , then_ = Command (Heal Stimpak)
                    , else_ =
                        If
                            { condition =
                                And
                                    (Operator { value = MyAP, op = GTE, number_ = 3 })
                                    (Operator { value = ChanceToHit (AimedShot Eyes), op = GTE, number_ = 80 })
                            , then_ = Command (Attack (AimedShot Eyes))
                            , else_ = Command (Attack NormalShot)
                            }
                    }
            }
    }
