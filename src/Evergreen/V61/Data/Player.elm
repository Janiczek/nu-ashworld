module Evergreen.V61.Data.Player exposing (..)

import AssocList
import Dict
import Evergreen.V61.Data.Auth
import Evergreen.V61.Data.HealthStatus
import Evergreen.V61.Data.Item
import Evergreen.V61.Data.Map
import Evergreen.V61.Data.Message
import Evergreen.V61.Data.Perk
import Evergreen.V61.Data.Player.PlayerName
import Evergreen.V61.Data.Special
import Evergreen.V61.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V61.Data.Xp.Level
    , name : Evergreen.V61.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V61.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V61.Data.Xp.Xp
    , name : Evergreen.V61.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V61.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V61.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V61.Data.Perk.Perk Int
    , messages : List Evergreen.V61.Data.Message.Message
    , items : Dict.Dict Evergreen.V61.Data.Item.Id Evergreen.V61.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V61.Data.Auth.Auth Evergreen.V61.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V61.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V61.Data.Auth.Password Evergreen.V61.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V61.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V61.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V61.Data.Perk.Perk Int
    , messages : List Evergreen.V61.Data.Message.Message
    , items : Dict.Dict Evergreen.V61.Data.Item.Id Evergreen.V61.Data.Item.Item
    }
