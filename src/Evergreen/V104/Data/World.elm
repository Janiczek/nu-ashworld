module Evergreen.V104.Data.World exposing (..)

import Dict
import Evergreen.V104.Data.Player
import Evergreen.V104.Data.Player.PlayerName
import Evergreen.V104.Data.Tick
import Evergreen.V104.Data.Vendor
import SeqDict
import Time
import Time.Extra


type alias Name =
    String


type alias Info =
    { name : String
    , description : String
    , playersCount : Int
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V104.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    }


type alias World =
    { players : Dict.Dict Evergreen.V104.Data.Player.PlayerName.PlayerName (Evergreen.V104.Data.Player.Player Evergreen.V104.Data.Player.SPlayer)
    , nextWantedTick : Maybe Time.Posix
    , nextVendorRestockTick : Maybe Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V104.Data.Vendor.Name Evergreen.V104.Data.Vendor.Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V104.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    }
