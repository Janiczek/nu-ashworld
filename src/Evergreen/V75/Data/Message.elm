module Evergreen.V75.Data.Message exposing (..)

import Evergreen.V75.Data.Fight
import Evergreen.V75.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V75.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V75.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
