module Evergreen.V77.Data.Message exposing (..)

import Evergreen.V77.Data.Fight
import Evergreen.V77.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V77.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V77.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
