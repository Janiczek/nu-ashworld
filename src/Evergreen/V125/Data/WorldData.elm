module Evergreen.V125.Data.WorldData exposing (..)

import Dict
import Evergreen.V125.Data.Player
import Evergreen.V125.Data.Player.PlayerName
import Evergreen.V125.Data.Quest
import Evergreen.V125.Data.Tick
import Evergreen.V125.Data.Vendor
import Evergreen.V125.Data.Vendor.Shop
import Evergreen.V125.Data.World
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V125.Data.World.Name
            { players : Dict.Dict Evergreen.V125.Data.Player.PlayerName.PlayerName (Evergreen.V125.Data.Player.Player Evergreen.V125.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V125.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V125.Data.World.Name (List Evergreen.V125.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V125.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V125.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V125.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V125.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V125.Data.Vendor.Shop.Shop Evergreen.V125.Data.Vendor.Vendor
    , questsProgress : SeqDict.SeqDict Evergreen.V125.Data.Quest.Name Evergreen.V125.Data.Quest.Progress
    , questRewardShops : SeqSet.SeqSet Evergreen.V125.Data.Vendor.Shop.Shop
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | IsPlayerSigningUp
    | NotLoggedIn
