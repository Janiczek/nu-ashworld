module Evergreen.V129.Data.Fight.OpponentType exposing (..)

import Evergreen.V129.Data.Enemy.Type
import Evergreen.V129.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V129.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V129.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
