module Evergreen.V124.Data.Fight.OpponentType exposing (..)

import Evergreen.V124.Data.Enemy.Type
import Evergreen.V124.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V124.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V124.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
