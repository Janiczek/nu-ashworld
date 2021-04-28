module Evergreen.V70.Data.Message exposing (..)

import Evergreen.V70.Data.Fight
import Evergreen.V70.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V70.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V70.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
