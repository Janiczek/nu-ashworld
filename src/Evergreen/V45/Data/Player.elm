module Evergreen.V45.Data.Player exposing (..)

import AssocList
import Evergreen.V45.Data.Auth
import Evergreen.V45.Data.HealthStatus
import Evergreen.V45.Data.Map
import Evergreen.V45.Data.Perk
import Evergreen.V45.Data.Special
import Evergreen.V45.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V45.Data.Auth.Password Evergreen.V45.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V45.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V45.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V45.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V45.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V45.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V45.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V45.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V45.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V45.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V45.Data.Auth.Auth Evergreen.V45.Data.Auth.Verified)
    | Player a