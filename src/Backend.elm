module Backend exposing (..)

import Dict
import Dict.Extra as Dict
import Html
import Lamdera exposing (ClientId, SessionId)
import Random
import Set
import Types exposing (..)
import Types.Fight as Fight
    exposing
        ( FightInfo
        , FightResult(..)
        )
import Types.Player as Player
    exposing
        ( PlayerName
        , SPlayer
        )
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
                world : WorldLoggedOutData
                world =
                    { players =
                        model.players
                            |> Dict.values
                            |> List.map Player.serverToClientOther
                    }
            in
            ( model
            , Lamdera.sendToFrontend clientId <| CurrentWorld world
            )

        GeneratedPlayerLogHimIn sessionId clientId player ->
            let
                world : WorldLoggedInData
                world =
                    { player = Player.serverToClient player
                    , otherPlayers =
                        model.players
                            |> Dict.toList
                            |> List.map (Tuple.second >> Player.serverToClientOther)
                    }
            in
            ( { model | players = Dict.insert sessionId player model.players }
            , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
            )

        GeneratedFight sessionId clientId fightInfo ->
            ( persistFight sessionId fightInfo model
            , Lamdera.sendToFrontend clientId <| YourFightResult fightInfo
            )


persistFight : SessionId -> FightInfo -> Model -> Model
persistFight attacker fightInfo model =
    findSessionIdForName fightInfo.target model
        |> Maybe.map
            (\target ->
                case fightInfo.result of
                    AttackerWon ->
                        model
                            -- TODO set HP of the attacker (dmg done to him?)
                            |> setHp target 0
                            |> addXp attacker fightInfo.winnerXpGained
                            |> addCaps attacker fightInfo.winnerCapsGained

                    TargetWon ->
                        model
                            -- TODO set HP of the target (dmg done to him?)
                            |> setHp attacker 0
                            |> addXp target fightInfo.winnerXpGained
                            |> addCaps target fightInfo.winnerCapsGained
            )
        |> Maybe.withDefault model


{-| TODO remove this once we have model.players have the key : PlayerName
-}
findSessionIdForName : PlayerName -> Model -> Maybe SessionId
findSessionIdForName playerName model =
    model.players
        |> Dict.find (\_ v -> v.name == playerName)
        |> Maybe.map Tuple.first


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
            case Dict.get sessionId model.players of
                Nothing ->
                    generatePlayerAndLogHimIn sessionId clientId model

                Just sPlayer ->
                    logPlayerIn sessionId clientId sPlayer model

        Fight otherPlayerName ->
            withPlayer (fight otherPlayerName)


generatePlayerAndLogHimIn : SessionId -> ClientId -> Model -> ( Model, Cmd BackendMsg )
generatePlayerAndLogHimIn sessionId clientId model =
    let
        generatePlayerCmd =
            let
                existingNames =
                    model.players
                        |> Dict.values
                        |> List.map .name
                        |> Set.fromList
            in
            Random.generate
                (GeneratedPlayerLogHimIn sessionId clientId)
                (Player.generator existingNames)
    in
    ( model, generatePlayerCmd )


logPlayerIn : SessionId -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
logPlayerIn sessionId clientId sPlayer model =
    let
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


fight : PlayerName -> SessionId -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
fight otherPlayerName sessionId clientId sPlayer model =
    ( model
    , Random.generate
        (GeneratedFight sessionId clientId)
        (Fight.generator
            { attacker = sPlayer.name
            , target = otherPlayerName
            }
        )
    )


subscriptions : Model -> Sub BackendMsg
subscriptions model =
    Lamdera.onConnect Connected


setHp : SessionId -> Int -> Model -> Model
setHp sessionId newHp model =
    { model
        | players =
            model.players
                |> Dict.update sessionId (Maybe.map (\player -> { player | hp = newHp }))
    }


addXp : SessionId -> Int -> Model -> Model
addXp sessionId addedXp model =
    { model
        | players =
            model.players
                |> Dict.update sessionId (Maybe.map (\player -> { player | xp = player.xp + addedXp }))
    }


addCaps : SessionId -> Int -> Model -> Model
addCaps sessionId addedCaps model =
    { model
        | players =
            model.players
                |> Dict.update sessionId (Maybe.map (\player -> { player | caps = player.caps + addedCaps }))
    }
