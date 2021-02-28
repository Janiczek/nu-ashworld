module Evergreen.V15.Data.Player exposing (..)

import Evergreen.V15.Data.HealthStatus
import Evergreen.V15.Data.Special
import Evergreen.V15.Data.Xp
import Lamdera


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V15.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V15.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V15.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V15.Data.Special.Special
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
    , special : Evergreen.V15.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }