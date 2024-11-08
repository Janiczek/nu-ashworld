module Evergreen.V136.Data.WorldInfo exposing (..)

import Evergreen.V136.Data.Tick
import Time
import Time.Extra


type alias WorldInfo =
    { name : String
    , description : String
    , playersCount : Int
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V136.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    }
