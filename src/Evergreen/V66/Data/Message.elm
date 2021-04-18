module Evergreen.V66.Data.Message exposing (..)

import Evergreen.V66.Data.Fight
import Evergreen.V66.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V66.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V66.Data.Fight.FightInfo
        }


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }
