module Evergreen.V133.Data.World exposing (..)

import Dict
import Evergreen.V133.Data.Player
import Evergreen.V133.Data.Player.PlayerName
import Evergreen.V133.Data.Quest
import Evergreen.V133.Data.Tick
import Evergreen.V133.Data.Vendor
import Evergreen.V133.Data.Vendor.Shop
import SeqDict
import SeqSet
import Set
import Time
import Time.Extra


type alias Name =
    String


type alias World =
    { players : Dict.Dict Evergreen.V133.Data.Player.PlayerName.PlayerName (Evergreen.V133.Data.Player.Player Evergreen.V133.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V133.Data.Vendor.Shop.Shop Evergreen.V133.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V133.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , questsProgress : SeqDict.SeqDict Evergreen.V133.Data.Quest.Quest (Dict.Dict Evergreen.V133.Data.Player.PlayerName.PlayerName Int)
    , questRewardShops : SeqSet.SeqSet Evergreen.V133.Data.Vendor.Shop.Shop
    , questRequirementsPaid : SeqDict.SeqDict Evergreen.V133.Data.Quest.Quest (Set.Set Evergreen.V133.Data.Player.PlayerName.PlayerName)
    }
