module Evergreen.V77.Data.Fight.Generator exposing (..)

import Evergreen.V77.Data.Fight
import Evergreen.V77.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V77.Data.Fight.Opponent
    , finalTarget : Evergreen.V77.Data.Fight.Opponent
    , fightInfo : Evergreen.V77.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V77.Data.Message.Message
    }
