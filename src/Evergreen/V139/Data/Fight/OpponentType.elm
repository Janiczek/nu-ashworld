module Evergreen.V139.Data.Fight.OpponentType exposing (..)

import Evergreen.V139.Data.Enemy.Type
import Evergreen.V139.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V139.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V139.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
