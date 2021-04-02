module Evergreen.V50.Data.Player exposing (..)

import AssocList
import Evergreen.V50.Data.Auth
import Evergreen.V50.Data.HealthStatus
import Evergreen.V50.Data.Map
import Evergreen.V50.Data.Perk
import Evergreen.V50.Data.Special
import Evergreen.V50.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V50.Data.Auth.Password Evergreen.V50.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V50.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V50.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V50.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V50.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V50.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V50.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V50.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V50.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V50.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V50.Data.Auth.Auth Evergreen.V50.Data.Auth.Verified)
    | Player a