module Evergreen.V112.Data.Fight.OpponentType exposing (..)

import Evergreen.V112.Data.Enemy.Type
import Evergreen.V112.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V112.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V112.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
