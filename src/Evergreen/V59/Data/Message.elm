module Evergreen.V59.Data.Message exposing (..)

import Evergreen.V59.Data.Fight
import Evergreen.V59.Data.Player.PlayerName
import Time


type Type
    = Welcome
    | YouAdvancedLevel 
    { newLevel : Int
    }
    | YouWereAttacked 
    { attacker : Evergreen.V59.Data.Player.PlayerName.PlayerName
    , fightInfo : Evergreen.V59.Data.Fight.FightInfo
    }


type alias Message = 
    { type_ : Type
    , hasBeenRead : Bool
    , date : Time.Posix
    }