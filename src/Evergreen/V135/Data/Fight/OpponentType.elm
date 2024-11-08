module Evergreen.V135.Data.Fight.OpponentType exposing (..)

import Evergreen.V135.Data.Enemy.Type
import Evergreen.V135.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V135.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V135.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
