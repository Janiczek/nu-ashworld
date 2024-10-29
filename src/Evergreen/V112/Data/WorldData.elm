module Evergreen.V112.Data.WorldData exposing (..)

import Dict
import Evergreen.V112.Data.Player
import Evergreen.V112.Data.Player.PlayerName
import Evergreen.V112.Data.Quest
import Evergreen.V112.Data.Tick
import Evergreen.V112.Data.Vendor
import Evergreen.V112.Data.Vendor.Shop
import Evergreen.V112.Data.World
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V112.Data.World.Name
            { players : Dict.Dict Evergreen.V112.Data.Player.PlayerName.PlayerName (Evergreen.V112.Data.Player.Player Evergreen.V112.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V112.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V112.Data.World.Name (List Evergreen.V112.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V112.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V112.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V112.Data.Player.Player Evergreen.V112.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V112.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V112.Data.Vendor.Shop.Shop Evergreen.V112.Data.Vendor.Vendor
    , questsProgress : SeqDict.SeqDict Evergreen.V112.Data.Quest.Name Evergreen.V112.Data.Quest.Progress
    , questRewardShops : SeqSet.SeqSet Evergreen.V112.Data.Vendor.Shop.Shop
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | NotLoggedIn
