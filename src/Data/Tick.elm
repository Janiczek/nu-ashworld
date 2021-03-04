module Data.Tick exposing
    ( acPerTick
    , nextTick
    )

import Time exposing (Posix)
import Time.Extra as Time


nextTick : Posix -> { nextTick : Posix, millisTillNextTick : Int }
nextTick time =
    let
        nextTick_ =
            Time.ceiling tickFrequency Time.utc time
    in
    { nextTick = nextTick_
    , millisTillNextTick = Time.diff Time.Millisecond Time.utc time nextTick_
    }


tickFrequency : Time.Interval
tickFrequency =
    Time.Hour


acPerTick : Int
acPerTick =
    2
