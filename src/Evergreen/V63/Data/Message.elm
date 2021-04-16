module Evergreen.V63.Data.Message exposing (..)

import Evergreen.V63.Data.Fight
import Evergreen.V63.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V63.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V63.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
