module Evergreen.V68.Data.Message exposing (..)

import Evergreen.V68.Data.Fight
import Evergreen.V68.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V68.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V68.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
