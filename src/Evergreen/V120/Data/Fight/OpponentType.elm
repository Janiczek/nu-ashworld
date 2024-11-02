module Evergreen.V120.Data.Fight.OpponentType exposing (..)

import Evergreen.V120.Data.Enemy.Type
import Evergreen.V120.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V120.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V120.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
