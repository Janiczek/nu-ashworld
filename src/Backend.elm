module Backend exposing (..)

import Admin
import AssocList as Dict_
import AssocSet as Set_
import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Barter as Barter
import Data.Enemy as Enemy
import Data.Fight as Fight exposing (FightResult(..), Opponent)
import Data.Fight.Generator as FightGen
import Data.Item as Item exposing (Item)
import Data.Ladder as Ladder
import Data.Map as Map exposing (TileCoords)
import Data.Map.Chunk as Chunk
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Message as Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player as Player
    exposing
        ( Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Player.SPlayer as SPlayer
import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Special.Perception as Perception
import Data.Tick as Tick
import Data.Trait as Trait
import Data.Vendor as Vendor exposing (Vendor)
import Data.World
    exposing
        ( AdminData
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Data.Xp as Xp
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Env
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lamdera exposing (ClientId, SessionId)
import List.Extra as List
import Logic
import Random exposing (Generator)
import Random.List
import Set exposing (Set)
import Set.ExtraExtra as Set
import Task
import Time exposing (Posix)
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
    let
        model =
            { players = Dict.empty
            , loggedInPlayers = Dict.empty
            , nextWantedTick = Nothing
            , adminLoggedIn = Nothing
            , time = Time.millisToPosix 0
            , vendors = Vendor.emptyVendors
            , lastItemId = 0
            }
    in
    ( model
    , Cmd.batch
        [ Task.perform Tick Time.now
        , restockVendors model
        ]
    )


restockVendors : Model -> Cmd BackendMsg
restockVendors model =
    Random.generate
        GeneratedNewVendorsStock
        (Vendor.restockVendors model.lastItemId model.vendors)


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
            |> Ladder.sort
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
        auth : Auth Verified
        auth =
            Player.getAuth player

        perception : Int
        perception =
            Player.getPlayerData player
                |> Maybe.map
                    (\player_ ->
                        Logic.special
                            { baseSpecial = player_.baseSpecial
                            , hasBruiserTrait = Trait.isSelected Trait.Bruiser player_.traits
                            , hasGiftedTrait = Trait.isSelected Trait.Gifted player_.traits
                            , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player_.traits
                            , isNewChar = False
                            }
                            |> .perception
                    )
                |> Maybe.withDefault 1

        sortedPlayers =
            model.players
                |> Dict.values
                |> List.filterMap Player.getPlayerData
                |> Ladder.sort

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
    { player = Player.map Player.serverToClient player
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
            , Lamdera.sendToFrontend clientId <| InitWorld world
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
                        { model
                            | nextWantedTick = Just nextTick
                            , time = currentTime
                        }
                            |> processTick

                    else
                        ( { model | time = currentTime }
                        , Cmd.none
                        )

        GeneratedFight clientId sPlayer fight_ ->
            let
                targetIsPlayer : Bool
                targetIsPlayer =
                    Fight.isPlayer fight_.finalTarget.type_

                updateIfPlayer : (SPlayer -> SPlayer) -> Opponent -> Model -> Model
                updateIfPlayer fn opponent =
                    case opponent.type_ of
                        Fight.Npc _ ->
                            identity

                        Fight.Player name ->
                            updatePlayer fn name

                newModel =
                    model
                        |> updateIfPlayer
                            (\player ->
                                player
                                    |> SPlayer.setHp fight_.finalAttacker.hp
                                    |> SPlayer.subtractTicks 1
                            )
                            fight_.finalAttacker
                        |> updateIfPlayer
                            (\player ->
                                player
                                    |> SPlayer.setHp fight_.finalTarget.hp
                                    |> SPlayer.addMessage fight_.messageForTarget
                            )
                            fight_.finalTarget
                        |> (case fight_.fightInfo.result of
                                BothDead ->
                                    identity

                                NobodyDead ->
                                    identity

                                TargetAlreadyDead ->
                                    identity

                                AttackerWon { xpGained, capsGained } ->
                                    identity
                                        >> updateIfPlayer
                                            (\player ->
                                                player
                                                    |> SPlayer.addXp xpGained model.time
                                                    |> SPlayer.addCaps capsGained
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
                                                    |> SPlayer.incLosses
                                            )
                                            fight_.finalTarget

                                TargetWon { xpGained, capsGained } ->
                                    identity
                                        >> updateIfPlayer
                                            (\player ->
                                                player
                                                    |> SPlayer.subtractCaps capsGained
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
                                                    |> SPlayer.incWins
                                            )
                                            fight_.finalTarget
                           )
            in
            getWorldLoggedIn sPlayer.name newModel
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

        CreateNewCharWithTime clientId newChar time ->
            withLoggedInPlayer clientId (createNewCharWithTime newChar time)

        GeneratedNewVendorsStock ( vendors, newLastItemId ) ->
            ( { model
                | vendors = vendors
                , lastItemId = newLastItemId
              }
            , Cmd.none
            )

        LoggedToBackendMsg ->
            ( model, Cmd.none )


processTick : Model -> ( Model, Cmd BackendMsg )
processTick model =
    -- TODO refresh the affected users that are logged-in
    ( { model
        | players =
            Dict.map
                (always (Player.map SPlayer.tick))
                model.players
      }
    , restockVendors model
    )


withLoggedInPlayer_ : Model -> ClientId -> (ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
withLoggedInPlayer_ model clientId fn =
    Dict.get clientId model.loggedInPlayers
        |> Maybe.andThen (\name -> Dict.get name model.players)
        |> Maybe.map (\player -> fn clientId player model)
        |> Maybe.withDefault ( model, Cmd.none )


logAndUpdateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
logAndUpdateFromFrontend sessionId clientId msg model =
    let
        playerName : String
        playerName =
            Dict.get clientId model.loggedInPlayers
                |> Maybe.withDefault ""

        logMsgCmd : Cmd BackendMsg
        logMsgCmd =
            Http.request
                { method = "POST"
                , url = "https://janiczek-nuashworld.builtwithdark.com/log-backend"
                , headers = [ Http.header "X-Api-Key" Env.loggingApiKey ]
                , body =
                    Http.jsonBody <|
                        JE.object
                            [ ( "session-id", JE.string sessionId )
                            , ( "client-id", JE.string clientId )
                            , ( "player-name", JE.string playerName )
                            , ( "to-backend-msg", JE.string <| JE.encode 0 <| encodeToBackendMsg msg )
                            ]
                , expect = Http.expectWhatever (always LoggedToBackendMsg)
                , tracker = Nothing
                , timeout = Nothing
                }

        ( newModel, normalCmd ) =
            updateFromFrontend sessionId clientId msg model
    in
    ( newModel, Cmd.batch [ logMsgCmd, normalCmd ] )


encodeToBackendMsg : ToBackend -> JE.Value
encodeToBackendMsg msg =
    case msg of
        LogMeIn auth ->
            JE.object
                [ ( "type", JE.string "LogMeIn" )
                , ( "auth", Auth.encode auth )
                ]

        RegisterMe auth ->
            JE.object
                [ ( "type", JE.string "RegisterMe" )
                , ( "auth", Auth.encode auth )
                ]

        CreateNewChar newChar ->
            JE.object
                [ ( "type", JE.string "CreateNewChar" )
                , ( "newChar", NewChar.encode newChar )
                ]

        LogMeOut ->
            JE.object
                [ ( "type", JE.string "LogMeOut" ) ]

        Fight playerName ->
            JE.object
                [ ( "type", JE.string "Fight" )
                , ( "playerName", JE.string playerName )
                ]

        HealMe ->
            JE.object
                [ ( "type", JE.string "HealMe" ) ]

        UseItem itemId ->
            JE.object
                [ ( "type", JE.string "UseItem" )
                , ( "itemId", JE.int itemId )
                ]

        Wander ->
            JE.object
                [ ( "type", JE.string "Wander" ) ]

        RefreshPlease ->
            JE.object
                [ ( "type", JE.string "RefreshPlease" ) ]

        TagSkill skill ->
            JE.object
                [ ( "type", JE.string "TagSkill" )
                , ( "skill", Skill.encode skill )
                ]

        IncSkill skill ->
            JE.object
                [ ( "type", JE.string "IncSkill" )
                , ( "skill", Skill.encode skill )
                ]

        MoveTo coords path ->
            JE.object
                [ ( "type", JE.string "MoveTo" )
                , ( "coords", Map.encodeCoords coords )
                , ( "path", Set.encode Map.encodeCoords path )
                ]

        MessageWasRead message ->
            JE.object
                [ ( "type", JE.string "MessageWasRead" )
                , ( "message", Message.encode message )
                ]

        RemoveMessage message ->
            JE.object
                [ ( "type", JE.string "RemoveMessage" )
                , ( "message", Message.encode message )
                ]

        Barter barterState ->
            JE.object
                [ ( "type", JE.string "Barter" )
                , ( "barterState", Barter.encode barterState )
                ]

        ChoosePerk perk ->
            JE.object
                [ ( "type", JE.string "ChoosePerk" )
                , ( "perk", Perk.encode perk )
                ]

        AdminToBackend ExportJson ->
            JE.object
                [ ( "type", JE.string "AdminToBackend ExportJson" ) ]

        AdminToBackend (ImportJson _) ->
            JE.object
                [ ( "type", JE.string "AdminToBackend ImportJson" )
                , ( "json", JE.string "<omitted>" )
                ]


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

        withLocation : (ClientId -> Location -> SPlayer -> Model -> ( Model, Cmd BackendMsg )) -> ( Model, Cmd BackendMsg )
        withLocation fn =
            withLoggedInCreatedPlayer
                (\cId ({ location } as player) m ->
                    case Location.location location of
                        Nothing ->
                            ( model, Cmd.none )

                        Just loc ->
                            fn cId loc player m
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
            withLoggedInCreatedPlayer <| fight otherPlayerName

        HealMe ->
            withLoggedInCreatedPlayer healMe

        UseItem itemId ->
            withLoggedInCreatedPlayer <| useItem itemId

        Wander ->
            withLoggedInCreatedPlayer wander

        ChoosePerk perk ->
            withLoggedInCreatedPlayer <| choosePerk perk

        RefreshPlease ->
            let
                loggedOut () =
                    ( model
                    , Lamdera.sendToFrontend clientId <| RefreshedLoggedOut <| getWorldLoggedOut model
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

        TagSkill skill ->
            withLoggedInCreatedPlayer (tagSkill skill)

        IncSkill skill ->
            withLoggedInCreatedPlayer (incSkill skill)

        CreateNewChar newChar ->
            withLoggedInPlayer (createNewChar newChar)

        MoveTo newCoords pathTaken ->
            withLoggedInCreatedPlayer (moveTo newCoords pathTaken)

        MessageWasRead message ->
            withLoggedInCreatedPlayer (readMessage message)

        RemoveMessage message ->
            withLoggedInCreatedPlayer (removeMessage message)

        Barter barterState ->
            withLocation (barter barterState)

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


barter : Barter.State -> ClientId -> Location -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
barter barterState clientId location player model =
    case Maybe.map (Vendor.getFrom model.vendors) (Location.getVendor location) of
        Nothing ->
            ( model, Cmd.none )

        Just vendor ->
            let
                playerSpecial : Special
                playerSpecial =
                    Logic.special
                        { baseSpecial = player.baseSpecial
                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                        , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                        , isNewChar = False
                        }

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
                                    |> Maybe.map (\item -> Item.basePrice item.kind * count)
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
                                                { itemCount = count
                                                , itemKind = item.kind
                                                , playerBarterSkill = Skill.get playerSpecial player.addedSkillPercentages Skill.Barter
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
                        barterAfterValidation barterState vendor location player model
                in
                getWorldLoggedIn player.name newModel
                    |> Maybe.map
                        (\world ->
                            ( newModel
                            , Lamdera.sendToFrontend clientId <|
                                BarterDone
                                    ( world
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


barterAfterValidation : Barter.State -> Vendor -> Location -> SPlayer -> Model -> Model
barterAfterValidation barterState vendor location player model =
    let
        removePlayerCaps : Int -> Model -> Model
        removePlayerCaps amount =
            updatePlayer (SPlayer.subtractCaps amount) player.name

        addPlayerCaps : Int -> Model -> Model
        addPlayerCaps amount =
            updatePlayer (SPlayer.addCaps amount) player.name

        removeVendorCaps : Int -> Model -> Model
        removeVendorCaps amount =
            updateVendor (Vendor.subtractCaps amount) location

        addVendorCaps : Int -> Model -> Model
        addVendorCaps amount =
            updateVendor (Vendor.addCaps amount) location

        removePlayerItems : Dict Item.Id Int -> Model -> Model
        removePlayerItems items model_ =
            items
                |> Dict.foldl
                    (\id count accModel ->
                        updatePlayer
                            (SPlayer.removeItem id count)
                            player.name
                            accModel
                    )
                    model_

        removeVendorItems : Dict Item.Id Int -> Model -> Model
        removeVendorItems items model_ =
            items
                |> Dict.foldl
                    (\id count accModel ->
                        updateVendor
                            (Vendor.removeItem id count)
                            location
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
                                    (Vendor.addItem { item | count = count })
                                    location
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
                                    (SPlayer.addItem { item | count = count })
                                    player.name
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
        special : Special
        special =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }

        currentCoords : TileCoords
        currentCoords =
            Map.toTileCoords player.location

        tickCost : Int
        tickCost =
            Pathfinding.tickCost pathTaken

        isSamePosition : Bool
        isSamePosition =
            currentCoords == newCoords

        pathDoesntAgree : Bool
        pathDoesntAgree =
            pathTaken
                /= Set.remove currentCoords
                    (Pathfinding.path
                        (Perception.level special.perception)
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

        NeedsCharCreated _ ->
            ( model
            , Task.perform (CreateNewCharWithTime clientId newChar) Time.now
            )


createNewCharWithTime : NewChar -> Posix -> ClientId -> Player SPlayer -> Model -> ( Model, Cmd BackendMsg )
createNewCharWithTime newChar currentTime clientId player model =
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


tagSkill : Skill -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
tagSkill skill clientId player model =
    let
        totalTagsAvailable : Int
        totalTagsAvailable =
            Logic.totalTags { hasTagPerk = Perk.rank Perk.Tag player.perks > 0 }

        unusedTags : Int
        unusedTags =
            totalTagsAvailable - Set_.size player.taggedSkills

        isTagged : Bool
        isTagged =
            Set_.member skill player.taggedSkills
    in
    if unusedTags > 0 && not isTagged then
        let
            newModel : Model
            newModel =
                model
                    |> updatePlayer (SPlayer.tagSkill skill) player.name
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


incSkill : Skill -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
incSkill skill clientId player model =
    let
        newModel : Model
        newModel =
            model
                |> updatePlayer (SPlayer.incSkill skill) player.name
    in
    getWorldLoggedIn player.name newModel
        |> Maybe.map
            (\world ->
                ( newModel
                , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


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


useItem : Item.Id -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
useItem itemId clientId player model =
    case Dict.get itemId player.items of
        Nothing ->
            ( model, Cmd.none )

        Just item ->
            let
                effects : List Item.Effect
                effects =
                    Item.usageEffects item.kind
            in
            if List.isEmpty effects then
                ( model, Cmd.none )

            else
                let
                    handleEffect : Item.Effect -> (SPlayer -> SPlayer)
                    handleEffect effect =
                        case effect of
                            Item.Heal amount ->
                                SPlayer.addHp amount

                            Item.RemoveAfterUse ->
                                SPlayer.removeItem itemId 1

                    combinedEffects : SPlayer -> SPlayer
                    combinedEffects =
                        effects
                            |> List.map handleEffect
                            |> List.foldl (>>) identity

                    newModel =
                        model
                            |> updatePlayer combinedEffects player.name
                in
                getWorldLoggedIn player.name newModel
                    |> Maybe.map
                        (\world ->
                            ( newModel
                            , Lamdera.sendToFrontend clientId <| YourCurrentWorld world
                            )
                        )
                    |> Maybe.withDefault ( model, Cmd.none )


wander : ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
wander clientId player model =
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
                    |> Chunk.chunk
                    |> Enemy.forChunk

            enemyTypeGenerator : Generator Enemy.Type
            enemyTypeGenerator =
                Random.List.choose possibleEnemies
                    |> Random.map (Tuple.first >> Maybe.withDefault Enemy.default)
        in
        ( model
        , Random.generate
            (GeneratedFight clientId player)
            (enemyTypeGenerator
                |> Random.andThen FightGen.enemyOpponentGenerator
                |> Random.andThen
                    (\enemyOpponent ->
                        FightGen.generator
                            { attacker = FightGen.playerOpponent player
                            , target = enemyOpponent
                            , currentTime = model.time
                            }
                    )
            )
        )


choosePerk : Perk -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
choosePerk perk clientId player model =
    let
        level =
            Xp.currentLevel player.xp

        finalSpecial =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }
    in
    if
        Perk.isApplicable
            { addedSkillPercentages = player.addedSkillPercentages
            , finalSpecial = finalSpecial
            , level = level
            , perks = player.perks
            }
            perk
    then
        let
            newModel =
                model
                    |> updatePlayer
                        (identity
                            >> SPlayer.incPerkRank perk
                            >> SPlayer.decAvailablePerks
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
        ( model, Cmd.none )


fight : PlayerName -> ClientId -> SPlayer -> Model -> ( Model, Cmd BackendMsg )
fight otherPlayerName clientId sPlayer model =
    if sPlayer.ticks <= 0 then
        ( model, Cmd.none )

    else if sPlayer.hp <= 0 then
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
                                    { attacker = FightGen.playerOpponent sPlayer
                                    , target = FightGen.playerOpponent target
                                    , currentTime = model.time
                                    }
                                )
                            )
                            model

                    else
                        ( model
                        , Random.generate
                            (GeneratedFight clientId sPlayer)
                            (FightGen.generator
                                { attacker = FightGen.playerOpponent sPlayer
                                , target = FightGen.playerOpponent target
                                , currentTime = model.time
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


updateVendor : (Vendor -> Vendor) -> Location -> Model -> Model
updateVendor fn location model =
    { model
        | vendors =
            case Location.getVendor location of
                Nothing ->
                    model.vendors

                Just vendorName ->
                    Dict_.update vendorName (Maybe.map fn) model.vendors
    }


createItem : { uniqueKey : Item.UniqueKey, count : Int } -> Model -> ( Item, Model )
createItem { uniqueKey, count } model =
    let
        ( item, newLastId ) =
            Item.create
                { lastId = model.lastItemId
                , uniqueKey = uniqueKey
                , count = count
                }
    in
    ( item
    , { model | lastItemId = newLastId }
    )
