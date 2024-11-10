module Evergreen.V139.Data.WorldData exposing (..)

import Dict
import Evergreen.V139.Data.Player
import Evergreen.V139.Data.Player.PlayerName
import Evergreen.V139.Data.Quest
import Evergreen.V139.Data.Tick
import Evergreen.V139.Data.Vendor
import Evergreen.V139.Data.Vendor.Shop
import Evergreen.V139.Data.World
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V139.Data.World.Name
            { players : Dict.Dict Evergreen.V139.Data.Player.PlayerName.PlayerName (Evergreen.V139.Data.Player.Player Evergreen.V139.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V139.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V139.Data.World.Name (List Evergreen.V139.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V139.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V139.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V139.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V139.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V139.Data.Vendor.Shop.Shop Evergreen.V139.Data.Vendor.Vendor
    , questsProgress : SeqDict.SeqDict Evergreen.V139.Data.Quest.Quest Evergreen.V139.Data.Quest.Progress
    , questRewardShops : SeqSet.SeqSet Evergreen.V139.Data.Vendor.Shop.Shop
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | IsPlayerSigningUp
    | NotLoggedIn
