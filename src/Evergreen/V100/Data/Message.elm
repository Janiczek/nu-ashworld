module Evergreen.V100.Data.Message exposing (..)

import Evergreen.V100.Data.Fight
import Evergreen.V100.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V100.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V100.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V100.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V100.Data.Fight.Info
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
