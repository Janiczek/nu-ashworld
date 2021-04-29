module Evergreen.V81.Data.Fight.Generator exposing (..)

import Evergreen.V81.Data.Fight
import Evergreen.V81.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V81.Data.Fight.Opponent
    , finalTarget : Evergreen.V81.Data.Fight.Opponent
    , fightInfo : Evergreen.V81.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V81.Data.Message.Message
    }
