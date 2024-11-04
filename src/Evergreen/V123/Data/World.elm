module Evergreen.V123.Data.World exposing (..)

import Dict
import Evergreen.V123.Data.Player
import Evergreen.V123.Data.Player.PlayerName
import Evergreen.V123.Data.Quest
import Evergreen.V123.Data.Tick
import Evergreen.V123.Data.Vendor
import Evergreen.V123.Data.Vendor.Shop
import SeqDict
import SeqSet
import Set
import Time
import Time.Extra


type alias Name =
    String


type alias World =
    { players : Dict.Dict Evergreen.V123.Data.Player.PlayerName.PlayerName (Evergreen.V123.Data.Player.Player Evergreen.V123.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V123.Data.Vendor.Shop.Shop Evergreen.V123.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V123.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , questsProgress : SeqDict.SeqDict Evergreen.V123.Data.Quest.Name (Dict.Dict Evergreen.V123.Data.Player.PlayerName.PlayerName Int)
    , questRewardShops : SeqSet.SeqSet Evergreen.V123.Data.Vendor.Shop.Shop
    , questRequirementsPaid : SeqDict.SeqDict Evergreen.V123.Data.Quest.Name (Set.Set Evergreen.V123.Data.Player.PlayerName.PlayerName)
    }