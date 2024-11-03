module Data.Map.Pathfinding exposing
    ( cost
    , path
    )

import Data.Map as Map exposing (TileCoords)
import Data.Map.Terrain as Terrain
import Data.Special.Perception exposing (PerceptionLevel(..))
import Logic
import RasterShapes
import Raycast2D
import Set exposing (Set)
import Vendored.AStar as AStar


carMultiplier : Float
carMultiplier =
    2 / 3


cost :
    { pathTaken : Set TileCoords
    , pathfinderPerkRanks : Int
    , carBatteryPromile : Maybe Int
    }
    -> { tickCost : Int, carBatteryPromileCost : Int }
cost { pathTaken, pathfinderPerkRanks, carBatteryPromile } =
    if Set.isEmpty pathTaken then
        { tickCost = 0
        , carBatteryPromileCost = 0
        }

    else
        let
            pathfinderMultiplier : Float
            pathfinderMultiplier =
                1 - (0.25 * toFloat pathfinderPerkRanks)

            walkPathTickCost : Float
            walkPathTickCost =
                pathTaken
                    |> Set.toList
                    |> List.map (Terrain.forCoords >> Terrain.tickCost)
                    |> List.sum
                    |> (*) pathfinderMultiplier
                    |> max 1
        in
        case carBatteryPromile of
            Nothing ->
                { tickCost = ceiling walkPathTickCost
                , carBatteryPromileCost = 0
                }

            Just carBatteryPromileAvailable ->
                let
                    -- You can run out of fuel in the middle of the way.
                    -- We don't implement keeping the car on the map, it's always magically in your inventory.
                    -- But if you run out of fuel you can't reap its benefits - you're slow again.
                    carBatteryPromileNeeded : Float
                    carBatteryPromileNeeded =
                        walkPathTickCost * toFloat Logic.carBatteryPromileCostPerTile

                    carBatteryPromileUsed : Float
                    carBatteryPromileUsed =
                        min (toFloat carBatteryPromileAvailable) carBatteryPromileNeeded

                    carPathPercentage : Float
                    carPathPercentage =
                        carBatteryPromileUsed / carBatteryPromileNeeded

                    costOfCarPortion : Float
                    costOfCarPortion =
                        carPathPercentage * walkPathTickCost * carMultiplier

                    costOfRestPortion : Float
                    costOfRestPortion =
                        (1 - carPathPercentage) * walkPathTickCost
                in
                { tickCost = ceiling (costOfCarPortion + costOfRestPortion)
                , carBatteryPromileCost = ceiling carBatteryPromileUsed
                }


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
