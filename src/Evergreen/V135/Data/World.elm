module Evergreen.V135.Data.World exposing (..)

import Dict
import Evergreen.V135.Data.Player
import Evergreen.V135.Data.Player.PlayerName
import Evergreen.V135.Data.Quest
import Evergreen.V135.Data.Tick
import Evergreen.V135.Data.Vendor
import Evergreen.V135.Data.Vendor.Shop
import SeqDict
import SeqSet
import Set
import Time
import Time.Extra


type alias Name =
    String


type alias World =
    { players : Dict.Dict Evergreen.V135.Data.Player.PlayerName.PlayerName (Evergreen.V135.Data.Player.Player Evergreen.V135.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V135.Data.Vendor.Shop.Shop Evergreen.V135.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V135.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , questsProgress : SeqDict.SeqDict Evergreen.V135.Data.Quest.Quest (Dict.Dict Evergreen.V135.Data.Player.PlayerName.PlayerName Int)
    , questRewardShops : SeqSet.SeqSet Evergreen.V135.Data.Vendor.Shop.Shop
    , questRequirementsPaid : SeqDict.SeqDict Evergreen.V135.Data.Quest.Quest (Set.Set Evergreen.V135.Data.Player.PlayerName.PlayerName)
    }
