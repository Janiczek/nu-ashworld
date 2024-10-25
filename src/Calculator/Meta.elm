module Calculator.Meta exposing (main)

import Browser
import Calculator.Meta.FightSimulation as FightSimulation
import Calculator.Meta.Individual as Individual exposing (Individual)
import Data.Fight as Fight
import Data.FightStrategy as FightStrategy
import Data.Special as Special
import Dict exposing (Dict)
import Dict.Extra
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List.ExtraExtra as List
import Process
import Random exposing (Generator)
import Random.Extra
import SeqSet
import Task



-- MODEL


type alias Model =
    { generation : Int
    , population : List Individual
    , fights : Dict ( Int, Int ) (List Fight.FightResult) -- ints are indexes into `population`
    , wins : Dict Int Int -- the key is index into the population, value is number of wins
    , autoRun : Bool
    }


initCmd : Cmd Msg
initCmd =
    Random.generate GeneratedPopulation
        (Random.list populationSize Individual.generator)


init : ( Model, Cmd Msg )
init =
    ( { generation = 0
      , population = []
      , fights = Dict.empty
      , wins = Dict.empty
      , autoRun = False
      }
    , initCmd
    )



-- UPDATE


type Msg
    = Reinit
    | Auto
    | GeneratedPopulation (List Individual)
    | RunSim
    | DidRunSim (Dict ( Int, Int ) (List Fight.FightResult))
    | Continue


populationSize : Int
populationSize =
    20


fightsPerPair : Int
fightsPerPair =
    4


maxGeneration : Int
maxGeneration =
    100


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reinit ->
            init

        Auto ->
            ( { model | autoRun = True }
            , Task.perform identity (Task.succeed RunSim)
            )

        GeneratedPopulation population ->
            ( { model | population = population }
            , if model.autoRun then
                Task.perform identity (Task.succeed RunSim)

              else
                Cmd.none
            )

        RunSim ->
            let
                pop : List ( Int, Individual )
                pop =
                    model.population
                        |> List.indexedMap Tuple.pair
            in
            ( model
            , Random.generate DidRunSim
                (pop
                    |> List.fastConcatMap
                        (\p1 ->
                            pop
                                |> List.map (\p2 -> ( p1, p2 ))
                        )
                    |> List.map
                        (\( ( i1, ind1 ), ( i2, ind2 ) ) ->
                            FightSimulation.generator ind1 ind2
                                |> Random.map (.fightInfo >> .result)
                                |> List.repeat fightsPerPair
                                |> Random.Extra.sequence
                                |> Random.map (Tuple.pair ( i1, i2 ))
                        )
                    |> Random.Extra.sequence
                    |> Random.map Dict.fromList
                )
            )

        DidRunSim fights ->
            let
                wins : Dict Int Int
                wins =
                    fights
                        |> Dict.toList
                        |> List.fastConcatMap
                            (\( ( i1, i2 ), results ) ->
                                results
                                    |> List.fastConcatMap
                                        (\result ->
                                            case result of
                                                Fight.AttackerWon _ ->
                                                    [ i1 ]

                                                Fight.TargetWon _ ->
                                                    [ i2 ]

                                                Fight.TargetAlreadyDead ->
                                                    []

                                                Fight.BothDead ->
                                                    []

                                                Fight.NobodyDead ->
                                                    []

                                                Fight.NobodyDeadGivenUp ->
                                                    []
                                        )
                            )
                        |> Dict.Extra.frequencies
            in
            ( { model
                | fights = fights
                , wins = wins
              }
            , if model.autoRun && model.generation < maxGeneration then
                Task.perform identity (Process.sleep 100 |> Task.andThen (\() -> Task.succeed Continue))

              else
                Cmd.none
            )

        Continue ->
            ( { model
                | generation = model.generation + 1
                , fights = Dict.empty
                , wins = Dict.empty
              }
            , Random.generate GeneratedPopulation (nextPopulationGenerator model.population model.wins)
            )


{-| ELITISM
Elite individuals will be copied verbatim into the next population

CROSSOVER
New offspring will be generated by crossing over pairs of parents.
Parents will be selected according to their fitness function (in our
case, the number of wins) by the Roulette Wheel Selection.
The parents will not go into the next population.

MUTATION
All new offspring will be mutated.

-}
nextPopulationGenerator : List Individual -> Dict Int Int -> Generator (List Individual)
nextPopulationGenerator population wins =
    let
        eliteCount : Int
        eliteCount =
            3

        sortedByWinsDesc : List { ind : Individual, wins : Int }
        sortedByWinsDesc =
            population
                |> List.indexedMap
                    (\i ind ->
                        { ind = ind
                        , wins = Dict.get i wins |> Maybe.withDefault 0
                        }
                    )
                |> List.sortBy (.wins >> negate)

        elite : List Individual
        elite =
            sortedByWinsDesc
                |> List.take eliteCount
                |> List.map .ind

        offspringCount : Int
        offspringCount =
            10

        offspring : Generator (List Individual)
        offspring =
            Random.list offspringCount
                (offspringGenerator sortedByWinsDesc
                    |> Random.andThen Individual.mutate
                )

        random : Generator (List Individual)
        random =
            Random.list (populationSize - eliteCount - offspringCount) Individual.generator
    in
    Random.map2 (\offspring_ random_ -> elite ++ offspring_ ++ random_)
        offspring
        random


weightedChoice : List ( Float, a ) -> Generator ( a, List ( Float, a ) )
weightedChoice xs =
    case xs of
        [] ->
            Debug.todo "weightedChoice: empty list"

        x :: xs_ ->
            Random.weighted x xs_
                |> Random.map
                    (\a ->
                        ( a
                        , xs |> List.filter (\( _, a_ ) -> a_ /= a)
                        )
                    )


offspringGenerator : List { ind : Individual, wins : Int } -> Generator Individual
offspringGenerator sortedByWinsDesc =
    let
        toWeighted : { ind : Individual, wins : Int } -> ( Float, Individual )
        toWeighted parent =
            ( toFloat parent.wins, parent.ind )

        all =
            List.map toWeighted sortedByWinsDesc
    in
    weightedChoice all
        |> Random.andThen
            (\( parent1, rest ) ->
                weightedChoice rest
                    |> Random.andThen
                        (\( parent2, _ ) -> Individual.crossover parent1 parent2)
            )



-- VIEW


view : Model -> Html Msg
view model =
    H.div [ HA.class "p-2" ]
        [ H.h1 [] [ H.text "NuAshworld Meta Calculator" ]
        , H.h3 [] [ H.text <| "Generation: " ++ String.fromInt model.generation ]
        , H.div [ HA.class "flex flex-row gap-2" ]
            [ H.button [ HE.onClick Reinit ] [ H.text "[Reinit]" ]
            , H.button [ HE.onClick RunSim ] [ H.text "[Run Sim]" ]
            , H.button [ HE.onClick Continue ] [ H.text "[Continue]" ]
            , H.button [ HE.onClick Auto ] [ H.text "[Auto]" ]
            ]
        , viewFights model.fights
        , viewRanking model.wins
        , viewPopulation model.population
        ]


viewFights : Dict ( Int, Int ) (List Fight.FightResult) -> Html Msg
viewFights fights =
    if Dict.isEmpty fights then
        H.text ""

    else
        let
            pop : List Int
            pop =
                List.range 0 (populationSize - 1)

            cellColor : Fight.FightResult -> String
            cellColor result =
                case result of
                    Fight.AttackerWon _ ->
                        "lime"

                    Fight.TargetWon _ ->
                        "red"

                    Fight.TargetAlreadyDead ->
                        "orange"

                    Fight.BothDead ->
                        "black"

                    Fight.NobodyDead ->
                        "cyan"

                    Fight.NobodyDeadGivenUp ->
                        "brown"

            headerCell : String -> Html Msg
            headerCell content =
                H.th [] [ H.text content ]

            resultSize : Int
            resultSize =
                10

            dataCell : List Fight.FightResult -> Html Msg
            dataCell results =
                results
                    |> List.map
                        (\result ->
                            H.span
                                [ HA.style "width" <| String.fromInt resultSize ++ "px"
                                , HA.style "height" <| String.fromInt resultSize ++ "px"
                                , HA.style "background-color" (cellColor result)
                                , HA.style "display" "inline-block"
                                ]
                                []
                        )
                    |> H.div
                        [ HA.style "width" <| String.fromInt (resultSize * 2) ++ "px"
                        , HA.style "display" "flex"
                        , HA.style "flex-direction" "row"
                        , HA.style "flex-wrap" "wrap"
                        ]
                    |> List.singleton
                    |> H.td []

            row : Int -> Html Msg
            row attacker =
                H.tr []
                    (H.td [] [ H.text ("#" ++ String.fromInt attacker) ]
                        :: List.map
                            (\target ->
                                dataCell
                                    (fights
                                        |> Dict.get ( attacker, target )
                                        |> Maybe.withDefault []
                                    )
                            )
                            pop
                    )
        in
        H.div []
            [ H.h2 [] [ H.text "Fight Results" ]
            , H.p [] [ H.text "Green = attacker won, red = attacker lost" ]
            , H.table [ HA.style "border-collapse" "collapse" ]
                [ H.thead []
                    [ H.tr []
                        (H.th [] [ H.text "Attacker \\ Target" ]
                            :: List.map (\target -> headerCell ("#" ++ String.fromInt target)) pop
                        )
                    ]
                , H.tbody [] (List.map row pop)
                ]
            ]


viewRanking : Dict Int Int -> Html Msg
viewRanking wins =
    H.div []
        [ H.h2 [] [ H.text "Ranking" ]
        , wins
            |> Dict.toList
            |> List.sortBy (Tuple.second >> negate)
            |> List.map (\( i, w ) -> H.li [] [ H.text <| "Individual #" ++ String.fromInt i ++ ": " ++ String.fromInt w ++ " wins" ])
            |> H.ol []
        ]


viewIndividual : Individual -> Html Msg
viewIndividual individual =
    H.details []
        [ H.summary []
            [ [ Special.all
                    |> List.map
                        (\s ->
                            Special.get s individual.special
                                |> String.fromInt
                        )
                    |> String.join " "
              , individual.taggedSkills
                    |> SeqSet.toList
                    |> List.map Debug.toString
                    |> List.sort
                    |> String.join ", "
              , individual.traits
                    |> SeqSet.toList
                    |> List.map Debug.toString
                    |> List.sort
                    |> String.join ", "
              ]
                |> String.join "  --  "
                |> H.text
                |> List.singleton
                |> H.span [ HA.class "whitespace-pre" ]
            ]
        , H.pre
            [ HA.style "white-space" "pre-wrap" ]
            [ H.text <| FightStrategy.toString individual.fightStrategy ]
        ]


viewPopulation : List Individual -> Html Msg
viewPopulation population =
    H.div []
        [ H.h2 [] [ H.text "Population" ]
        , H.ol
            [ HA.start 0
            , HA.class "list-decimal"
            ]
          <|
            List.map
                (\individual ->
                    H.li
                        [ HA.class "ml-8" ]
                        [ viewIndividual individual ]
                )
                population
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
