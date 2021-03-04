module Evergreen.V27.Data.Player exposing (..)

import Evergreen.V27.Data.Auth
import Evergreen.V27.Data.HealthStatus
import Evergreen.V27.Data.Map
import Evergreen.V27.Data.Special
import Evergreen.V27.Data.Xp
import Set


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V27.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V27.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V27.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V27.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V27.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V27.Data.Map.TileNum)
    , distantMapTiles : (Set.Set Evergreen.V27.Data.Map.TileNum)
    }


type Player a
    = NeedsCharCreated (Evergreen.V27.Data.Auth.Auth Evergreen.V27.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V27.Data.Auth.Password Evergreen.V27.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V27.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V27.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V27.Data.Map.TileNum)
    , distantMapTiles : (Set.Set Evergreen.V27.Data.Map.TileNum)
    }