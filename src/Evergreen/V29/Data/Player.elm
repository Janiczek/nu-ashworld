module Evergreen.V29.Data.Player exposing (..)

import Evergreen.V29.Data.Auth
import Evergreen.V29.Data.HealthStatus
import Evergreen.V29.Data.Map
import Evergreen.V29.Data.Special
import Evergreen.V29.Data.Xp
import Set


type alias PlayerName = String


type alias COtherPlayer = 
    { level : Evergreen.V29.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V29.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V29.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V29.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V29.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V29.Data.Map.TileNum)
    }


type Player a
    = NeedsCharCreated (Evergreen.V29.Data.Auth.Auth Evergreen.V29.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V29.Data.Auth.Password Evergreen.V29.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V29.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V29.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V29.Data.Map.TileNum)
    }