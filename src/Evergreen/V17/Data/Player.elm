module Evergreen.V17.Data.Player exposing (..)

import Evergreen.V17.Data.Auth
import Evergreen.V17.Data.HealthStatus
import Evergreen.V17.Data.Special
import Evergreen.V17.Data.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V17.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V17.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V17.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V17.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V17.Data.Auth.Auth Evergreen.V17.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V17.Data.Auth.Password Evergreen.V17.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V17.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }