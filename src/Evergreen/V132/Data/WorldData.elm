module Evergreen.V132.Data.WorldData exposing (..)

import Dict
import Evergreen.V132.Data.Player
import Evergreen.V132.Data.Player.PlayerName
import Evergreen.V132.Data.Quest
import Evergreen.V132.Data.Tick
import Evergreen.V132.Data.Vendor
import Evergreen.V132.Data.Vendor.Shop
import Evergreen.V132.Data.World
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V132.Data.World.Name
            { players : Dict.Dict Evergreen.V132.Data.Player.PlayerName.PlayerName (Evergreen.V132.Data.Player.Player Evergreen.V132.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V132.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V132.Data.World.Name (List Evergreen.V132.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V132.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V132.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V132.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V132.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V132.Data.Vendor.Shop.Shop Evergreen.V132.Data.Vendor.Vendor
    , questsProgress : SeqDict.SeqDict Evergreen.V132.Data.Quest.Quest Evergreen.V132.Data.Quest.Progress
    , questRewardShops : SeqSet.SeqSet Evergreen.V132.Data.Vendor.Shop.Shop
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | IsPlayerSigningUp
    | NotLoggedIn
