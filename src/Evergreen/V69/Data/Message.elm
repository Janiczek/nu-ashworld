module Evergreen.V69.Data.Message exposing (..)

import Evergreen.V69.Data.Fight
import Evergreen.V69.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V69.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V69.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
