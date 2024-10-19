module Evergreen.V101.Data.Message exposing (..)

import Evergreen.V101.Data.Fight
import Evergreen.V101.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V101.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V101.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V101.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V101.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
