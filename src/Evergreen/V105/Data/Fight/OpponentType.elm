module Evergreen.V105.Data.Fight.OpponentType exposing (..)

import Evergreen.V105.Data.Enemy
import Evergreen.V105.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V105.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V105.Data.Enemy.Type
    | Player PlayerOpponent
