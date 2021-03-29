module Data.Map.Pathfinding exposing
    ( path
    , tickCost
    )

import Data.Map as Map exposing (TileCoords)
import Data.Map.Terrain as Terrain
import Data.Special.Perception exposing (PerceptionLevel(..))
import RasterShapes
import Raycast2D
import Set exposing (Set)
import Vendored.AStar as AStar


tickCost : Set TileCoords -> Int
tickCost pathTaken =
    pathTaken
        |> Set.toList
        |> List.map (Terrain.forCoords >> Terrain.tickCost)
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
            terrainAwareOptimalPath

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


terrainAwareOptimalPath :
    { from : TileCoords
    , to : TileCoords
    }
    -> Set TileCoords
terrainAwareOptimalPath { from, to } =
    AStar.findPath
        (\_ neighbourTileCoords -> Terrain.tickCost (Terrain.forCoords neighbourTileCoords))
        AStar.manhattanHeuristic
        Map.neighbours
        from
        to
        |> Maybe.withDefault []
        |> Set.fromList
