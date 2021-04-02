module Evergreen.V55.Data.Player exposing (..)

import AssocList
import Evergreen.V55.Data.Auth
import Evergreen.V55.Data.HealthStatus
import Evergreen.V55.Data.Map
import Evergreen.V55.Data.Perk
import Evergreen.V55.Data.Special
import Evergreen.V55.Data.Xp


type alias PlayerName = String


type alias SPlayer = 
    { name : PlayerName
    , password : (Evergreen.V55.Data.Auth.Password Evergreen.V55.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V55.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V55.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V55.Data.Perk.Perk Int)
    }


type alias COtherPlayer = 
    { level : Evergreen.V55.Data.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V55.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V55.Data.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V55.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V55.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V55.Data.Perk.Perk Int)
    }


type Player a
    = NeedsCharCreated (Evergreen.V55.Data.Auth.Auth Evergreen.V55.Data.Auth.Verified)
    | Player a