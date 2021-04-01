module Evergreen.V49.Data.Player exposing (..)

import AssocList
import Evergreen.V49.Data.Auth
import Evergreen.V49.Data.HealthStatus
import Evergreen.V49.Data.Map
import Evergreen.V49.Data.Perk
import Evergreen.V49.Data.Special
import Evergreen.V49.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V49.Data.Auth.Password Evergreen.V49.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V49.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V49.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V49.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V49.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V49.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V49.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V49.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V49.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V49.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V49.Data.Auth.Auth Evergreen.V49.Data.Auth.Verified)
    | Player a