module Evergreen.V136.Data.Fight.OpponentType exposing (..)

import Evergreen.V136.Data.Enemy.Type
import Evergreen.V136.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V136.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V136.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
