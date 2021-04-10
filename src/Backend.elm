module Backend exposing (..)

import Admin
import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Fight as Fight exposing (FightResult(..))
import Data.Fight.Generator as FightGen
import Data.Map as Map exposing (TileCoords, TileNum)
import Data.Map.Pathfinding as Pathfinding
import Data.Message exposing (Message)
import Data.NewChar exposing (NewChar)
import Data.Player as Player
    exposing
        ( Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Player.SPlayer as SPlayer
import Data.Special as Special exposing (SpecialType)
import Data.Special.Perception as Perception
import Data.Tick as Tick
import Data.Vendor as Vendor
import Data.World
    exposing
        ( AdminData
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Data.Xp as Xp
import Dict
import Dict.Extra as Dict
import Json.Decode as JD
import Json.Encode as JE
import Lamdera exposing (ClientId, SessionId)
import Logic
import Random
import Set exposing (Set)
import Set.Extra as Set
import Task
import Time exposing (Posix)
import Time.Extra as Time
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
    let
        model =
            { players = Dict.empty
            , loggedInPlayers = Dict.empty
            , nextWantedTick = Nothing
            , adminLoggedIn = Nothing
            , time = Time.millisToPosix 0
            , vendors = Vendor.emptyVendors
            }
    in
    ( model
    , Cmd.batch
        [ Task.perform Tick Time.now
        , Random.generate GeneratedNewVendorsStock
            (Vendor.restockVendors model.vendors)
        ]
    )


getAdminData : Model -> AdminData
getAdminData model =
    { players = Dict.values model.players
    , loggedInPlayers = Dict.values model.loggedInPlayers
    , nextWantedTick = model.nextWantedTick
    }


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
    , vendors = model.vendors
    }


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    let
        withLoggedInPlayer =
            withLoggedInPlayer_ model
    in
    case msg of
        Connected _ clientId ->
            let
                world =
                    getWorldLoggedOut model
            in
            ( model
            , Lamdera.sendToFrontend clientId <| CurrentWorld world
            )

        Disconnected _ clientId ->
            ( { model | loggedInPlayers = Dict.remove clientId model.loggedInPlayers }
            , Cmd.none
            )

        Tick currentTime ->
            case model.nextWantedTick of
                Nothing ->
                    let
                        { nextTick } =
                            Tick.nextTick currentTime
                    in
                    ( { model
                        | nextWantedTick = Just nextTick
                        , time = currentTime
                      }
                    , Cmd.none
                    )

                Just nextWantedTick ->
                    if Time.posixToMillis currentTime >= Time.posixToMillis nextWantedTick then
                        let
                            { nextTick } =
                                Tick.nextTick currentTime
                        in
                        ( { model
                            | nextWantedTick = Just nextTick
                            , time = currentTime
                          }
                            |> processTick
                        , Cmd.none
                        )

                    else
                        ( { model | time = currentTime }
                        , Cmd.none
                        )

        GeneratedFight clientId sPlayer fight_ ->
            let
                newModel =
                    model
                        |> savePlayer fight_.finalAttacker
                        |> savePlayer fight_.finalTarget
            in
            getWorldLoggedIn sPlayer.name newModel
                |> Maybe.map
                    (\world ->
                        ( newModel
                        , Lamdera.sendToFrontend clientId <| YourFightResult ( fight_.fightInfo, world )
                        )
                    )
                -- Shouldn't happen but we don't have a good way of getting rid of the Maybe
                |> Maybe.withDefault ( newModel, Cmd.none )

        CreateNewCharWithTime clientId newChar time ->
            withLoggedInPlayer clientId (createNewCharWithTime newChar time)

        GeneratedNewVendorsStock vendors ->
            ( { model | vendors = vendors }
            , Cmd.none
            )


processTick : Model -> Model
processTick model =
    -- TODO refresh the affected users that are logged-in
    { model | players = Dict.map (always (Player.map SPlayer.tick)) model.players }


withLoggedInPlayer_ : Model -> ClientId -> (ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
withLoggedInPlayer_ model clientId fn =
    Dict.get clientId model.loggedInPlayers
        |> Maybe.andThen (\name -> Dict.get name model.players)
        |> Maybe.map (\player -> fn clientId player model)
        |> Maybe.withDefault ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        withLoggedInPlayer =
            withLoggedInPlayer_ model clientId

        withLoggedInCreatedPlayer : (ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
        withLoggedInCreatedPlayer fn =
            Dict.get clientId model.loggedInPlayers
                |> Maybe.andThen (\name -> Dict.get name model.players)
                |> Maybe.andThen Player.getPlayerData
                |> Maybe.map (\player -> fn clientId player model)
                |> Maybe.withDefault ( model, Cmd.none )

        withAdmin : (Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
        withAdmin fn =
            if isAdmin sessionId clientId model then
                fn model

            else
                ( model, Cmd.none )
    in
    case msg of
        LogMeIn auth ->
            if Auth.isAdminName auth then
                if Auth.adminPasswordChecksOut auth then
                    let
                        adminData : AdminData
                        adminData =
                            getAdminData model
                    in
                    ( { model | adminLoggedIn = Just ( sessionId, clientId ) }
                    , Lamdera.sendToFrontend clientId <| YoureLoggedInAsAdmin adminData
                    )

                else
                    ( model
                    , Lamdera.sendToFrontend clientId <| AlertMessage "Nuh-uh..."
                    )

            else
                case Dict.get auth.name model.players of
                    Nothing ->
                        ( model
                        , Lamdera.sendToFrontend clientId <| AlertMessage "Login failed"
                        )

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
                                        let
                                            ( loggedOutPlayers, otherPlayers ) =
                                                Dict.partition (\_ name -> name == auth.name) model.loggedInPlayers

                                            worldLoggedOut =
                                                getWorldLoggedOut model
                                        in
                                        ( { model | loggedInPlayers = Dict.insert clientId auth.name otherPlayers }
                                        , Cmd.batch <|
                                            (Lamdera.sendToFrontend clientId <| YoureLoggedIn world)
                                                :: (loggedOutPlayers
                                                        |> Dict.keys
                                                        |> List.map (\cId -> Lamdera.sendToFrontend cId <| YoureLoggedOut worldLoggedOut)
                                                   )
                                        )
                                    )
                                -- weird?
                                |> Maybe.withDefault ( model, Cmd.none )

                        else
                            ( model
                            , Lamdera.sendToFrontend clientId <| AlertMessage "Login failed"
                            )

        RegisterMe auth ->
            if Auth.isAdminName auth then
                ( model
                , Lamdera.sendToFrontend clientId <| AlertMessage "Nuh-uh..."
                )

            else
                case Dict.get auth.name model.players of
                    Just _ ->
                        ( model
                        , Lamdera.sendToFrontend clientId <| AlertMessage "Username exists"
                        )

                    Nothing ->
                        if Auth.isEmpty auth.password then
                            ( model
                            , Lamdera.sendToFrontend clientId <| AlertMessage "Password is empty"
                            )

                        else
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
            let
                newModel =
                    if isAdmin sessionId clientId model then
                        { model | adminLoggedIn = Nothing }

                    else
                        { model | loggedInPlayers = Dict.remove clientId model.loggedInPlayers }

                world =
                    getWorldLoggedOut newModel
            in
            ( newModel
            , Lamdera.sendToFrontend clientId <| YoureLoggedOut world
            )

        Fight otherPlayerName ->
            withLoggedInCreatedPlayer (fight otherPlayerName)

        HealMe ->
            withLoggedInCreatedPlayer healMe

        RefreshPlease ->
            let
                loggedOut () =
                    ( model
                    , Lamdera.sendToFrontend clientId <| CurrentWorld <| getWorldLoggedOut model
                    )
            in
            if isAdmin sessionId clientId model then
                ( model
                , Lamdera.sendToFrontend clientId <| CurrentAdminData <| getAdminData model
                )

            else
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

        MoveTo newCoords pathTaken ->
            withLoggedInCreatedPlayer (moveTo newCoords pathTaken)

        MessageWasRead message ->
            withLoggedInCreatedPlayer (readMessage message)

        RemoveMessage message ->
            withLoggedInCreatedPlayer (removeMessage message)

        AdminToBackend adminMsg ->
            withAdmin (updateAdmin clientId adminMsg)


updateAdmin : ClientId -> AdminToBackend -> Model -> ( Model, Cmd BackendMsg )
updateAdmin clientId msg model =
    case msg of
        ExportJson ->
            let
                json : String
                json =
                    model
                        |> Admin.encodeBackendModel
                        |> JE.encode 0
            in
            ( model
            , Lamdera.sendToFrontend clientId <| JsonExportDone json
            )

        ImportJson jsonString ->
            case JD.decodeString Admin.backendModelDecoder jsonString of
                Ok newModel ->
                    ( { newModel | adminLoggedIn = model.adminLoggedIn }
                    , Cmd.batch
                        [ Lamdera.sendToFrontend clientId <| CurrentAdminData <| getAdminData newModel
                        , Lamdera.sendToFrontend clientId <| AlertMessage "Import successful!"
                        ]
                    )

                Err error ->
                    ( model
                    , Lamdera.sendToFrontend clientId <| AlertMessage <| JD.errorToString error
                    )


isAdmin : SessionId -> ClientId -> Model -> Bool
isAdmin sessionId clientId { adminLoggedIn } =
    adminLoggedIn == Just ( sessionId, clientId )


readMessage : Message -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
readMessage message clientId player model =
    let
        newModel =
            model
                |> updatePlayer (SPlayer.readMessage message) player.name
    in
    getWorldLoggedIn player.name newModel
        |> Maybe.map
            (\world ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


removeMessage : Message -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
removeMessage message clientId player model =
    let
        newModel =
            model
                |> updatePlayer (SPlayer.removeMessage message) player.name
    in
    getWorldLoggedIn player.name newModel
        |> Maybe.map
            (\world ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


moveTo : TileCoords -> Set TileCoords -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
moveTo newCoords pathTaken clientId player model =
    let
        currentCoords : TileCoords
        currentCoords =
            Map.toTileCoords player.location

        tickCost : Int
        tickCost =
            Pathfinding.tickCost pathTaken
    in
    if currentCoords == newCoords then
        ( model, Cmd.none )

    else if
        pathTaken
            /= Set.remove currentCoords
                (Pathfinding.path
                    (Perception.level player.special.perception)
                    { from = currentCoords
                    , to = newCoords
                    }
                )
    then
        ( model, Cmd.none )

    else if tickCost > player.ticks then
        ( model, Cmd.none )

    else
        let
            newModel =
                model
                    |> updatePlayer
                        (SPlayer.subtractTicks tickCost
                            >> SPlayer.setLocation (Map.toTileNum newCoords)
                        )
                        player.name
        in
        getWorldLoggedIn player.name newModel
            |> Maybe.map
                (\world ->
                    ( newModel
                    , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                    )
                )
            |> Maybe.withDefault ( model, Cmd.none )


createNewChar : NewChar -> ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )
createNewChar newChar clientId player model =
    case player of
        Player _ ->
            ( model, Cmd.none )

        NeedsCharCreated auth ->
            ( model
            , Task.perform (CreateNewCharWithTime clientId newChar) Time.now
            )


createNewCharWithTime : NewChar -> Posix -> ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )
createNewCharWithTime newChar currentTime clientId player model =
    case player of
        Player _ ->
            ( model, Cmd.none )

        NeedsCharCreated auth ->
            let
                sPlayer : SPlayer
                sPlayer =
                    Player.fromNewChar currentTime auth newChar

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
                model
                    |> updatePlayer
                        (SPlayer.incSpecial type_
                            >> SPlayer.decAvailableSpecial
                            >> SPlayer.recalculateHp
                        )
                        player.name
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


healMe : ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
healMe clientId player model =
    let
        newModel =
            model
                |> updatePlayer SPlayer.healUsingTick player.name
    in
    getWorldLoggedIn player.name newModel
        |> Maybe.map
            (\world ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


fight : PlayerName -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
fight otherPlayerName clientId sPlayer model =
    if sPlayer.hp == 0 then
        ( model, Cmd.none )

    else
        Dict.get otherPlayerName model.players
            |> Maybe.andThen Player.getPlayerData
            |> Maybe.map
                (\target ->
                    if target.hp == 0 then
                        update
                            (GeneratedFight
                                clientId
                                sPlayer
                                (FightGen.targetAlreadyDead
                                    { attacker = sPlayer
                                    , target = target
                                    }
                                )
                            )
                            model

                    else
                        ( model
                        , Random.generate
                            (GeneratedFight clientId sPlayer)
                            (FightGen.generator
                                model.time
                                { attacker = sPlayer
                                , target = target
                                }
                            )
                        )
                )
            |> Maybe.withDefault ( model, Cmd.none )


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect Connected
        , Lamdera.onDisconnect Disconnected
        , Time.every 1000 Tick
        ]


savePlayer : SPlayer -> Model -> Model
savePlayer newPlayer model =
    updatePlayer (always newPlayer) newPlayer.name model


updatePlayer : (SPlayer -> SPlayer) -> PlayerName -> Model -> Model
updatePlayer fn playerName model =
    { model | players = Dict.update playerName (Maybe.map (Player.map fn)) model.players }
