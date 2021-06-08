module Evergreen.V97.Data.Message exposing (..)

import Evergreen.V97.Data.Fight
import Evergreen.V97.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V97.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V97.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V97.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V97.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
