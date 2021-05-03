module Evergreen.V83.Data.Fight.Generator exposing (..)

import Evergreen.V83.Data.Fight
import Evergreen.V83.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V83.Data.Fight.Opponent
    , finalTarget : Evergreen.V83.Data.Fight.Opponent
    , fightInfo : Evergreen.V83.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V83.Data.Message.Message
    }
