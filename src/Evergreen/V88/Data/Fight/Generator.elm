module Evergreen.V88.Data.Fight.Generator exposing (..)

import Evergreen.V88.Data.Fight
import Evergreen.V88.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V88.Data.Fight.Opponent
    , finalTarget : Evergreen.V88.Data.Fight.Opponent
    , fightInfo : Evergreen.V88.Data.Fight.Info
    , messageForTarget : Evergreen.V88.Data.Message.Message
    }
