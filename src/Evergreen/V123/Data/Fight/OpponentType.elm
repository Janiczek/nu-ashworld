module Evergreen.V123.Data.Fight.OpponentType exposing (..)

import Evergreen.V123.Data.Enemy.Type
import Evergreen.V123.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V123.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V123.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
