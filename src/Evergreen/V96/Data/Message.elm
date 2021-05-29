module Evergreen.V96.Data.Message exposing (..)

import Evergreen.V96.Data.Fight
import Evergreen.V96.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V96.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V96.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
