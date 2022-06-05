module Data.WorldInfo exposing (WorldInfo)

import Data.Tick exposing (TickPerIntervalCurve)
import Time exposing (Posix)
import Time.Extra as Time


type alias WorldInfo =
    { name : String
    , description : String
    , playersCount : Int
    , startedAt : Posix
    , tickFrequency : Time.Interval
    , tickPerIntervalCurve : TickPerIntervalCurve
    , vendorRestockFrequency : Time.Interval
    }
