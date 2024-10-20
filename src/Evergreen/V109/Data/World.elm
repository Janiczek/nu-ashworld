module Evergreen.V109.Data.World exposing (..)

import Dict
import Evergreen.V109.Data.Player
import Evergreen.V109.Data.Player.PlayerName
import Evergreen.V109.Data.Quest
import Evergreen.V109.Data.Tick
import Evergreen.V109.Data.Vendor
import Evergreen.V109.Data.Vendor.Shop
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias Name =
    String


type alias World =
    { players : Dict.Dict Evergreen.V109.Data.Player.PlayerName.PlayerName (Evergreen.V109.Data.Player.Player Evergreen.V109.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V109.Data.Vendor.Shop.Shop Evergreen.V109.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V109.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , questsProgress : SeqDict.SeqDict Evergreen.V109.Data.Quest.Name (Dict.Dict Evergreen.V109.Data.Player.PlayerName.PlayerName Int)
    , questRewardShops : SeqSet.SeqSet Evergreen.V109.Data.Vendor.Shop.Shop
    }
