module Evergreen.V118.Data.Fight.OpponentType exposing (..)

import Evergreen.V118.Data.Enemy.Type
import Evergreen.V118.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V118.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V118.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
