module Evergreen.V63.Data.Player exposing (..)

import AssocList
import Dict
import Evergreen.V63.Data.Auth
import Evergreen.V63.Data.HealthStatus
import Evergreen.V63.Data.Item
import Evergreen.V63.Data.Map
import Evergreen.V63.Data.Message
import Evergreen.V63.Data.Perk
import Evergreen.V63.Data.Player.PlayerName
import Evergreen.V63.Data.Special
import Evergreen.V63.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V63.Data.Xp.Level
    , name : Evergreen.V63.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V63.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V63.Data.Xp.Xp
    , name : Evergreen.V63.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V63.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V63.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V63.Data.Perk.Perk Int
    , messages : List Evergreen.V63.Data.Message.Message
    , items : Dict.Dict Evergreen.V63.Data.Item.Id Evergreen.V63.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V63.Data.Auth.Auth Evergreen.V63.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V63.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V63.Data.Auth.Password Evergreen.V63.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V63.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V63.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V63.Data.Perk.Perk Int
    , messages : List Evergreen.V63.Data.Message.Message
    , items : Dict.Dict Evergreen.V63.Data.Item.Id Evergreen.V63.Data.Item.Item
    }
