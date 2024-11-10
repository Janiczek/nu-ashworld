module Evergreen.V137.Data.Fight.OpponentType exposing (..)

import Evergreen.V137.Data.Enemy.Type
import Evergreen.V137.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V137.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V137.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
