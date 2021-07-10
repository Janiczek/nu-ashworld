module Evergreen.V100.Data.Fight.Generator exposing (..)

import Evergreen.V100.Data.Fight
import Evergreen.V100.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V100.Data.Fight.Opponent
    , finalTarget : Evergreen.V100.Data.Fight.Opponent
    , fightInfo : Evergreen.V100.Data.Fight.Info
    , messageForTarget : Evergreen.V100.Data.Message.Message
    , messageForAttacker : Evergreen.V100.Data.Message.Message
    }
