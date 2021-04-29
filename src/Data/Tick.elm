module Data.Tick exposing
    ( limit
    , nextTick
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


limit : Int
limit =
    200


ticksAddedPerInterval : Int -> Int
ticksAddedPerInterval currentTicks =
    if currentTicks < (limit // 4) then
        -- 0-50 will take ~0.5 day to fill
        4

    else if currentTicks < limit then
        -- 50-200 will take ~3 days to fill
        2

    else
        -- hard cap at 200 = takes 87.5 hours to max = ~half a week
        0
