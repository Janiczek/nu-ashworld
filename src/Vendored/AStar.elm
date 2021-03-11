module Vendored.AStar exposing (findPath, manhattanHeuristic)

{-| My fork to krisajenkins/elm-astar, not yet merged.

<https://github.com/krisajenkins/elm-astar/issues/9>
<https://github.com/krisajenkins/elm-astar/pull/10>

Introduces the neighbour cost.

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Set exposing (Set)


findPath :
    (comparable -> comparable -> Float)
    -> (comparable -> comparable -> Float)
    -> (comparable -> Set comparable)
    -> comparable
    -> comparable
    -> Maybe (List comparable)
findPath neighbourCostFn heuristicFn moveFn start end =
    initialModel start
        |> astar neighbourCostFn heuristicFn moveFn end
        |> Maybe.map Array.toList


type alias Model comparable =
    { evaluated : Set comparable
    , openSet : Set comparable
    , costs : Dict comparable Float
    , cameFrom : Dict comparable comparable
    }


initialModel : comparable -> Model comparable
initialModel start =
    { evaluated = Set.empty
    , openSet = Set.singleton start
    , costs = Dict.singleton start 0
    , cameFrom = Dict.empty
    }


cheapestOpen : (comparable -> Float) -> Model comparable -> Maybe comparable
cheapestOpen heuristicFn model =
    model.openSet
        |> Set.toList
        |> List.filterMap
            (\position ->
                case Dict.get position model.costs of
                    Nothing ->
                        Nothing

                    Just cost ->
                        Just ( position, cost + heuristicFn position )
            )
        |> List.sortBy Tuple.second
        |> List.head
        |> Maybe.map Tuple.first


reconstructPath : Dict comparable comparable -> comparable -> Array comparable
reconstructPath cameFrom goal =
    case Dict.get goal cameFrom of
        Nothing ->
            Array.empty

        Just next ->
            Array.push goal
                (reconstructPath cameFrom next)


updateCost : (comparable -> comparable -> Float) -> comparable -> comparable -> Model comparable -> Model comparable
updateCost neighbourCostFn current neighbour model =
    let
        newCameFrom =
            Dict.insert neighbour current model.cameFrom

        newCosts =
            Dict.insert neighbour distanceTo model.costs

        distanceTo =
            neighbourCostFn current neighbour
                + (reconstructPath newCameFrom neighbour
                    |> Array.length
                    |> toFloat
                  )

        newModel =
            { model
                | costs = newCosts
                , cameFrom = newCameFrom
            }
    in
    case Dict.get neighbour model.costs of
        Nothing ->
            newModel

        Just previousDistance ->
            if distanceTo < previousDistance then
                newModel

            else
                model


astar :
    (comparable -> comparable -> Float)
    -> (comparable -> comparable -> Float)
    -> (comparable -> Set comparable)
    -> comparable
    -> Model comparable
    -> Maybe (Array comparable)
astar neighbourCostFn heuristicFn moveFn goal model =
    case cheapestOpen (heuristicFn goal) model of
        Nothing ->
            Nothing

        Just current ->
            if current == goal then
                Just (reconstructPath model.cameFrom goal)

            else
                let
                    modelPopped =
                        { model
                            | openSet = Set.remove current model.openSet
                            , evaluated = Set.insert current model.evaluated
                        }

                    neighbours =
                        moveFn current

                    newNeighbours =
                        Set.diff neighbours modelPopped.evaluated

                    modelWithNeighbours =
                        { modelPopped
                            | openSet =
                                Set.union modelPopped.openSet
                                    newNeighbours
                        }

                    modelWithCosts =
                        Set.foldl (updateCost neighbourCostFn current) modelWithNeighbours newNeighbours
                in
                astar neighbourCostFn heuristicFn moveFn goal modelWithCosts


manhattanHeuristic : ( Int, Int ) -> ( Int, Int ) -> Float
manhattanHeuristic ( x1, y1 ) ( x2, y2 ) =
    let
        dx =
            abs (x1 - x2)

        dy =
            abs (y1 - y2)
    in
    toFloat <| dx + dy
