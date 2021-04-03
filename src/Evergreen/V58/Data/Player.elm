module Evergreen.V58.Data.Player exposing (..)

import AssocList
import Evergreen.V58.Data.Auth
import Evergreen.V58.Data.HealthStatus
import Evergreen.V58.Data.Map
import Evergreen.V58.Data.Perk
import Evergreen.V58.Data.Special
import Evergreen.V58.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V58.Data.Auth.Password Evergreen.V58.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V58.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V58.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V58.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V58.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V58.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V58.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V58.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V58.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V58.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V58.Data.Auth.Auth Evergreen.V58.Data.Auth.Verified)
    | Player a