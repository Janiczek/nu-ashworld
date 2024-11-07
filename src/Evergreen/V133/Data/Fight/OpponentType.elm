module Evergreen.V133.Data.Fight.OpponentType exposing (..)

import Evergreen.V133.Data.Enemy.Type
import Evergreen.V133.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V133.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V133.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
