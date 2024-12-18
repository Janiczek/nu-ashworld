module Backend exposing (..)

import Admin
import BiDict
import Cmd.Extra as Cmd
import Cmd.ExtraExtra as Cmd
import Codec
import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Barter as Barter
import Data.Enemy as Enemy
import Data.Enemy.Type as EnemyType exposing (EnemyType)
import Data.Fight as Fight exposing (Opponent)
import Data.Fight.Generator as FightGen
import Data.Fight.OpponentType as OpponentType
import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item exposing (Item)
import Data.Item.Effect as ItemEffect
import Data.Item.Kind as ItemKind
import Data.Ladder as Ladder
import Data.Map exposing (TileCoords)
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Map.SmallChunk as SmallChunk
import Data.Map.Terrain as Terrain
import Data.Message as Message
import Data.NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Perk.Requirement as PerkRequirement
import Data.Player as Player
    exposing
        ( CPlayer
        , Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Player.SPlayer as SPlayer
import Data.Quest as Quest exposing (Quest)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Data.Tick as Tick
import Data.Vendor as Vendor exposing (Vendor)
import Data.Vendor.Shop as Shop exposing (Shop)
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
import SeqSet exposing (SeqSet)
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
      , isInMaintenance = False
      }
    , Task.perform FirstTick Time.now
    )


restockVendors : World.Name -> Model -> ( Model, Cmd BackendMsg )
restockVendors worldName model =
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
                    |> Maybe.andThen Player.getPlayerData
                    |> Maybe.map (getPlayerData_ worldName world)
            )


{-| A "child" helper of getPlayerData for when you already have
the `Player SPlayer` value fetched.
-}
getPlayerData_ : World.Name -> World -> SPlayer -> PlayerData
getPlayerData_ worldName world player =
    let
        hasAwarenessPerk : Bool
        hasAwarenessPerk =
            Perk.rank Perk.Awareness player.perks > 0

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = hasAwarenessPerk
                }

        players =
            world.players
                |> Dict.values
                |> List.filterMap Player.getPlayerData

        sortedPlayers =
            Ladder.sort players

        isCurrentPlayer p =
            p.name == player.name

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
    , player = Player.serverToClient player
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
                                { perceptionLevel = perceptionLevel
                                , hasAwarenessPerk = hasAwarenessPerk
                                }
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
                        engagedPlayersCount : Int
                        engagedPlayersCount =
                            players
                                |> List.count (\player_ -> SeqSet.member quest player_.questsActive)

                        ticksPerHour : Int
                        ticksPerHour =
                            engagedPlayersCount * Logic.questTicksPerHour

                        ticksGiven : Int
                        ticksGiven =
                            ticksGivenPerPlayer
                                |> Dict.values
                                |> List.sum

                        ticksGivenByPlayer : Int
                        ticksGivenByPlayer =
                            Dict.get player.name ticksGivenPerPlayer
                                |> Maybe.withDefault 0
                    in
                    { ticksGiven = ticksGiven
                    , ticksPerHour = ticksPerHour
                    , playersActive = engagedPlayersCount
                    , ticksGivenByPlayer = ticksGivenByPlayer
                    , alreadyPaidRequirements =
                        world.questRequirementsPaid
                            |> SeqDict.get quest
                            |> Maybe.withDefault Set.empty
                            |> Set.member player.name
                    }
                )
    , questRewardShops = world.questRewardShops
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
            , Lamdera.sendToFrontend clientId <|
                CurrentWorlds
                    { worlds = worlds
                    , isInMaintenance = model.isInMaintenance
                    }
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
                                                        { model_
                                                            | worlds =
                                                                model_.worlds
                                                                    |> Dict.update worldName (Maybe.map (updateNextWantedTick nextTick))
                                                        }
                                                            -- On init, run the action immediately.
                                                            |> postprocess worldName

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
                                                                -- Enough time elapsed, run the action.
                                                                |> postprocess worldName

                                                        else
                                                            -- Not enough time elapsed, do nothing.
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
                                            |> Cmd.andThen (refreshPlayersOnWorld worldName)
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
    model
        |> processGameTickForPlayers worldName
        |> processGameTickForQuests worldName
        |> Cmd.pure


processGameTickForPlayers : String -> Model -> Model
processGameTickForPlayers worldName model =
    model
        |> updateWorld worldName
            (\world ->
                { world
                    | players =
                        Dict.map
                            (always (Player.map (SPlayer.tick model.time world.tickPerIntervalCurve)))
                            world.players
                }
            )


processGameTickForQuests : String -> Model -> Model
processGameTickForQuests worldName model =
    let
        modelWithUpdatedWorld =
            model
                |> updateWorld worldName
                    (\world ->
                        { world
                            | questsProgress =
                                SeqDict.map
                                    (\quest progressPerPlayer ->
                                        if World.isQuestDone_ progressPerPlayer quest then
                                            progressPerPlayer

                                        else
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
                                                                            if SeqSet.member quest player_.questsActive then
                                                                                Logic.questTicksPerHour

                                                                            else
                                                                                0
                                                                        )
                                                                    |> Maybe.withDefault 0
                                                        in
                                                        progress + ticksGiven
                                                    )
                                    )
                                    world.questsProgress
                        }
                    )

        completedQuests : SeqSet Quest
        completedQuests =
            Maybe.map2
                (\oldWorld newWorld ->
                    Quest.all
                        |> List.filter
                            (\quest ->
                                not (World.isQuestDone oldWorld quest)
                                    && World.isQuestDone newWorld quest
                            )
                        |> SeqSet.fromList
                )
                (Dict.get worldName model.worlds)
                (Dict.get worldName modelWithUpdatedWorld.worlds)
                |> Maybe.withDefault SeqSet.empty
    in
    if SeqSet.isEmpty completedQuests then
        modelWithUpdatedWorld

    else
        List.foldl
            (\completedQuest model_ ->
                { model_
                    | worlds =
                        model_.worlds
                            |> Dict.update worldName
                                (Maybe.map
                                    (\world ->
                                        let
                                            ( newLastItemId, updatedPlayers ) =
                                                Dict.foldl
                                                    (\playerName player ( lastItemId, players ) ->
                                                        case player of
                                                            Player.NeedsCharCreated _ ->
                                                                ( lastItemId, players )

                                                            Player.Player playerData ->
                                                                if SeqSet.member completedQuest playerData.questsActive then
                                                                    let
                                                                        ticksGiven =
                                                                            World.ticksGiven completedQuest playerData.name world.questsProgress

                                                                        xpReward =
                                                                            Quest.xpPerTickGiven completedQuest * ticksGiven

                                                                        playerRewards =
                                                                            Quest.playerRewards completedQuest

                                                                        enoughTicksGivenForReward =
                                                                            ticksGiven >= playerRewards.ticksNeeded

                                                                        ( newLastItemId_, newPlayerData ) =
                                                                            { playerData
                                                                                | questsActive =
                                                                                    playerData.questsActive
                                                                                        |> SeqSet.remove completedQuest
                                                                            }
                                                                                |> SPlayer.addMessage
                                                                                    { read = False }
                                                                                    model.time
                                                                                    (Message.YouCompletedAQuest
                                                                                        { quest = completedQuest
                                                                                        , xpReward = xpReward
                                                                                        , playerReward =
                                                                                            if enoughTicksGivenForReward then
                                                                                                Just playerRewards.rewards

                                                                                            else
                                                                                                Nothing
                                                                                        , globalRewards = Quest.globalRewards completedQuest
                                                                                        }
                                                                                    )
                                                                                |> (if enoughTicksGivenForReward then
                                                                                        applyPlayerQuestRewards playerRewards.rewards lastItemId

                                                                                    else
                                                                                        \p -> ( lastItemId, p )
                                                                                   )
                                                                    in
                                                                    ( newLastItemId_
                                                                    , players
                                                                        |> Dict.insert playerName (Player.Player newPlayerData)
                                                                    )

                                                                else
                                                                    let
                                                                        newPlayerData =
                                                                            playerData
                                                                                |> SPlayer.addMessage
                                                                                    { read = False }
                                                                                    model.time
                                                                                    (Message.OthersCompletedAQuest
                                                                                        { quest = completedQuest
                                                                                        , globalRewards = Quest.globalRewards completedQuest
                                                                                        }
                                                                                    )
                                                                    in
                                                                    ( lastItemId
                                                                    , players
                                                                        |> Dict.insert playerName (Player.Player newPlayerData)
                                                                    )
                                                    )
                                                    ( world.lastItemId, world.players )
                                                    world.players
                                        in
                                        List.foldl
                                            applyGlobalQuestReward
                                            { world
                                                | players = updatedPlayers
                                                , lastItemId = newLastItemId
                                            }
                                            (Quest.globalRewards completedQuest)
                                    )
                                )
                }
            )
            modelWithUpdatedWorld
            (SeqSet.toList completedQuests)


applyPlayerQuestRewards : List Quest.PlayerReward -> Int -> SPlayer -> ( Int, SPlayer )
applyPlayerQuestRewards rewards lastItemId player =
    List.foldl
        applyPlayerQuestReward
        ( lastItemId, player )
        rewards


applyPlayerQuestReward : Quest.PlayerReward -> ( Int, SPlayer ) -> ( Int, SPlayer )
applyPlayerQuestReward reward ( lastItemId, player ) =
    case reward of
        Quest.ItemReward { what, amount } ->
            ( lastItemId + 1
            , player
                |> SPlayer.addItem { id = lastItemId, kind = what, count = amount }
            )

        Quest.SkillUpgrade { skill, percentage } ->
            ( lastItemId
            , { player
                | addedSkillPercentages =
                    player.addedSkillPercentages
                        |> SeqDict.update skill
                            (\maybeCurrentPct ->
                                Maybe.withDefault 0 maybeCurrentPct
                                    |> (+) percentage
                                    |> Just
                            )
              }
            )

        Quest.PerkReward perk ->
            ( lastItemId
            , { player
                | perks =
                    player.perks
                        |> SeqDict.update perk
                            (\maybeCount ->
                                (1 + Maybe.withDefault 0 maybeCount)
                                    |> min (Perk.maxRank perk)
                                    |> Just
                            )
              }
            )

        Quest.CapsReward amount ->
            ( lastItemId
            , { player | caps = player.caps + amount }
            )

        Quest.CarReward ->
            ( lastItemId
            , { player | carBatteryPromile = Just 1000 }
            )

        Quest.TravelToEnclaveReward ->
            -- TODO reset barter etc.? What might be happening while we're teleporting the player away?
            ( lastItemId
            , { player
                | location =
                    Location.EnclavePlatform
                        |> Location.coords
              }
            )


applyGlobalQuestReward : Quest.GlobalReward -> World -> World
applyGlobalQuestReward reward world =
    case reward of
        Quest.NewItemsInStock { who, what, amount } ->
            { world
                | vendors =
                    world.vendors
                        |> SeqDict.update who
                            (Maybe.map
                                (\vendor ->
                                    { vendor
                                        | currentSpec =
                                            { stock =
                                                vendor.currentSpec.stock
                                                    |> SeqDict.insert { kind = what } { maxCount = amount }
                                            , caps = vendor.currentSpec.caps
                                            }
                                    }
                                )
                            )
            }

        Quest.Discount { who, percentage } ->
            { world
                | vendors =
                    world.vendors
                        |> SeqDict.update who
                            (Maybe.map
                                (\vendor ->
                                    { vendor | discountPct = vendor.discountPct + percentage }
                                )
                            )
            }

        Quest.VendorAvailable who ->
            { world
                | questRewardShops =
                    world.questRewardShops
                        |> SeqSet.insert who
            }

        Quest.EndTheGame ->
            -- TODO do something!
            world


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
                                        , ( "to-backend-msg"
                                          , msg
                                                |> Codec.encodeToString 0 Admin.toBackendMsgCodec
                                                |> JE.string
                                          )
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
                                    let
                                        data =
                                            getPlayerData auth.worldName auth.name model

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

                                        msgToSend =
                                            case data of
                                                Nothing ->
                                                    YoureLoggedInSigningUp

                                                Just data_ ->
                                                    YoureLoggedIn data_
                                    in
                                    ( newModel
                                    , Cmd.batch <|
                                        Lamdera.sendToFrontend clientId msgToSend
                                            :: refreshAdminLoggedInPlayers newModel
                                            :: (clientIdsToLogout
                                                    |> Set.toList
                                                    |> List.map (\cId -> Lamdera.sendToFrontend cId <| YoureLoggedOut loggedOutData)
                                               )
                                    )

                                else
                                    ( model
                                    , Lamdera.sendToFrontend clientId <| AlertMessage "Login failed"
                                    )

        SignMeUp auth ->
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
                                    in
                                    ( newModel
                                    , Cmd.batch
                                        [ Lamdera.sendToFrontend clientId YoureSignedUp
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

        PreferAmmo itemKind ->
            withLoggedInCreatedPlayer <| preferAmmo itemKind

        UnequipArmor ->
            withLoggedInCreatedPlayer unequipArmor

        UnequipWeapon ->
            withLoggedInCreatedPlayer unequipWeapon

        ClearPreferredAmmo ->
            withLoggedInCreatedPlayer clearPreferredAmmo

        SetFightStrategy ( strategy, text ) ->
            withLoggedInCreatedPlayer <| setFightStrategy ( strategy, text )

        ChoosePerk perk ->
            withLoggedInCreatedPlayer <| choosePerk perk

        WorldsPlease ->
            let
                worlds =
                    getWorlds model
            in
            ( model
            , Lamdera.sendToFrontend clientId <|
                CurrentWorlds
                    { worlds = worlds
                    , isInMaintenance = model.isInMaintenance
                    }
            )

        RefreshPlease ->
            let
                loggedOut () =
                    ( model
                    , Lamdera.sendToFrontend clientId <|
                        CurrentWorlds
                            { worlds = getWorlds model
                            , isInMaintenance = model.isInMaintenance
                            }
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

        RemoveAllMessages ->
            withLoggedInCreatedPlayer removeAllMessages

        Barter barterState shop ->
            withLocation (barter barterState shop)

        AdminToBackend adminMsg ->
            withAdmin (updateAdmin clientId adminMsg)

        StopProgressing quest ->
            withLoggedInCreatedPlayer (stopProgressing quest)

        StartProgressing quest ->
            withLoggedInCreatedPlayer (startProgressing quest)

        RefuelCar fuelKind ->
            withLoggedInCreatedPlayer (refuelCar fuelKind)


updateAdmin : ClientId -> AdminToBackend -> Model -> ( Model, Cmd BackendMsg )
updateAdmin clientId msg model =
    case msg of
        ExportJson ->
            let
                json : String
                json =
                    model
                        |> Codec.encodeToString 0 (Admin.backendModelCodec model.randomSeed)
            in
            ( model
            , Lamdera.sendToFrontend clientId <| JsonExportDone json
            )

        ImportJson jsonString ->
            case Codec.decodeString (Admin.backendModelCodec model.randomSeed) jsonString of
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
                newModel
                    |> restockVendors worldName
                    |> Cmd.andThen
                        (\modelAfterRestocking ->
                            ( modelAfterRestocking
                            , Lamdera.sendToFrontend clientId <| CurrentAdmin <| getAdminData modelAfterRestocking
                            )
                        )

        ChangeWorldSpeed r ->
            case Dict.get r.world model.worlds of
                Nothing ->
                    ( model, Cmd.none )

                Just world ->
                    let
                        frequency =
                            if r.fast then
                                Time.Second

                            else
                                Time.Hour

                        newWorld : World
                        newWorld =
                            { world
                                | tickFrequency = frequency
                                , vendorRestockFrequency = frequency
                                , nextWantedTick = Nothing
                                , nextVendorRestockTick = Nothing
                            }

                        newModel =
                            { model | worlds = Dict.insert r.world newWorld model.worlds }
                    in
                    newModel
                        |> Cmd.with (refreshAdminData newModel)
                        |> Cmd.andThen (refreshPlayersOnWorld r.world)

        SwitchMaintenance r ->
            ( { model
                | isInMaintenance = r.now
                , playerDataCache = Dict.empty
                , loggedInPlayers = BiDict.empty
              }
            , Lamdera.broadcast <| MaintenanceModeChanged r
            )


refreshPlayersOnWorld : World.Name -> Model -> ( Model, Cmd BackendMsg )
refreshPlayersOnWorld worldName model =
    playersOnWorld worldName model
        |> List.foldl
            (\( ( wn, pn ), clientIds ) ( accModel, accCmds ) ->
                case getPlayerData wn pn model of
                    Nothing ->
                        ( accModel, accCmds )

                    Just playerData_ ->
                        let
                            newHash : Int
                            newHash =
                                Lamdera.Hash.hash
                                    Types.w3_encode_PlayerData_
                                    playerData_

                            newCmds : List (Cmd BackendMsg)
                            newCmds =
                                clientIds
                                    |> Set.toList
                                    |> List.filterMap
                                        (\clientId ->
                                            if Lamdera.Hash.hasChanged newHash clientId model.playerDataCache then
                                                Just (Lamdera.sendToFrontend clientId (CurrentPlayer playerData_))

                                            else
                                                Nothing
                                        )

                            newModel : Model
                            newModel =
                                clientIds
                                    |> Set.toList
                                    |> List.filter
                                        (\clientId ->
                                            Lamdera.Hash.hasChanged newHash clientId model.playerDataCache
                                        )
                                    |> List.foldl
                                        (\clientId m ->
                                            saveToPlayerDataCache clientId newHash m
                                        )
                                        accModel
                        in
                        ( newModel, newCmds ++ accCmds )
            )
            ( model, [] )
        |> Tuple.mapSecond Cmd.batch


playersOnWorld : World.Name -> Model -> List ( ( World.Name, PlayerName ), Set ClientId )
playersOnWorld worldName model =
    model.loggedInPlayers
        |> BiDict.toReverseList
        |> List.filter (\( ( wn, _ ), _ ) -> wn == worldName)


isAdmin : SessionId -> ClientId -> Model -> Bool
isAdmin sessionId clientId model =
    model.adminLoggedIn == Just ( sessionId, clientId )


barter : Barter.State -> Shop -> ClientId -> World -> World.Name -> Location -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
barter barterState shop clientId world worldName location player model =
    if Shop.isAvailable world.questRewardShops shop then
        let
            vendor : Vendor
            vendor =
                Vendor.getFrom world.vendors shop
        in
        let
            shopInLocation : Bool
            shopInLocation =
                Shop.forLocation location
                    |> List.member shop

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
                                |> Maybe.map (\item -> ItemKind.baseValue item.kind * count)
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
                                            { baseValue = count * ItemKind.baseValue item.kind
                                            , playerBarterSkill = Skill.get player.special player.addedSkillPercentages Skill.Barter
                                            , traderBarterSkill = Shop.barterSkill shop
                                            , hasMasterTraderPerk = Perk.rank Perk.MasterTrader player.perks > 0
                                            , discountPct = vendor.discountPct
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
                [ shopInLocation
                , barterNotEmpty
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

    else
        ( model, Cmd.none )


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
            updateVendor vendor.shop worldName location (Vendor.subtractCaps amount)

        addVendorCaps : Int -> Model -> Model
        addVendorCaps amount =
            updateVendor vendor.shop worldName location (Vendor.addCaps amount)

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
                            vendor.shop
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
                                    vendor.shop
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


removeAllMessages : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
removeAllMessages clientId _ worldName player model =
    let
        newModel =
            model
                |> updatePlayer worldName player.name SPlayer.removeAllMessages
    in
    case getPlayerData worldName player.name newModel of
        Nothing ->
            -- Shouldn't happen?
            ( newModel, Cmd.none )

        Just newWorld ->
            ( newModel
            , Lamdera.sendToFrontend clientId <| YourMessages newWorld.player.messages
            )


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

        Just newWorld ->
            ( newModel
            , Lamdera.sendToFrontend clientId <| YourMessages newWorld.player.messages
            )


moveTo : TileCoords -> Set TileCoords -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
moveTo newCoords pathTaken clientId _ worldName player model =
    let
        { tickCost, carBatteryPromileCost } =
            Pathfinding.cost
                { pathTaken = pathTaken
                , pathfinderPerkRanks = Perk.rank Perk.Pathfinder player.perks
                , carBatteryPromile = player.carBatteryPromile
                }

        isSamePosition : Bool
        isSamePosition =
            player.location == newCoords

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                }

        pathDoesntAgree : Bool
        pathDoesntAgree =
            pathTaken
                /= Set.remove player.location
                    (Pathfinding.path
                        perceptionLevel
                        { from = player.location
                        , to = newCoords
                        }
                    )

        notEnoughTicks : Bool
        notEnoughTicks =
            tickCost > player.ticks

        impassableTiles : Set TileCoords
        impassableTiles =
            pathTaken
                |> Set.filter (Terrain.forCoords >> Terrain.isPassable >> not)

        notAllPassable : Bool
        notAllPassable =
            not (Set.isEmpty impassableTiles)
    in
    if isSamePosition || pathDoesntAgree || notEnoughTicks || notAllPassable then
        ( model, Cmd.none )

    else
        model
            |> updatePlayer
                worldName
                player.name
                (SPlayer.subtractTicks tickCost
                    >> SPlayer.setLocation newCoords
                    >> SPlayer.removeCarBattery carBatteryPromileCost
                )
            |> sendCurrentWorld worldName player.name clientId
            |> Cmd.andThen (\m -> ( m, refreshAdminData m ))
            |> Cmd.andThen (\m -> ( m, refreshOtherPlayers worldName player.name m ))


{-| Don't send anything to the `initiatorPlayerName`, they already got a msg
with their full data. The others just need to know the location changed.
-}
refreshOtherPlayers : World.Name -> PlayerName -> Model -> Cmd BackendMsg
refreshOtherPlayers worldName initiatorPlayerName model =
    case Dict.get worldName model.worlds of
        Nothing ->
            Cmd.none

        Just world ->
            let
                allLoggedInPlayers : List ( ClientId, PlayerName )
                allLoggedInPlayers =
                    model.loggedInPlayers
                        |> BiDict.toList
                        |> List.filterMap
                            (\( clientId, ( wn, playerName ) ) ->
                                if wn == worldName then
                                    Just ( clientId, playerName )

                                else
                                    Nothing
                            )
            in
            allLoggedInPlayers
                |> List.filterMap
                    (\( clientId, playerName ) ->
                        if playerName == initiatorPlayerName then
                            -- Don't send anything to this one
                            Nothing

                        else
                            Dict.get playerName world.players
                                |> Maybe.andThen Player.getPlayerData
                                |> Maybe.andThen
                                    (\player ->
                                        -- We want to create a List COtherPlayer for this `player`.
                                        -- Let's go through all the players in the world again, filter out `playerName`
                                        -- and collect the data.
                                        let
                                            hasAwarenessPerk =
                                                Perk.rank Perk.Awareness player.perks > 0

                                            perceptionLevel =
                                                Perception.level
                                                    { perception = player.special.perception
                                                    , hasAwarenessPerk = hasAwarenessPerk
                                                    }
                                        in
                                        world.players
                                            |> Dict.values
                                            |> List.filterMap
                                                (\otherPlayer ->
                                                    otherPlayer
                                                        |> Player.getPlayerData
                                                        |> Maybe.andThen
                                                            (\otherPlayerData ->
                                                                if otherPlayerData.name == playerName then
                                                                    Nothing

                                                                else
                                                                    Player.serverToClientOther
                                                                        { perceptionLevel = perceptionLevel
                                                                        , hasAwarenessPerk = hasAwarenessPerk
                                                                        }
                                                                        otherPlayerData
                                                                        |> Just
                                                            )
                                                )
                                            |> CurrentOtherPlayers
                                            |> Lamdera.sendToFrontend clientId
                                            |> Just
                                    )
                    )
                |> Cmd.batch


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
                            getPlayerData_ worldName world sPlayer
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
            if ItemKind.isArmor item.kind then
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
            if ItemKind.isWeapon item.kind then
                model
                    |> updatePlayer worldName player.name (SPlayer.equipWeapon item)
                    |> sendCurrentWorld worldName player.name clientId

            else
                ( model, Cmd.none )


preferAmmo : ItemKind.Kind -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
preferAmmo itemKind clientId _ worldName player model =
    if ItemKind.isAmmo itemKind then
        model
            |> updatePlayer worldName player.name (SPlayer.preferAmmo itemKind)
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
                    effects : List ItemEffect.Effect
                    effects =
                        ItemKind.usageEffects item.kind
                in
                case Logic.canUseItem player item.kind of
                    Err _ ->
                        ( model, Cmd.none )

                    Ok () ->
                        let
                            handleEffect : ItemEffect.Effect -> Generator (SPlayer -> SPlayer)
                            handleEffect effect =
                                case effect of
                                    ItemEffect.Heal r ->
                                        Logic.healAmountGenerator_ r
                                            |> Random.map SPlayer.addHp

                                    ItemEffect.RemoveAfterUse ->
                                        SPlayer.removeItem itemId 1
                                            |> Random.constant

                                    ItemEffect.BookRemoveTicks ->
                                        SPlayer.subtractTicks
                                            (Logic.bookUseTickCost { intelligence = player.special.intelligence })
                                            |> Random.constant

                                    ItemEffect.BookAddSkillPercent skill ->
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


clearPreferredAmmo : ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
clearPreferredAmmo clientId _ worldName player model =
    case player.preferredAmmo of
        Nothing ->
            ( model, Cmd.none )

        Just _ ->
            model
                |> updatePlayer worldName player.name SPlayer.clearPreferredAmmo
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
            possibleEnemies : List EnemyType
            possibleEnemies =
                player.location
                    |> SmallChunk.forCoords
                    |> Enemy.forSmallChunk

            enemyTypeGenerator : Generator EnemyType
            enemyTypeGenerator =
                Random.List.choose possibleEnemies
                    |> Random.map (Tuple.first >> Maybe.withDefault EnemyType.GiantAnt)

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
                OpponentType.Npc _ ->
                    identity

                OpponentType.Player player ->
                    updatePlayer worldName player.name fn

        newModel =
            -- We purposefully don't persist the critical effect Blinded changes to SPECIAL Perception (-> 1). Blindness is short-term.
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
                            |> SPlayer.setPreferredAmmo fight_.finalAttacker.preferredAmmo
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
                            |> SPlayer.setPreferredAmmo fight_.finalTarget.preferredAmmo
                            |> SPlayer.addMessage
                                { read = False }
                                model.time
                                fight_.messageForTarget
                    )
                    fight_.finalTarget
                |> (case fight_.fightInfoForAttacker.result of
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
                        ( fight_.fightInfoForAttacker
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

                Perk.QuickRecovery ->
                    Nothing

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

                Perk.Sharpshooter ->
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

                Perk.Sniper ->
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

                Perk.NightVision ->
                    Nothing

                Perk.BonusRangedDamage ->
                    Nothing
    in
    Perk.all
        |> List.filterMap (\perk -> oneTimeEffect perk |> Maybe.map (Tuple.pair perk))
        |> SeqDict.fromList


choosePerk : Perk -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
choosePerk perk clientId world worldName player model =
    let
        level =
            Xp.currentLevel player.xp
    in
    if
        PerkRequirement.isApplicable
            { addedSkillPercentages = player.addedSkillPercentages
            , special = player.special
            , level = level
            , perks = player.perks
            , questsDone = questsReceivedRewardFor player.name world
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


questsReceivedRewardFor : PlayerName -> World -> SeqSet Quest
questsReceivedRewardFor playerName world =
    world.questsProgress
        |> SeqDict.toList
        |> List.filterMap
            (\( quest, progress ) ->
                let
                    givenEnough =
                        Dict.get playerName progress
                            |> Maybe.withDefault 0
                            |> (\given -> given >= (Quest.playerRewards quest).ticksNeeded)
                in
                if givenEnough then
                    Just quest

                else
                    Nothing
            )
        |> SeqSet.fromList


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


updateVendor : Shop -> World.Name -> Location -> (Vendor -> Vendor) -> Model -> Model
updateVendor shop worldName location fn model =
    model
        |> updateWorld
            worldName
            (\world ->
                { world
                    | vendors =
                        if List.member shop (Shop.forLocation location) then
                            world.vendors
                                |> SeqDict.update shop (Maybe.map fn)

                        else
                            world.vendors
                }
            )


stopProgressing : Quest -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
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


startProgressing : Quest -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
startProgressing quest clientId world worldName player model =
    let
        locationQuestAllowed : Bool
        locationQuestAllowed =
            quest
                |> Quest.location
                |> Quest.locationQuestRequirements
                |> List.all (\requiredQuest -> World.isQuestDone world requiredQuest)

        playerRequirements : List Quest.PlayerRequirement
        playerRequirements =
            Quest.playerRequirements quest

        playerAlreadyPaidRequirements : Bool
        playerAlreadyPaidRequirements =
            world.questRequirementsPaid
                |> SeqDict.get quest
                |> Maybe.withDefault Set.empty
                |> Set.member player.name

        playerCanPayRequirements : Bool
        playerCanPayRequirements =
            playerRequirements
                |> List.all (\req -> Logic.passesPlayerRequirement req player)

        completedQuests : SeqSet Quest
        completedQuests =
            world.questsProgress
                |> SeqDict.toList
                |> List.filterMap
                    (\( quest_, progress ) ->
                        let
                            given =
                                progress
                                    |> Dict.values
                                    |> List.sum
                        in
                        if Quest.ticksNeeded quest_ <= given then
                            Just quest_

                        else
                            Nothing
                    )
                |> SeqSet.fromList

        isExclusiveWithCompletedQuest : Bool
        isExclusiveWithCompletedQuest =
            completedQuests
                |> SeqSet.toList
                |> List.any (\completedQuest -> Quest.isExclusiveWith completedQuest quest)
    in
    if locationQuestAllowed && (playerAlreadyPaidRequirements || playerCanPayRequirements) && not isExclusiveWithCompletedQuest then
        let
            ensurePlayerPresent : World -> World
            ensurePlayerPresent world_ =
                if SPlayer.canStartProgressing world.tickPerIntervalCurve player then
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
                                                    |> Dict.update player.name (Maybe.withDefault 0 >> Just)
                                                    |> Just
                                    )
                    }

                else
                    world_

            newModel =
                if World.isQuestDone world quest then
                    model

                else
                    model
                        |> updatePlayer worldName player.name (SPlayer.startProgressing quest world.tickPerIntervalCurve)
                        |> updateWorld worldName ensurePlayerPresent
                        |> (if playerAlreadyPaidRequirements then
                                identity

                            else
                                updatePlayer worldName player.name (SPlayer.payQuestRequirements playerRequirements)
                                    >> updateWorld worldName (notePlayerPaidRequirements quest player.name)
                           )
        in
        getPlayerData worldName player.name newModel
            |> Maybe.map
                (\data ->
                    ( newModel
                    , Lamdera.sendToFrontend clientId <| CurrentPlayer data
                    )
                )
            |> Maybe.withDefault ( model, Cmd.none )

    else
        ( model, Cmd.none )


refuelCar : ItemKind.Kind -> ClientId -> World -> World.Name -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
refuelCar fuelKind clientId _ worldName player model =
    let
        newModel =
            model
                |> updatePlayer worldName player.name (SPlayer.refuelCar fuelKind)
    in
    getPlayerData worldName player.name newModel
        |> Maybe.map
            (\data ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| CurrentPlayer data
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


notePlayerPaidRequirements : Quest -> PlayerName -> World -> World
notePlayerPaidRequirements quest player world =
    { world
        | questRequirementsPaid =
            world.questRequirementsPaid
                |> SeqDict.update quest (Maybe.withDefault Set.empty >> Set.insert player >> Just)
    }
