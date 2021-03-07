module Tests exposing (suite)

import Data.Map exposing (PxCoords, TileCoords)
import Expect
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
        , touchedTilesExampleDiagonal
        , touchedTilesExampleProblematic1
        , touchedTilesExampleProblematic2
        , touchedTilesExampleProblematic3
        , touchedTilesWithinMapFinishFrom "left top" ( 0, 0 )
        , touchedTilesWithinMapFinishFrom "right top" ( Data.Map.columns - 1, 0 )
        , touchedTilesWithinMapFinishFrom "left bottom" ( 0, Data.Map.rows - 1 )
        , touchedTilesWithinMapFinishFrom "right bottom" ( Data.Map.columns - 1, Data.Map.rows - 1 )
        ]


touchedTilesWithinMapFinishFrom : String -> TileCoords -> Test
touchedTilesWithinMapFinishFrom whichCorner coords =
    Test.test ("all tiles within map finish when starting from the " ++ whichCorner ++ " corner") <|
        \() ->
            let
                _ =
                    List.range 0 (Data.Map.columns - 1)
                        |> List.concatMap
                            (\x ->
                                List.range 0 (Data.Map.rows - 1)
                                    |> List.map
                                        (\y ->
                                            Data.Map.touchedTiles
                                                Data.Map.tileSizeFloat
                                                (Data.Map.tileCenterPx coords)
                                                (Data.Map.tileCenterPx ( x, y ))
                                        )
                            )
            in
            Expect.pass


touchedTilesExampleNondegenerate : Test
touchedTilesExampleNondegenerate =
    Test.test "(1,1) -> (6,3)" <|
        \() ->
            Data.Map.touchedTiles
                Data.Map.tileSizeFloat
                (Data.Map.tileCenterPx ( 1, 1 ))
                (Data.Map.tileCenterPx ( 6, 3 ))
                |> Expect.equalSets
                    (Set.fromList [ ( 1, 1 ), ( 2, 1 ), ( 2, 2 ), ( 3, 2 ), ( 4, 2 ), ( 5, 2 ), ( 5, 3 ), ( 6, 3 ) ])


touchedTilesExampleDiagonal : Test
touchedTilesExampleDiagonal =
    Test.test "(3,2) -> (0,5)" <|
        \() ->
            Data.Map.touchedTiles
                Data.Map.tileSizeFloat
                (Data.Map.tileCenterPx ( 3, 2 ))
                (Data.Map.tileCenterPx ( 0, 5 ))
                |> Expect.equalSets
                    (Set.fromList [ ( 3, 2 ), ( 2, 3 ), ( 1, 4 ), ( 0, 5 ) ])


touchedTilesExampleProblematic1 : Test
touchedTilesExampleProblematic1 =
    Test.test "(0,0) -> (1,13)" <|
        \() ->
            Data.Map.touchedTiles
                Data.Map.tileSizeFloat
                (Data.Map.tileCenterPx ( 0, 0 ))
                (Data.Map.tileCenterPx ( 1, 13 ))
                |> Expect.equalSets
                    (Set.fromList [ ( 0, 0 ), ( 0, 1 ), ( 0, 2 ), ( 0, 3 ), ( 0, 4 ), ( 0, 5 ), ( 0, 6 ), ( 1, 7 ), ( 1, 8 ), ( 1, 9 ), ( 1, 10 ), ( 1, 11 ), ( 1, 12 ), ( 1, 13 ) ])


touchedTilesExampleProblematic2 : Test
touchedTilesExampleProblematic2 =
    Test.test "(0,0) -> (27,25)" <|
        \() ->
            Data.Map.touchedTiles
                Data.Map.tileSizeFloat
                (Data.Map.tileCenterPx ( 0, 0 ))
                (Data.Map.tileCenterPx ( 27, 25 ))
                |> Expect.equalSets
                    (Set.fromList [ ( 0, 0 ), ( 1, 0 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ), ( 3, 2 ), ( 3, 3 ), ( 4, 3 ), ( 4, 4 ), ( 5, 4 ), ( 5, 5 ), ( 6, 5 ), ( 6, 6 ), ( 7, 6 ), ( 7, 7 ), ( 8, 7 ), ( 8, 8 ), ( 9, 8 ), ( 9, 9 ), ( 10, 9 ), ( 10, 10 ), ( 11, 10 ), ( 11, 11 ), ( 12, 11 ), ( 12, 12 ), ( 13, 12 ), ( 14, 13 ), ( 15, 13 ), ( 15, 14 ), ( 16, 14 ), ( 16, 15 ), ( 17, 15 ), ( 17, 16 ), ( 18, 16 ), ( 18, 17 ), ( 19, 17 ), ( 19, 18 ), ( 20, 18 ), ( 20, 19 ), ( 21, 19 ), ( 21, 20 ), ( 22, 20 ), ( 22, 21 ), ( 23, 21 ), ( 23, 22 ), ( 24, 22 ), ( 24, 23 ), ( 25, 23 ), ( 25, 24 ), ( 26, 24 ), ( 26, 25 ), ( 27, 25 ) ])


touchedTilesExampleProblematic3 : Test
touchedTilesExampleProblematic3 =
    Test.test "(27,0) -> (26,1)" <|
        \() ->
            Data.Map.touchedTiles
                Data.Map.tileSizeFloat
                (Data.Map.tileCenterPx ( 27, 0 ))
                (Data.Map.tileCenterPx ( 26, 1 ))
                |> Expect.equalSets
                    (Set.fromList [ ( 27, 0 ), ( 26, 1 ) ])
