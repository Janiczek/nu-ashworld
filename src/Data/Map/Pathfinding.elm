module Data.Map.Pathfinding exposing (apCost, naiveStraightPath)

import Data.Map as Map exposing (TileCoords)
import Data.Map.Terrain as Terrain
import Raycast2D
import Set exposing (Set)



-- TODO add leastApCostPath that will use A*


naiveStraightPath :
    { from : TileCoords
    , to : TileCoords
    }
    -> Set TileCoords
naiveStraightPath { from, to } =
    Raycast2D.touchedTiles
        Map.tileSizeFloat
        (Map.tileCenterPx from)
        (Map.tileCenterPx to)
        |> Set.remove from


apCost : Set TileCoords -> Int
apCost pathTaken =
    pathTaken
        |> Set.toList
        |> List.map (Terrain.forCoords >> Terrain.apCost)
        |> List.sum
        |> ceiling
