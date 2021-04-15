module Evergreen.V62.Data.Player exposing (..)

import AssocList
import Dict
import Evergreen.V62.Data.Auth
import Evergreen.V62.Data.HealthStatus
import Evergreen.V62.Data.Item
import Evergreen.V62.Data.Map
import Evergreen.V62.Data.Message
import Evergreen.V62.Data.Perk
import Evergreen.V62.Data.Player.PlayerName
import Evergreen.V62.Data.Special
import Evergreen.V62.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V62.Data.Xp.Level
    , name : Evergreen.V62.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V62.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V62.Data.Xp.Xp
    , name : Evergreen.V62.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V62.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V62.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V62.Data.Perk.Perk Int
    , messages : List Evergreen.V62.Data.Message.Message
    , items : Dict.Dict Evergreen.V62.Data.Item.Id Evergreen.V62.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V62.Data.Auth.Auth Evergreen.V62.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V62.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V62.Data.Auth.Password Evergreen.V62.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V62.Data.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V62.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V62.Data.Perk.Perk Int
    , messages : List Evergreen.V62.Data.Message.Message
    , items : Dict.Dict Evergreen.V62.Data.Item.Id Evergreen.V62.Data.Item.Item
    }
