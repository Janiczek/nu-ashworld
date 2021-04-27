module Random.FloatExtra exposing
    ( NormalIntSpec
    , NormalSpec
    , normallyDistributedInt
    )

import Random exposing (Generator)
import Random.Float


type alias NormalSpec =
    { average : Float
    , maxDeviation : Float
    }


type alias NormalIntSpec =
    { average : Int
    , maxDeviation : Int
    }


{-| Avg = 300, maxDeviation = 50 means we'll generate values in range 250..350,
distributed normally (a bell curve).
-}
normallyDistributed : NormalSpec -> Generator Float
normallyDistributed { average, maxDeviation } =
    -- dev/3 == 99.7% chance the value will fall inside the range
    -- we'll just clamp the remaining 0.3%
    Random.Float.normal average (maxDeviation / 3)
        |> Random.map
            (clamp
                (average - maxDeviation)
                (average + maxDeviation)
            )


{-| Int version of normallyDistributed
-}
normallyDistributedInt : NormalIntSpec -> Generator Int
normallyDistributedInt { average, maxDeviation } =
    normallyDistributed
        { average = toFloat average
        , maxDeviation = toFloat maxDeviation
        }
        |> Random.map round
