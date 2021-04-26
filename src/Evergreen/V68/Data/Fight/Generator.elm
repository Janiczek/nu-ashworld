module Evergreen.V68.Data.Fight.Generator exposing (..)

import Evergreen.V68.Data.Fight
import Evergreen.V68.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V68.Data.Fight.Opponent
    , finalTarget : Evergreen.V68.Data.Fight.Opponent
    , fightInfo : Evergreen.V68.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V68.Data.Message.Message
    }
