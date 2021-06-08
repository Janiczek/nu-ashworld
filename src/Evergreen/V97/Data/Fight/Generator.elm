module Evergreen.V97.Data.Fight.Generator exposing (..)

import Evergreen.V97.Data.Fight
import Evergreen.V97.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V97.Data.Fight.Opponent
    , finalTarget : Evergreen.V97.Data.Fight.Opponent
    , fightInfo : Evergreen.V97.Data.Fight.Info
    , messageForTarget : Evergreen.V97.Data.Message.Message
    , messageForAttacker : Evergreen.V97.Data.Message.Message
    }
