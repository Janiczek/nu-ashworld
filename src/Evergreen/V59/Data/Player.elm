module Evergreen.V59.Data.Player exposing (..)

import AssocList
import Evergreen.V59.Data.Auth
import Evergreen.V59.Data.HealthStatus
import Evergreen.V59.Data.Map
import Evergreen.V59.Data.Message
import Evergreen.V59.Data.Perk
import Evergreen.V59.Data.Player.PlayerName
import Evergreen.V59.Data.Special
import Evergreen.V59.Data.Xp


type alias COtherPlayer = 
    { level : Evergreen.V59.Data.Xp.Level
    , name : Evergreen.V59.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V59.Data.HealthStatus.HealthStatus
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V59.Data.Xp.Xp
    , name : Evergreen.V59.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V59.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V59.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V59.Data.Perk.Perk Int)
    , messages : (List Evergreen.V59.Data.Message.Message)
    }


type Player a
    = NeedsCharCreated (Evergreen.V59.Data.Auth.Auth Evergreen.V59.Data.Auth.Verified)
    | Player a


type alias SPlayer = 
    { name : Evergreen.V59.Data.Player.PlayerName.PlayerName
    , password : (Evergreen.V59.Data.Auth.Password Evergreen.V59.Data.Auth.Verified)
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V59.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V59.Data.Map.TileNum
    , perks : (AssocList.Dict Evergreen.V59.Data.Perk.Perk Int)
    , messages : (List Evergreen.V59.Data.Message.Message)
    }