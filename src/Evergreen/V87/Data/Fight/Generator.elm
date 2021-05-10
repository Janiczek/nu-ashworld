module Evergreen.V87.Data.Fight.Generator exposing (..)

import Evergreen.V87.Data.Fight
import Evergreen.V87.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V87.Data.Fight.Opponent
    , finalTarget : Evergreen.V87.Data.Fight.Opponent
    , fightInfo : Evergreen.V87.Data.Fight.Info
    , messageForTarget : Evergreen.V87.Data.Message.Message
    }
