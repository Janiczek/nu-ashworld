module Backend exposing (..)

import Dict
import Html
import Lamdera exposing (ClientId, SessionId)
import Random
import Set
import Types exposing (..)
import Types.Player as Player exposing (SPlayer)
import Types.World
    exposing
        ( World
        , WorldLoggedInData
        , WorldLoggedOutData
        )


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { players = Dict.empty }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        Connected sessionId clientId ->
            let
                generatePlayerCmd =
                    if Dict.member sessionId model.players then
                        Cmd.none

                    else
                        let
                            existingNames =
                                model.players
                                    |> Dict.values
                                    |> List.map .name
                                    |> Set.fromList
                        in
                        Random.generate
                            (GeneratedPlayer sessionId)
                            (Player.generator existingNames)

                world : WorldLoggedOutData
                world =
                    { players =
                        model.players
                            |> Dict.values
                            |> List.map Player.serverToClientOther
                    }
            in
            ( model
            , Cmd.batch
                [ generatePlayerCmd
                , Lamdera.sendToFrontend clientId <| CurrentWorld world
                ]
            )

        GeneratedPlayer sessionId player ->
            ( { model | players = Dict.insert sessionId player model.players }
            , Cmd.none
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        withPlayer :
            (SessionId -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg ))
            -> ( Model, Cmd BackendMsg )
        withPlayer fn =
            case Dict.get sessionId model.players of
                Nothing ->
                    ( model, Cmd.none )

                Just sPlayer ->
                    fn sessionId clientId sPlayer model
    in
    case msg of
        LogMeIn ->
            -- TODO check password
            withPlayer updateTicksAndSendClientWorld

        GiveMeCurrentWorld ->
            withPlayer updateTicksAndSendClientWorld


updateTicksAndSendClientWorld : SessionId -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
updateTicksAndSendClientWorld sessionId clientId sPlayer model =
    let
        -- TODO check elapsed ticks
        world : WorldLoggedInData
        world =
            { player = Player.serverToClient sPlayer
            , otherPlayers =
                model.players
                    |> Dict.toList
                    |> List.filterMap
                        (\( sId, player ) ->
                            if sId == sessionId then
                                Nothing

                            else
                                Just <| Player.serverToClientOther player
                        )
            }
    in
    ( model
    , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
    )


subscriptions : Model -> Sub BackendMsg
subscriptions model =
    Lamdera.onConnect Connected
