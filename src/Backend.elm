module Backend exposing (..)

import Dict
import Html
import Lamdera exposing (ClientId, SessionId)
import Random
import Set
import Types exposing (..)
import Types.Player as Player exposing (SPlayer)
import Types.World exposing (CWorld)


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
    ( { players = Dict.empty
      , onlinePlayers = Set.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        Connected sessionId _ ->
            -- TODO later do this counting based on username instead of session ID?
            let
                generatePlayerCmd =
                    if Dict.member sessionId model.players then
                        Cmd.none

                    else
                        Random.generate (GeneratedPlayer sessionId) Player.generator

                broadcastOnlinePlayersCountCmd =
                    if Set.member sessionId model.onlinePlayers then
                        Cmd.none

                    else
                        Lamdera.broadcast (OnlinePlayersCountChanged (Set.size model.onlinePlayers + 1))
            in
            ( { model | onlinePlayers = Set.insert sessionId model.onlinePlayers }
            , Cmd.batch
                [ generatePlayerCmd
                , broadcastOnlinePlayersCountCmd
                ]
            )

        Disconnected sessionId _ ->
            -- TODO later do this counting based on username instead of session ID?
            let
                broadcastOnlinePlayersCountCmd =
                    if Set.member sessionId model.onlinePlayers then
                        Lamdera.broadcast (OnlinePlayersCountChanged (Set.size model.onlinePlayers - 1))

                    else
                        Cmd.none
            in
            ( { model | onlinePlayers = Set.remove sessionId model.onlinePlayers }
            , broadcastOnlinePlayersCountCmd
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
        cWorld : CWorld
        cWorld =
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
    , Lamdera.sendToFrontend clientId <| YourCurrentWorld cWorld
    )


subscriptions : Model -> Sub BackendMsg
subscriptions model =
    Sub.batch
        [ Lamdera.onConnect Connected
        , Lamdera.onDisconnect Disconnected
        ]
