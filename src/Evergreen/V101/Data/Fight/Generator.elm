module Evergreen.V101.Data.Fight.Generator exposing (..)

import Evergreen.V101.Data.Fight
import Evergreen.V101.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V101.Data.Fight.Opponent
    , finalTarget : Evergreen.V101.Data.Fight.Opponent
    , fightInfo : Evergreen.V101.Data.Fight.Info
    , messageForTarget : Evergreen.V101.Data.Message.Message
    , messageForAttacker : Evergreen.V101.Data.Message.Message
    }
