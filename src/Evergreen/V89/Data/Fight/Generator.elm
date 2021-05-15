module Evergreen.V89.Data.Fight.Generator exposing (..)

import Evergreen.V89.Data.Fight
import Evergreen.V89.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V89.Data.Fight.Opponent
    , finalTarget : Evergreen.V89.Data.Fight.Opponent
    , fightInfo : Evergreen.V89.Data.Fight.Info
    , messageForTarget : Evergreen.V89.Data.Message.Message
    }
