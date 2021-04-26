module Random.FloatExtra exposing (normallyDistributed)

import Random exposing (Generator)
import Random.Float


{-| Avg = 300, maxDeviation = 50 means we'll generate values in range 250..350,
distributed normally (a bell curve).
-}
normallyDistributed :
    { average : Float
    , maxDeviation : Float
    }
    -> Generator Float
normallyDistributed { average, maxDeviation } =
    -- dev/3 == 99.7% chance the value will fall inside the range
    -- we'll just clamp the remaining 0.3%
    Random.Float.normal average (maxDeviation / 3)
        |> Random.map
            (clamp
                (average - maxDeviation)
                (average + maxDeviation)
            )
