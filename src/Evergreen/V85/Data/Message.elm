module Evergreen.V85.Data.Message exposing (..)

import Evergreen.V85.Data.Fight
import Evergreen.V85.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V85.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V85.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
