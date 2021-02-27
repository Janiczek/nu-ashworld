module Evergreen.V12.Data.Player exposing (..)

import Evergreen.V12.Data.HealthStatus
import Evergreen.V12.Data.Special
import Evergreen.V12.Data.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { hp : Int
    , level : Evergreen.V12.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V12.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V12.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V12.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias SPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : PlayerName
    , special : Evergreen.V12.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }