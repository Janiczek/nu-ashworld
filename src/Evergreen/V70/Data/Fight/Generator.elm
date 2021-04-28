module Evergreen.V70.Data.Fight.Generator exposing (..)

import Evergreen.V70.Data.Fight
import Evergreen.V70.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V70.Data.Fight.Opponent
    , finalTarget : Evergreen.V70.Data.Fight.Opponent
    , fightInfo : Evergreen.V70.Data.Fight.FightInfo
    , messageForTarget : Evergreen.V70.Data.Message.Message
    }
