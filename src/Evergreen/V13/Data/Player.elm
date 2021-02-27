module Evergreen.V13.Data.Player exposing (..)

import Evergreen.V13.Data.HealthStatus
import Evergreen.V13.Data.Special
import Evergreen.V13.Data.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V13.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V13.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V13.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V13.Data.Special.Special
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
    , special : Evergreen.V13.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }