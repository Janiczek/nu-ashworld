module Evergreen.V114.Data.WorldData exposing (..)

import Dict
import Evergreen.V114.Data.Player
import Evergreen.V114.Data.Player.PlayerName
import Evergreen.V114.Data.Quest
import Evergreen.V114.Data.Tick
import Evergreen.V114.Data.Vendor
import Evergreen.V114.Data.Vendor.Shop
import Evergreen.V114.Data.World
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V114.Data.World.Name
            { players : Dict.Dict Evergreen.V114.Data.Player.PlayerName.PlayerName (Evergreen.V114.Data.Player.Player Evergreen.V114.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V114.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V114.Data.World.Name (List Evergreen.V114.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V114.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V114.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V114.Data.Player.Player Evergreen.V114.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V114.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V114.Data.Vendor.Shop.Shop Evergreen.V114.Data.Vendor.Vendor
    , questsProgress : SeqDict.SeqDict Evergreen.V114.Data.Quest.Name Evergreen.V114.Data.Quest.Progress
    , questRewardShops : SeqSet.SeqSet Evergreen.V114.Data.Vendor.Shop.Shop
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | NotLoggedIn
