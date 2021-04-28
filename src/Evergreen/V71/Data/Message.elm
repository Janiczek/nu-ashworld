module Evergreen.V71.Data.Message exposing (..)

import Evergreen.V71.Data.Fight
import Evergreen.V71.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V71.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V71.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
