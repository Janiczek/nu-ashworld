module Evergreen.V88.Data.Message exposing (..)

import Evergreen.V88.Data.Fight
import Evergreen.V88.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V88.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V88.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
