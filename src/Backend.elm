module Backend exposing (..)

import Admin
import AssocSet as Set_
import Data.Auth as Auth
    exposing
        ( Auth
        , Verified
        )
import Data.Barter as Barter
import Data.Fight.Generator as FightGen
import Data.Item as Item exposing (Item)
import Data.Ladder as Ladder
import Data.Map as Map exposing (TileCoords)
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk as Perk
import Data.Player as Player
    exposing
        ( Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Player.SPlayer as SPlayer
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special, SpecialType)
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
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Decode as JD
import Json.Encode as JE
import Lamdera exposing (ClientId, SessionId)
import List.Extra as List
import Logic
import Random
import Set exposing (Set)
import Task
import Time exposing (Posix)
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

        GeneratedNewVendorsStock ( vendors, newLastItemId ) ->
            ( { model
                | vendors = vendors
                , lastItemId = newLastItemId
              }
            , Cmd.none
            )


processTick : Model -> ( Model, Cmd BackendMsg )
processTick model =
    -- TODO refresh the affected users that are logged-in
    ( { model | players = Dict.map (always (Player.map SPlayer.tick)) model.players }
    , restockVendors model
    )


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
    case Location.getVendor location model.vendors of
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
    in
    if currentCoords == newCoords then
        ( model, Cmd.none )

    else if
        pathTaken
            /= Set.remove currentCoords
                (Pathfinding.path
                    (Perception.level special.perception)
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


updateVendor : (Vendor -> Vendor) -> Location -> Model -> Model
updateVendor fn location model =
    { model | vendors = Location.mapVendor fn location model.vendors }


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
