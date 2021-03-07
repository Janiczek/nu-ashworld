module Tests exposing (suite)

import Data.Map exposing (Coords)
import Expect
import Fuzz exposing (Fuzzer)
import Set
import Test exposing (Test)


suite : Test
suite =
    Test.concat
        [ mapTests
        ]


mapTests : Test
mapTests =
    Test.describe "Data.Map"
        [ touchedTiles
        ]


touchedTiles : Test
touchedTiles =
    Test.describe "Data.Map.touchedTiles"
        [ touchedTilesExampleNondegenerate
        , touchedTilesCommutativity
        ]


touchedTilesExampleNondegenerate : Test
touchedTilesExampleNondegenerate =
    Test.test "(1,1) -> (6,3)" <|
        \() ->
            Data.Map.touchedTiles
                Data.Map.tileSizeFloat
                (Data.Map.tileCenterPx ( 1, 1 ))
                (Data.Map.tileCenterPx ( 6, 3 ))
                |> Expect.equalSets
                    (Set.fromList
                        [ ( 1, 1 )
                        , ( 2, 1 )
                        , ( 2, 2 )
                        , ( 3, 2 )
                        , ( 4, 2 )
                        , ( 5, 2 )
                        , ( 5, 3 )
                        , ( 6, 3 )
                        ]
                    )


coordsFuzzer : Fuzzer ( Float, Float )
coordsFuzzer =
    Fuzz.tuple
        ( Fuzz.floatRange 0 (toFloat Data.Map.columns * Data.Map.tileSizeFloat - 1)
        , Fuzz.floatRange 0 (toFloat Data.Map.rows * Data.Map.tileSizeFloat - 1)
        )


touchedTilesCommutativity : Test
touchedTilesCommutativity =
    Test.fuzz2 coordsFuzzer coordsFuzzer "touchedTiles commutativity (t from to == t to from)" <|
        \from to ->
            Data.Map.touchedTiles Data.Map.tileSizeFloat from to
                |> Expect.equalSets (Data.Map.touchedTiles Data.Map.tileSizeFloat to from)
