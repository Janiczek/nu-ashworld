module Evergreen.V110.Data.WorldInfo exposing (..)

import Evergreen.V110.Data.Tick
import Time
import Time.Extra


type alias WorldInfo =
    { name : String
    , description : String
    , playersCount : Int
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V110.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    }
