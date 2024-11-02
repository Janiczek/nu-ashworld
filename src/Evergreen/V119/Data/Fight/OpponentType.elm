module Evergreen.V119.Data.Fight.OpponentType exposing (..)

import Evergreen.V119.Data.Enemy.Type
import Evergreen.V119.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V119.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V119.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
