module Random.FloatExtra exposing
    ( NormalIntSpec
    , NormalSpec
    , normalIntSpecCodec
    , normallyDistributedInt
    )

import Codec exposing (Codec)
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
    let
        maxDeviation_ =
            min average maxDeviation
    in
    -- dev/3 == 99.7% chance the value will fall inside the range
    -- we'll just clamp the remaining 0.3%
    Random.Float.normal average (maxDeviation_ / 3)
        |> Random.map
            (clamp
                (average - maxDeviation_)
                (average + maxDeviation_)
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


normalIntSpecCodec : Codec NormalIntSpec
normalIntSpecCodec =
    Codec.object NormalIntSpec
        |> Codec.field "average" .average Codec.int
        |> Codec.field "maxDeviation" .maxDeviation Codec.int
        |> Codec.buildObject
