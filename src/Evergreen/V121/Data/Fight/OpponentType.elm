module Evergreen.V121.Data.Fight.OpponentType exposing (..)

import Evergreen.V121.Data.Enemy.Type
import Evergreen.V121.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V121.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V121.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
