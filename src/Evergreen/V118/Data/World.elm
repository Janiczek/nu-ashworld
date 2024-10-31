module Evergreen.V118.Data.World exposing (..)

import Dict
import Evergreen.V118.Data.Player
import Evergreen.V118.Data.Player.PlayerName
import Evergreen.V118.Data.Quest
import Evergreen.V118.Data.Tick
import Evergreen.V118.Data.Vendor
import Evergreen.V118.Data.Vendor.Shop
import SeqDict
import SeqSet
import Set
import Time
import Time.Extra


type alias Name =
    String


type alias World =
    { players : Dict.Dict Evergreen.V118.Data.Player.PlayerName.PlayerName (Evergreen.V118.Data.Player.Player Evergreen.V118.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V118.Data.Vendor.Shop.Shop Evergreen.V118.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V118.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , questsProgress : SeqDict.SeqDict Evergreen.V118.Data.Quest.Name (Dict.Dict Evergreen.V118.Data.Player.PlayerName.PlayerName Int)
    , questRewardShops : SeqSet.SeqSet Evergreen.V118.Data.Vendor.Shop.Shop
    , questRequirementsPaid : SeqDict.SeqDict Evergreen.V118.Data.Quest.Name (Set.Set Evergreen.V118.Data.Player.PlayerName.PlayerName)
    }
