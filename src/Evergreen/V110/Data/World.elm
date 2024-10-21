module Evergreen.V110.Data.World exposing (..)

import Dict
import Evergreen.V110.Data.Player
import Evergreen.V110.Data.Player.PlayerName
import Evergreen.V110.Data.Quest
import Evergreen.V110.Data.Tick
import Evergreen.V110.Data.Vendor
import Evergreen.V110.Data.Vendor.Shop
import SeqDict
import SeqSet
import Time
import Time.Extra


type alias Name =
    String


type alias World =
    { players : Dict.Dict Evergreen.V110.Data.Player.PlayerName.PlayerName (Evergreen.V110.Data.Player.Player Evergreen.V110.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V110.Data.Vendor.Shop.Shop Evergreen.V110.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V110.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , questsProgress : SeqDict.SeqDict Evergreen.V110.Data.Quest.Name (Dict.Dict Evergreen.V110.Data.Player.PlayerName.PlayerName Int)
    , questRewardShops : SeqSet.SeqSet Evergreen.V110.Data.Vendor.Shop.Shop
    }
