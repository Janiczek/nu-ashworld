module Evergreen.V109.Data.Fight.OpponentType exposing (..)

import Evergreen.V109.Data.Enemy.Type
import Evergreen.V109.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V109.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V109.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
