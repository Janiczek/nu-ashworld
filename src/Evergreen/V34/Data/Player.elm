module Evergreen.V34.Data.Player exposing (..)

import AssocList
import Evergreen.V34.Data.Auth
import Evergreen.V34.Data.HealthStatus
import Evergreen.V34.Data.Map
import Evergreen.V34.Data.Perk
import Evergreen.V34.Data.Special
import Evergreen.V34.Data.Xp
import Set


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V34.Data.Auth.Password Evergreen.V34.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V34.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V34.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V34.Data.Map.TileNum)
    , perks : (AssocList.Dict Evergreen.V34.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V34.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V34.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V34.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V34.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V34.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V34.Data.Map.TileNum)
    , perks : (AssocList.Dict Evergreen.V34.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V34.Data.Auth.Auth Evergreen.V34.Data.Auth.Verified)
    | Player a