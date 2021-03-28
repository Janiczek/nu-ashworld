module Evergreen.V35.Data.Player exposing (..)

import AssocList
import Evergreen.V35.Data.Auth
import Evergreen.V35.Data.HealthStatus
import Evergreen.V35.Data.Map
import Evergreen.V35.Data.Perk
import Evergreen.V35.Data.Special
import Evergreen.V35.Data.Xp
import Set


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V35.Data.Auth.Password Evergreen.V35.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V35.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V35.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V35.Data.Map.TileNum)
    , perks : (AssocList.Dict Evergreen.V35.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V35.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V35.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V35.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V35.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V35.Data.Map.TileNum
    , knownMapTiles : (Set.Set Evergreen.V35.Data.Map.TileNum)
    , perks : (AssocList.Dict Evergreen.V35.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V35.Data.Auth.Auth Evergreen.V35.Data.Auth.Verified)
    | Player a