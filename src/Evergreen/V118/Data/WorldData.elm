module Evergreen.V118.Data.WorldData exposing (..)

import Dict
import Evergreen.V118.Data.Player
import Evergreen.V118.Data.Player.PlayerName
import Evergreen.V118.Data.Quest
import Evergreen.V118.Data.Tick
import Evergreen.V118.Data.Vendor
import Evergreen.V118.Data.Vendor.Shop
import Evergreen.V118.Data.World
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V118.Data.World.Name
            { players : Dict.Dict Evergreen.V118.Data.Player.PlayerName.PlayerName (Evergreen.V118.Data.Player.Player Evergreen.V118.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V118.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V118.Data.World.Name (List Evergreen.V118.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V118.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V118.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V118.Data.Player.Player Evergreen.V118.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V118.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V118.Data.Vendor.Shop.Shop Evergreen.V118.Data.Vendor.Vendor
    , questsProgress : SeqDict.SeqDict Evergreen.V118.Data.Quest.Name Evergreen.V118.Data.Quest.Progress
    , questRewardShops : SeqSet.SeqSet Evergreen.V118.Data.Vendor.Shop.Shop
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | NotLoggedIn
