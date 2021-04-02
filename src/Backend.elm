module Backend exposing (..)

import Admin
import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Fight as Fight exposing (FightResult(..))
import Data.Map as Map exposing (TileCoords, TileNum)
import Data.Map.Pathfinding as Pathfinding
import Data.NewChar exposing (NewChar)
import Data.Player as Player
    exposing
        ( Player(..)
        , PlayerName
        , SPlayer
        )
import Data.Player.SPlayer as SPlayer
import Data.Special as Special exposing (SpecialType)
import Data.Special.Perception as Perception
import Data.Tick as Tick
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
import Time
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
    ( { players = Dict.empty
      , loggedInPlayers = Dict.empty
      , nextWantedTick = Nothing
      , adminLoggedIn = Nothing
      }
    , Task.perform Tick Time.now
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
    }


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
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
                    ( { model | nextWantedTick = Just nextTick }
                    , Cmd.none
                    )

                Just nextWantedTick ->
                    if Time.posixToMillis currentTime >= Time.posixToMillis nextWantedTick then
                        let
                            { nextTick } =
                                Tick.nextTick currentTime
                        in
                        ( { model | nextWantedTick = Just nextTick }
                            |> processTick
                        , Cmd.none
                        )

                    else
                        ( model, Cmd.none )

        GeneratedFight clientId sPlayer fightInfo ->
            let
                newModel =
                    model
                        |> savePlayer fightInfo.attacker
                        |> savePlayer fightInfo.target
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


processTick : Model -> Model
processTick model =
    -- TODO refresh the affected users that are logged-in
    { model
        | players =
            model.players
                |> Dict.map
                    (\_ player ->
                        player
                            |> tickHeal
                            |> tickAddAp
                    )
    }


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
                    , Lamdera.sendToFrontend clientId <| Message "Nuh-uh..."
                    )

            else
                case Dict.get auth.name model.players of
                    Nothing ->
                        ( model
                        , Lamdera.sendToFrontend clientId <| Message "Login failed"
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
                            , Lamdera.sendToFrontend clientId <| Message "Login failed"
                            )

        RegisterMe auth ->
            if Auth.isAdminName auth then
                ( model
                , Lamdera.sendToFrontend clientId <| Message "Nuh-uh..."
                )

            else
                case Dict.get auth.name model.players of
                    Just _ ->
                        ( model
                        , Lamdera.sendToFrontend clientId <| Message "Username exists"
                        )

                    Nothing ->
                        if Auth.isEmpty auth.password then
                            ( model
                            , Lamdera.sendToFrontend clientId <| Message "Password is empty"
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
                        , Lamdera.sendToFrontend clientId <| Message "Import successful!"
                        ]
                    )

                Err error ->
                    ( model
                    , Lamdera.sendToFrontend clientId <| Message <| JD.errorToString error
                    )


isAdmin : SessionId -> ClientId -> Model -> Bool
isAdmin sessionId clientId { adminLoggedIn } =
    adminLoggedIn == Just ( sessionId, clientId )


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
                    |> subtractTicks tickCost player.name
                    |> setLocation (Map.toTileNum newCoords) player.name
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
            maybeRecalculateHp =
                if Logic.affectsHitpoints type_ then
                    recalculateHp player.name

                else
                    identity

            newModel : Model
            newModel =
                model
                    |> incSpecial type_ player.name
                    |> decAvailableSpecial player.name
                    |> maybeRecalculateHp
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
    if player.hp >= player.maxHp then
        ( model, Cmd.none )

    else if player.ticks <= 0 then
        ( model, Cmd.none )

    else
        let
            newModel =
                model
                    |> subtractTicks 1 player.name
                    |> setHp player.maxHp player.name
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
                                (Fight.targetAlreadyDead
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
                            (Fight.generator
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
        , Time.every 10000 Tick
        ]


savePlayer : SPlayer -> Model -> Model
savePlayer newPlayer model =
    updatePlayer (always newPlayer) newPlayer.name model


updatePlayer : (SPlayer -> SPlayer) -> PlayerName -> Model -> Model
updatePlayer fn playerName model =
    { model | players = Dict.update playerName (Maybe.map (Player.map fn)) model.players }


setHp : Int -> PlayerName -> Model -> Model
setHp newHp =
    updatePlayer (SPlayer.setHp newHp)


addXp : Int -> PlayerName -> Model -> Model
addXp n =
    updatePlayer (SPlayer.addXp n)


addCaps : Int -> PlayerName -> Model -> Model
addCaps n =
    updatePlayer (SPlayer.addCaps n)


subtractCaps : Int -> PlayerName -> Model -> Model
subtractCaps n =
    updatePlayer (SPlayer.subtractCaps n)


incWins : PlayerName -> Model -> Model
incWins =
    updatePlayer SPlayer.incWins


incLosses : PlayerName -> Model -> Model
incLosses =
    updatePlayer SPlayer.incLosses


incSpecial : SpecialType -> PlayerName -> Model -> Model
incSpecial type_ =
    updatePlayer (SPlayer.incSpecial type_)


decAvailableSpecial : PlayerName -> Model -> Model
decAvailableSpecial =
    updatePlayer SPlayer.decAvailableSpecial


subtractTicks : Int -> PlayerName -> Model -> Model
subtractTicks n =
    updatePlayer (SPlayer.subtractTicks n)


setLocation : TileNum -> PlayerName -> Model -> Model
setLocation tileNum =
    updatePlayer (SPlayer.setLocation tileNum)


tickAddAp : Player SPlayer -> Player SPlayer
tickAddAp =
    Player.map (SPlayer.addTicks Tick.ticksAddedPerInterval)


tickHeal : Player SPlayer -> Player SPlayer
tickHeal =
    Player.map
        (\player ->
            if player.hp < player.maxHp then
                -- Logic.healingRate already accounts for tick healing rate multiplier
                player
                    |> SPlayer.addHp (Logic.healingRate player.special)

            else
                player
        )


recalculateHp : PlayerName -> Model -> Model
recalculateHp =
    updatePlayer
        (\player ->
            let
                newMaxHp =
                    Logic.hitpoints
                        { level = Xp.currentLevel player.xp
                        , special = player.special
                        }

                diff =
                    newMaxHp - player.maxHp

                newHp =
                    -- adding maxHp: add hp too
                    -- lowering maxHp: try to keep hp the same
                    if diff > 0 then
                        player.hp + diff

                    else
                        min player.hp newMaxHp
            in
            player
                |> SPlayer.setMaxHp newMaxHp
                |> SPlayer.setHp newHp
        )
