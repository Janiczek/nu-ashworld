module Evergreen.V22.Data.Player exposing (..)

import Evergreen.V22.Data.Auth
import Evergreen.V22.Data.HealthStatus
import Evergreen.V22.Data.Special
import Evergreen.V22.Data.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V22.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V22.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V22.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V22.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V22.Data.Auth.Auth Evergreen.V22.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V22.Data.Auth.Password Evergreen.V22.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V22.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }