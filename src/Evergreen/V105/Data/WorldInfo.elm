module Evergreen.V105.Data.WorldInfo exposing (..)

import Evergreen.V105.Data.Tick
import Time
import Time.Extra


type alias WorldInfo =
    { name : String
    , description : String
    , playersCount : Int
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V105.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    }
