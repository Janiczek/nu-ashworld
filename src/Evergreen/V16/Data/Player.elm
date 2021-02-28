module Evergreen.V16.Data.Player exposing (..)

import Evergreen.V16.Data.HealthStatus
import Evergreen.V16.Data.Special
import Evergreen.V16.Data.Xp
import Lamdera


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V16.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V16.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V16.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V16.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias PlayerKey = Lamdera.SessionId


type alias SPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : PlayerName
    , special : Evergreen.V16.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }