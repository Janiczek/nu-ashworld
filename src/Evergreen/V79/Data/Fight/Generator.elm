module Evergreen.V79.Data.Fight.Generator exposing (..)

import Evergreen.V79.Data.Fight
import Evergreen.V79.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V79.Data.Fight.Opponent
    , finalTarget : Evergreen.V79.Data.Fight.Opponent
    , fightInfo : Evergreen.V79.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V79.Data.Message.Message
    }
