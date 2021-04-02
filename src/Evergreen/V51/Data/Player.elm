module Evergreen.V51.Data.Player exposing (..)

import AssocList
import Evergreen.V51.Data.Auth
import Evergreen.V51.Data.HealthStatus
import Evergreen.V51.Data.Map
import Evergreen.V51.Data.Perk
import Evergreen.V51.Data.Special
import Evergreen.V51.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V51.Data.Auth.Password Evergreen.V51.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V51.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V51.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V51.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V51.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V51.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V51.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V51.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V51.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V51.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V51.Data.Auth.Auth Evergreen.V51.Data.Auth.Verified)
    | Player a