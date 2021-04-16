module Data.Tick exposing
    ( nextTick
    , ticksAddedPerInterval
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


ticksAddedPerInterval : Int -> Int
ticksAddedPerInterval currentTicks =
    if currentTicks < 50 then
        -- 0-50 will take ~1 day to fill
        2

    else if currentTicks < 200 then
        -- 50-200 will take ~6 days to fill
        1

    else
        -- hard cap at 200 = takes 175 hours to max = ~week
        0
