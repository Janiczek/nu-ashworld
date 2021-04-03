module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Data.Auth as Auth
import Data.Fight exposing (FightAction(..), FightInfo, FightResult(..), Who(..))
import Data.Fight.ShotType as ShotType exposing (ShotType(..))
import Data.Fight.View
import Data.HealthStatus as HealthStatus
import Data.Map as Map exposing (TileCoords)
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Map.Terrain as Terrain
import Data.Message as Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Player as Player
    exposing
        ( COtherPlayer
        , CPlayer
        , Player(..)
        )
import Data.Special as Special
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Data.Tick as Tick
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
import File.Download
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
import List.Extra
import Logic
import Markdown
import Set exposing (Set)
import Svg as S
import Svg.Attributes as SA
import Task
import Time exposing (Posix)
import Time.Extra as Time
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
                { model | route = route }
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

        AskToIncSpecial type_ ->
            ( model
            , Lamdera.sendToBackend <| IncSpecial type_
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

        SetImportValue newTextarea ->
            ( { model
                | route = Route.setImportValue newTextarea model.route
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        CreateChar ->
            ( { model | newChar = NewChar.init }
            , Lamdera.sendToBackend <| CreateNewChar model.newChar
            )

        NewCharIncSpecial type_ ->
            ( { model | newChar = NewChar.incSpecial type_ model.newChar }
            , Cmd.none
            )

        NewCharDecSpecial type_ ->
            ( { model | newChar = NewChar.decSpecial type_ model.newChar }
            , Cmd.none
            )

        MapMouseAtCoords mouseCoords ->
            case model.world of
                WorldLoggedIn world ->
                    case world.player of
                        Player cPlayer ->
                            let
                                playerCoords =
                                    Map.toTileCoords cPlayer.location
                            in
                            ( { model
                                | mapMouseCoords =
                                    Just
                                        ( mouseCoords
                                        , Pathfinding.path
                                            (Perception.level cPlayer.special.perception)
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


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        YoureLoggedIn world ->
            ( { model
                | world = WorldLoggedIn world
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
            ( { model | world = WorldAdmin adminData }
            , Cmd.none
            )

        YoureRegistered world ->
            ( { model
                | world = WorldLoggedIn world
                , route = Route.CharCreation
              }
            , Cmd.none
            )

        YouHaveCreatedChar world ->
            ( { model
                | world = WorldLoggedIn world
                , route = Route.Ladder
              }
            , Cmd.none
            )

        YoureLoggedOut world ->
            ( { model
                | world = WorldLoggedOut Auth.init world
                , route = Route.loggedOut model.route
              }
            , Cmd.none
            )

        YourCurrentWorld world ->
            ( { model | world = WorldLoggedIn world }
            , Cmd.none
            )

        CurrentAdminData data ->
            ( { model | world = WorldAdmin data }
            , Cmd.none
            )

        CurrentWorld world ->
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
            ( model
            , File.Download.string
                "nu-ashworld-db-export.json"
                "application/json"
                json
            )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "NuAshworld " ++ Version.version
    , body =
        [ stylesLinkView
        , favicon16View
        , favicon32View
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
        , HA.classList [ ( "logged-in", World.isLoggedIn model.world ) ]
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
        withCreatedPlayer : Player CPlayer -> (CPlayer -> List (Html FrontendMsg)) -> List (Html FrontendMsg)
        withCreatedPlayer player fn =
            case player of
                NeedsCharCreated _ ->
                    contentUnavailableToNonCreatedView

                Player cPlayer ->
                    fn cPlayer
    in
    H.div [ HA.id "content" ]
        (case ( model.route, model.world ) of
            ( Route.Character, WorldLoggedIn world ) ->
                withCreatedPlayer world.player characterView

            ( Route.Character, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Map, WorldLoggedIn world ) ->
                withCreatedPlayer world.player
                    (mapView model.mapMouseCoords)

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
                            |> List.map (Player.serverToClientOther { perception = 10 })
                    }

            ( Route.Ladder, WorldNotInitialized _ ) ->
                ladderLoadingView

            ( Route.Town, WorldLoggedIn _ ) ->
                townView

            ( Route.Town, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Settings, WorldLoggedIn _ ) ->
                settingsView

            ( Route.Settings, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.About, _ ) ->
                aboutView

            ( Route.News, _ ) ->
                newsView model.zone

            ( Route.Fight fightInfo, WorldLoggedIn world ) ->
                withCreatedPlayer world.player (fightView fightInfo)

            ( Route.Fight _, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Messages, WorldLoggedIn world ) ->
                withCreatedPlayer world.player (messagesView model.time model.zone)

            ( Route.Messages, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Message message, WorldLoggedIn world ) ->
                withCreatedPlayer world.player (messageView model.zone message)

            ( Route.Message _, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.CharCreation, WorldLoggedIn _ ) ->
                charCreationView model.newChar

            ( Route.CharCreation, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Admin Route.Players, WorldAdmin _ ) ->
                adminPlayersView

            ( Route.Admin Route.Players, _ ) ->
                contentUnavailableToNonAdminView

            ( Route.Admin Route.LoggedIn, WorldAdmin data ) ->
                adminLoggedInView data

            ( Route.Admin Route.LoggedIn, _ ) ->
                contentUnavailableToNonAdminView

            ( Route.Admin (Route.Import textarea), WorldAdmin _ ) ->
                adminImportView textarea

            ( Route.Admin (Route.Import _), _ ) ->
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
    , data.loggedInPlayers
        |> List.map (\name -> H.li [] [ H.text name ])
        |> H.ul []
    ]


adminImportView : String -> List (Html FrontendMsg)
adminImportView textarea =
    [ pageTitleView "Admin :: Import"
    , H.div []
        [ H.textarea
            [ HE.onInput SetImportValue
            , HA.id "import-textarea"
            ]
            [ H.text textarea ]
        ]
    , H.button
        [ HE.onClick <| AskToImport textarea
        , HA.disabled <| String.isEmpty textarea
        ]
        [ H.text "[ IMPORT ]" ]
    ]


mapView :
    Maybe ( TileCoords, Set TileCoords )
    -> CPlayer
    -> List (Html FrontendMsg)
mapView mouseCoords player =
    let
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
                , H.viewIf (Perception.atLeast Perception.Good player.special.perception) <|
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
        [ locationsView
        , mapMarkerView playerCoords
        , mouseEventCatcherView
        , H.viewMaybe mouseRelatedView mouseCoords
        ]
    ]


locationView : Location -> Html FrontendMsg
locationView location =
    let
        ( x, y ) =
            Location.coords location

        size : Location.Size
        size =
            Location.size location

        name : String
        name =
            Location.name location
    in
    H.div
        [ HA.classList
            [ ( "tile", True )
            , ( "map-location", True )
            , ( "small", size == Location.Small )
            , ( "middle", size == Location.Middle )
            , ( "large", size == Location.Large )
            ]
        , HA.attribute "data-location-name" name
        , cssVars
            [ ( "--tile-coord-x", String.fromInt x )
            , ( "--tile-coord-y", String.fromInt y )
            ]
        ]
        []


locationsView : Html FrontendMsg
locationsView =
    Location.allLocations
        |> List.map locationView
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
        [ locationsView ]
    ]


townView : List (Html FrontendMsg)
townView =
    [ pageTitleView "Town"
    , H.text "TODO"
    ]


settingsView : List (Html FrontendMsg)
settingsView =
    [ pageTitleView "Settings"
    , H.text "TODO"
    ]


charCreationView : NewChar -> List (Html FrontendMsg)
charCreationView newChar =
    let
        specialItemView type_ =
            let
                value =
                    Special.get type_ newChar.special

                isUseful =
                    Special.isUseful type_
            in
            H.tr
                [ HA.classList
                    [ ( "character-special-item", True )
                    , ( "not-useful", not isUseful )
                    ]
                ]
                [ H.td
                    [ HA.class "character-special-item-dec" ]
                    [ H.button
                        [ HE.onClick <| NewCharDecSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canDecrement
                                    type_
                                    newChar.special
                        ]
                        [ H.text "[-]" ]
                    ]
                , H.td
                    [ HA.class "character-special-item-label"
                    , HA.attributeIf (not isUseful) skillNotUseful
                    ]
                    [ H.text <| Special.label type_ ]
                , H.td
                    [ HA.class "character-special-item-value" ]
                    [ H.text <| String.fromInt value ]
                , H.td
                    [ HA.class "character-special-item-inc" ]
                    [ H.button
                        [ HE.onClick <| NewCharIncSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canIncrement
                                    newChar.availableSpecial
                                    type_
                                    newChar.special
                        ]
                        [ H.text "[+]" ]
                    ]
                ]

        itemView : ( String, String ) -> Html FrontendMsg
        itemView ( label, value ) =
            H.li [] [ H.text <| label ++ ": " ++ value ]

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level newChar.special.perception
    in
    [ pageTitleView "New Character"
    , H.table
        [ HA.id "character-special-table" ]
        (List.map specialItemView Special.all)
    , H.div
        [ HA.class "character-special-available" ]
        [ H.span
            [ HA.class "character-special-available-label" ]
            [ H.text "Available SPECIAL points: " ]
        , H.span
            [ HA.class "character-special-available-number" ]
            [ H.text <| String.fromInt newChar.availableSpecial ]
        ]
    , [ ( "Hitpoints"
        , String.fromInt <|
            Logic.hitpoints
                { level = 1
                , special = newChar.special
                }
        )
      , ( "Healing rate"
        , (String.fromInt <| Logic.healingRate newChar.special)
            ++ " HP/tick"
        )
      , ( "Perception Level"
        , Perception.label perceptionLevel
            ++ ". "
            ++ Perception.tooltip perceptionLevel
        )
      , ( "Action Points"
        , String.fromInt <| Logic.actionPoints newChar.special
        )
      ]
        |> List.map itemView
        |> H.ul [ HA.id "character-stats-list" ]
    , H.div [ HA.id "create-char-button" ]
        [ H.button
            [ HE.onClick CreateChar ]
            [ H.text "[Create]" ]
        ]
    ]


skillNotUseful : Attribute msg
skillNotUseful =
    HA.title "This skill is not yet useful in this version of the game."


characterView : CPlayer -> List (Html FrontendMsg)
characterView player =
    let
        specialItemView type_ =
            let
                value =
                    Special.get type_ player.special

                isUseful =
                    Special.isUseful type_
            in
            H.tr
                [ HA.classList
                    [ ( "character-special-item", True )
                    , ( "not-useful", not isUseful )
                    ]
                ]
                [ H.td
                    [ HA.class "character-special-item-label"
                    , HA.attributeIf (not isUseful) skillNotUseful
                    ]
                    [ H.text <| Special.label type_ ]
                , H.td
                    [ HA.class "character-special-item-value" ]
                    [ H.text <| String.fromInt value ]
                , H.td
                    [ HA.class "character-special-item-inc" ]
                    [ H.button
                        [ HE.onClick <| AskToIncSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canIncrement
                                    player.availableSpecial
                                    type_
                                    player.special
                        ]
                        [ H.text "[+]" ]
                    ]
                ]

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
            Perception.level player.special.perception
    in
    [ pageTitleView "Character"
    , H.div
        [ HA.id "character-special" ]
        [ H.h3
            [ HA.id "character-special-title" ]
            [ H.text "SPECIAL" ]
        , H.table
            [ HA.id "character-special-table" ]
            (List.map specialItemView Special.all)
        , H.div
            [ HA.class "character-special-available" ]
            [ H.span
                [ HA.class "character-special-available-label" ]
                [ H.text "Available SPECIAL points: " ]
            , H.span
                [ HA.class "character-special-available-number" ]
                [ H.text <| String.fromInt player.availableSpecial ]
            ]
        ]
    , [ ( "HP", String.fromInt player.hp ++ "/" ++ String.fromInt player.maxHp, Nothing )
      , ( "XP", String.fromInt player.xp, Nothing )
      , ( "Name", player.name, Nothing )
      , ( "Caps", String.fromInt player.caps, Nothing )
      , ( "Ticks", String.fromInt player.ticks, Nothing )
      , ( "Wins", String.fromInt player.wins, Nothing )
      , ( "Losses", String.fromInt player.losses, Nothing )
      , ( "Healing rate"
        , (String.fromInt <| Logic.healingRate player.special)
            ++ " HP/tick"
        , Nothing
        )
      , ( "Perception Level"
        , Perception.label perceptionLevel
        , Just <| Perception.tooltip perceptionLevel
        )
      , ( "Action Points"
        , String.fromInt <| Logic.actionPoints player.special
        , Nothing
        )
      ]
        |> List.map itemView
        |> H.ul [ HA.id "character-stats-list" ]
    ]


messagesView : Posix -> Time.Zone -> CPlayer -> List (Html FrontendMsg)
messagesView currentTime zone player =
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
                            , -- TODO does this work here?
                              HE.onClick <| OpenMessage message
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
    ]


messageView : Time.Zone -> Message -> CPlayer -> List (Html FrontendMsg)
messageView zone message player =
    [ pageTitleView "Message"
    , H.h3
        [ HA.id "message-summary" ]
        [ H.text <| Message.summary message ]
    , H.div
        [ HA.id "message-date" ]
        [ H.text <| Message.fullDate zone message ]
    , Message.content
        [ HA.id "message-content" ]
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


fightView : FightInfo -> CPlayer -> List (Html FrontendMsg)
fightView fight player =
    [ pageTitleView "Fight"
    , Data.Fight.View.view fight player.name
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
                                        H.td
                                            [ HA.class "ladder-status"
                                            , HA.title <|
                                                if loggedInPlayer_.special.perception <= 1 then
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
                        healTooltip =
                            if p.hp >= p.maxHp then
                                Just "Cost: 1 tick. You are at full HP!"

                            else if p.ticks < 1 then
                                Just "Cost: 1 tick. You have no ticks left!"

                            else
                                Just "Cost: 1 tick"

                        healDisabled =
                            p.ticks < 1 || p.hp >= p.maxHp
                    in
                    [ linkMsg "Heal" AskToHeal healTooltip healDisabled
                    , linkMsg "Refresh" Refresh Nothing False
                    , linkIn "Character" Route.Character Nothing False
                    , linkIn "Map" Route.Map Nothing False
                    , linkIn "Ladder" Route.Ladder Nothing False
                    , linkIn "Town" Route.Town Nothing False
                    , linkIn "Settings" Route.Settings Nothing False
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
            , linkIn "Import" (Route.Admin (Route.Import "")) Nothing False
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
         , linkOut "Twitter →" "https://twitter.com/NuAshworld" Nothing False
         , linkOut "Discord →" "https://discord.gg/HUmwvnv4xV" Nothing False
         , linkOut "Reddit  →" "https://www.reddit.com/r/NuAshworld/" Nothing False
         , linkOut "GitHub  →" "https://github.com/Janiczek/nu-ashworld-lamdera" Nothing False
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
