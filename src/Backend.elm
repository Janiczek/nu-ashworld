module Backend exposing (..)

import Admin
import BiDict
import Cmd.Extra as Cmd
import Cmd.ExtraExtra as Cmd
import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Barter as Barter
import Data.Enemy as Enemy
import Data.Fight as Fight exposing (Opponent)
import Data.Fight.Generator as FightGen
import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item exposing (Item)
import Data.Ladder as Ladder
import Data.Map as Map exposing (TileCoords)
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Map.SmallChunk as SmallChunk
import Data.Message as Message
import Data.NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player as Player
    exposing
        ( CPlayer
        , Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Player.SPlayer as SPlayer
import Data.Quest as Quest
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Data.Tick as Tick
import Data.Vendor as Vendor exposing (Vendor)
import Data.World as World exposing (World)
import Data.WorldData
    exposing
        ( AdminData
        , PlayerData
        )
import Data.WorldInfo exposing (WorldInfo)
import Data.Xp as Xp
import Dict exposing (Dict)
import Dict.Extra as Dict
import Dict.ExtraExtra as Dict
import Env
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lamdera exposing (ClientId, SessionId)
import Lamdera.Hash
import List.Extra as List
import Logic
import Queue
import Random exposing (Generator)
import Random.List
import SeqDict exposing (SeqDict)
import SeqSet
import Set exposing (Set)
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
        , updateFromFrontend = logAndUpdateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { worlds = Dict.singleton Logic.mainWorldName (World.init { fast = False })
      , time = Time.millisToPosix 0
      , loggedInPlayers = BiDict.empty
      , adminLoggedIn = Nothing
      , lastTenToBackendMsgs = Queue.empty
      , randomSeed = Random.initialSeed 0
      , playerDataCache = Dict.empty
      }
    , Task.perform FirstTick Time.now
    )


restockVendors : World.Name -> Model -> ( Model, Cmd BackendMsg )
restockVendors worldName model =
    -- TODO don't forget to restock vendors when you create a world
    case Dict.get worldName model.worlds of
        Nothing ->
            ( model, Cmd.none )

        Just world ->
            let
                ( ( vendors, newLastItemId ), newRandomSeed ) =
                    Random.step
                        (Vendor.restockVendors world.lastItemId world.vendors)
                        model.randomSeed
            in
            ( { model | randomSeed = newRandomSeed }
                |> updateWorld worldName
                    (\world_ ->
                        { world_
                            | vendors = vendors
                            , lastItemId = newLastItemId
                        }
                    )
            , Cmd.none
            )


getAdminData : Model -> AdminData
getAdminData model =
    { worlds =
        model.worlds
            |> Dict.map
                (\_ world ->
                    { players = world.players
                    , nextWantedTick = world.nextWantedTick
                    , description = world.description
                    , startedAt = world.startedAt
                    , tickFrequency = world.tickFrequency
                    , tickPerIntervalCurve = world.tickPerIntervalCurve
                    , vendorRestockFrequency = world.vendorRestockFrequency
                    }
                )
    , loggedInPlayers = getLoggedInPlayers model
    }


getLoggedInPlayers : Model -> Dict World.Name (List PlayerName)
getLoggedInPlayers model =
    model.loggedInPlayers
        |> BiDict.values
        |> List.gatherEqualsBy Tuple.first
        |> List.map
            (\( ( worldName, _ ) as first, rest ) ->
                ( worldName
                , (first :: rest)
                    |> List.map Tuple.second
                )
            )
        |> Dict.fromList


getWorlds : Model -> List WorldInfo
getWorlds model =
    model.worlds
        |> Dict.toList
        |> List.map
            (\( worldName, world ) ->
                { name = worldName
                , description = world.description
                , playersCount = Dict.size world.players
                , startedAt = world.startedAt
                , tickFrequency = world.tickFrequency
                , tickPerIntervalCurve = world.tickPerIntervalCurve
                , vendorRestockFrequency = world.vendorRestockFrequency
                }
            )


getPlayerData : World.Name -> PlayerName -> Model -> Maybe PlayerData
getPlayerData worldName playerName model =
    model.worlds
        |> Dict.get worldName
        |> Maybe.andThen
            (\world ->
                Dict.get playerName world.players
                    |> Maybe.map (getPlayerData_ worldName world)
            )


{-| A "child" helper of getPlayerData for when you already have
the `Player SPlayer` value fetched.
-}
getPlayerData_ : World.Name -> World -> Player SPlayer -> PlayerData
getPlayerData_ worldName world player =
    let
        auth : Auth Verified
        auth =
            Player.getAuth player

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Player.getPlayerData player
                |> Maybe.map
                    (\player_ ->
                        Perception.level
                            { perception = player_.special.perception
                            , hasAwarenessPerk = Perk.rank Perk.Awareness player_.perks > 0
                            }
                    )
                |> Maybe.withDefault Perception.Atrocious

        players =
            world.players
                |> Dict.values
                |> List.filterMap Player.getPlayerData

        sortedPlayers =
            Ladder.sort players

        isCurrentPlayer p =
            p.name == auth.name

        playerRank =
            sortedPlayers
                |> List.indexedMap Tuple.pair
                |> List.find (Tuple.second >> isCurrentPlayer)
                |> Maybe.map (Tuple.first >> (+) 1)
                -- TODO find this info in a non-Maybe way?
                |> Maybe.withDefault 1
    in
    { worldName = worldName
    , description = world.description
    , startedAt = world.startedAt
    , tickFrequency = world.tickFrequency
    , tickPerIntervalCurve = world.tickPerIntervalCurve
    , vendorRestockFrequency = world.vendorRestockFrequency
    , player = Player.map Player.serverToClient player
    , playerRank = playerRank
    , otherPlayers =
        sortedPlayers
            |> List.filterMap
                (\otherPlayer ->
                    if isCurrentPlayer otherPlayer then
                        Nothing

                    else
                        Just <|
                            Player.serverToClientOther
                                perceptionLevel
                                otherPlayer
                )
    , vendors = world.vendors
    , questsProgress =
        {- TODO perhaps we should keep these values cached instead of
           recalculating them all the time
        -}
        world.questsProgress
            |> SeqDict.map
                (\quest ticksGivenPerPlayer ->
                    let
                        engagements : List Quest.Engagement
                        engagements =
                            players
                                |> List.map (\player_ -> SPlayer.questEngagement player_ quest)

                        playersActive : Int
                        playersActive =
                            engagements
                                |> List.filter (\e -> e /= Quest.NotProgressing)
                                |> List.length

                        ticksPerHour : Int
                        ticksPerHour =
                            engagements
                                |> List.map Logic.ticksGivenPerQuestEngagement
                                |> List.sum

                        ticksGiven : Int
                        ticksGiven =
                            ticksGivenPerPlayer
                                |> Dict.values
                                |> List.sum

                        ticksGivenByPlayer : Int
                        ticksGivenByPlayer =
                            player
                                |> Player.getPlayerData
                                |> Maybe.andThen (\{ name } -> Dict.get name ticksGivenPerPlayer)
                                |> Maybe.withDefault 0
                    in
                    { ticksGiven = ticksGiven
                    , ticksPerHour = ticksPerHour
                    , playersActive = playersActive
                    , ticksGivenByPlayer = ticksGivenByPlayer
                    }
                )
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
                worlds =
                    getWorlds model
            in
            ( model
            , Lamdera.sendToFrontend clientId <| CurrentWorlds worlds
            )

        Disconnected _ clientId ->
            ( { model | loggedInPlayers = BiDict.remove clientId model.loggedInPlayers }
            , Cmd.none
            )

        FirstTick currentTime ->
            ( { model
                | time = currentTime
                , randomSeed = Random.initialSeed (Time.posixToMillis currentTime)
              }
            , Cmd.none
            )

        Tick currentTime ->
            let
                modelWithTime =
                    { model | time = currentTime }
            in
            model.worlds
                |> Dict.keys
                |> List.foldl
                    (\worldName ( accModel, cmd ) ->
                        let
                            ( newModel, newCmd ) =
                                case Dict.get worldName accModel.worlds of
                                    Nothing ->
                                        ( accModel, Cmd.none )

                                    Just world ->
                                        let
                                            processTick :
                                                Time.Interval
                                                -> Maybe Posix
                                                -> (Posix -> World -> World)
                                                -> (World.Name -> Model -> ( Model, Cmd BackendMsg ))
                                                -> Model
                                                -> ( Model, Cmd BackendMsg )
                                            processTick tickFrequency nextWantedTick updateNextWantedTick postprocess model_ =
                                                case nextWantedTick of
                                                    Nothing ->
                                                        let
                                                            nextTick =
                                                                Tick.nextTick tickFrequency currentTime
                                                        in
                                                        ( { model_
                                                            | worlds =
                                                                model_.worlds
                                                                    |> Dict.update worldName (Maybe.map (updateNextWantedTick nextTick))
                                                          }
                                                        , Cmd.none
                                                        )

                                                    Just nextWantedTick_ ->
                                                        if Time.posixToMillis currentTime >= Time.posixToMillis nextWantedTick_ then
                                                            let
                                                                nextTick =
                                                                    Tick.nextTick tickFrequency currentTime
                                                            in
                                                            { model_
                                                                | worlds =
                                                                    model_.worlds
                                                                        |> Dict.update worldName (Maybe.map (updateNextWantedTick nextTick))
                                                            }
                                                                |> postprocess worldName

                                                        else
                                                            ( model_
                                                            , Cmd.none
                                                            )
                                        in
                                        accModel
                                            |> processTick
                                                world.tickFrequency
                                                world.nextWantedTick
                                                (\nextTick world_ -> { world_ | nextWantedTick = Just nextTick })
                                                processGameTick
                                            |> Cmd.andThen
                                                (processTick
                                                    world.vendorRestockFrequency
                                                    world.nextVendorRestockTick
                                                    (\nextTick world_ -> { world_ | nextVendorRestockTick = Just nextTick })
                                                    restockVendors
                                                )
                                            |> Cmd.andThen
                                                (\m ->
                                                    model.loggedInPlayers
                                                        |> BiDict.toReverseList
                                                        |> List.filter (\( ( wn, _ ), _ ) -> wn == worldName)
                                                        |> List.foldl
                                                            (\( ( wn, pn ), clientIds ) accOuter ->
                                                                case getPlayerData wn pn m of
                                                                    Nothing ->
                                                                        accOuter

                                                                    Just playerData_ ->
                                                                        let
                                                                            newHash : Int
                                                                            newHash =
                                                                                Lamdera.Hash.hash
                                                                                    Types.w3_encode_PlayerData_
                                                                                    playerData_
                                                                        in
                                                                        clientIds
                                                                            |> Set.toList
                                                                            |> List.foldl
                                                                                (\clientId accInner ->
                                                                                    if Lamdera.Hash.hasChanged newHash clientId model.playerDataCache then
                                                                                        accInner
                                                                                            |> Tuple.mapFirst (saveToPlayerDataCache clientId newHash)
                                                                                            |> Cmd.add (Lamdera.sendToFrontend clientId (CurrentPlayer playerData_))

                                                                                    else
                                                                                        accInner
                                                                                )
                                                                                accOuter
                                                            )
                                                            ( m, Cmd.none )
                                                )
                        in
                        ( newModel, Cmd.batch [ cmd, newCmd ] )
                    )
                    ( modelWithTime, Cmd.none )

        CreateNewCharWithTime clientId newChar time ->
            withLoggedInPlayer clientId (createNewCharWithTime newChar time)

        LoggedToBackendMsg ->
            ( model, Cmd.none )


saveToPlayerDataCache : ClientId -> Int -> Model -> Model
saveToPlayerDataCache clientId newHash model =
    { model | playerDataCache = Dict.insert clientId newHash model.playerDataCache }


processGameTick : World.Name -> Model -> ( Model, Cmd BackendMsg )
processGameTick worldName model =
    -- TODO refresh the affected users that are logged-in?
    model
        |> processGameTickForPlayers worldName
        |> processGameTickForQuests worldName
        |> restockVendors worldName


processGameTickForPlayers : String -> Model -> Model
processGameTickForPlayers worldName model =
    model
        |> updateWorld worldName
            (\world ->
                -- TODO refresh the affected users that are logged-in
                { world
                    | players =
                        Dict.map
                            (always (Player.map (SPlayer.tick model.time world.tickPerIntervalCurve)))
                            world.players
                }
            )


processGameTickForQuests : String -> Model -> Model
processGameTickForQuests worldName model =
    model
        |> updateWorld worldName
            (\world ->
                { world
                    | questsProgress =
                        SeqDict.map
                            (\quest progressPerPlayer ->
                                progressPerPlayer
                                    |> Dict.map
                                        (\playerName progress ->
                                            let
                                                player : Maybe SPlayer
                                                player =
                                                    Dict.get playerName world.players
                                                        |> Maybe.andThen Player.getPlayerData

                                                ticksGiven : Int
                                                ticksGiven =
                                                    player
                                                        |> Maybe.map
                                                            (\player_ ->
                                                                quest
                                                                    |> SPlayer.questEngagement player_
                                                                    |> Logic.ticksGivenPerQuestEngagement
                                                            )
                                                        |> Maybe.withDefault 0
                                            in
                                            progress + ticksGiven
                                        )
                            )
                            world.questsProgress
                }
            )


withLoggedInPlayer_ :
    Model
    -> ClientId
    -> (ClientId -> World -> World.Name -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg ))
    -> ( Model, Cmd BackendMsg )
withLoggedInPlayer_ model clientId fn =
    BiDict.get clientId model.loggedInPlayers
        |> Maybe.andThen
            (\( worldName, playerName ) ->
                Dict.get worldName model.worlds
                    |> Maybe.map (\world -> ( world, worldName, playerName ))
            )
        |> Maybe.andThen
            (\( world, worldName, playerName ) ->
                Dict.get playerName world.players
                    |> Maybe.map
                        (\player -> fn clientId world worldName player model)
            )
        |> Maybe.withDefault ( model, Cmd.none )


logAndUpdateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
logAndUpdateFromFrontend =
    if String.isEmpty Env.loggingApiKey then
        updateFromFrontend

    else
        logAndUpdateFromFrontend_


isAdminMsg : ToBackend -> Bool
isAdminMsg msg =
    case msg of
        AdminToBackend _ ->
            True

        _ ->
            False


logAndUpdateFromFrontend_ : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
logAndUpdateFromFrontend_ sessionId clientId msg model =
    let
        logMsgCmd =
            -- TODO rethink this, something something Event Sourcing? Or maybe indeed just log all *Msgs somewhere and build tooling on being able to play it back
            BiDict.get clientId model.loggedInPlayers
                |> Maybe.map
                    (\( worldName, playerName ) ->
                        Http.request
                            { method = "POST"
                            , url = "https://janiczek-nuashworld.builtwithdark.com/log-backend"
                            , headers = [ Http.header "x-api-key" Env.loggingApiKey ]
                            , body =
                                Http.jsonBody <|
                                    JE.object
                                        [ ( "session-id", JE.string sessionId )
                                        , ( "client-id", JE.string clientId )
                                        , ( "player-name", JE.string playerName )
                                        , ( "world-name", JE.string worldName )
                                        , ( "to-backend-msg", JE.string <| JE.encode 0 <| Admin.encodeToBackendMsg msg )
                                        ]
                            , expect = Http.expectWhatever (always LoggedToBackendMsg)
                            , tracker = Nothing
                            , timeout = Nothing
                            }
                    )
                |> Maybe.withDefault Cmd.none

        ( worldName_, playerName_ ) =
            BiDict.get clientId model.loggedInPlayers
                |> Maybe.withDefault ( "-", "anonymous" )

        modelWithLoggedMsg =
            if isAdminMsg msg then
                model

            else
                { model
                    | lastTenToBackendMsgs =
                        model.lastTenToBackendMsgs
                            |> (if Queue.size model.lastTenToBackendMsgs >= 10 then
                                    Queue.dequeue >> Tuple.second

                                else
                                    identity
                               )
                            |> Queue.enqueue ( playerName_, worldName_, msg )
                }

        ( newModel, normalCmd ) =
            updateFromFrontend sessionId clientId msg modelWithLoggedMsg
    in
    ( newModel
    , Cmd.batch
        [ logMsgCmd
        , refreshAdminLastTenToBackendMsgs newModel
        , normalCmd
        ]
    )


refreshAdminData : Model -> Cmd BackendMsg
refreshAdminData model =
    case model.adminLoggedIn of
        Nothing ->
            Cmd.none

        Just ( adminClientId, _ ) ->
            Lamdera.sendToFrontend adminClientId (CurrentAdmin (getAdminData model))


refreshAdminLoggedInPlayers : Model -> Cmd BackendMsg
refreshAdminLoggedInPlayers model =
    case model.adminLoggedIn of
        Nothing ->
            Cmd.none

        Just ( adminClientId, _ ) ->
            Lamdera.sendToFrontend adminClientId (CurrentAdminLoggedInPlayers (getLoggedInPlayers model))


refreshAdminLastTenToBackendMsgs : Model -> Cmd BackendMsg
refreshAdminLastTenToBackendMsgs model =
    case model.adminLoggedIn of
        Nothing ->
            Cmd.none

        Just ( adminClientId, _ ) ->
            Lamdera.sendToFrontend adminClientId (CurrentAdminLastTenToBackendMsgs (Queue.toList model.lastTenToBackendMsgs))


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    let
        withLoggedInPlayer :
            (ClientId -> World -> World.Name -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg ))
            -> ( Model, Cmd BackendMsg )
        withLoggedInPlayer =
            withLoggedInPlayer_ model clientId

        withLoggedInCreatedPlayer :
            (ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg ))
            -> ( Model, Cmd BackendMsg )
        withLoggedInCreatedPlayer fn =
            BiDict.get clientId model.loggedInPlayers
                |> Maybe.andThen
                    (\( worldName, playerName ) ->
                        Dict.get worldName model.worlds
                            |> Maybe.andThen
                                (\world ->
                                    Dict.get playerName world.players
                                        |> Maybe.andThen Player.getPlayerData
                                        |> Maybe.map (\player -> fn clientId world worldName player model)
                                )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        withAdmin :
            (Model -> ( Model, Cmd BackendMsg ))
            -> ( Model, Cmd BackendMsg )
        withAdmin fn =
            if isAdmin sessionId clientId model then
                fn model

            else
                ( model, Cmd.none )

        withLocation :
            (ClientId -> World -> World.Name -> Location -> SPlayer -> Model -> ( Model, Cmd BackendMsg ))
            -> ( Model, Cmd BackendMsg )
        withLocation fn =
            withLoggedInCreatedPlayer
                (\cId w wn ({ location } as player) m ->
                    case Location.location location of
                        Nothing ->
                            ( model, Cmd.none )

                        Just loc ->
                            fn cId w wn loc player m
                )
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
                case Dict.get auth.worldName model.worlds of
                    Nothing ->
                        ( model
                        , Lamdera.sendToFrontend clientId <| AlertMessage "Login failed"
                        )

                    Just world ->
                        case Dict.get auth.name world.players of
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
                                    getPlayerData auth.worldName auth.name model
                                        |> Maybe.map
                                            (\data ->
                                                let
                                                    names =
                                                        ( auth.worldName, auth.name )

                                                    clientIdsToLogout : Set ClientId
                                                    clientIdsToLogout =
                                                        BiDict.getReverse names model.loggedInPlayers

                                                    loggedOutData =
                                                        getWorlds model

                                                    newModel =
                                                        { model
                                                            | loggedInPlayers =
                                                                model.loggedInPlayers
                                                                    |> -- TODO: BiDict.removeReverse would be nice
                                                                       BiDict.filter (\_ names_ -> names_ /= names)
                                                                    |> BiDict.insert clientId names
                                                        }
                                                in
                                                ( newModel
                                                , Cmd.batch <|
                                                    (Lamdera.sendToFrontend clientId <| YoureLoggedIn data)
                                                        :: refreshAdminLoggedInPlayers newModel
                                                        :: (clientIdsToLogout
                                                                |> Set.toList
                                                                |> List.map (\cId -> Lamdera.sendToFrontend cId <| YoureLoggedOut loggedOutData)
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
                case Dict.get auth.worldName model.worlds of
                    Nothing ->
                        ( model
                        , Lamdera.sendToFrontend clientId <| AlertMessage "World not found"
                        )

                    Just world ->
                        case Dict.get auth.name world.players of
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

                                        newWorld =
                                            { world | players = Dict.insert auth.name player world.players }

                                        newModel =
                                            { model
                                                | loggedInPlayers = BiDict.insert clientId ( auth.worldName, auth.name ) model.loggedInPlayers
                                                , worlds = model.worlds |> Dict.insert auth.worldName newWorld
                                            }

                                        data =
                                            getPlayerData_ auth.worldName newWorld player
                                    in
                                    ( newModel
                                    , Cmd.batch
                                        [ Lamdera.sendToFrontend clientId <| YoureRegistered data
                                        , refreshAdminLoggedInPlayers newModel
                                        ]
                                    )

        LogMeOut ->
            let
                isAdmin_ =
                    isAdmin sessionId clientId model

                newModel =
                    if isAdmin_ then
                        { model | adminLoggedIn = Nothing }

                    else
                        { model | loggedInPlayers = BiDict.remove clientId model.loggedInPlayers }

                world =
                    getWorlds newModel
            in
            ( newModel
            , Cmd.batch
                [ Lamdera.sendToFrontend clientId <| YoureLoggedOut world
                , if isAdmin_ then
                    Cmd.none

                  else
                    refreshAdminLoggedInPlayers newModel
                ]
            )

        Fight otherPlayerName ->
            withLoggedInCreatedPlayer <| fight otherPlayerName

        HealMe ->
            withLoggedInCreatedPlayer healMe

        UseItem itemId ->
            withLoggedInCreatedPlayer <| useItem itemId

        Wander ->
            withLoggedInCreatedPlayer wander

        EquipArmor itemId ->
            withLoggedInCreatedPlayer <| equipArmor itemId

        EquipWeapon itemId ->
            withLoggedInCreatedPlayer <| equipWeapon itemId

        UnequipArmor ->
            withLoggedInCreatedPlayer unequipArmor

        UnequipWeapon ->
            withLoggedInCreatedPlayer unequipWeapon

        SetFightStrategy ( strategy, text ) ->
            withLoggedInCreatedPlayer <| setFightStrategy ( strategy, text )

        ChoosePerk perk ->
            withLoggedInCreatedPlayer <| choosePerk perk

        RefreshPlease ->
            let
                loggedOut () =
                    ( model
                    , Lamdera.sendToFrontend clientId <| CurrentWorlds <| getWorlds model
                    )
            in
            if isAdmin sessionId clientId model then
                ( model
                , Lamdera.sendToFrontend clientId <| CurrentAdmin <| getAdminData model
                )

            else
                case BiDict.get clientId model.loggedInPlayers of
                    Nothing ->
                        loggedOut ()

                    Just (( worldName, playerName ) as worldAndPlayer) ->
                        let
                            clientIds : Set ClientId
                            clientIds =
                                BiDict.getReverse worldAndPlayer model.loggedInPlayers
                        in
                        getPlayerData worldName playerName model
                            |> Maybe.map
                                (\data ->
                                    ( model
                                    , clientIds
                                        |> Set.toList
                                        |> List.map (\cId -> Lamdera.sendToFrontend cId <| CurrentPlayer data)
                                        |> Cmd.batch
                                    )
                                )
                            |> Maybe.withDefault (loggedOut ())

        TagSkill skill ->
            withLoggedInCreatedPlayer (tagSkill skill)

        UseSkillPoints skill ->
            withLoggedInCreatedPlayer (useSkillPoints skill)

        CreateNewChar newChar ->
            withLoggedInPlayer (createNewChar newChar)

        MoveTo newCoords pathTaken ->
            withLoggedInCreatedPlayer (moveTo newCoords pathTaken)

        MessageWasRead messageId ->
            withLoggedInCreatedPlayer (readMessage messageId)

        RemoveMessage messageId ->
            withLoggedInCreatedPlayer (removeMessage messageId)

        RemoveFightMessages ->
            withLoggedInCreatedPlayer removeFightMessages

        Barter barterState ->
            withLocation (barter barterState)

        AdminToBackend adminMsg ->
            withAdmin (updateAdmin clientId adminMsg)

        StopProgressing quest ->
            withLoggedInCreatedPlayer (stopProgressing quest)

        StartProgressing quest ->
            withLoggedInCreatedPlayer (startProgressing quest)


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
            case JD.decodeString (Admin.backendModelDecoder model.randomSeed) jsonString of
                Ok newModel ->
                    ( { newModel | adminLoggedIn = model.adminLoggedIn }
                    , Cmd.batch
                        [ Lamdera.sendToFrontend clientId <| CurrentAdmin <| getAdminData newModel
                        , Lamdera.sendToFrontend clientId <| AlertMessage "Import successful!"
                        ]
                    )

                Err error ->
                    ( model
                    , Lamdera.sendToFrontend clientId <| AlertMessage <| JD.errorToString error
                    )

        CreateNewWorld worldName fast ->
            if Dict.member worldName model.worlds then
                ( model, Cmd.none )

            else
                let
                    newModel =
                        { model
                            | worlds =
                                Dict.insert
                                    worldName
                                    (World.init { fast = fast })
                                    model.worlds
                        }
                in
                ( newModel
                , Lamdera.sendToFrontend clientId <| CurrentAdmin <| getAdminData newModel
                )


isAdmin : SessionId -> ClientId -> Model -> Bool
isAdmin sessionId clientId model =
    model.adminLoggedIn == Just ( sessionId, clientId )


barter : Barter.State -> ClientId -> World -> World.Name -> Location -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
barter barterState clientId world worldName location player model =
    case Maybe.map (Vendor.getFrom world.vendors) (Vendor.forLocation location) of
        Nothing ->
            ( model, Cmd.none )

        Just vendor ->
            let
                barterNotEmpty : Bool
                barterNotEmpty =
                    barterState /= Barter.empty

                hasItem : Dict Item.Id Item -> Item.Id -> Int -> Bool
                hasItem ownedItems itemId neededQuantity =
                    case Dict.get itemId ownedItems of
                        Nothing ->
                            False

                        Just { count } ->
                            neededQuantity <= count

                vendorHasEnoughItems : Bool
                vendorHasEnoughItems =
                    Dict.all (hasItem vendor.items) barterState.vendorItems

                playerHasEnoughItems : Bool
                playerHasEnoughItems =
                    Dict.all (hasItem player.items) barterState.playerItems

                vendorHasEnoughCaps : Bool
                vendorHasEnoughCaps =
                    barterState.vendorCaps <= vendor.caps

                playerHasEnoughCaps : Bool
                playerHasEnoughCaps =
                    barterState.playerCaps <= player.caps

                capsNonnegative : Bool
                capsNonnegative =
                    barterState.playerCaps >= 0 && barterState.vendorCaps >= 0

                playerItemsPrice : Int
                playerItemsPrice =
                    barterState.playerItems
                        |> Dict.toList
                        |> List.filterMap
                            (\( itemId, count ) ->
                                Dict.get itemId player.items
                                    |> Maybe.map (\item -> Item.baseValue item.kind * count)
                            )
                        |> List.sum

                vendorItemsPrice : Int
                vendorItemsPrice =
                    barterState.vendorItems
                        |> Dict.toList
                        |> List.filterMap
                            (\( itemId, count ) ->
                                Dict.get itemId vendor.items
                                    |> Maybe.map
                                        (\item ->
                                            Logic.price
                                                { baseValue = count * Item.baseValue item.kind
                                                , playerBarterSkill = Skill.get player.special player.addedSkillPercentages Skill.Barter
                                                , traderBarterSkill = vendor.barterSkill
                                                , hasMasterTraderPerk = Perk.rank Perk.MasterTrader player.perks > 0
                                                }
                                        )
                            )
                        |> List.sum

                playerValue : Int
                playerValue =
                    playerItemsPrice + barterState.playerCaps

                vendorValue : Int
                vendorValue =
                    vendorItemsPrice + barterState.vendorCaps

                playerOfferValuableEnough : Bool
                playerOfferValuableEnough =
                    playerValue >= vendorValue
            in
            if
                List.all identity
                    [ barterNotEmpty
                    , capsNonnegative
                    , vendorHasEnoughItems
                    , playerHasEnoughItems
                    , vendorHasEnoughCaps
                    , playerHasEnoughCaps
                    , playerOfferValuableEnough
                    ]
            then
                let
                    newModel =
                        barterAfterValidation barterState vendor world worldName location player model
                in
                getPlayerData worldName player.name newModel
                    |> Maybe.map
                        (\data ->
                            ( newModel
                            , Lamdera.sendToFrontend clientId <|
                                BarterDone
                                    ( data
                                    , if vendorValue == 0 then
                                        Just Barter.YouGaveStuffForFree

                                      else
                                        Nothing
                                    )
                            )
                        )
                    |> Maybe.withDefault ( model, Cmd.none )

            else
                ( model
                , -- TODO somehow generate and filter this during all the checks above?
                  if not barterNotEmpty then
                    Lamdera.sendToFrontend clientId <| BarterMessage Barter.BarterIsEmpty

                  else if not playerOfferValuableEnough then
                    Lamdera.sendToFrontend clientId <| BarterMessage Barter.PlayerOfferNotValuableEnough

                  else
                    -- silent error ... somebody's trying to hack probably
                    Cmd.none
                )


barterAfterValidation : Barter.State -> Vendor -> World -> World.Name -> Location -> SPlayer -> Model -> Model
barterAfterValidation barterState vendor _ worldName location player model =
    let
        removePlayerCaps : Int -> Model -> Model
        removePlayerCaps amount =
            updatePlayer worldName player.name (SPlayer.subtractCaps amount)

        addPlayerCaps : Int -> Model -> Model
        addPlayerCaps amount =
            updatePlayer worldName player.name (SPlayer.addCaps amount)

        removeVendorCaps : Int -> Model -> Model
        removeVendorCaps amount =
            updateVendor worldName location (Vendor.subtractCaps amount)

        addVendorCaps : Int -> Model -> Model
        addVendorCaps amount =
            updateVendor worldName location (Vendor.addCaps amount)

        removePlayerItems : Dict Item.Id Int -> Model -> Model
        removePlayerItems items model_ =
            items
                |> Dict.foldl
                    (\id count accModel ->
                        updatePlayer
                            worldName
                            player.name
                            (SPlayer.removeItem id count)
                            accModel
                    )
                    model_

        removeVendorItems : Dict Item.Id Int -> Model -> Model
        removeVendorItems items model_ =
            items
                |> Dict.foldl
                    (\id count accModel ->
                        updateVendor
                            worldName
                            location
                            (Vendor.removeItem id count)
                            accModel
                    )
                    model_

        addVendorItems : Dict Item.Id Int -> Model -> Model
        addVendorItems items model_ =
            items
                |> Dict.foldl
                    (\id count accModel ->
                        case Dict.get id player.items of
                            Nothing ->
                                -- weird: player was supposed to have this item
                                -- we can't get the Item definition
                                -- anyways, other checks make sure we can't get here
                                accModel

                            Just item ->
                                updateVendor
                                    worldName
                                    location
                                    (Vendor.addItem { item | count = count })
                                    accModel
                    )
                    model_

        addPlayerItems : Dict Item.Id Int -> Model -> Model
        addPlayerItems items model_ =
            items
                |> Dict.foldl
                    (\id count accModel ->
                        case Dict.get id vendor.items of
                            Nothing ->
                                -- weird: vendor was supposed to have this player item
                                -- we can't get the Item definition
                                -- anyways, other checks make sure we can't get here
                                accModel

                            Just item ->
                                updatePlayer
                                    worldName
                                    player.name
                                    (SPlayer.addItem { item | count = count })
                                    accModel
                    )
                    model_
    in
    model
        -- player caps:
        |> removePlayerCaps barterState.playerCaps
        |> addVendorCaps barterState.playerCaps
        -- vendor caps:
        |> removeVendorCaps barterState.vendorCaps
        |> addPlayerCaps barterState.vendorCaps
        -- player items:
        |> removePlayerItems barterState.playerItems
        |> addVendorItems barterState.playerItems
        -- vendor items:
        |> removeVendorItems barterState.vendorItems
        |> addPlayerItems barterState.vendorItems


readMessage : Message.Id -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
readMessage messageId clientId _ worldName player model =
    model
        |> updatePlayer worldName player.name (SPlayer.readMessage messageId)
        |> sendCurrentWorld worldName player.name clientId


removeMessage : Message.Id -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
removeMessage messageId clientId _ worldName player model =
    model
        |> updatePlayer worldName player.name (SPlayer.removeMessage messageId)
        |> sendCurrentWorld worldName player.name clientId


removeFightMessages : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
removeFightMessages clientId _ worldName player model =
    let
        newModel =
            model
                |> updatePlayer worldName player.name SPlayer.removeFightMessages
    in
    case getPlayerData worldName player.name newModel of
        Nothing ->
            -- Shouldn't happen?
            ( newModel, Cmd.none )

        Just newPlayer ->
            case newPlayer.player of
                Player.NeedsCharCreated _ ->
                    ( newModel, Cmd.none )

                Player.Player player_ ->
                    ( newModel
                    , Lamdera.sendToFrontend clientId <| YourMessages player_.messages
                    )


moveTo : TileCoords -> Set TileCoords -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
moveTo newCoords pathTaken clientId _ worldName player model =
    let
        currentCoords : TileCoords
        currentCoords =
            Map.toTileCoords player.location

        tickCost : Int
        tickCost =
            Pathfinding.tickCost
                { pathTaken = pathTaken
                , pathfinderPerkRanks = Perk.rank Perk.Pathfinder player.perks
                }

        isSamePosition : Bool
        isSamePosition =
            currentCoords == newCoords

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                }

        pathDoesntAgree : Bool
        pathDoesntAgree =
            pathTaken
                /= Set.remove currentCoords
                    (Pathfinding.path
                        perceptionLevel
                        { from = currentCoords
                        , to = newCoords
                        }
                    )

        notEnoughTicks : Bool
        notEnoughTicks =
            tickCost > player.ticks
    in
    if isSamePosition || pathDoesntAgree || notEnoughTicks then
        ( model, Cmd.none )

    else
        model
            |> updatePlayer
                worldName
                player.name
                (SPlayer.subtractTicks tickCost
                    >> SPlayer.setLocation (Map.toTileNum newCoords)
                )
            |> sendCurrentWorld worldName player.name clientId
            |> Cmd.andThen (\m -> ( m, refreshAdminData m ))


createNewChar : NewChar -> ClientId -> World -> World.Name -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )
createNewChar newChar clientId _ _ player model =
    case player of
        Player _ ->
            ( model, Cmd.none )

        NeedsCharCreated _ ->
            ( model
            , Task.perform (CreateNewCharWithTime clientId newChar) Time.now
            )


createNewCharWithTime : NewChar -> Posix -> ClientId -> World -> World.Name -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )
createNewCharWithTime newChar currentTime clientId world worldName player model =
    case player of
        Player _ ->
            ( model, Cmd.none )

        NeedsCharCreated auth ->
            case Player.fromNewChar currentTime auth newChar of
                Err creationError ->
                    ( model
                    , Lamdera.sendToFrontend clientId <| CharCreationError creationError
                    )

                Ok sPlayer ->
                    let
                        newPlayer : Player SPlayer
                        newPlayer =
                            Player sPlayer

                        newCPlayer : CPlayer
                        newCPlayer =
                            Player.serverToClient sPlayer

                        newModel : Model
                        newModel =
                            updateWorld
                                worldName
                                (\world_ -> { world_ | players = Dict.insert auth.name newPlayer world_.players })
                                model

                        data : PlayerData
                        data =
                            getPlayerData_ worldName world newPlayer
                    in
                    ( newModel
                    , Lamdera.sendToFrontend clientId <| YouHaveCreatedChar newCPlayer data
                    )


tagSkill : Skill -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
tagSkill skill clientId _ worldName player model =
    let
        totalTagsAvailable : Int
        totalTagsAvailable =
            Logic.totalTags { hasTagPerk = Perk.rank Perk.Tag player.perks > 0 }

        unusedTags : Int
        unusedTags =
            totalTagsAvailable - SeqSet.size player.taggedSkills

        isTagged : Bool
        isTagged =
            SeqSet.member skill player.taggedSkills
    in
    if unusedTags > 0 && not isTagged then
        model
            |> updatePlayer worldName player.name (SPlayer.tagSkill skill)
            |> sendCurrentWorld worldName player.name clientId

    else
        -- TODO notify the user?
        ( model, Cmd.none )


useSkillPoints : Skill -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
useSkillPoints skill clientId _ worldName player model =
    model
        |> updatePlayer worldName player.name (SPlayer.useSkillPoints skill)
        |> sendCurrentWorld worldName player.name clientId


healMe : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
healMe clientId _ worldName player model =
    model
        |> updatePlayer worldName player.name SPlayer.healManuallyUsingTick
        |> sendCurrentWorld worldName player.name clientId


equipArmor : Item.Id -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
equipArmor itemId clientId _ worldName player model =
    case Dict.get itemId player.items of
        Nothing ->
            ( model, Cmd.none )

        Just item ->
            if Item.isArmor item.kind then
                model
                    |> updatePlayer worldName player.name (SPlayer.equipArmor item)
                    |> sendCurrentWorld worldName player.name clientId

            else
                ( model, Cmd.none )


equipWeapon : Item.Id -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
equipWeapon itemId clientId _ worldName player model =
    case Dict.get itemId player.items of
        Nothing ->
            ( model, Cmd.none )

        Just item ->
            if Item.isWeapon item.kind then
                model
                    |> updatePlayer worldName player.name (SPlayer.equipWeapon item)
                    |> sendCurrentWorld worldName player.name clientId

            else
                ( model, Cmd.none )


setFightStrategy : ( FightStrategy, String ) -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
setFightStrategy ( strategy, text ) clientId _ worldName player model =
    model
        |> updatePlayer worldName player.name (SPlayer.setFightStrategy ( strategy, text ))
        |> sendCurrentWorld worldName player.name clientId


useItem : Item.Id -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
useItem itemId clientId _ worldName player model =
    case Dict.get itemId player.items of
        Nothing ->
            ( model, Cmd.none )

        Just item ->
            if item.count <= 0 then
                {- In case there is a bug that leaves `0x Stimpak` in our
                   inventory or something similar. It sometimes happens, we're
                   not perfect :)

                   When writing this, the occasion was running a fight strategy
                   and healing inside a fight.
                -}
                model
                    |> updatePlayer worldName player.name (SPlayer.removeItem itemId 1)
                    |> sendCurrentWorld worldName player.name clientId

            else
                let
                    effects : List Item.Effect
                    effects =
                        Item.usageEffects item.kind
                in
                case Logic.canUseItem player item.kind of
                    Err _ ->
                        ( model, Cmd.none )

                    Ok () ->
                        let
                            handleEffect : Item.Effect -> Generator (SPlayer -> SPlayer)
                            handleEffect effect =
                                case effect of
                                    Item.Heal r ->
                                        Item.healAmountGenerator_ r
                                            |> Random.map SPlayer.addHp

                                    Item.RemoveAfterUse ->
                                        SPlayer.removeItem itemId 1
                                            |> Random.constant

                                    Item.BookRemoveTicks ->
                                        SPlayer.subtractTicks
                                            (Logic.bookUseTickCost { intelligence = player.special.intelligence })
                                            |> Random.constant

                                    Item.BookAddSkillPercent skill ->
                                        SPlayer.addSkillPercentage
                                            (Logic.bookAddedSkillPercentage
                                                { currentPercentage = Skill.get player.special player.addedSkillPercentages skill
                                                , hasComprehensionPerk = Perk.rank Perk.Comprehension player.perks > 0
                                                }
                                            )
                                            skill
                                            |> Random.constant

                            combinedEffectsGen : Generator (SPlayer -> SPlayer)
                            combinedEffectsGen =
                                effects
                                    |> List.map handleEffect
                                    |> List.foldl
                                        (Random.map2 (>>))
                                        (Random.constant identity)

                            ( combinedEffects, newRandomSeed ) =
                                Random.step combinedEffectsGen model.randomSeed
                        in
                        { model | randomSeed = newRandomSeed }
                            |> updatePlayer worldName player.name combinedEffects
                            |> sendCurrentWorld worldName player.name clientId


unequipArmor : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
unequipArmor clientId _ worldName player model =
    case player.equippedArmor of
        Nothing ->
            ( model, Cmd.none )

        Just _ ->
            model
                |> updatePlayer worldName player.name SPlayer.unequipArmor
                |> sendCurrentWorld worldName player.name clientId


unequipWeapon : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
unequipWeapon clientId _ worldName player model =
    case player.equippedWeapon of
        Nothing ->
            ( model, Cmd.none )

        Just _ ->
            model
                |> updatePlayer worldName player.name SPlayer.unequipWeapon
                |> sendCurrentWorld worldName player.name clientId


wander : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
wander clientId world worldName player model =
    let
        isInTown : Bool
        isInTown =
            Location.location player.location /= Nothing

        notEnoughTicks : Bool
        notEnoughTicks =
            player.ticks <= 0
    in
    if isInTown || notEnoughTicks then
        ( model, Cmd.none )

    else
        let
            possibleEnemies : List Enemy.Type
            possibleEnemies =
                player.location
                    |> Map.toTileCoords
                    |> SmallChunk.forCoords
                    |> Enemy.forSmallChunk

            enemyTypeGenerator : Generator Enemy.Type
            enemyTypeGenerator =
                Random.List.choose possibleEnemies
                    |> Random.map (Tuple.first >> Maybe.withDefault Enemy.default)

            fightGen : Generator ( FightGen.Fight, Int )
            fightGen =
                enemyTypeGenerator
                    |> Random.andThen
                        (FightGen.enemyOpponentGenerator
                            { hasFortuneFinderPerk = Perk.rank Perk.FortuneFinder player.perks > 0 }
                            world.lastItemId
                        )
                    |> Random.andThen
                        (\( enemyOpponent, newItemId ) ->
                            FightGen.generator
                                { attacker = FightGen.playerOpponent player
                                , target = enemyOpponent
                                , currentTime = model.time
                                }
                                |> Random.map (\f -> ( f, newItemId ))
                        )

            ( fight_, newRandomSeed ) =
                Random.step fightGen model.randomSeed
        in
        { model | randomSeed = newRandomSeed }
            |> processFight clientId worldName player fight_


processFight : ClientId -> World.Name -> SPlayer -> ( FightGen.Fight, Int ) -> Model -> ( Model, Cmd BackendMsg )
processFight clientId worldName sPlayer ( fight_, newItemId ) model =
    let
        targetIsPlayer : Bool
        targetIsPlayer =
            Fight.isPlayer fight_.finalTarget.type_

        updateIfPlayer : (SPlayer -> SPlayer) -> Opponent -> Model -> Model
        updateIfPlayer fn opponent =
            case opponent.type_ of
                Fight.Npc _ ->
                    identity

                Fight.Player player ->
                    updatePlayer worldName player.name fn

        newModel =
            { model
                | worlds =
                    model.worlds
                        |> Dict.update worldName (Maybe.map (\world -> { world | lastItemId = newItemId }))
            }
                |> updateIfPlayer
                    (\player ->
                        player
                            |> SPlayer.setHp fight_.finalAttacker.hp
                            |> SPlayer.subtractTicks 1
                            |> SPlayer.setItems fight_.finalAttacker.items
                            |> (if targetIsPlayer then
                                    SPlayer.addMessage
                                        { read = True }
                                        model.time
                                        fight_.messageForAttacker

                                else
                                    identity
                               )
                    )
                    fight_.finalAttacker
                |> updateIfPlayer
                    (\player ->
                        player
                            |> SPlayer.setHp fight_.finalTarget.hp
                            |> SPlayer.setItems fight_.finalTarget.items
                            |> SPlayer.addMessage
                                { read = False }
                                model.time
                                fight_.messageForTarget
                    )
                    fight_.finalTarget
                |> (case fight_.fightInfo.result of
                        Fight.BothDead ->
                            identity

                        Fight.NobodyDead ->
                            identity

                        Fight.NobodyDeadGivenUp ->
                            identity

                        Fight.TargetAlreadyDead ->
                            identity

                        Fight.AttackerWon { xpGained, capsGained, itemsGained } ->
                            identity
                                >> updateIfPlayer
                                    (\player ->
                                        player
                                            |> SPlayer.addXp xpGained model.time
                                            |> SPlayer.addCaps capsGained
                                            |> SPlayer.addItems itemsGained
                                            |> (if targetIsPlayer then
                                                    SPlayer.incWins

                                                else
                                                    identity
                                               )
                                    )
                                    fight_.finalAttacker
                                >> updateIfPlayer
                                    (\player ->
                                        player
                                            |> SPlayer.subtractCaps capsGained
                                            |> SPlayer.removeItems (List.map (\item -> ( item.id, item.count )) itemsGained)
                                            |> SPlayer.incLosses
                                    )
                                    fight_.finalTarget

                        Fight.TargetWon { xpGained, capsGained, itemsGained } ->
                            identity
                                >> updateIfPlayer
                                    (\player ->
                                        player
                                            |> SPlayer.subtractCaps capsGained
                                            |> SPlayer.removeItems (List.map (\item -> ( item.id, item.count )) itemsGained)
                                            |> (if targetIsPlayer then
                                                    SPlayer.incLosses

                                                else
                                                    identity
                                               )
                                    )
                                    fight_.finalAttacker
                                >> updateIfPlayer
                                    (\player ->
                                        player
                                            |> SPlayer.addXp xpGained model.time
                                            |> SPlayer.addCaps capsGained
                                            |> SPlayer.addItems itemsGained
                                            |> SPlayer.incWins
                                    )
                                    fight_.finalTarget
                   )
    in
    getPlayerData worldName sPlayer.name newModel
        |> Maybe.map
            (\world ->
                ( newModel
                , Lamdera.sendToFrontend clientId <|
                    YourFightResult
                        ( fight_.fightInfo
                        , world
                        )
                )
            )
        -- Shouldn't happen but we don't have a good way of getting rid of the Maybe
        |> Maybe.withDefault ( newModel, Cmd.none )


oneTimePerkEffects : Posix -> SeqDict Perk (SPlayer -> SPlayer)
oneTimePerkEffects currentTime =
    let
        oneTimeEffect : Perk -> Maybe (SPlayer -> SPlayer)
        oneTimeEffect perk =
            case perk of
                Perk.HereAndNow ->
                    Just <| SPlayer.levelUpHereAndNow currentTime

                Perk.Survivalist ->
                    Just <| SPlayer.addSkillPercentage 25 Skill.Outdoorsman

                Perk.GainStrength ->
                    Just <| SPlayer.incSpecial Special.Strength

                Perk.GainPerception ->
                    Just <| SPlayer.incSpecial Special.Perception

                Perk.GainEndurance ->
                    Just <| SPlayer.incSpecial Special.Endurance

                Perk.GainCharisma ->
                    Just <| SPlayer.incSpecial Special.Charisma

                Perk.GainIntelligence ->
                    Just <| SPlayer.incSpecial Special.Intelligence

                Perk.GainAgility ->
                    Just <| SPlayer.incSpecial Special.Agility

                Perk.GainLuck ->
                    Just <| SPlayer.incSpecial Special.Luck

                Perk.Thief ->
                    Just <|
                        \player ->
                            player
                                |> SPlayer.addSkillPercentage 10 Skill.Sneak
                                |> SPlayer.addSkillPercentage 10 Skill.Lockpick
                                |> SPlayer.addSkillPercentage 10 Skill.Steal
                                |> SPlayer.addSkillPercentage 10 Skill.Traps

                Perk.AdrenalineRush ->
                    Just <|
                        \player ->
                            SPlayer.updateStrengthForAdrenalineRush
                                { oldHp = player.maxHp
                                , oldMaxHp = player.maxHp
                                , newHp = player.hp
                                , newMaxHp = player.maxHp
                                }
                                player

                Perk.Gambler ->
                    Just <| SPlayer.addSkillPercentage 20 Skill.Gambling

                Perk.Negotiator ->
                    Just <|
                        \player ->
                            player
                                |> SPlayer.addSkillPercentage 10 Skill.Speech
                                |> SPlayer.addSkillPercentage 10 Skill.Barter

                Perk.Ranger ->
                    Just <| SPlayer.addSkillPercentage 15 Skill.Outdoorsman

                Perk.Salesman ->
                    Just <| SPlayer.addSkillPercentage 20 Skill.Barter

                Perk.Speaker ->
                    Just <| SPlayer.addSkillPercentage 20 Skill.Speech

                Perk.Lifegiver ->
                    Just SPlayer.recalculateHp

                Perk.LivingAnatomy ->
                    Just <| SPlayer.addSkillPercentage 10 Skill.Doctor

                Perk.MasterThief ->
                    Just <|
                        \player ->
                            player
                                |> SPlayer.addSkillPercentage 15 Skill.Lockpick
                                |> SPlayer.addSkillPercentage 15 Skill.Steal

                Perk.Medic ->
                    Just <|
                        \player ->
                            player
                                |> SPlayer.addSkillPercentage 10 Skill.FirstAid
                                |> SPlayer.addSkillPercentage 10 Skill.Doctor

                Perk.MrFixit ->
                    Just <|
                        \player ->
                            player
                                |> SPlayer.addSkillPercentage 10 Skill.Repair
                                |> SPlayer.addSkillPercentage 10 Skill.Science

                Perk.BonusHthAttacks ->
                    Nothing

                Perk.BonusRateOfFire ->
                    Nothing

                Perk.BonusHthDamage ->
                    Nothing

                Perk.MasterTrader ->
                    Nothing

                Perk.Awareness ->
                    Nothing

                Perk.CautiousNature ->
                    Nothing

                Perk.Comprehension ->
                    Nothing

                Perk.EarlierSequence ->
                    Nothing

                Perk.FasterHealing ->
                    Nothing

                Perk.SwiftLearner ->
                    Nothing

                Perk.Toughness ->
                    Nothing

                Perk.Educated ->
                    Nothing

                Perk.MoreCriticals ->
                    Nothing

                Perk.BetterCriticals ->
                    Nothing

                Perk.Tag ->
                    Nothing

                Perk.Slayer ->
                    Nothing

                Perk.FortuneFinder ->
                    Nothing

                Perk.Pathfinder ->
                    Nothing

                Perk.Dodger ->
                    Nothing

                Perk.ActionBoy ->
                    Nothing

                Perk.HthEvade ->
                    Nothing

                Perk.GeckoSkinning ->
                    Nothing
    in
    Perk.all
        |> List.filterMap (\perk -> oneTimeEffect perk |> Maybe.map (Tuple.pair perk))
        |> SeqDict.fromList


choosePerk : Perk -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
choosePerk perk clientId _ worldName player model =
    let
        level =
            Xp.currentLevel player.xp
    in
    if
        Perk.isApplicableForLevelup
            { addedSkillPercentages = player.addedSkillPercentages
            , special = player.special
            , level = level
            , perks = player.perks
            }
            perk
    then
        model
            |> updatePlayer
                worldName
                player.name
                (identity
                    >> SPlayer.incPerkRank perk
                    >> SPlayer.decAvailablePerks
                    >> (case SeqDict.get perk (oneTimePerkEffects model.time) of
                            Nothing ->
                                identity

                            Just effect ->
                                effect
                       )
                )
            |> sendCurrentWorld worldName player.name clientId

    else
        ( model, Cmd.none )


sendCurrentWorld : World.Name -> PlayerName -> ClientId -> Model -> ( Model, Cmd BackendMsg )
sendCurrentWorld worldName playerName clientId model =
    getPlayerData worldName playerName model
        |> Maybe.map
            (\world ->
                ( model
                , Lamdera.sendToFrontend clientId <| CurrentPlayer world
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


fight : PlayerName -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
fight otherPlayerName clientId world worldName sPlayer model =
    if sPlayer.ticks <= 0 then
        ( model, Cmd.none )

    else if sPlayer.hp <= 0 then
        ( model, Cmd.none )

    else
        Dict.get otherPlayerName world.players
            |> Maybe.andThen Player.getPlayerData
            |> Maybe.map
                (\target ->
                    if target.hp == 0 then
                        let
                            fight_ : ( FightGen.Fight, Int )
                            fight_ =
                                ( FightGen.targetAlreadyDead
                                    { attacker = FightGen.playerOpponent sPlayer
                                    , target = FightGen.playerOpponent target
                                    , currentTime = model.time
                                    }
                                , world.lastItemId
                                )
                        in
                        model
                            |> processFight clientId worldName sPlayer fight_

                    else
                        let
                            fightGen : Generator ( FightGen.Fight, Int )
                            fightGen =
                                FightGen.generator
                                    { attacker = FightGen.playerOpponent sPlayer
                                    , target = FightGen.playerOpponent target
                                    , currentTime = model.time
                                    }
                                    |> Random.map (\f -> ( f, world.lastItemId ))

                            ( fight_, newRandomSeed ) =
                                Random.step fightGen model.randomSeed
                        in
                        { model | randomSeed = newRandomSeed }
                            |> processFight clientId worldName sPlayer fight_
                )
            |> Maybe.withDefault ( model, Cmd.none )


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect Connected
        , Lamdera.onDisconnect Disconnected
        , Time.every 1000 Tick
        ]


savePlayer : World.Name -> SPlayer -> Model -> Model
savePlayer worldName newPlayer model =
    updatePlayer worldName newPlayer.name (always newPlayer) model


updateWorld_ : World.Name -> (World -> ( World, Cmd BackendMsg )) -> Model -> ( Model, Cmd BackendMsg )
updateWorld_ worldName fn model =
    case Dict.get worldName model.worlds of
        Nothing ->
            ( model, Cmd.none )

        Just world ->
            let
                ( newWorld, cmd ) =
                    fn world
            in
            ( { model | worlds = Dict.insert worldName newWorld model.worlds }
            , cmd
            )


updateWorld : World.Name -> (World -> World) -> Model -> Model
updateWorld worldName fn model =
    { model | worlds = Dict.update worldName (Maybe.map fn) model.worlds }


updatePlayer : World.Name -> PlayerName -> (SPlayer -> SPlayer) -> Model -> Model
updatePlayer worldName playerName fn model =
    model
        |> updateWorld
            worldName
            (\world ->
                { world
                    | players =
                        Dict.update
                            playerName
                            (Maybe.map (Player.map fn))
                            world.players
                }
            )


updateVendor : World.Name -> Location -> (Vendor -> Vendor) -> Model -> Model
updateVendor worldName location fn model =
    model
        |> updateWorld
            worldName
            (\world ->
                { world
                    | vendors =
                        case Vendor.forLocation location of
                            Nothing ->
                                world.vendors

                            Just vendorName ->
                                SeqDict.update vendorName (Maybe.map fn) world.vendors
                }
            )


createItem : World.Name -> World -> { uniqueKey : Item.UniqueKey, count : Int } -> Model -> ( Item, Model )
createItem worldName world { uniqueKey, count } model =
    -- TODO why is this not used?
    let
        ( item, newLastId ) =
            Item.create
                { lastId = world.lastItemId
                , uniqueKey = uniqueKey
                , count = count
                }
    in
    ( item
    , { model | worlds = model.worlds |> Dict.insert worldName { world | lastItemId = newLastId } }
    )


stopProgressing : Quest.Name -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
stopProgressing quest clientId _ worldName player model =
    let
        newModel =
            model
                |> updatePlayer worldName player.name (SPlayer.stopProgressing quest)
    in
    getPlayerData worldName player.name newModel
        |> Maybe.map
            (\data ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| CurrentPlayer data
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


startProgressing : Quest.Name -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
startProgressing quest clientId world worldName player model =
    let
        ensurePlayerIsInQuestProgressDict : World -> World
        ensurePlayerIsInQuestProgressDict world_ =
            if SPlayer.canStartProgressing quest world.tickPerIntervalCurve player then
                { world_
                    | questsProgress =
                        world_.questsProgress
                            |> SeqDict.update quest
                                (\maybePlayersProgress ->
                                    case maybePlayersProgress of
                                        Nothing ->
                                            Just (Dict.singleton player.name 0)

                                        Just playersProgress ->
                                            playersProgress
                                                |> Dict.update player.name
                                                    (\maybePlayerProgress ->
                                                        case maybePlayerProgress of
                                                            Nothing ->
                                                                Just 0

                                                            Just n ->
                                                                Just n
                                                    )
                                                |> Just
                                )
                }

            else
                world_

        newModel =
            model
                |> updatePlayer worldName player.name (SPlayer.startProgressing quest world.tickPerIntervalCurve)
                |> updateWorld worldName ensurePlayerIsInQuestProgressDict
    in
    getPlayerData worldName player.name newModel
        |> Maybe.map
            (\data ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| CurrentPlayer data
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )
