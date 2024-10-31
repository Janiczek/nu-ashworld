module Evergreen.V114.Data.Fight.OpponentType exposing (..)

import Evergreen.V114.Data.Enemy.Type
import Evergreen.V114.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V114.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V114.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
