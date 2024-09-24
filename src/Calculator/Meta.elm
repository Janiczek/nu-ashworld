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
import Random
import Random.Extra
import SeqSet



-- MODEL


type alias Model =
    { generation : Int
    , population : List Individual
    , fights : Dict ( Int, Int ) (List Fight.Result) -- ints are indexes into `population`
    , wins : Dict Int Int -- the key is index into the population, value is number of wins
    }


initialModel : Model
initialModel =
    { generation = 0
    , population = []
    , fights = Dict.empty
    , wins = Dict.empty
    }



-- UPDATE


type Msg
    = GenerateInitialPopulation
    | GeneratedInitialPopulation (List Individual)
    | EvaluateGeneration
    | EvaluatedGeneration (Dict ( Int, Int ) (List Fight.Result))


populationSize : Int
populationSize =
    20


fightsPerPair : Int
fightsPerPair =
    4


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateInitialPopulation ->
            ( { model
                | population = []
                , fights = Dict.empty
                , wins = Dict.empty
              }
            , Random.generate GeneratedInitialPopulation
                (Random.list populationSize Individual.generator)
            )

        GeneratedInitialPopulation population ->
            ( { model | population = population }
            , Cmd.none
            )

        EvaluateGeneration ->
            let
                pop : List ( Int, Individual )
                pop =
                    model.population
                        |> List.indexedMap Tuple.pair
            in
            ( model
            , Random.generate EvaluatedGeneration
                (pop
                    |> List.concatMap
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

        EvaluatedGeneration fights ->
            let
                wins : Dict Int Int
                wins =
                    fights
                        |> Dict.toList
                        |> List.concatMap
                            (\( ( i1, i2 ), results ) ->
                                results
                                    |> List.concatMap
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
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    H.div []
        [ H.h1 [] [ H.text "NuAshworld Meta Calculator" ]
        , H.h3 [] [ H.text <| "Generation: " ++ String.fromInt model.generation ]
        , H.button
            [ HE.onClick GenerateInitialPopulation ]
            [ H.text "Generate Initial Population" ]
        , H.button
            [ HE.onClick EvaluateGeneration ]
            [ H.text "Evaluate Generation" ]
        , viewFights model.fights
        , viewRanking model.wins
        , viewPopulation model.population
        ]


viewFights : Dict ( Int, Int ) (List Fight.Result) -> Html Msg
viewFights fights =
    if Dict.isEmpty fights then
        H.text ""

    else
        let
            pop : List Int
            pop =
                List.range 0 (populationSize - 1)

            cellColor : Fight.Result -> String
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

            dataCell : List Fight.Result -> Html Msg
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
                    |> String.join ", "
              , individual.traits
                    |> SeqSet.toList
                    |> List.map Debug.toString
                    |> String.join ", "
              ]
                |> String.join " | "
                |> H.text
            ]
        , H.pre
            [ HA.style "white-space" "pre-wrap" ]
            [ H.text <| FightStrategy.toString individual.fightStrategy ]
        ]


viewPopulation : List Individual -> Html Msg
viewPopulation population =
    H.div []
        [ H.h2 [] [ H.text "Population" ]
        , H.ol [ HA.start 0 ] <| List.map (\individual -> H.li [] [ viewIndividual individual ]) population
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
