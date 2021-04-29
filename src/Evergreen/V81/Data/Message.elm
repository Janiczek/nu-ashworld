module Evergreen.V81.Data.Message exposing (..)

import Evergreen.V81.Data.Fight
import Evergreen.V81.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V81.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V81.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
