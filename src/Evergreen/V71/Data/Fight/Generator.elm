module Evergreen.V71.Data.Fight.Generator exposing (..)

import Evergreen.V71.Data.Fight
import Evergreen.V71.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V71.Data.Fight.Opponent
    , finalTarget : Evergreen.V71.Data.Fight.Opponent
    , fightInfo : Evergreen.V71.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V71.Data.Message.Message
    }
