module Evergreen.V125.Data.Fight.OpponentType exposing (..)

import Evergreen.V125.Data.Enemy.Type
import Evergreen.V125.Data.Player.PlayerName


type alias PlayerOpponent =
    { name : Evergreen.V125.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V125.Data.Enemy.Type.EnemyType
    | Player PlayerOpponent
