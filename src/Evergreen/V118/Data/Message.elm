module Evergreen.V118.Data.Message exposing (..)

import Evergreen.V118.Data.Fight
import Evergreen.V118.Data.Player.PlayerName
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V118.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V118.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V118.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V118.Data.Fight.Info
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
