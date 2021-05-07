module Evergreen.V85.Data.Fight.Generator exposing (..)

import Evergreen.V85.Data.Fight
import Evergreen.V85.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V85.Data.Fight.Opponent
    , finalTarget : Evergreen.V85.Data.Fight.Opponent
    , fightInfo : Evergreen.V85.Data.Fight.Info
    , messageForTarget : Evergreen.V85.Data.Message.Message
    }
