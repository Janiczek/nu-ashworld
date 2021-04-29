module Evergreen.V75.Data.Fight.Generator exposing (..)

import Evergreen.V75.Data.Fight
import Evergreen.V75.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V75.Data.Fight.Opponent
    , finalTarget : Evergreen.V75.Data.Fight.Opponent
    , fightInfo : Evergreen.V75.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V75.Data.Message.Message
    }
