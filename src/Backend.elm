module Backend exposing (..)

import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Fight as Fight
    exposing
        ( FightInfo
        , FightResult(..)
        )
import Data.NewChar exposing (NewChar)
import Data.Player as Player
    exposing
        ( Player(..)
        , PlayerName
        , SPlayer
        )
import Data.Special as Special exposing (SpecialType)
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



--
-- TODO it would be nice if we didn't have to send the hashed password back to the user


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
      , loggedInPlayers = Dict.empty
      }
    , Cmd.none
    )


getWorldLoggedOut : Model -> WorldLoggedOutData
getWorldLoggedOut model =
    { players =
        model.players
            |> Dict.values
            |> List.filterMap Player.getPlayerData
            |> List.sortBy (negate << .xp)
            |> List.map
                (Player.serverToClientOther
                    -- no info about alive/dead!
                    { perception = 1 }
                )
    }


getWorldLoggedIn : PlayerName -> Model -> Maybe WorldLoggedInData
getWorldLoggedIn playerName model =
    Dict.get playerName model.players
        |> Maybe.map (\player -> getWorldLoggedIn_ player model)


getWorldLoggedIn_ : Player SPlayer -> Model -> WorldLoggedInData
getWorldLoggedIn_ player model =
    let
        auth =
            Player.getAuth player

        perception =
            Player.getPlayerData player
                |> Maybe.map (.special >> .perception)
                |> Maybe.withDefault 1
    in
    { player = Player.map Player.serverToClient player
    , otherPlayers =
        model.players
            |> Dict.values
            |> List.filterMap Player.getPlayerData
            |> List.sortBy (negate << .xp)
            |> List.filterMap
                (\otherPlayer ->
                    if otherPlayer.name == auth.name then
                        Nothing

                    else
                        Just <|
                            Player.serverToClientOther
                                { perception = perception }
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

        GeneratedFight clientId sPlayer fightInfo ->
            let
                newModel =
                    persistFight fightInfo model
            in
            getWorldLoggedIn sPlayer.name newModel
                |> Maybe.map
                    (\world ->
                        ( newModel
                        , Lamdera.sendToFrontend clientId <| YourFightResult ( fightInfo, world )
                        )
                    )
                -- Shouldn't happen but we don't have a good way of getting rid of the Maybe
                |> Maybe.withDefault ( newModel, Cmd.none )


persistFight : FightInfo -> Model -> Model
persistFight ({ attacker, target } as fightInfo) model =
    case fightInfo.result of
        AttackerWon ->
            model
                -- TODO set HP of the attacker (dmg done to him?)
                |> setHp 0 target
                |> addXp fightInfo.winnerXpGained attacker
                |> addCaps fightInfo.winnerCapsGained attacker
                |> subtractCaps fightInfo.winnerCapsGained target
                |> incWins attacker
                |> incLosses target
                |> decAP attacker

        TargetWon ->
            model
                -- TODO set HP of the target (dmg done to him?)
                |> setHp 0 attacker
                |> addXp fightInfo.winnerXpGained target
                |> addCaps fightInfo.winnerCapsGained target
                |> subtractCaps fightInfo.winnerCapsGained attacker
                |> incWins target
                |> incLosses attacker
                |> decAP attacker

        TargetAlreadyDead ->
            model
                |> decAP attacker


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        withLoggedInPlayer : (ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
        withLoggedInPlayer fn =
            Dict.get clientId model.loggedInPlayers
                |> Maybe.andThen (\name -> Dict.get name model.players)
                |> Maybe.map (\player -> fn clientId player model)
                |> Maybe.withDefault ( model, Cmd.none )

        withLoggedInCreatedPlayer : (ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
        withLoggedInCreatedPlayer fn =
            Dict.get clientId model.loggedInPlayers
                |> Maybe.andThen (\name -> Dict.get name model.players)
                |> Maybe.andThen Player.getPlayerData
                |> Maybe.map (\player -> fn clientId player model)
                |> Maybe.withDefault ( model, Cmd.none )
    in
    case msg of
        LogMeIn auth ->
            case Dict.get auth.name model.players of
                Nothing ->
                    -- TODO send the player a message that it failed? (user doesn't exist but they don't have to know)
                    ( model, Cmd.none )

                Just player ->
                    let
                        playerAuth : Auth Verified
                        playerAuth =
                            Player.getAuth player
                    in
                    if Auth.verify auth playerAuth then
                        getWorldLoggedIn auth.name model
                            |> Maybe.map
                                (\world ->
                                    ( { model | loggedInPlayers = Dict.insert clientId auth.name model.loggedInPlayers }
                                    , Lamdera.sendToFrontend clientId <| YoureLoggedIn world
                                    )
                                )
                            -- weird?
                            |> Maybe.withDefault ( model, Cmd.none )

                    else
                        -- TODO send the player a message that it failed? (password wrong but they don't have to know)
                        ( model, Cmd.none )

        RegisterMe auth ->
            case Dict.get auth.name model.players of
                Just _ ->
                    -- TODO send the player a message that it failed? (username already exists)
                    ( model, Cmd.none )

                Nothing ->
                    let
                        player =
                            NeedsCharCreated <| Auth.promote auth

                        newModel =
                            { model
                                | players = Dict.insert auth.name player model.players
                                , loggedInPlayers = Dict.insert clientId auth.name model.loggedInPlayers
                            }

                        world =
                            getWorldLoggedIn_ player model
                    in
                    ( newModel
                    , Lamdera.sendToFrontend clientId <| YoureRegistered world
                    )

        LogMeOut ->
            -- TODO perhaps also log them out on disconnect? to clean the dict...
            let
                newModel =
                    { model | loggedInPlayers = Dict.remove clientId model.loggedInPlayers }

                world =
                    getWorldLoggedOut newModel
            in
            ( newModel
            , Lamdera.sendToFrontend clientId <| YoureLoggedOut world
            )

        Fight otherPlayerName ->
            withLoggedInCreatedPlayer (fight otherPlayerName)

        RefreshPlease ->
            let
                loggedOut () =
                    ( model
                    , Lamdera.sendToFrontend clientId <| CurrentWorld <| getWorldLoggedOut model
                    )
            in
            case Dict.get clientId model.loggedInPlayers of
                Nothing ->
                    loggedOut ()

                Just playerName ->
                    getWorldLoggedIn playerName model
                        |> Maybe.map
                            (\world ->
                                ( model
                                , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                                )
                            )
                        |> Maybe.withDefault (loggedOut ())

        IncSpecial type_ ->
            withLoggedInCreatedPlayer (incrementSpecial type_)

        CreateNewChar newChar ->
            withLoggedInPlayer (createNewChar newChar)


createNewChar : NewChar -> ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )
createNewChar newChar clientId player model =
    case player of
        Player _ ->
            -- TODO send the player a message? "already created"
            ( model, Cmd.none )

        NeedsCharCreated auth ->
            let
                sPlayer : SPlayer
                sPlayer =
                    Player.fromNewChar auth newChar

                newPlayer : Player SPlayer
                newPlayer =
                    Player sPlayer

                newModel : Model
                newModel =
                    { model | players = Dict.insert auth.name newPlayer model.players }

                world : WorldLoggedInData
                world =
                    getWorldLoggedIn_ newPlayer newModel
            in
            ( newModel
            , Lamdera.sendToFrontend clientId <| YouHaveCreatedChar world
            )


incrementSpecial : SpecialType -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
incrementSpecial type_ clientId player model =
    if Special.canIncrement player.availableSpecial type_ player.special then
        let
            newModel : Model
            newModel =
                -- TODO FIX recalculate HP and max HP
                model
                    |> incSpecial type_ player.name
                    |> decAvailableSpecial player.name
        in
        getWorldLoggedIn player.name newModel
            |> Maybe.map
                (\world ->
                    ( newModel
                    , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                    )
                )
            |> Maybe.withDefault ( model, Cmd.none )

    else
        -- TODO notify the user?
        ( model, Cmd.none )


fight : PlayerName -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
fight otherPlayerName clientId sPlayer model =
    if sPlayer.hp == 0 then
        ( model, Cmd.none )

    else
        -- TODO consume an AP
        Dict.get otherPlayerName model.players
            |> Maybe.andThen Player.getPlayerData
            |> Maybe.map
                (\target ->
                    if target.hp == 0 then
                        update
                            (GeneratedFight
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
                            (GeneratedFight clientId sPlayer)
                            (Fight.generator
                                { attacker = sPlayer
                                , target = target
                                }
                            )
                        )
                )
            |> Maybe.withDefault ( model, Cmd.none )


subscriptions : Model -> Sub BackendMsg
subscriptions model =
    Lamdera.onConnect Connected


updatePlayer : (SPlayer -> SPlayer) -> PlayerName -> Model -> Model
updatePlayer fn playerName model =
    { model | players = Dict.update playerName (Maybe.map (Player.map fn)) model.players }


setHp : Int -> PlayerName -> Model -> Model
setHp newHp =
    updatePlayer (\player -> { player | hp = newHp })


addXp : Int -> PlayerName -> Model -> Model
addXp addedXp =
    updatePlayer (\player -> { player | xp = player.xp + addedXp })


addCaps : Int -> PlayerName -> Model -> Model
addCaps addedCaps =
    updatePlayer (\player -> { player | caps = player.caps + addedCaps })


subtractCaps : Int -> PlayerName -> Model -> Model
subtractCaps addedCaps =
    updatePlayer (\player -> { player | caps = max 0 <| player.caps - addedCaps })


incWins : PlayerName -> Model -> Model
incWins =
    updatePlayer (\player -> { player | wins = player.wins + 1 })


incLosses : PlayerName -> Model -> Model
incLosses =
    updatePlayer (\player -> { player | losses = player.losses + 1 })


incSpecial : SpecialType -> PlayerName -> Model -> Model
incSpecial type_ =
    updatePlayer (\player -> { player | special = Special.increment type_ player.special })


decAvailableSpecial : PlayerName -> Model -> Model
decAvailableSpecial =
    updatePlayer (\player -> { player | availableSpecial = player.availableSpecial - 1 })


decAP : PlayerName -> Model -> Model
decAP =
    updatePlayer (\player -> { player | ap = max 0 (player.ap - 1) })
