module Evergreen.V104.Data.Fight.Generator exposing (..)

import Evergreen.V104.Data.Fight
import Evergreen.V104.Data.Message


type alias Fight =
    { finalAttacker : Evergreen.V104.Data.Fight.Opponent
    , finalTarget : Evergreen.V104.Data.Fight.Opponent
    , fightInfo : Evergreen.V104.Data.Fight.Info
    , messageForTarget : Evergreen.V104.Data.Message.Content
    , messageForAttacker : Evergreen.V104.Data.Message.Content
    }
