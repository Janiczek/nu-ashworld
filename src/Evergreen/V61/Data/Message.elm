module Evergreen.V61.Data.Message exposing (..)

import Evergreen.V61.Data.Fight
import Evergreen.V61.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V61.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V61.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
