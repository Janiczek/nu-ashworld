module Evergreen.V42.Data.Player exposing (..)

import AssocList
import Evergreen.V42.Data.Auth
import Evergreen.V42.Data.HealthStatus
import Evergreen.V42.Data.Map
import Evergreen.V42.Data.Perk
import Evergreen.V42.Data.Special
import Evergreen.V42.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V42.Data.Auth.Password Evergreen.V42.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V42.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V42.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V42.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V42.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V42.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V42.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V42.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V42.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V42.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V42.Data.Auth.Auth Evergreen.V42.Data.Auth.Verified)
    | Player a