module Data.Map.Pathfinding exposing
    ( apCost
    , path
    )

import AStar
import Data.Map as Map exposing (TileCoords)
import Data.Map.Terrain as Terrain
import Data.Special exposing (Special)
import Data.Special.Perception exposing (PerceptionLevel(..))
import RasterShapes
import Raycast2D
import Set exposing (Set)


apCost : Set TileCoords -> Int
apCost pathTaken =
    pathTaken
        |> Set.toList
        |> List.map (Terrain.forCoords >> Terrain.apCost)
        |> List.sum
        |> ceiling


path :
    PerceptionLevel
    ->
        { from : TileCoords
        , to : TileCoords
        }
    -> Set TileCoords
path level =
    case level of
        Perfect ->
            terrainAwarePath

        Great ->
            okayPath

        Good ->
            okayPath

        Bad ->
            inefficientPath

        Atrocious ->
            inefficientPath


inefficientPath :
    { from : TileCoords
    , to : TileCoords
    }
    -> Set TileCoords
inefficientPath { from, to } =
    Raycast2D.touchedTiles
        Map.tileSizeFloat
        (Map.tileCenterPx from)
        (Map.tileCenterPx to)
        |> Set.remove from


okayPath :
    { from : TileCoords
    , to : TileCoords
    }
    -> Set TileCoords
okayPath { from, to } =
    let
        ( fromX, fromY ) =
            from

        ( toX, toY ) =
            to

        toCoords : { x : Int, y : Int } -> TileCoords
        toCoords { x, y } =
            ( x, y )
    in
    RasterShapes.line
        { x = fromX, y = fromY }
        { x = toX, y = toY }
        |> List.map toCoords
        |> Set.fromList
        |> Set.remove from


terrainAwarePath :
    { from : TileCoords
    , to : TileCoords
    }
    -> Set TileCoords
terrainAwarePath { from, to } =
    AStar.findPath
        {- This implementation of A* always has the goal tile as the first
           argument, and any candidate tile from the open set as the second
           argument. We can take advantage of that and treat this
           (from -> to -> cost) function as a (tile -> cost) function by ignoring
           the first argument.

           This makes the algorithm do much more work than a simple manhattanCost
           or straightLineCost would though. TODO optimize it! Find a way to do
           A* that cares about terrains, fast.
        -}
        (\_ tileCoords -> Terrain.apCost (Terrain.forCoords tileCoords))
        Map.neighbours
        from
        to
        |> Maybe.withDefault []
        |> Set.fromList
