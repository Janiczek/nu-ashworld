module Evergreen.V78.Data.Fight.Generator exposing (..)

import Evergreen.V78.Data.Fight
import Evergreen.V78.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V78.Data.Fight.Opponent
    , finalTarget : Evergreen.V78.Data.Fight.Opponent
    , fightInfo : Evergreen.V78.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V78.Data.Message.Message
    }
