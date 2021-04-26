module Frontend exposing (..)

import AssocList as Dict_
import AssocSet as Set_
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Data.Auth as Auth
import Data.Barter as Barter
import Data.Fight as Fight exposing (FightInfo)
import Data.Fight.View
import Data.HealthStatus as HealthStatus
import Data.Item as Item exposing (Item)
import Data.Ladder as Ladder
import Data.Map as Map exposing (TileCoords)
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Map.Terrain as Terrain
import Data.Message as Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player as Player
    exposing
        ( COtherPlayer
        , CPlayer
        , Player(..)
        )
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Data.Tick as Tick
import Data.Trait as Trait exposing (Trait)
import Data.Vendor as Vendor
import Data.Version as Version
import Data.World as World
    exposing
        ( AdminData
        , World(..)
        , WorldLoggedInData
        )
import Data.Xp as Xp
import DateFormat
import DateFormat.Relative
import Dict exposing (Dict)
import Dict.Extra as Dict
import File
import File.Download
import File.Select
import Frontend.News as News
import Frontend.Route as Route exposing (Route)
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HA
import Html.Events as HE
import Html.Events.Extra as HE
import Html.Extra as H
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Lamdera
import Logic
import Set exposing (Set)
import Task
import Time exposing (Posix)
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init _ key =
    ( { key = key
      , route = Route.News
      , world = WorldNotInitialized Auth.init
      , time = Time.millisToPosix 0
      , zone = Time.utc
      , newChar = NewChar.init
      , alertMessage = Nothing
      , mapMouseCoords = Nothing
      }
    , Cmd.batch
        [ Task.perform GotZone Time.here
        , Task.perform GotTime Time.now
        ]
    )


subscriptions : Model -> Sub FrontendMsg
subscriptions _ =
    Time.every 1000 GotTime


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        GoToRoute route ->
            ( if Route.needsAdmin route && not (World.isAdmin model.world) then
                model

              else if Route.needsLogin route && not (World.isLoggedIn model.world) then
                model

              else
                { model
                    | route = route
                    , alertMessage = Nothing
                }
            , Cmd.none
            )

        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Nav.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged _ ->
            ( model, Cmd.none )

        Logout ->
            ( model
            , Lamdera.sendToBackend LogMeOut
            )

        Login ->
            World.getAuth model.world
                |> Maybe.map Auth.hash
                |> Maybe.map
                    (\auth ->
                        ( model
                        , Lamdera.sendToBackend <| LogMeIn auth
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        Register ->
            World.getAuth model.world
                |> Maybe.map Auth.hash
                |> Maybe.map
                    (\auth ->
                        ( model
                        , Lamdera.sendToBackend <| RegisterMe auth
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        GotTime time ->
            ( { model | time = time }
            , Cmd.none
            )

        GotZone zone ->
            ( { model | zone = zone }
            , Cmd.none
            )

        AskToFight playerName ->
            ( model
            , Lamdera.sendToBackend <| Fight playerName
            )

        AskToHeal ->
            ( model
            , Lamdera.sendToBackend HealMe
            )

        AskToWander ->
            ( model
            , Lamdera.sendToBackend Wander
            )

        ImportButtonClicked ->
            ( model
            , File.Select.file [ "application/json" ] ImportFileSelected
            )

        ImportFileSelected file ->
            ( model
            , Task.perform AskToImport (File.toString file)
            )

        AskToImport jsonString ->
            ( model
            , Lamdera.sendToBackend <| AdminToBackend <| ImportJson jsonString
            )

        AskForExport ->
            ( model
            , Lamdera.sendToBackend <| AdminToBackend ExportJson
            )

        Refresh ->
            ( model
            , Lamdera.sendToBackend RefreshPlease
            )

        AskToTagSkill skill ->
            ( model
            , Lamdera.sendToBackend <| TagSkill skill
            )

        AskToIncSkill skill ->
            ( model
            , Lamdera.sendToBackend <| IncSkill skill
            )

        SetAuthName newName ->
            ( { model
                | world =
                    World.mapAuth
                        (\auth -> { auth | name = newName })
                        model.world
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        SetAuthPassword newPassword ->
            ( { model
                | world =
                    World.mapAuth
                        (Auth.setPlaintextPassword newPassword)
                        model.world
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        CreateChar ->
            ( model
            , Lamdera.sendToBackend <| CreateNewChar model.newChar
            )

        NewCharIncSpecial type_ ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.incSpecial type_
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        NewCharDecSpecial type_ ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.decSpecial type_
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        NewCharToggleTaggedSkill skill ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.toggleTaggedSkill skill
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        NewCharToggleTrait trait ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.toggleTrait trait
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        MapMouseAtCoords mouseCoords ->
            case model.world of
                WorldLoggedIn world ->
                    case world.player of
                        Player cPlayer ->
                            let
                                special : Special
                                special =
                                    Logic.special
                                        { baseSpecial = cPlayer.baseSpecial
                                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser cPlayer.traits
                                        , hasGiftedTrait = Trait.isSelected Trait.Gifted cPlayer.traits
                                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame cPlayer.traits
                                        , isNewChar = False
                                        }

                                playerCoords =
                                    Map.toTileCoords cPlayer.location
                            in
                            ( { model
                                | mapMouseCoords =
                                    Just
                                        ( mouseCoords
                                        , Pathfinding.path
                                            (Perception.level special.perception)
                                            { from = playerCoords
                                            , to = mouseCoords
                                            }
                                        )
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        MapMouseOut ->
            ( { model | mapMouseCoords = Nothing }
            , Cmd.none
            )

        MapMouseClick ->
            case model.mapMouseCoords of
                Nothing ->
                    ( model, Cmd.none )

                Just ( newCoords, path ) ->
                    ( model
                    , Lamdera.sendToBackend <| MoveTo newCoords path
                    )

        OpenMessage message ->
            ( { model | route = Route.Message message }
            , Lamdera.sendToBackend <| MessageWasRead message
            )

        AskToRemoveMessage message ->
            ( model
            , Lamdera.sendToBackend <| RemoveMessage message
            )

        BarterMsg barterMsg ->
            updateBarter barterMsg model


mapBarter_ : (Barter.State -> Barter.State) -> Model -> Model
mapBarter_ fn model =
    { model | route = Route.mapBarterState fn model.route }


mapBarter : (Barter.State -> Barter.State) -> Model -> ( Model, Cmd FrontendMsg )
mapBarter fn model =
    ( mapBarter_ fn model
    , Cmd.none
    )


resetBarter : Model -> ( Model, Cmd FrontendMsg )
resetBarter model =
    mapBarter (always Barter.empty) model


updateBarter : BarterMsg -> Model -> ( Model, Cmd FrontendMsg )
updateBarter msg model =
    Tuple.mapFirst (mapBarter_ Barter.dismissMessage) <|
        case msg of
            ResetBarter ->
                resetBarter model

            ConfirmBarter ->
                Route.barterState model.route
                    |> Maybe.map
                        (\barterState ->
                            ( model
                            , Lamdera.sendToBackend <| Barter barterState
                            )
                        )
                    |> Maybe.withDefault ( model, Cmd.none )

            AddPlayerItem itemId count ->
                mapBarter (Barter.addPlayerItem itemId count) model

            AddVendorItem itemId count ->
                mapBarter (Barter.addVendorItem itemId count) model

            AddPlayerCaps amount ->
                mapBarter (Barter.addPlayerCaps amount) model

            AddVendorCaps amount ->
                mapBarter (Barter.addVendorCaps amount) model

            RemovePlayerItem itemId count ->
                mapBarter (Barter.removePlayerItem itemId count) model

            RemoveVendorItem itemId count ->
                mapBarter (Barter.removeVendorItem itemId count) model

            RemovePlayerCaps amount ->
                mapBarter (Barter.removePlayerCaps amount) model

            RemoveVendorCaps amount ->
                mapBarter (Barter.removeVendorCaps amount) model

            SetTransferNInput position string ->
                mapBarter (Barter.setTransferNInput position string) model

            SetTransferNHover position ->
                mapBarter (Barter.setTransferNHover position) model

            UnsetTransferNHover ->
                mapBarter Barter.unsetTransferNHover model


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        YoureLoggedIn world ->
            ( { model
                | world = WorldLoggedIn world
                , alertMessage = Nothing
                , route =
                    case world.player of
                        NeedsCharCreated _ ->
                            Route.CharCreation

                        Player _ ->
                            Route.Ladder
              }
            , Cmd.none
            )

        YoureLoggedInAsAdmin adminData ->
            ( { model
                | world = WorldAdmin adminData
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        YoureRegistered world ->
            ( { model
                | world = WorldLoggedIn world
                , alertMessage = Nothing
                , route = Route.CharCreation
              }
            , Cmd.none
            )

        CharCreationError error ->
            ( { model | newChar = NewChar.setError error model.newChar }
            , Cmd.none
            )

        YouHaveCreatedChar world ->
            ( { model
                | world = WorldLoggedIn world
                , route = Route.Ladder
                , alertMessage = Nothing
                , newChar = NewChar.init
              }
            , Cmd.none
            )

        YoureLoggedOut world ->
            ( { model
                | world = WorldLoggedOut Auth.init world
                , alertMessage = Nothing
                , route = Route.loggedOut model.route
              }
            , Cmd.none
            )

        YourCurrentWorld world ->
            ( { model
                | world = WorldLoggedIn world
              }
            , Cmd.none
            )

        CurrentAdminData data ->
            ( { model | world = WorldAdmin data }
            , Cmd.none
            )

        InitWorld world ->
            case model.world of
                WorldNotInitialized auth ->
                    ( { model | world = WorldLoggedOut auth world }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        RefreshedLoggedOut world ->
            let
                auth =
                    model.world
                        |> World.getAuth
                        |> Maybe.withDefault Auth.init
            in
            ( { model
                | world = WorldLoggedOut auth world
                , route = Route.loggedOut model.route
              }
            , Cmd.none
            )

        YourFightResult ( fightInfo, world ) ->
            ( { model
                | route = Route.Fight fightInfo
                , world = WorldLoggedIn world
              }
            , Cmd.none
            )

        AlertMessage message ->
            ( { model | alertMessage = Just message }
            , Cmd.none
            )

        JsonExportDone json ->
            let
                date : String
                date =
                    DateFormat.format
                        [ DateFormat.yearNumber
                        , DateFormat.text "-"
                        , DateFormat.monthFixed
                        , DateFormat.text "-"
                        , DateFormat.dayOfMonthFixed
                        ]
                        model.zone
                        model.time
            in
            ( model
            , File.Download.string
                ("nu-ashworld-db-export-" ++ date ++ ".json")
                "application/json"
                json
            )

        BarterDone ( world, maybeMessage ) ->
            { model | world = WorldLoggedIn world }
                |> resetBarter
                |> (case maybeMessage of
                        Nothing ->
                            identity

                        Just message ->
                            Tuple.mapFirst (mapBarter_ (Barter.setMessage message))
                   )

        BarterMessage message ->
            mapBarter (Barter.setMessage message) model


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "NuAshworld " ++ Version.version
    , body =
        [ stylesLinkView
        , favicon16View
        , favicon32View
        , genericFaviconView
        , genericFavicon2View
        , case model.world of
            WorldNotInitialized _ ->
                notInitializedView model

            WorldLoggedOut _ _ ->
                loggedOutView model

            WorldLoggedIn data ->
                loggedInView data model

            WorldAdmin data ->
                adminView data model
        ]
    }


appView :
    { leftNav : List (Html FrontendMsg) }
    -> Model
    -> Html FrontendMsg
appView { leftNav } model =
    H.div
        [ HA.id "app"
        , HA.classList
            [ ( "logged-in", World.isLoggedIn model.world )
            , ( "admin", World.isAdmin model.world )
            ]
        ]
        [ H.div [ HA.id "left-nav" ]
            (logoView
                :: nextTickView model.zone model.time
                :: leftNav
                ++ [ commonLinksView model.route ]
            )
        , contentView model
        ]


nextTickView : Time.Zone -> Posix -> Html FrontendMsg
nextTickView zone time =
    let
        millis =
            Time.posixToMillis time
    in
    H.div [ HA.id "next-tick" ] <|
        if millis == 0 then
            []

        else
            let
                { nextTick } =
                    Tick.nextTick time

                nextTickString =
                    DateFormat.format
                        [ DateFormat.hourMilitaryFixed
                        , DateFormat.text ":"
                        , DateFormat.minuteFixed
                        ]
                        zone
                        nextTick
            in
            [ H.text "Next tick: "
            , H.span
                [ HA.class "slightly-emphasized" ]
                [ H.text nextTickString ]
            ]


serverTickView : Time.Zone -> Posix -> Posix -> Html FrontendMsg
serverTickView zone currentTime serverTick =
    let
        { nextTick } =
            Tick.nextTick currentTime

        isOk : Bool
        isOk =
            nextTick == serverTick

        ( serverTickTooltip, serverTickString ) =
            if isOk then
                ( "Agrees with what users see"
                , "OK"
                )

            else
                ( Iso8601.fromTime serverTick
                , DateFormat.format
                    [ DateFormat.hourMilitaryFixed
                    , DateFormat.text ":"
                    , DateFormat.minuteFixed
                    ]
                    zone
                    serverTick
                )
    in
    H.div
        [ HA.id "server-tick"
        , HA.classList [ ( "ok", isOk ) ]
        ]
        [ H.text "Server planned tick: "
        , H.span
            [ HA.class "slightly-emphasized"
            , HA.title serverTickTooltip
            ]
            [ H.text serverTickString ]
        ]


contentView : Model -> Html FrontendMsg
contentView model =
    let
        withCreatedPlayer : WorldLoggedInData -> (WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)) -> List (Html FrontendMsg)
        withCreatedPlayer world fn =
            case world.player of
                NeedsCharCreated _ ->
                    contentUnavailableToNonCreatedView

                Player cPlayer ->
                    fn world cPlayer

        withLocation : WorldLoggedInData -> (Location -> WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)) -> List (Html FrontendMsg)
        withLocation world fn =
            world.player
                |> Player.getPlayerData
                |> Maybe.andThen (.location >> Location.location)
                |> Maybe.map (\loc -> withCreatedPlayer world (fn loc))
                |> Maybe.withDefault contentUnavailableWhenNotInTownView
    in
    H.div [ HA.id "content" ]
        (case ( model.route, model.world ) of
            ( Route.Character, WorldLoggedIn world ) ->
                withCreatedPlayer world characterView

            ( Route.Character, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Inventory, WorldLoggedIn world ) ->
                withCreatedPlayer world inventoryView

            ( Route.Inventory, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Map, WorldLoggedIn world ) ->
                withCreatedPlayer world (mapView model.mapMouseCoords)

            ( Route.Map, _ ) ->
                mapLoggedOutView

            ( Route.Ladder, WorldLoggedIn world ) ->
                case world.player of
                    NeedsCharCreated _ ->
                        ladderView
                            { loggedInPlayer = Nothing
                            , players = World.allPlayers world
                            }

                    Player cPlayer ->
                        ladderView
                            { loggedInPlayer = Just cPlayer
                            , players = World.allPlayers world
                            }

            ( Route.Ladder, WorldLoggedOut _ world ) ->
                ladderView
                    { loggedInPlayer = Nothing
                    , players = world.players
                    }

            ( Route.Ladder, WorldAdmin data ) ->
                ladderView
                    { loggedInPlayer = Nothing
                    , players =
                        data.players
                            |> List.filterMap Player.getPlayerData
                            |> Ladder.sort
                            |> List.map (Player.serverToClientOther { perception = 10 })
                    }

            ( Route.Ladder, WorldNotInitialized _ ) ->
                ladderLoadingView

            ( Route.Town Route.MainSquare, WorldLoggedIn world ) ->
                withLocation world townMainSquareView

            ( Route.Town (Route.Store { barter }), WorldLoggedIn world ) ->
                withLocation world (townStoreView barter)

            ( Route.Town _, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.About, _ ) ->
                aboutView

            ( Route.News, _ ) ->
                newsView model.zone

            ( Route.Fight fightInfo, WorldLoggedIn world ) ->
                withCreatedPlayer world (fightView fightInfo)

            ( Route.Fight _, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Messages, WorldLoggedIn world ) ->
                withCreatedPlayer world (messagesView model.time model.zone)

            ( Route.Messages, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Message message, WorldLoggedIn world ) ->
                withCreatedPlayer world (messageView model.zone message)

            ( Route.Message _, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.CharCreation, WorldLoggedIn _ ) ->
                newCharView model.newChar

            ( Route.CharCreation, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Admin Route.Players, WorldAdmin _ ) ->
                adminPlayersView

            ( Route.Admin Route.LoggedIn, WorldAdmin data ) ->
                adminLoggedInView data

            ( Route.Admin _, _ ) ->
                contentUnavailableToNonAdminView
        )


pageTitleView : String -> Html FrontendMsg
pageTitleView title =
    H.h2
        [ HA.id "page-title" ]
        [ H.text title ]


aboutView : List (Html FrontendMsg)
aboutView =
    [ pageTitleView "About"
    , H.text "TODO"
    ]


adminPlayersView : List (Html FrontendMsg)
adminPlayersView =
    [ pageTitleView "Admin :: Players"
    , H.text "TODO"
    ]


adminLoggedInView : AdminData -> List (Html FrontendMsg)
adminLoggedInView data =
    [ pageTitleView "Admin :: Logged In"
    , if List.isEmpty data.loggedInPlayers then
        H.text "Nobody's here!"

      else
        data.loggedInPlayers
            |> List.map (\name -> H.li [] [ H.text name ])
            |> H.ul []
    ]


mapView :
    Maybe ( TileCoords, Set TileCoords )
    -> WorldLoggedInData
    -> CPlayer
    -> List (Html FrontendMsg)
mapView mouseCoords _ player =
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

        playerCoords : TileCoords
        playerCoords =
            Map.toTileCoords player.location

        mouseRelatedView : ( TileCoords, Set TileCoords ) -> Html FrontendMsg
        mouseRelatedView ( ( x, y ) as mouseCoords_, pathTaken ) =
            let
                notAllPassable : Bool
                notAllPassable =
                    pathTaken
                        |> Set.toList
                        |> List.any (Terrain.forCoords >> Terrain.isPassable >> not)

                cost : Int
                cost =
                    Pathfinding.tickCost pathTaken

                tooDistant : Bool
                tooDistant =
                    cost > player.ticks
            in
            H.div
                [ HA.id "map-mouse-layer"
                , HA.classList
                    [ ( "too-distant", tooDistant )
                    , ( "not-all-passable", notAllPassable )
                    ]
                ]
                [ H.div
                    [ HA.id "map-mouse-tile"
                    , HA.class "tile"
                    , cssVars
                        [ ( "--tile-coord-x", String.fromInt x )
                        , ( "--tile-coord-y", String.fromInt y )
                        ]
                    ]
                    []
                , H.div
                    [ HA.id "map-path-tiles" ]
                    (List.map pathTileView
                        (Set.toList (Set.remove mouseCoords_ pathTaken))
                    )
                , H.viewIf (Perception.atLeast Perception.Good special.perception) <|
                    H.div
                        [ HA.id "map-cost-info"
                        , cssVars
                            [ ( "--tile-coord-x", String.fromInt x )
                            , ( "--tile-coord-y", String.fromInt y )
                            ]
                        ]
                        [ if notAllPassable then
                            H.text "Not all tiles in your path are passable."

                          else
                            H.div []
                                [ H.div [] [ H.text <| "Path cost: " ++ String.fromInt cost ++ " ticks" ]
                                , H.viewIf tooDistant <|
                                    H.div [] [ H.text "You don't have enough ticks." ]
                                ]
                        ]
                ]

        pathTileView : TileCoords -> Html FrontendMsg
        pathTileView ( x, y ) =
            H.div
                [ HA.classList
                    [ ( "tile", True )
                    , ( "map-path-tile", True )
                    ]
                , cssVars
                    [ ( "--tile-coord-x", String.fromInt x )
                    , ( "--tile-coord-y", String.fromInt y )
                    ]
                ]
                []

        mouseCoordsOnly : Maybe TileCoords
        mouseCoordsOnly =
            Maybe.map Tuple.first mouseCoords

        mouseEventCatcherView : Html FrontendMsg
        mouseEventCatcherView =
            H.div
                [ HA.id "map-mouse-event-catcher"
                , HE.stopPropagationOn "mouseover"
                    (JD.map (\c -> ( MapMouseAtCoords c, True )) <|
                        changedCoordsDecoder mouseCoordsOnly
                    )
                , HE.stopPropagationOn "mousemove"
                    (JD.map (\c -> ( MapMouseAtCoords c, True )) <|
                        changedCoordsDecoder mouseCoordsOnly
                    )
                , HE.onMouseOut MapMouseOut
                , HE.onClick MapMouseClick
                ]
                []
    in
    [ pageTitleView "Map"
    , H.div
        [ HA.id "map"
        , cssVars
            [ ( "--map-columns", String.fromInt Map.columns )
            , ( "--map-rows", String.fromInt Map.rows )
            , ( "--map-cell-size", String.fromInt Map.tileSize ++ "px" )
            ]
        ]
        [ locationsView (Just playerCoords)
        , mapMarkerView playerCoords
        , mouseEventCatcherView
        , H.viewMaybe mouseRelatedView mouseCoords
        ]
    ]


locationView : Maybe TileCoords -> Location -> Html FrontendMsg
locationView maybePlayer location =
    let
        ( x, y ) =
            Location.coords location

        size : Location.Size
        size =
            Location.size location

        name : String
        name =
            Location.name location

        hasVendor : Bool
        hasVendor =
            Location.hasVendor location

        isCurrent : Bool
        isCurrent =
            maybePlayer == Just ( x, y )
    in
    H.div
        [ HA.classList
            [ ( "tile", True )
            , ( "map-location", True )
            , ( "small", size == Location.Small )
            , ( "middle", size == Location.Middle )
            , ( "large", size == Location.Large )
            , ( "has-vendor", hasVendor )
            , ( "is-current", isCurrent )
            ]
        , HA.attribute "data-location-name" name
        , cssVars
            [ ( "--tile-coord-x", String.fromInt x )
            , ( "--tile-coord-y", String.fromInt y )
            ]
        ]
        []


locationsView : Maybe TileCoords -> Html FrontendMsg
locationsView maybePlayer =
    Location.allLocations
        |> List.map (locationView maybePlayer)
        |> H.div [ HA.id "map-locations" ]


changedCoordsDecoder : Maybe TileCoords -> Decoder TileCoords
changedCoordsDecoder mouseCoords =
    JD.map2 Tuple.pair
        (JD.field "offsetX" JD.int)
        (JD.field "offsetY" JD.int)
        |> JD.andThen
            (\( x, y ) ->
                let
                    newCoords =
                        ( x // Map.tileSize
                        , y // Map.tileSize
                        )
                in
                case mouseCoords of
                    Nothing ->
                        JD.succeed newCoords

                    Just oldCoords ->
                        if oldCoords == newCoords then
                            JD.fail "no change"

                        else
                            JD.succeed newCoords
            )


mapMarkerView : TileCoords -> Html FrontendMsg
mapMarkerView ( x, y ) =
    H.img
        [ HA.id "map-marker"
        , cssVars
            [ ( "--player-coord-x", String.fromInt x )
            , ( "--player-coord-y", String.fromInt y )
            ]
        , HA.src "images/map_marker.png"
        , HA.width 25
        , HA.height 13
        ]
        []


cssVars : List ( String, String ) -> Attribute FrontendMsg
cssVars vars =
    vars
        |> List.map (\( var, value ) -> var ++ ": " ++ value)
        |> String.join ";"
        |> HA.attribute "style"


mapLoggedOutView : List (Html FrontendMsg)
mapLoggedOutView =
    [ pageTitleView "Map"
    , H.div
        [ HA.id "map"
        , cssVars
            [ ( "--map-columns", String.fromInt Map.columns )
            , ( "--map-rows", String.fromInt Map.rows )
            , ( "--map-cell-size", String.fromInt Map.tileSize ++ "px" )
            ]
        ]
        [ locationsView Nothing ]
    ]


townMainSquareView : Location -> WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)
townMainSquareView location _ _ =
    [ pageTitleView <| "Town: " ++ Location.name location
    , case Location.getVendor location of
        Nothing ->
            H.div [] [ H.text "No vendor in this town..." ]

        Just _ ->
            H.div []
                [ H.button
                    [ HE.onClick (GoToRoute (Route.Town (Route.Store { barter = Barter.empty }))) ]
                    [ H.text "[Visit store]" ]
                ]
    ]


townStoreView :
    Barter.State
    -> Location
    -> WorldLoggedInData
    -> CPlayer
    -> List (Html FrontendMsg)
townStoreView barter location world player =
    case Maybe.map (Vendor.getFrom world.vendors) (Location.getVendor location) of
        Nothing ->
            contentUnavailableWhenNotInTownView

        Just vendor ->
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

                playerKeptCaps : Int
                playerKeptCaps =
                    player.caps - barter.playerCaps

                vendorKeptCaps : Int
                vendorKeptCaps =
                    vendor.caps - barter.vendorCaps

                playerTradedCaps : Int
                playerTradedCaps =
                    barter.playerCaps

                vendorTradedCaps : Int
                vendorTradedCaps =
                    barter.vendorCaps

                playerTradedItemsValue : Int
                playerTradedItemsValue =
                    playerTradedItems
                        |> List.filterMap
                            (\( id, count ) ->
                                Dict.get id player.items
                                    |> Maybe.map (\{ kind } -> Item.basePrice kind * count)
                            )
                        |> List.sum

                playerTradedValue : Int
                playerTradedValue =
                    barter.playerCaps + playerTradedItemsValue

                vendorTradedItemsValue : Int
                vendorTradedItemsValue =
                    vendorTradedItems
                        |> List.filterMap
                            (\( id, count ) ->
                                Dict.get id vendor.items
                                    |> Maybe.map
                                        (\{ kind } ->
                                            Logic.price
                                                { itemCount = count
                                                , itemKind = kind
                                                , playerBarterSkill = Skill.get special player.addedSkillPercentages Skill.Barter
                                                , traderBarterSkill = vendor.barterSkill
                                                , hasMasterTraderPerk = Perk.rank Perk.MasterTrader player.perks > 0
                                                }
                                        )
                            )
                        |> List.sum

                vendorTradedValue : Int
                vendorTradedValue =
                    barter.vendorCaps + vendorTradedItemsValue

                playerKeptItems : List ( Item.Id, Int )
                playerKeptItems =
                    player.items
                        |> Dict.filterMap
                            (\itemId item ->
                                case Dict.get itemId barter.playerItems of
                                    Nothing ->
                                        -- player is not trading this item at all
                                        Just item.count

                                    Just tradedCount ->
                                        if tradedCount >= item.count then
                                            -- player is trading it all!
                                            Nothing

                                        else
                                            -- what amount does player have left in the inventory
                                            Just <| item.count - tradedCount
                            )
                        |> Dict.toList

                vendorKeptItems : List ( Item.Id, Int )
                vendorKeptItems =
                    vendor.items
                        |> Dict.filterMap
                            (\itemId item ->
                                case Dict.get itemId barter.vendorItems of
                                    Nothing ->
                                        -- vendor is not trading this item at all
                                        Just item.count

                                    Just tradedCount ->
                                        if tradedCount >= item.count then
                                            -- vendor is trading it all!
                                            Nothing

                                        else
                                            -- what amount does vendor have left in the inventory
                                            Just <| item.count - tradedCount
                            )
                        |> Dict.toList

                playerTradedItems : List ( Item.Id, Int )
                playerTradedItems =
                    Dict.toList barter.playerItems

                vendorTradedItems : List ( Item.Id, Int )
                vendorTradedItems =
                    Dict.toList barter.vendorItems

                resetBtn : Html FrontendMsg
                resetBtn =
                    H.button
                        [ HA.id "town-store-reset-btn"
                        , HE.onClick <| BarterMsg ResetBarter
                        ]
                        [ H.text "[Reset]" ]

                confirmBtn : Html FrontendMsg
                confirmBtn =
                    H.button
                        [ HA.id "town-store-confirm-btn"
                        , HE.onClick <| BarterMsg ConfirmBarter
                        ]
                        [ H.text "[Confirm]" ]

                capsView :
                    { class : String
                    , transfer : Int -> FrontendMsg
                    , transferNPosition : Barter.TransferNPosition
                    }
                    -> Int
                    -> Html FrontendMsg
                capsView { class, transfer, transferNPosition } caps =
                    let
                        capsString : String
                        capsString =
                            String.fromInt caps

                        arrowsDirection : Barter.ArrowsDirection
                        arrowsDirection =
                            Barter.arrowsDirection transferNPosition

                        transferNValue : String
                        transferNValue =
                            Dict_.get transferNPosition barter.transferNInputs
                                |> Maybe.withDefault Barter.defaultTransferN

                        isNHovered : Bool
                        isNHovered =
                            barter.transferNHover == Just transferNPosition

                        transferNView =
                            H.div
                                [ HA.class "town-store-transfer-n-area"
                                , HE.onMouseEnter <| BarterMsg <| SetTransferNHover transferNPosition
                                , HE.onMouseLeave <| BarterMsg UnsetTransferNHover
                                ]
                                [ H.button
                                    [ HA.class "town-store-transfer-btn before-hover"
                                    , HA.disabled <| caps <= 0
                                    , HA.title "Transfer N items"
                                    ]
                                    [ H.text "N" ]
                                , H.input
                                    [ HA.class "town-store-transfer-n-input after-hover"
                                    , HA.value transferNValue
                                    , HE.onInput <| BarterMsg << SetTransferNInput transferNPosition
                                    , HA.title "Transfer N items"
                                    ]
                                    []
                                , case String.toInt transferNValue of
                                    Nothing ->
                                        H.button
                                            [ HA.disabled True
                                            , HA.class "town-store-transfer-btn after-hover"
                                            , HA.title "Transfer N items"
                                            ]
                                            [ H.text "OK" ]

                                    Just n ->
                                        H.button
                                            [ HE.onClick <| transfer n
                                            , HA.disabled <| n <= 0 || n > caps
                                            , HA.class "town-store-transfer-btn after-hover"
                                            , HA.title "Transfer N items"
                                            ]
                                            [ H.text "OK" ]
                                ]

                        transferOneView =
                            H.button
                                [ HE.onClick <| transfer 1
                                , HA.disabled <| caps <= 0
                                , HA.classList
                                    [ ( "town-store-transfer-btn", True )
                                    , ( "hidden", isNHovered )
                                    ]
                                , HA.title "Transfer 1 item"
                                ]
                                [ H.text <| Barter.singleArrow arrowsDirection ]

                        transferAllView =
                            H.button
                                [ HE.onClick <| transfer caps
                                , HA.disabled <| caps <= 0
                                , HA.classList
                                    [ ( "town-store-transfer-btn", True )
                                    , ( "hidden", isNHovered )
                                    ]
                                , HA.title "Transfer all items"
                                ]
                                [ H.text <| Barter.doubleArrow arrowsDirection ]

                        itemView =
                            H.span
                                [ HA.class "town-store-item-label" ]
                                [ H.text <| "Caps: $" ++ capsString ]
                    in
                    H.div
                        [ HA.class <| "town-store-item town-store-caps " ++ class
                        , HA.attribute "data-caps" capsString
                        ]
                    <|
                        case arrowsDirection of
                            Barter.ArrowLeft ->
                                [ transferAllView
                                , transferNView
                                , transferOneView
                                , itemView
                                ]

                            Barter.ArrowRight ->
                                [ itemView
                                , transferOneView
                                , transferNView
                                , transferAllView
                                ]

                playerItemView :
                    { items : Dict Item.Id Item
                    , class : String
                    , transfer : Item.Id -> Int -> FrontendMsg
                    , transferNPosition : Item.Id -> Barter.TransferNPosition
                    }
                    -> ( Item.Id, Int )
                    -> Html FrontendMsg
                playerItemView { items, class, transfer, transferNPosition } ( id, count ) =
                    let
                        itemName =
                            case Dict.get id items of
                                Nothing ->
                                    "<BUG>"

                                Just item ->
                                    Item.name item.kind

                        position : Barter.TransferNPosition
                        position =
                            transferNPosition id

                        arrowsDirection : Barter.ArrowsDirection
                        arrowsDirection =
                            Barter.arrowsDirection position

                        transferNValue : String
                        transferNValue =
                            Dict_.get position barter.transferNInputs
                                |> Maybe.withDefault Barter.defaultTransferN

                        isNHovered : Bool
                        isNHovered =
                            barter.transferNHover == Just position

                        transferNView =
                            H.div
                                [ HA.class "town-store-transfer-n-area"
                                , HE.onMouseEnter <| BarterMsg <| SetTransferNHover position
                                , HE.onMouseLeave <| BarterMsg UnsetTransferNHover
                                ]
                                [ H.button
                                    [ HA.class "town-store-transfer-btn before-hover"
                                    , HA.disabled <| count <= 0
                                    , HA.title "Transfer N items"
                                    ]
                                    [ H.text "N" ]
                                , H.input
                                    [ HA.class "town-store-transfer-n-input after-hover"
                                    , HA.value transferNValue
                                    , HE.onInput <| BarterMsg << SetTransferNInput position
                                    , HA.title "Transfer N items"
                                    ]
                                    []
                                , case String.toInt transferNValue of
                                    Nothing ->
                                        H.button
                                            [ HA.disabled True
                                            , HA.class "town-store-transfer-btn after-hover"
                                            , HA.title "Transfer N items"
                                            ]
                                            [ H.text "OK" ]

                                    Just n ->
                                        H.button
                                            [ HE.onClick <| transfer id n
                                            , HA.disabled <| n <= 0 || n > count
                                            , HA.class "town-store-transfer-btn after-hover"
                                            , HA.title "Transfer N items"
                                            ]
                                            [ H.text "OK" ]
                                ]

                        transferOneView =
                            H.button
                                [ HE.onClick <| transfer id 1
                                , HA.disabled <| count <= 0
                                , HA.classList
                                    [ ( "town-store-transfer-btn", True )
                                    , ( "hidden", isNHovered )
                                    ]
                                , HA.title "Transfer 1 item"
                                ]
                                [ H.text <| Barter.singleArrow arrowsDirection ]

                        transferAllView =
                            H.button
                                [ HE.onClick <| transfer id count
                                , HA.disabled <| count <= 0
                                , HA.classList
                                    [ ( "town-store-transfer-btn", True )
                                    , ( "hidden", isNHovered )
                                    ]
                                , HA.title "Transfer all items"
                                ]
                                [ H.text <| Barter.doubleArrow arrowsDirection ]

                        itemView =
                            H.span
                                [ HA.class "town-store-item-label" ]
                                [ H.text <| String.fromInt count ++ "x " ++ itemName ]
                    in
                    H.div [ HA.class <| "town-store-item " ++ class ] <|
                        case arrowsDirection of
                            Barter.ArrowLeft ->
                                [ transferAllView
                                , transferNView
                                , transferOneView
                                , itemView
                                ]

                            Barter.ArrowRight ->
                                [ itemView
                                , transferOneView
                                , transferNView
                                , transferAllView
                                ]

                playerNameView : Html FrontendMsg
                playerNameView =
                    H.div
                        [ HA.id "town-store-player-name" ]
                        [ H.text <| "Player: " ++ player.name ]

                vendorNameView : Html FrontendMsg
                vendorNameView =
                    H.div
                        [ HA.id "town-store-vendor-name" ]
                        [ H.text <| "Vendor: " ++ Vendor.name vendor.name ]

                playerTradedValueView : Html FrontendMsg
                playerTradedValueView =
                    H.div
                        [ HA.id "town-store-player-traded-value" ]
                        [ H.text <| "Value: $" ++ String.fromInt playerTradedValue ]

                vendorTradedValueView : Html FrontendMsg
                vendorTradedValueView =
                    H.div
                        [ HA.id "town-store-vendor-traded-value" ]
                        [ H.text <| "Value: $" ++ String.fromInt vendorTradedValue ]

                playerKeptItemsView : Html FrontendMsg
                playerKeptItemsView =
                    H.div [ HA.id "town-store-player-kept-items" ]
                        (List.map
                            (playerItemView
                                { items = player.items
                                , class = "player-kept-item"
                                , transfer = \id count -> BarterMsg <| AddPlayerItem id count
                                , transferNPosition = Barter.PlayerKeptItem
                                }
                            )
                            playerKeptItems
                        )

                playerTradedItemsView : Html FrontendMsg
                playerTradedItemsView =
                    H.div [ HA.id "town-store-player-traded-items" ]
                        (List.map
                            (playerItemView
                                { items = player.items
                                , class = "player-traded-item"
                                , transfer = \id count -> BarterMsg <| RemovePlayerItem id count
                                , transferNPosition = Barter.PlayerTradedItem
                                }
                            )
                            playerTradedItems
                        )

                vendorKeptItemsView : Html FrontendMsg
                vendorKeptItemsView =
                    H.div [ HA.id "town-store-vendor-kept-items" ]
                        (List.map
                            (playerItemView
                                { items = vendor.items
                                , class = "vendor-kept-item"
                                , transfer = \id count -> BarterMsg <| AddVendorItem id count
                                , transferNPosition = Barter.VendorKeptItem
                                }
                            )
                            vendorKeptItems
                        )

                vendorTradedItemsView : Html FrontendMsg
                vendorTradedItemsView =
                    H.div [ HA.id "town-store-vendor-traded-items" ]
                        (List.map
                            (playerItemView
                                { items = vendor.items
                                , class = "vendor-traded-item"
                                , transfer = \id count -> BarterMsg <| RemoveVendorItem id count
                                , transferNPosition = Barter.VendorTradedItem
                                }
                            )
                            vendorTradedItems
                        )

                playerKeptCapsView : Html FrontendMsg
                playerKeptCapsView =
                    capsView
                        { class = "player-kept-caps"
                        , transfer = BarterMsg << AddPlayerCaps
                        , transferNPosition = Barter.PlayerKeptCaps
                        }
                        playerKeptCaps

                playerTradedCapsView : Html FrontendMsg
                playerTradedCapsView =
                    capsView
                        { class = "player-traded-caps"
                        , transfer = BarterMsg << RemovePlayerCaps
                        , transferNPosition = Barter.PlayerTradedCaps
                        }
                        playerTradedCaps

                vendorKeptCapsView : Html FrontendMsg
                vendorKeptCapsView =
                    capsView
                        { class = "vendor-kept-caps"
                        , transfer = BarterMsg << AddVendorCaps
                        , transferNPosition = Barter.VendorKeptCaps
                        }
                        vendorKeptCaps

                vendorTradedCapsView : Html FrontendMsg
                vendorTradedCapsView =
                    capsView
                        { class = "vendor-traded-caps"
                        , transfer = BarterMsg << RemoveVendorCaps
                        , transferNPosition = Barter.VendorTradedCaps
                        }
                        vendorTradedCaps

                playerTradedBg : Html FrontendMsg
                playerTradedBg =
                    H.div [ HA.id "town-store-player-traded-bg" ] []

                vendorTradedBg : Html FrontendMsg
                vendorTradedBg =
                    H.div [ HA.id "town-store-vendor-traded-bg" ] []

                gridContents : List (Html FrontendMsg)
                gridContents =
                    [ playerTradedBg
                    , vendorTradedBg
                    , resetBtn
                    , confirmBtn
                    , playerNameView
                    , vendorNameView
                    , playerKeptCapsView
                    , vendorKeptCapsView
                    , playerTradedCapsView
                    , vendorTradedCapsView
                    , playerTradedValueView
                    , vendorTradedValueView
                    , playerKeptItemsView
                    , playerTradedItemsView
                    , vendorKeptItemsView
                    , vendorTradedItemsView
                    ]
            in
            [ pageTitleView <| "Store: " ++ Location.name location
            , H.button
                [ HE.onClick (GoToRoute (Route.Town Route.MainSquare)) ]
                [ H.text "[Back]" ]
            , H.div [ HA.id "town-store-grid" ] gridContents
            , H.viewMaybe
                (\message ->
                    H.div
                        [ HA.id "town-store-barter-message" ]
                        [ H.text <| Barter.messageText message ]
                )
                barter.lastMessage
            ]


newCharView : NewChar -> List (Html FrontendMsg)
newCharView newChar =
    let
        createBtnView =
            H.div [ HA.id "new-character-create-btn" ]
                [ H.button
                    [ HE.onClick CreateChar ]
                    [ H.text "[Create]" ]
                ]

        errorView =
            H.viewMaybe
                (\error ->
                    H.div [ HA.id "new-character-error" ]
                        [ H.text <| NewChar.error error ]
                )
                newChar.error
    in
    [ pageTitleView "New Character"
    , H.div
        [ HA.id "new-character-grid" ]
        [ H.div
            [ HA.class "new-character-column" ]
            [ newCharSpecialView newChar
            , newCharTraitsView newChar.traits
            , createBtnView
            , errorView
            ]
        , H.div
            [ HA.class "new-character-column" ]
            [ newCharSkillsView newChar
            ]
        , H.div
            [ HA.class "new-character-column" ]
            [ newCharDerivedStatsView newChar
            , newCharHelpView
            ]
        ]
    ]


newCharHelpView : Html FrontendMsg
newCharHelpView =
    H.div
        [ HA.id "new-character-help" ]
        [ H.h3
            [ HA.class "new-character-section-title" ]
            [ H.text "Help" ]
        , H.p [] [ H.text "TODO info about hovered item" ]
        ]


newCharDerivedStatsView : NewChar -> Html FrontendMsg
newCharDerivedStatsView newChar =
    let
        finalSpecial =
            Logic.special
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                , isNewChar = True
                }

        itemView : ( String, String, Maybe String ) -> Html FrontendMsg
        itemView ( label, value, tooltip ) =
            let
                ( liAttrs, valueAttrs ) =
                    case tooltip of
                        Just tooltip_ ->
                            ( [ HA.title tooltip_ ]
                            , [ HA.class "has-tooltip" ]
                            )

                        Nothing ->
                            ( [], [] )
            in
            H.li liAttrs
                [ H.text <| label ++ ": "
                , H.span valueAttrs [ H.text value ]
                ]

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level finalSpecial.perception
    in
    H.div
        [ HA.id "new-character-derived-stats" ]
        [ H.h3
            [ HA.class "new-character-section-title" ]
            [ H.text "Derived stats" ]
        , H.ul [ HA.id "new-character-derived-stats-list" ] <|
            List.map itemView
                [ ( "Hitpoints"
                  , String.fromInt <|
                        Logic.hitpoints
                            { level = 1
                            , finalSpecial = finalSpecial
                            }
                  , Nothing
                  )
                , ( "Healing rate"
                  , (String.fromInt <| Logic.healingRate finalSpecial)
                        ++ " HP/tick"
                  , Nothing
                  )
                , ( "Perception Level"
                  , Perception.label perceptionLevel
                  , Just <| Perception.tooltip perceptionLevel
                  )
                , ( "Action Points"
                  , String.fromInt <|
                        Logic.actionPoints
                            { hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                            , finalSpecial = finalSpecial
                            }
                  , Nothing
                  )
                ]
        ]


newCharSpecialView : NewChar -> Html FrontendMsg
newCharSpecialView newChar =
    let
        finalSpecial =
            Logic.special
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                , isNewChar = True
                }

        specialItemView type_ =
            let
                value =
                    Special.get type_ finalSpecial
            in
            H.tr
                [ HA.class "character-special-attribute" ]
                [ H.td
                    [ HA.class "character-special-attribute-dec" ]
                    [ H.button
                        [ HE.onClick <| NewCharDecSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canDecrement
                                    type_
                                    finalSpecial
                        ]
                        [ H.text "[-]" ]
                    ]
                , H.td
                    [ HA.class "character-special-attribute-label" ]
                    [ H.text <| Special.label type_ ]
                , H.td
                    [ HA.classList
                        [ ( "character-special-attribute-value", True )
                        , ( "out-of-range", not <| Special.isValueInRange value )
                        ]
                    ]
                    [ H.text <| String.fromInt value ]
                , H.td
                    [ HA.class "character-special-attribute-inc" ]
                    [ H.button
                        [ HE.onClick <| NewCharIncSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canIncrement
                                    newChar.availableSpecial
                                    type_
                                    finalSpecial
                        ]
                        [ H.text "[+]" ]
                    ]
                ]
    in
    H.div
        [ HA.id "new-character-special" ]
        [ H.h3
            [ HA.class "new-character-section-title" ]
            [ H.text "SPECIAL ("
            , H.span
                [ HA.class "new-character-section-available-number" ]
                [ H.text <| String.fromInt newChar.availableSpecial ]
            , H.text " points left)"
            ]
        , H.table
            [ HA.id "character-special-table" ]
            (List.map specialItemView Special.all)
        , H.p [] [ H.text "Distribute your SPECIAL points (each attribute can be in range 1..10)." ]
        ]


newCharTraitsView : Set_.Set Trait -> Html FrontendMsg
newCharTraitsView traits =
    let
        availableTraits : Int
        availableTraits =
            Logic.maxTraits - Set_.size traits

        traitView : Trait -> Html FrontendMsg
        traitView trait =
            let
                isToggled : Bool
                isToggled =
                    Set_.member trait traits

                buttonLabel : String
                buttonLabel =
                    if isToggled then
                        "[*]"

                    else
                        "[ ]"
            in
            H.li
                [ HA.classList
                    [ ( "new-character-traits-trait", True )
                    , ( "is-toggled", isToggled )
                    ]
                , HE.onClick <| NewCharToggleTrait trait
                ]
                [ H.button
                    [ HE.onClickStopPropagation <| NewCharToggleTrait trait
                    , HA.class "new-character-trait-tag-btn"
                    ]
                    [ H.text buttonLabel ]
                , H.div [] [ H.text <| Trait.name trait ]
                ]
    in
    H.div
        [ HA.id "new-character-traits" ]
        [ H.h3
            [ HA.class "new-character-section-title" ]
            [ H.text "Traits ("
            , H.span
                [ HA.class "new-character-section-available-number" ]
                [ H.text <| String.fromInt availableTraits ]
            , H.text " available)"
            ]
        , H.ul
            [ HA.id "new-character-traits-list" ]
            (List.map traitView Trait.all)
        , H.p [] [ H.text "Select up to two traits." ]
        ]


newCharSkillsView : NewChar -> Html FrontendMsg
newCharSkillsView newChar =
    let
        finalSpecial : Special
        finalSpecial =
            Logic.special
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                , isNewChar = True
                }
    in
    skillsView_
        { addedSkillPercentages =
            Logic.addedSkillPercentages
                { taggedSkills = newChar.taggedSkills
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                }
        , special = finalSpecial
        , taggedSkills = newChar.taggedSkills
        , hasTagPerk = False
        , availableSkillPoints = 0
        , isNewChar = True
        , id = "new-character-skills"
        }


characterView : WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)
characterView _ player =
    [ pageTitleView "Character"
    , H.div
        [ HA.id "character-grid" ]
        [ H.div
            [ HA.class "character-column" ]
            [ charSpecialView player
            , charTraitsView player.traits
            , charPerksView player.perks
            ]
        , H.div
            [ HA.class "character-column" ]
            [ charSkillsView player
            ]
        , H.div
            [ HA.class "character-column" ]
            [ charDerivedStatsView player
            , charHelpView
            ]
        ]
    ]


charTraitsView : Set_.Set Trait -> Html FrontendMsg
charTraitsView traits =
    let
        itemView : Trait -> Html FrontendMsg
        itemView trait =
            H.li
                [ HA.class "character-traits-trait" ]
                [ H.text <| Trait.name trait ]
    in
    H.div
        [ HA.id "character-traits" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "Traits" ]
        , if Set_.isEmpty traits then
            H.p [] [ H.text "You have no traits." ]

          else
            H.ul
                [ HA.id "character-traits-list" ]
                (List.map itemView <| Set_.toList traits)
        ]


charHelpView : Html FrontendMsg
charHelpView =
    H.div
        [ HA.id "character-help" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "Help" ]
        , H.p [] [ H.text "TODO info about hovered item" ]
        ]


charDerivedStatsView : CPlayer -> Html FrontendMsg
charDerivedStatsView player =
    let
        finalSpecial : Special
        finalSpecial =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }

        itemView : ( String, String, Maybe String ) -> Html FrontendMsg
        itemView ( label, value, tooltip ) =
            let
                ( liAttrs, valueAttrs ) =
                    case tooltip of
                        Just tooltip_ ->
                            ( [ HA.title tooltip_ ]
                            , [ HA.class "has-tooltip" ]
                            )

                        Nothing ->
                            ( [], [] )
            in
            H.li liAttrs
                [ H.text <| label ++ ": "
                , H.span valueAttrs [ H.text value ]
                ]

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level finalSpecial.perception
    in
    H.div
        [ HA.id "character-derived-stats" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "Derived stats" ]
        , H.ul [ HA.id "character-derived-stats-list" ] <|
            List.map itemView
                [ ( "Hitpoints"
                  , String.fromInt <|
                        Logic.hitpoints
                            { level = 1
                            , finalSpecial = finalSpecial
                            }
                  , Nothing
                  )
                , ( "Healing rate"
                  , (String.fromInt <| Logic.healingRate finalSpecial)
                        ++ " HP/tick"
                  , Nothing
                  )
                , ( "Perception Level"
                  , Perception.label perceptionLevel
                  , Just <| Perception.tooltip perceptionLevel
                  )
                , ( "Action Points"
                  , String.fromInt <|
                        Logic.actionPoints
                            { hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                            , finalSpecial = finalSpecial
                            }
                  , Nothing
                  )
                ]
        ]


charSpecialView : CPlayer -> Html FrontendMsg
charSpecialView player =
    let
        special =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }

        specialItemView type_ =
            let
                value =
                    Special.get type_ special
            in
            H.tr
                [ HA.class "character-special-attribute" ]
                [ H.td
                    [ HA.class "character-special-attribute-label" ]
                    [ H.text <| Special.label type_ ]
                , H.td
                    [ HA.class "character-special-attribute-value"

                    -- TODO highlighted if addiction etc?
                    ]
                    [ H.text <| String.fromInt value ]
                ]
    in
    H.div
        [ HA.id "character-special" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "SPECIAL" ]
        , H.table
            [ HA.id "character-special-table" ]
            (List.map specialItemView Special.all)
        ]


skillsView_ :
    { addedSkillPercentages : Dict_.Dict Skill Int
    , special : Special
    , taggedSkills : Set_.Set Skill
    , hasTagPerk : Bool
    , availableSkillPoints : Int
    , isNewChar : Bool
    , id : String
    }
    -> Html FrontendMsg
skillsView_ r =
    let
        onTag : Skill -> FrontendMsg
        onTag =
            if r.isNewChar then
                NewCharToggleTaggedSkill

            else
                AskToTagSkill

        totalTags : Int
        totalTags =
            Logic.totalTags { hasTagPerk = r.hasTagPerk }

        availableTags : Int
        availableTags =
            max 0 <| totalTags - Set_.size r.taggedSkills

        skillView : Skill -> Html FrontendMsg
        skillView skill =
            let
                percent : Int
                percent =
                    Skill.get r.special r.addedSkillPercentages skill

                notUseful : Bool
                notUseful =
                    not <| Skill.isUseful skill

                isTagged : Bool
                isTagged =
                    Set_.member skill r.taggedSkills

                ( showTagButton, isTaggingDisabled, tagButtonLabel ) =
                    case ( r.isNewChar, isTagged ) of
                        ( True, True ) ->
                            ( True, False, "[*]" )

                        ( True, False ) ->
                            ( True, availableTags == 0, "[ ]" )

                        ( False, True ) ->
                            ( availableTags > 0, True, "[*]" )

                        ( False, False ) ->
                            ( availableTags > 0, availableTags == 0, "[ ]" )

                isIncButtonDisabled : Bool
                isIncButtonDisabled =
                    r.availableSkillPoints <= 0
            in
            H.li
                [ HA.classList
                    [ ( "character-skills-skill", True )
                    , ( "not-useful", notUseful )
                    , ( "is-tagged", isTagged )
                    , ( "is-taggable", showTagButton && not isTaggingDisabled )
                    ]
                , HA.attributeIf notUseful <| HA.title "This skill is not yet useful in the game."
                , HA.attributeIf (not isTaggingDisabled) <| HE.onClick <| onTag skill
                ]
                [ H.div
                    [ HA.class "character-skill-name" ]
                    [ H.viewIf showTagButton <|
                        H.button
                            [ HE.onClickStopPropagation <| onTag skill
                            , HA.disabled isTaggingDisabled
                            , HA.class "character-skill-tag-btn"
                            ]
                            [ H.text tagButtonLabel ]
                    , H.text <| Skill.name skill
                    ]
                , H.div
                    [ HA.class "character-skill-value" ]
                    [ H.div
                        [ HA.class "character-skill-percent" ]
                        [ H.text <| String.fromInt percent ++ "%" ]
                    , H.viewIf (not r.isNewChar) <|
                        H.button
                            [ HE.onClickStopPropagation <| AskToIncSkill skill
                            , HA.class "character-skill-inc-btn"
                            , HA.disabled isIncButtonDisabled
                            , HA.attributeIf isIncButtonDisabled <|
                                HA.title "You have no skill points available."
                            ]
                            [ H.text "[+]" ]
                    ]
                ]
    in
    if r.isNewChar then
        H.div
            [ HA.id r.id ]
            [ H.h3
                [ HA.class "new-character-section-title" ]
                [ H.text "Skills ("
                , H.span
                    [ HA.class "new-character-section-available-number" ]
                    [ H.text <| String.fromInt availableTags ]
                , H.text " tags left)"
                ]
            , H.ul
                [ HA.id "character-skills-list" ]
                (List.map skillView Skill.all)
            , H.p [] [ H.text "Tag three skills. Dimmed skills are not yet useful in the game." ]
            ]

    else
        H.div
            [ HA.id r.id
            , HA.classList [ ( "cannot-inc", r.availableSkillPoints <= 0 ) ]
            ]
            [ H.h3
                [ HA.class "character-section-title" ]
                [ H.text "Skills ("
                , H.span
                    [ HA.class "character-section-available-number" ]
                    [ H.text <| String.fromInt r.availableSkillPoints ]
                , H.text " points available)"
                ]
            , H.ul
                [ HA.id "character-skills-list" ]
                (List.map skillView Skill.all)
            , H.viewIf (availableTags > 0) <|
                H.p [] [ H.text <| "Tags available: " ++ String.fromInt availableTags ]
            , H.viewIf (r.availableSkillPoints > 0) <|
                H.p [] [ H.text <| "Skill points available: " ++ String.fromInt r.availableSkillPoints ]
            ]


charSkillsView : CPlayer -> Html FrontendMsg
charSkillsView player =
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
    in
    skillsView_
        { addedSkillPercentages = player.addedSkillPercentages
        , special = special
        , taggedSkills = player.taggedSkills
        , hasTagPerk = Perk.rank Perk.Tag player.perks > 0
        , availableSkillPoints = player.availableSkillPoints
        , isNewChar = False
        , id = "character-skills"
        }


charPerksView : Dict_.Dict Perk Int -> Html FrontendMsg
charPerksView perks =
    let
        itemView : ( Perk, Int ) -> Html FrontendMsg
        itemView ( perk, rank ) =
            let
                maxRank : Int
                maxRank =
                    Perk.maxRank perk
            in
            H.li
                [ HA.class "character-perks-perk" ]
                [ H.text <|
                    if maxRank == 1 then
                        Perk.name perk

                    else
                        Perk.name perk ++ " (" ++ String.fromInt rank ++ "x)"
                ]
    in
    H.div
        [ HA.id "character-perks" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "Perks" ]
        , if Dict_.isEmpty perks then
            H.p [] [ H.text "No perks yet!" ]

          else
            H.ul
                [ HA.id "character-perks-list" ]
                (List.map itemView <| Dict_.toList perks)
        ]


inventoryView : WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)
inventoryView _ player =
    let
        itemView : Item -> Html FrontendMsg
        itemView item =
            H.li
                [ HA.class "inventory-item" ]
                [ H.text <| String.fromInt item.count ++ "x " ++ Item.name item.kind ]
    in
    [ pageTitleView "Inventory"
    , if Dict.isEmpty player.items then
        H.p [] [ H.text "You have no items!" ]

      else
        H.ul
            [ HA.id "inventory-list" ]
            (List.map itemView <| Dict.values player.items)
    ]


messagesView : Posix -> Time.Zone -> WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)
messagesView currentTime zone _ player =
    [ pageTitleView "Messages"
    , H.table [ HA.id "messages-table" ]
        [ H.thead []
            [ H.tr []
                [ H.th
                    [ HA.class "messages-unread"
                    , HA.title "Unread"
                    ]
                    [ H.text "U" ]
                , H.th [ HA.class "messages-summary" ] [ H.text "Summary" ]
                , H.th [ HA.class "messages-date" ] [ H.text "Date" ]
                , H.th
                    [ HA.class "messages-remove"
                    , HA.title "Remove"
                    ]
                    [ H.text "✗" ]
                ]
            ]
        , H.tbody []
            (player.messages
                |> List.map
                    (\message ->
                        let
                            isUnread : Bool
                            isUnread =
                                not message.hasBeenRead

                            summary : String
                            summary =
                                Message.summary message

                            relativeDate : String
                            relativeDate =
                                DateFormat.Relative.relativeTime
                                    currentTime
                                    message.date
                        in
                        H.tr
                            [ HA.classList [ ( "is-unread", isUnread ) ]
                            , HE.onClick <| OpenMessage message
                            ]
                            [ if isUnread then
                                H.td
                                    [ HA.class "messages-unread"
                                    , HA.title "Unread"
                                    ]
                                    [ H.text "*" ]

                              else
                                H.td [ HA.class "messages-unread" ] []
                            , H.td
                                [ HA.class "messages-summary"
                                , HA.title summary
                                ]
                                [ H.text summary ]
                            , H.td
                                [ HA.class "messages-date"
                                , HA.title <| Message.fullDate zone message
                                ]
                                [ H.text relativeDate ]
                            , H.td
                                [ HA.class "messages-remove"
                                , HA.title "Remove"
                                , HE.onClickStopPropagation <| AskToRemoveMessage message
                                ]
                                [ H.text "✗" ]
                            ]
                    )
            )
        ]
    , H.viewIf (List.isEmpty player.messages) <|
        H.div
            [ HA.id "messages-empty-note" ]
            [ H.text "No messages right now!" ]
    ]


messageView : Time.Zone -> Message -> WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)
messageView zone message _ player =
    let
        special =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }
    in
    [ pageTitleView "Message"
    , H.h3
        [ HA.id "message-summary" ]
        [ H.text <| Message.summary message ]
    , H.div
        [ HA.id "message-date" ]
        [ H.text <| Message.fullDate zone message ]
    , Message.content
        [ HA.id "message-content" ]
        special.perception
        message
    , H.button
        [ HE.onClick <| GoToRoute Route.Messages
        , HA.id "message-back-button"
        ]
        [ H.text "[Back]" ]
    ]


newsItemView : Time.Zone -> News.Item -> Html FrontendMsg
newsItemView zone { date, title, text } =
    H.div
        [ HA.class "news-item" ]
        [ H.h3
            [ HA.class "news-item-title" ]
            [ H.text title ]
        , H.time
            [ HA.class "news-item-date" ]
            [ date
                |> News.formatDate zone
                |> H.text
            ]
        , News.formatText "news-item-text" text
        ]


newsView : Time.Zone -> List (Html FrontendMsg)
newsView zone =
    pageTitleView "News"
        :: List.map (newsItemView zone) News.items


fightView : FightInfo -> WorldLoggedInData -> CPlayer -> List (Html FrontendMsg)
fightView fight _ player =
    let
        youAreAttacker =
            fight.attacker == Fight.Player player.name

        finalSpecial =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }
    in
    [ pageTitleView "Fight"
    , H.div []
        [ H.text <|
            "Attacker: "
                ++ Fight.opponentName fight.attacker
                ++ (if youAreAttacker then
                        " (you)"

                    else
                        ""
                   )
        ]
    , H.div []
        [ H.text <|
            "Target: "
                ++ Fight.opponentName fight.target
                ++ (if youAreAttacker then
                        ""

                    else
                        " (you)"
                   )
        ]
    , Data.Fight.View.view finalSpecial.perception fight player.name
    , H.button
        [ HE.onClick <| GoToRoute Route.Ladder
        , HA.id "fight-back-button"
        ]
        [ H.text "[Back]" ]
    ]


ladderLoadingView : List (Html FrontendMsg)
ladderLoadingView =
    [ pageTitleView "Ladder"
    , H.div []
        [ H.text "Ladder is loading..."
        , H.span [ HA.class "loading-cursor" ] []
        ]
    ]


ladderView :
    { loggedInPlayer : Maybe CPlayer
    , players : List COtherPlayer
    }
    -> List (Html FrontendMsg)
ladderView data =
    [ pageTitleView "Ladder"
    , ladderTableView data
    ]


ladderTableView :
    { loggedInPlayer : Maybe CPlayer
    , players : List COtherPlayer
    }
    -> Html FrontendMsg
ladderTableView { loggedInPlayer, players } =
    let
        cantFight : String -> Html FrontendMsg
        cantFight message =
            H.td
                [ HA.class "ladder-fight"
                , HA.title message
                ]
                [ H.text "-" ]
    in
    H.table [ HA.id "ladder-table" ]
        [ H.thead []
            [ H.tr []
                [ H.th
                    [ HA.class "ladder-rank"
                    , HA.title "Rank"
                    ]
                    [ H.text "#" ]
                , H.viewIf (loggedInPlayer /= Nothing) <|
                    H.th [ HA.class "ladder-fight" ] [ H.text "Fight" ]
                , H.th [ HA.class "ladder-name" ] [ H.text "Name" ]
                , H.viewIf (loggedInPlayer /= Nothing) <|
                    H.th
                        [ HA.class "ladder-status"
                        , HA.title "Health status"
                        ]
                        [ H.text "Status" ]
                , H.th [ HA.class "ladder-lvl" ] [ H.text "Lvl" ]

                --, H.th [HA.class "ladder-city"] [ H.text "City" ] -- city
                --, H.th [HA.class "ladder-flag"] [] -- flag
                , H.th
                    [ HA.class "ladder-wins"
                    , HA.title "Wins"
                    ]
                    [ H.text "W" ]
                , H.th
                    [ HA.class "ladder-losses"
                    , HA.title "Losses"
                    ]
                    [ H.text "L" ]
                ]
            ]
        , H.tbody []
            (players
                |> List.indexedMap
                    (\i player ->
                        H.tr [ HA.classList [ ( "is-player", Maybe.map .name loggedInPlayer == Just player.name ) ] ]
                            [ H.td
                                [ HA.class "ladder-rank"
                                , HA.title "Rank"
                                ]
                                [ H.text <| String.fromInt <| i + 1 ]
                            , loggedInPlayer
                                |> H.viewMaybe
                                    (\loggedInPlayer_ ->
                                        if loggedInPlayer_.name == player.name then
                                            cantFight "Hey, that's you!"

                                        else if loggedInPlayer_.hp == 0 then
                                            cantFight "Can't fight: you're dead!"

                                        else if HealthStatus.isDead player.healthStatus then
                                            cantFight "Can't fight this person: they're dead!"

                                        else if loggedInPlayer_.ticks <= 0 then
                                            cantFight "Can't fight: you have no ticks!"

                                        else
                                            H.td
                                                [ HA.class "ladder-fight"
                                                , HE.onClick <| AskToFight player.name
                                                ]
                                                [ H.text "Fight" ]
                                    )
                            , H.td
                                [ HA.class "ladder-name"
                                , HA.title "Name"
                                ]
                                [ H.text player.name ]
                            , loggedInPlayer
                                |> H.viewMaybe
                                    (\loggedInPlayer_ ->
                                        let
                                            special : Special
                                            special =
                                                Logic.special
                                                    { baseSpecial = loggedInPlayer_.baseSpecial
                                                    , hasBruiserTrait = Trait.isSelected Trait.Bruiser loggedInPlayer_.traits
                                                    , hasGiftedTrait = Trait.isSelected Trait.Gifted loggedInPlayer_.traits
                                                    , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame loggedInPlayer_.traits
                                                    , isNewChar = False
                                                    }
                                        in
                                        H.td
                                            [ HA.class "ladder-status"
                                            , HA.title <|
                                                if special.perception <= 1 then
                                                    "Health status. Your perception is so low you genuinely can't say whether they're even alive or dead."

                                                else
                                                    "Health status"
                                            ]
                                            [ H.text <| HealthStatus.label player.healthStatus ]
                                    )
                            , H.td
                                [ HA.class "ladder-lvl"
                                , HA.title "Level"
                                ]
                                [ H.text <| String.fromInt player.level ]
                            , H.td
                                [ HA.class "ladder-wins"
                                , HA.title "Wins"
                                ]
                                [ H.text <| String.fromInt player.wins ]
                            , H.td
                                [ HA.class "ladder-losses"
                                , HA.title "Losses"
                                ]
                                [ H.text <| String.fromInt player.losses ]
                            ]
                    )
            )
        ]


contentUnavailableToLoggedOutView : List (Html FrontendMsg)
contentUnavailableToLoggedOutView =
    contentUnavailableView "you're not logged in"


contentUnavailableWhenNotInTownView : List (Html FrontendMsg)
contentUnavailableWhenNotInTownView =
    contentUnavailableView "you're not in a town or another location"


contentUnavailableWhenNoVendorView : List (Html FrontendMsg)
contentUnavailableWhenNoVendorView =
    contentUnavailableView "you're not in a town that has a vendor"


contentUnavailableToNonAdminView : List (Html FrontendMsg)
contentUnavailableToNonAdminView =
    contentUnavailableView "you're not an admin"


contentUnavailableToNonCreatedView : List (Html FrontendMsg)
contentUnavailableToNonCreatedView =
    contentUnavailableView "you haven't created your character yet"


contentUnavailableView : String -> List (Html FrontendMsg)
contentUnavailableView reason =
    [ H.text <|
        "Content unavailable ("
            ++ reason
            ++ "). This is most likely a bug. We should have redirected you someplace else. Could you report this to the developers please?"
    ]


notInitializedView : Model -> Html FrontendMsg
notInitializedView model =
    appView
        { leftNav =
            [ loginFormView model.world
            , alertMessageView model.alertMessage
            , loadingNavView
            ]
        }
        model


loadingNavView : Html FrontendMsg
loadingNavView =
    H.div
        [ HA.id "loading-nav" ]
        [ H.text "Loading..."
        , H.span [ HA.class "loading-cursor" ] []
        ]


loggedOutView : Model -> Html FrontendMsg
loggedOutView model =
    appView
        { leftNav =
            [ loginFormView model.world
            , alertMessageView model.alertMessage
            , loggedOutLinksView model.route
            ]
        }
        model


loggedInView : WorldLoggedInData -> Model -> Html FrontendMsg
loggedInView world model =
    appView
        { leftNav =
            [ alertMessageView model.alertMessage
            , playerInfoView world.player
            , loggedInLinksView world.player model.route
            ]
        }
        model


adminView : AdminData -> Model -> Html FrontendMsg
adminView adminData model =
    appView
        { leftNav =
            [ H.viewMaybe (serverTickView model.zone model.time) adminData.nextWantedTick
            , alertMessageView model.alertMessage
            , adminLinksView model.route
            ]
        }
        model


alertMessageView : Maybe String -> Html FrontendMsg
alertMessageView maybeMessage =
    maybeMessage
        |> H.viewMaybe
            (\message ->
                H.div
                    [ HA.id "alert-message" ]
                    [ H.text message ]
            )


loginFormView : World -> Html FrontendMsg
loginFormView world =
    World.getAuth world
        |> H.viewMaybe
            (\auth ->
                let
                    formId =
                        "login-form"
                in
                H.form
                    [ HA.id formId
                    , HE.onSubmit Login
                    ]
                    [ H.input
                        [ HA.id "login-name-input"
                        , HA.value auth.name
                        , HA.placeholder "Username__________"
                        , HE.onInput SetAuthName
                        ]
                        []
                    , H.input
                        [ HA.id "login-password-input"
                        , HA.type_ "password"
                        , HA.value <| Auth.unwrap auth.password
                        , HA.placeholder "Password__________"
                        , HE.onInput SetAuthPassword
                        ]
                        []
                    , H.div
                        [ HA.id "login-form-buttons" ]
                        [ H.button
                            [ HA.id "login-button"
                            , HE.onClickPreventDefault Login
                            ]
                            [ H.text "[Login]" ]
                        , H.button
                            [ HA.id "register-button"
                            , HE.onClickPreventDefault Register
                            ]
                            [ H.text "[Register]" ]
                        ]
                    ]
            )


type LinkType
    = LinkOut String
    | LinkIn Route
    | LinkMsg FrontendMsg


linkView : Route -> Link -> Html FrontendMsg
linkView currentRoute { label, type_, tooltip, disabled } =
    let
        ( tag, linkAttrs, maybeRoute ) =
            case type_ of
                LinkOut http ->
                    ( H.a
                    , [ HA.href http
                      , HA.target "_blank"
                      , HA.attributeMaybe HA.title tooltip
                      ]
                    , Nothing
                    )

                LinkIn route ->
                    ( H.button
                    , [ HE.onClick <| GoToRoute route
                      , HA.attributeMaybe HA.title tooltip
                      , HA.disabled disabled
                      ]
                    , Just route
                    )

                LinkMsg msg ->
                    ( H.button
                    , [ HE.onClick msg
                      , HA.attributeMaybe HA.title tooltip
                      , HA.disabled disabled
                      ]
                    , Nothing
                    )

        isActive =
            maybeRoute == Just currentRoute
    in
    tag
        (HA.class "link"
            :: HA.classList [ ( "active", isActive ) ]
            :: linkAttrs
        )
        [ H.span
            [ HA.class "link-left-bracket" ]
            [ H.text "[" ]
        , H.span
            [ HA.class "link-label" ]
            [ H.text label ]
        , H.span
            [ HA.class "link-right-bracket" ]
            [ H.text "]" ]
        ]


type alias Link =
    { label : String
    , type_ : LinkType
    , tooltip : Maybe String
    , disabled : Bool
    }


linkOut : String -> String -> Maybe String -> Bool -> Link
linkOut label url tooltip disabled =
    Link label (LinkOut url) tooltip disabled


linkIn : String -> Route -> Maybe String -> Bool -> Link
linkIn label route tooltip disabled =
    Link label (LinkIn route) tooltip disabled


linkMsg : String -> FrontendMsg -> Maybe String -> Bool -> Link
linkMsg label msg tooltip disabled =
    Link label (LinkMsg msg) tooltip disabled


loggedInLinksView : Player CPlayer -> Route -> Html FrontendMsg
loggedInLinksView player currentRoute =
    let
        links =
            case player of
                NeedsCharCreated _ ->
                    [ linkIn "New Char" Route.CharCreation Nothing False
                    , linkMsg "Logout" Logout Nothing False
                    ]

                Player p ->
                    let
                        ( healTooltip, healDisabled ) =
                            if p.hp >= p.maxHp then
                                ( Just "Heal your HP fully. Cost: 1 tick. You are at full HP!"
                                , True
                                )

                            else if p.ticks < 1 then
                                ( Just "Heal your HP fully. Cost: 1 tick. You have no ticks left!"
                                , True
                                )

                            else
                                ( Just "Heal your HP fully. Cost: 1 tick"
                                , False
                                )

                        ( wanderTooltip, wanderDisabled ) =
                            if p.hp <= 0 then
                                ( Just "Find something to fight. Cost: 1 tick. You are dead!"
                                , True
                                )

                            else if p.ticks < 1 then
                                ( Just "Find something to fight. Cost: 1 tick. You have no ticks left!"
                                , True
                                )

                            else
                                ( Just "Find something to fight. Cost: 1 tick"
                                , False
                                )

                        isInTown : Bool
                        isInTown =
                            Location.location p.location /= Nothing
                    in
                    [ linkMsg "Heal" AskToHeal healTooltip healDisabled
                    , linkMsg "Refresh" Refresh Nothing False
                    , linkIn "Character" Route.Character Nothing False
                    , linkIn "Inventory" Route.Inventory Nothing False
                    , linkIn "Map" Route.Map Nothing False
                    , linkIn "Ladder" Route.Ladder Nothing False
                    , if isInTown then
                        linkIn "Town" (Route.Town Route.MainSquare) Nothing False

                      else
                        linkMsg "Wander" AskToWander wanderTooltip wanderDisabled
                    , linkIn "Messages" Route.Messages Nothing False
                    , linkMsg "Logout" Logout Nothing False
                    ]
    in
    H.div
        [ HA.id "logged-in-links"
        , HA.class "links"
        ]
        (List.map (linkView currentRoute) links)


adminLinksView : Route -> Html FrontendMsg
adminLinksView currentRoute =
    let
        links =
            [ linkMsg "Refresh" Refresh Nothing False
            , linkIn "Players" (Route.Admin Route.Players) Nothing False
            , linkIn "Logged In" (Route.Admin Route.LoggedIn) Nothing False
            , linkMsg "Import" ImportButtonClicked Nothing False
            , linkMsg "Export" AskForExport Nothing False
            , linkIn "Ladder" Route.Ladder Nothing False
            , linkMsg "Logout" Logout Nothing False
            ]
    in
    H.div
        [ HA.id "logged-in-links"
        , HA.class "links"
        ]
        (List.map (linkView currentRoute) links)


loggedOutLinksView : Route -> Html FrontendMsg
loggedOutLinksView currentRoute =
    H.div
        [ HA.id "logged-out-links"
        , HA.class "links"
        ]
        ([ linkMsg "Refresh" Refresh Nothing False
         , linkIn "Map" Route.Map Nothing False
         , linkIn "Ladder" Route.Ladder Nothing False
         ]
            |> List.map (linkView currentRoute)
        )


commonLinksView : Route -> Html FrontendMsg
commonLinksView currentRoute =
    H.div
        [ HA.id "common-links"
        , HA.class "links"
        ]
        ([ linkIn "News" Route.News Nothing False
         , linkIn "About" Route.About Nothing False
         , linkOut "Wiki    →" "https://nu-ashworld.tiddlyhost.com" Nothing False
         , linkOut "Discord →" "https://discord.gg/HUmwvnv4xV" Nothing False
         , linkOut "Twitter →" "https://twitter.com/NuAshworld" Nothing False
         , linkOut "GitHub  →" "https://github.com/Janiczek/nu-ashworld" Nothing False
         , linkOut "Reddit  →" "https://www.reddit.com/r/NuAshworld/" Nothing False
         , linkOut "Donate  →" "https://patreon.com/janiczek" Nothing False
         ]
            |> List.map (linkView currentRoute)
        )


playerInfoView : Player CPlayer -> Html FrontendMsg
playerInfoView player =
    player
        |> Player.getPlayerData
        |> H.viewMaybe createdPlayerInfoView


createdPlayerInfoView : CPlayer -> Html FrontendMsg
createdPlayerInfoView player =
    H.div
        [ HA.id "player-info" ]
        [ H.div [ HA.class "player-stat-label" ] [ H.text "Name:" ]
        , H.div
            [ HA.classList
                [ ( "player-stat-value", True )
                , ( "emphasized", True )
                ]
            ]
            [ H.text player.name ]
        , H.div
            [ HA.class "player-stat-label"
            , HA.title "Hitpoints"
            ]
            [ H.text "HP:" ]
        , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt player.hp ++ "/" ++ String.fromInt player.maxHp ]
        , H.div
            [ HA.class "player-stat-label"
            , HA.title "Experience points"
            ]
            [ H.text "XP:" ]
        , H.div [ HA.class "player-stat-value" ]
            [ H.span [] [ H.text <| String.fromInt player.xp ]
            , H.span
                [ HA.class "deemphasized" ]
                [ H.text <| "/" ++ String.fromInt (Xp.nextLevelXp player.xp) ]
            ]
        , H.div [ HA.class "player-stat-label" ] [ H.text "Level:" ]
        , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt <| Xp.currentLevel player.xp ]
        , H.div
            [ HA.class "player-stat-label"
            , HA.title "Wins/Losses"
            ]
            [ H.text "W/L:" ]
        , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt player.wins ++ "/" ++ String.fromInt player.losses ]
        , H.div [ HA.class "player-stat-label" ] [ H.text "Caps:" ]
        , H.div [ HA.class "player-stat-value" ] [ H.text <| "$" ++ String.fromInt player.caps ]
        , H.div
            [ HA.class "player-stat-label"
            , HA.title "Ticks"
            ]
            [ H.text "Ticks:" ]
        , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt player.ticks ]
        ]


stylesLinkView : Html msg
stylesLinkView =
    H.node "link"
        [ HA.rel "stylesheet"
        , HA.href <| "styles/app.css?v=" ++ Version.version
        ]
        []


favicon16View : Html msg
favicon16View =
    H.node "link" [ HA.rel "icon", HA.href "images/favicon-16.png" ] []


favicon32View : Html msg
favicon32View =
    H.node "link" [ HA.rel "icon", HA.href "images/favicon-32.png" ] []


genericFaviconView : Html msg
genericFaviconView =
    H.node "link" [ HA.rel "shortcut icon", HA.type_ "image/png", HA.href "images/favicon-392.png" ] []


genericFavicon2View : Html msg
genericFavicon2View =
    H.node "link" [ HA.rel "apple-touch-icon", HA.href "images/favicon-392.png" ] []


logoView : Html msg
logoView =
    H.div [ HA.id "logo-wrapper" ]
        [ H.img
            [ HA.src "images/logo-black-small.png"
            , HA.alt "NuAshworld Logo"
            , HA.title "NuAshworld - go to homepage"
            , HA.id "logo"
            , HA.width 190
            , HA.height 36
            ]
            []
        , H.div
            [ HA.id "version"
            , HA.title "Game version"
            ]
            [ H.text Version.version ]
        ]
