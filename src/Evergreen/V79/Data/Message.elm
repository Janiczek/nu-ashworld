module Evergreen.V79.Data.Message exposing (..)

import Evergreen.V79.Data.Fight
import Evergreen.V79.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V79.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V79.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
