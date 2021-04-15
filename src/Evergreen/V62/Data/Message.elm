module Evergreen.V62.Data.Message exposing (..)

import Evergreen.V62.Data.Fight
import Evergreen.V62.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V62.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V62.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
