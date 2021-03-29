module Evergreen.V37.Data.Player exposing (..)

import AssocList
import Evergreen.V37.Data.Auth
import Evergreen.V37.Data.HealthStatus
import Evergreen.V37.Data.Map
import Evergreen.V37.Data.Perk
import Evergreen.V37.Data.Special
import Evergreen.V37.Data.Xp
import Set


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V37.Data.Auth.Password Evergreen.V37.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V37.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V37.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V37.Data.Map.TileNum)
    , perks : (AssocList.Dict Evergreen.V37.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V37.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V37.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V37.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V37.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V37.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V37.Data.Map.TileNum)
    , perks : (AssocList.Dict Evergreen.V37.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V37.Data.Auth.Auth Evergreen.V37.Data.Auth.Verified)
    | Player a