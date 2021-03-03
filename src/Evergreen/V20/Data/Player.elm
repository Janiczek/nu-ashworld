module Evergreen.V20.Data.Player exposing (..)

import Evergreen.V20.Data.Auth
import Evergreen.V20.Data.HealthStatus
import Evergreen.V20.Data.Special
import Evergreen.V20.Data.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V20.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V20.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V20.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V20.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V20.Data.Auth.Auth Evergreen.V20.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V20.Data.Auth.Password Evergreen.V20.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V20.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }