module Evergreen.V87.Data.Message exposing (..)

import Evergreen.V87.Data.Fight
import Evergreen.V87.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V87.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V87.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
