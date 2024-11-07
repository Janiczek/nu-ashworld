module Evergreen.V132.Data.Fight.OpponentType exposing (..)

import Evergreen.V132.Data.Enemy.Type
import Evergreen.V132.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V132.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V132.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
