module Evergreen.V110.Data.Fight.OpponentType exposing (..)

import Evergreen.V110.Data.Enemy.Type
import Evergreen.V110.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V110.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V110.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
