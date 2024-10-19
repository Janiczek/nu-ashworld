module Evergreen.V102.Data.Message exposing (..)

import Evergreen.V102.Data.Fight
import Evergreen.V102.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V102.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V102.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V102.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V102.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
