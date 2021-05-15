module Evergreen.V89.Data.Message exposing (..)

import Evergreen.V89.Data.Fight
import Evergreen.V89.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V89.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V89.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
