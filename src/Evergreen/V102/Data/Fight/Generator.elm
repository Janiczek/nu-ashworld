module Evergreen.V102.Data.Fight.Generator exposing (..)

import Evergreen.V102.Data.Fight
import Evergreen.V102.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V102.Data.Fight.Opponent
    , finalTarget : Evergreen.V102.Data.Fight.Opponent
    , fightInfo : Evergreen.V102.Data.Fight.Info
    , messageForTarget : Evergreen.V102.Data.Message.Message
    , messageForAttacker : Evergreen.V102.Data.Message.Message
    }
