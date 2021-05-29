module Evergreen.V96.Data.Fight.Generator exposing (..)

import Evergreen.V96.Data.Fight
import Evergreen.V96.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V96.Data.Fight.Opponent
    , finalTarget : Evergreen.V96.Data.Fight.Opponent
    , fightInfo : Evergreen.V96.Data.Fight.Info
    , messageForTarget : Evergreen.V96.Data.Message.Message
    }
