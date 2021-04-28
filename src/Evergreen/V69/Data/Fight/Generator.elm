module Evergreen.V69.Data.Fight.Generator exposing (..)

import Evergreen.V69.Data.Fight
import Evergreen.V69.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V69.Data.Fight.Opponent
    , finalTarget : Evergreen.V69.Data.Fight.Opponent
    , fightInfo : Evergreen.V69.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V69.Data.Message.Message
    }
