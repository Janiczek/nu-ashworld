module Evergreen.V83.Data.Message exposing (..)

import Evergreen.V83.Data.Fight
import Evergreen.V83.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V83.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V83.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
