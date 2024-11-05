module Evergreen.V128.Data.Fight.OpponentType exposing (..)

import Evergreen.V128.Data.Enemy.Type
import Evergreen.V128.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V128.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V128.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
