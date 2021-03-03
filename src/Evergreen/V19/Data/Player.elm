module Evergreen.V19.Data.Player exposing (..)

import Evergreen.V19.Data.Auth
import Evergreen.V19.Data.HealthStatus
import Evergreen.V19.Data.Special
import Evergreen.V19.Data.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V19.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V19.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V19.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V19.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V19.Data.Auth.Auth Evergreen.V19.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V19.Data.Auth.Password Evergreen.V19.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V19.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }