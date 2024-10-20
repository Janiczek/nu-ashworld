module Evergreen.V108.Data.Fight.OpponentType exposing (..)

import Evergreen.V108.Data.Enemy.Type
import Evergreen.V108.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V108.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V108.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
