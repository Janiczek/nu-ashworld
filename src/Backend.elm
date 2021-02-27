module Backend exposing (..)

import Data.Fight as Fight
    exposing
        ( FightInfo
        , FightResult(..)
        )
import Data.Player as Player
    exposing
        ( PlayerName
        , SPlayer
        )
import Data.World
    exposing
        ( World
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Dict
import Dict.Extra as Dict
import Html
import Lamdera exposing (ClientId, SessionId)
import Random
import Set
import Types exposing (..)


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


getWorldLoggedOut : Model -> WorldLoggedOutData
getWorldLoggedOut model =
    { players =
        model.players
            |> Dict.values
            |> List.map
                (Player.serverToClientOther
                    -- no info about alive/dead!
                    { perception = 1 }
                )
    }


getWorldLoggedIn : SessionId -> Model -> Maybe WorldLoggedInData
getWorldLoggedIn sessionId model =
    Dict.get sessionId model.players
        |> Maybe.map (\sPlayer -> getWorldLoggedIn_ sPlayer model)


getWorldLoggedIn_ : SPlayer -> Model -> WorldLoggedInData
getWorldLoggedIn_ sPlayer model =
    { player = Player.serverToClient sPlayer
    , otherPlayers =
        model.players
            |> Dict.values
            |> List.filterMap
                (\otherPlayer ->
                    if otherPlayer.name == sPlayer.name then
                        Nothing

                    else
                        Just <|
                            Player.serverToClientOther
                                { perception = sPlayer.special.perception }
                                otherPlayer
                )
    }


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        Connected sessionId clientId ->
            let
                world =
                    getWorldLoggedOut model
            in
            ( model
            , Lamdera.sendToFrontend clientId <| CurrentWorld world
            )

        GeneratedPlayerLogHimIn sessionId clientId player ->
            let
                newModel =
                    { model | players = Dict.insert sessionId player model.players }

                world =
                    getWorldLoggedIn_ player newModel
            in
            ( newModel
            , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
            )

        GeneratedFight sessionId clientId sPlayer fightInfo ->
            let
                newModel =
                    persistFight sessionId fightInfo model
            in
            getWorldLoggedIn sessionId newModel
                |> Maybe.map
                    (\world ->
                        ( newModel
                        , Lamdera.sendToFrontend clientId <| YourFightResult ( fightInfo, world )
                        )
                    )
                -- Shouldn't happen but we don't have a good way of getting rid of the Maybe
                |> Maybe.withDefault ( newModel, Cmd.none )


persistFight : SessionId -> FightInfo -> Model -> Model
persistFight attacker fightInfo model =
    findSessionIdForName fightInfo.target model
        |> Maybe.map
            (\target ->
                case fightInfo.result of
                    AttackerWon ->
                        model
                            -- TODO set HP of the attacker (dmg done to him?)
                            |> setHp 0 target
                            |> addXp fightInfo.winnerXpGained attacker
                            |> addCaps fightInfo.winnerCapsGained attacker
                            |> incWins attacker
                            |> incLosses target

                    TargetWon ->
                        model
                            -- TODO set HP of the target (dmg done to him?)
                            |> setHp 0 attacker
                            |> addXp fightInfo.winnerXpGained target
                            |> addCaps fightInfo.winnerCapsGained target
                            |> incWins target
                            |> incLosses attacker

                    TargetAlreadyDead ->
                        model
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
            getWorldLoggedIn_ sPlayer model
    in
    ( model
    , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
    )


fight : PlayerName -> SessionId -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
fight otherPlayerName sessionId clientId sPlayer model =
    if sPlayer.hp == 0 then
        ( model, Cmd.none )

    else
        -- TODO consume an AP
        findSessionIdForName otherPlayerName model
            |> Maybe.andThen (\targetSessionId -> Dict.get targetSessionId model.players)
            |> Maybe.map
                (\target ->
                    if target.hp == 0 then
                        update
                            (GeneratedFight sessionId
                                clientId
                                sPlayer
                                (Fight.targetAlreadyDead
                                    { attacker = sPlayer.name
                                    , target = otherPlayerName
                                    }
                                )
                            )
                            model

                    else
                        ( model
                        , Random.generate
                            (GeneratedFight sessionId clientId sPlayer)
                            (Fight.generator
                                { attacker = sPlayer.name
                                , target = otherPlayerName
                                }
                            )
                        )
                )
            |> Maybe.withDefault ( model, Cmd.none )


subscriptions : Model -> Sub BackendMsg
subscriptions model =
    Lamdera.onConnect Connected


updatePlayer : (SPlayer -> SPlayer) -> SessionId -> Model -> Model
updatePlayer fn sessionId model =
    { model | players = Dict.update sessionId (Maybe.map fn) model.players }


setHp : Int -> SessionId -> Model -> Model
setHp newHp =
    updatePlayer (\player -> { player | hp = newHp })


addXp : Int -> SessionId -> Model -> Model
addXp addedXp =
    updatePlayer (\player -> { player | xp = player.xp + addedXp })


addCaps : Int -> SessionId -> Model -> Model
addCaps addedCaps =
    updatePlayer (\player -> { player | caps = player.caps + addedCaps })


incWins : SessionId -> Model -> Model
incWins =
    updatePlayer (\player -> { player | wins = player.wins + 1 })


incLosses : SessionId -> Model -> Model
incLosses =
    updatePlayer (\player -> { player | losses = player.losses + 1 })
