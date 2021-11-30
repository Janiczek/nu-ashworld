module Frontend exposing (..)

import AssocList as Dict_
import AssocSet as Set_
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Data.Auth as Auth exposing (Auth, Plaintext)
import Data.Barter as Barter
import Data.Fight as Fight
import Data.Fight.ShotType as ShotType
import Data.Fight.View
import Data.FightStrategy as FightStrategy exposing (FightStrategy)
import Data.FightStrategy.Help as FightStrategyHelp
import Data.FightStrategy.Named as FightStrategy
import Data.FightStrategy.Parser as FightStrategy
import Data.HealthStatus as HealthStatus
import Data.Item as Item exposing (Item)
import Data.Ladder as Ladder
import Data.Map as Map exposing (TileCoords)
import Data.Map.BigChunk as BigChunk exposing (BigChunk(..))
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
import Data.WorldData as WorldData
    exposing
        ( AdminData
        , PlayerData
        , WorldData(..)
        )
import Data.Xp as Xp
import DateFormat
import DateFormat.Relative
import Dict exposing (Dict)
import Dict.Extra as Dict
import Dict.ExtraExtra as Dict
import File
import File.Download
import File.Select
import Frontend.HoveredItem as HoveredItem exposing (HoveredItem(..))
import Frontend.News as News
import Frontend.Route as Route
    exposing
        ( AdminRoute(..)
        , PlayerRoute
        , Route(..)
        )
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HA
import Html.Events as HE
import Html.Events.Extra as HE
import Html.Extra as H
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Lamdera
import Logic exposing (AttackStats, ItemNotUsableReason(..))
import Markdown
import Parser
import Result.Extra as Result
import Set exposing (Set)
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Task
import Time exposing (Posix)
import Time.Extra as Time
import Time.ExtraExtra as Time
import Types exposing (..)
import Url exposing (Url)


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


init : Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , time = Time.millisToPosix 0
      , route =
            -- TODO change URL when changing route
            Route.fromUrl url
      , zone = Time.utc
      , loginForm = Auth.init
      , worlds = Nothing
      , worldData = NotLoggedIn

      -- mostly player frontend state
      , newChar = NewChar.init
      , alertMessage = Nothing
      , mapMouseCoords = Nothing
      , hoveredItem = Nothing
      , barter = Barter.empty
      , fightInfo = Nothing
      , fightStrategyText = ""
      }
    , Cmd.batch
        [ Task.perform GotZone Time.here
        , Task.perform GotTime Time.now
        ]
    )


subscriptions : Model -> Sub FrontendMsg
subscriptions _ =
    Time.every 1000 GotTime


isPlayer : Model -> Bool
isPlayer model =
    WorldData.isPlayer model.worldData


isAdmin : Model -> Bool
isAdmin model =
    WorldData.isAdmin model.worldData


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg ({ loginForm } as model) =
    let
        withLoggedInPlayer : (PlayerData -> ( Model, Cmd FrontendMsg )) -> ( Model, Cmd FrontendMsg )
        withLoggedInPlayer fn =
            case model.worldData of
                IsPlayer data ->
                    fn data

                _ ->
                    ( model, Cmd.none )
    in
    case msg of
        GoToRoute route ->
            ( if Route.needsAdmin route && not (isAdmin model) then
                model

              else if Route.needsPlayer route && not (isPlayer model) then
                model

              else
                { model
                    | route = route
                    , alertMessage = Nothing
                }
            , Cmd.none
            )

        GoToTownStore ->
            { model | barter = Barter.empty }
                |> update (GoToRoute (PlayerRoute Route.TownStore))

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
            ( model
            , Lamdera.sendToBackend <| LogMeIn <| Auth.hash model.loginForm
            )

        Register ->
            ( model
            , Lamdera.sendToBackend <| RegisterMe <| Auth.hash model.loginForm
            )

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

        AskToEquipItem itemId ->
            ( model
            , Lamdera.sendToBackend <| EquipItem itemId
            )

        AskToUnequipArmor ->
            ( model
            , Lamdera.sendToBackend UnequipArmor
            )

        AskToUseItem itemId ->
            ( model
            , Lamdera.sendToBackend <| UseItem itemId
            )

        AskToWander ->
            ( model
            , Lamdera.sendToBackend Wander
            )

        AskToSetFightStrategy ( strategy, text ) ->
            ( model
            , Lamdera.sendToBackend <| SetFightStrategy ( strategy, text )
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

        AskToUseSkillPoints skill ->
            ( model
            , Lamdera.sendToBackend <| UseSkillPoints skill
            )

        AskToChoosePerk perk ->
            ( model
            , Lamdera.sendToBackend <| ChoosePerk perk
            )

        SetAuthName newName ->
            ( { model
                | loginForm = { loginForm | name = newName }
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        SetAuthPassword newPassword ->
            ( { model
                | loginForm = Auth.setPlaintextPassword newPassword model.loginForm
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
            withLoggedInPlayer <|
                \data ->
                    case data.player of
                        Player cPlayer ->
                            let
                                perceptionLevel : PerceptionLevel
                                perceptionLevel =
                                    Perception.level
                                        { perception = cPlayer.special.perception
                                        , hasAwarenessPerk = Perk.rank Perk.Awareness cPlayer.perks > 0
                                        }

                                playerCoords =
                                    Map.toTileCoords cPlayer.location
                            in
                            ( { model
                                | mapMouseCoords =
                                    Just
                                        ( mouseCoords
                                        , Pathfinding.path
                                            perceptionLevel
                                            { from = playerCoords
                                            , to = mouseCoords
                                            }
                                        )
                              }
                            , Cmd.none
                            )

                        NeedsCharCreated _ ->
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

        OpenMessage messageId ->
            ( { model | route = PlayerRoute (Route.Message messageId) }
            , Lamdera.sendToBackend <| MessageWasRead messageId
            )

        AskToRemoveMessage messageId ->
            ( model
            , Lamdera.sendToBackend <| RemoveMessage messageId
            )

        BarterMsg barterMsg ->
            updateBarter barterMsg model

        HoverItem item ->
            ( { model | hoveredItem = Just item }
            , Cmd.none
            )

        StopHoveringItem ->
            ( { model | hoveredItem = Nothing }
            , Cmd.none
            )

        SetFightStrategyText text ->
            ( { model | fightStrategyText = text }
            , Cmd.none
            )


resetBarter : Model -> ( Model, Cmd FrontendMsg )
resetBarter model =
    ( { model | barter = Barter.empty }
    , Cmd.none
    )


mapBarter_ : (Barter.State -> Barter.State) -> Model -> Model
mapBarter_ fn model =
    { model | barter = fn model.barter }


mapBarter : (Barter.State -> Barter.State) -> Model -> ( Model, Cmd FrontendMsg )
mapBarter fn model =
    ( mapBarter_ fn model
    , Cmd.none
    )


updateBarter : BarterMsg -> Model -> ( Model, Cmd FrontendMsg )
updateBarter msg model =
    Tuple.mapFirst (\model_ -> { model_ | barter = Barter.dismissMessage model_.barter }) <|
        case msg of
            ResetBarter ->
                resetBarter model

            ConfirmBarter ->
                ( model
                , Lamdera.sendToBackend <| Barter model.barter
                )

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


updateLoggedInWorld : PlayerData -> Model -> Model
updateLoggedInWorld data model =
    case model.worldData of
        IsPlayer _ ->
            { model | worldData = IsPlayer data }

        _ ->
            model


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        YoureLoggedIn data ->
            ( { model
                | worldData = IsPlayer data
                , alertMessage = Nothing
                , route =
                    case data.player of
                        NeedsCharCreated _ ->
                            PlayerRoute Route.CharCreation

                        Player _ ->
                            PlayerRoute Route.Ladder
              }
            , Cmd.none
            )

        YoureLoggedInAsAdmin data ->
            ( { model
                | worldData = IsAdmin data
                , route = AdminRoute AdminWorldsList
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        YoureRegistered data ->
            ( { model
                | worldData = IsPlayer data
                , route = PlayerRoute Route.CharCreation
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        CharCreationError error ->
            ( { model | newChar = NewChar.setError error model.newChar }
            , Cmd.none
            )

        YouHaveCreatedChar data ->
            ( { model
                | worldData = IsPlayer data
                , route = PlayerRoute Route.Ladder
                , alertMessage = Nothing
                , newChar = NewChar.init
              }
            , Cmd.none
            )

        YoureLoggedOut worlds ->
            ( { model
                | loginForm = Auth.init
                , alertMessage = Nothing
                , route = Route.loggedOut model.route
                , worlds = Just worlds
              }
            , Cmd.none
            )

        CurrentWorlds worlds ->
            ( { model | worlds = Just worlds }
            , Cmd.none
            )

        CurrentPlayer data ->
            ( case model.worldData of
                IsPlayer _ ->
                    { model | worldData = IsPlayer data }

                _ ->
                    model
            , Cmd.none
            )

        CurrentAdmin data ->
            ( case model.worldData of
                IsAdmin _ ->
                    { model | worldData = IsAdmin data }

                _ ->
                    model
            , Cmd.none
            )

        YourFightResult ( fightInfo, world ) ->
            ( { model | route = PlayerRoute Route.Fight }
                |> updateLoggedInWorld world
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
            model
                |> updateLoggedInWorld world
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
        , view_ model
        ]
    }


appView :
    { leftNav : List (Html FrontendMsg) }
    -> Model
    -> Html FrontendMsg
appView { leftNav } model =
    let
        tickFrequency : Maybe Time.Interval
        tickFrequency =
            case model.worldData of
                IsAdmin data ->
                    Nothing

                IsPlayer data ->
                    Just data.tickFrequency

                NotLoggedIn ->
                    Nothing
    in
    H.div
        [ HA.id "app"
        , HA.classList
            [ ( "player", isPlayer model )
            , ( "admin", isAdmin model )
            ]
        ]
        [ H.div [ HA.id "left-nav" ]
            (logoView
                :: (tickFrequency
                        |> H.viewMaybe (\freq -> nextTickView freq model.zone model.time)
                   )
                :: leftNav
                ++ [ commonLinksView model.route ]
            )
        , contentView model
        ]


nextTickView : Time.Interval -> Time.Zone -> Posix -> Html FrontendMsg
nextTickView tickFrequency zone time =
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
                    Tick.nextTick tickFrequency time

                nextTickString =
                    DateFormat.format
                        [ DateFormat.hourMilitaryFixed
                        , DateFormat.text ":"
                        , DateFormat.minuteFixed
                        , DateFormat.text ":"
                        , DateFormat.secondFixed
                        ]
                        zone
                        nextTick
            in
            [ H.text "Next tick: "
            , H.span
                [ HA.class "slightly-emphasized" ]
                [ H.text nextTickString ]
            ]


contentView : Model -> Html FrontendMsg
contentView model =
    let
        withCreatedPlayer :
            PlayerData
            -> (PlayerData -> CPlayer -> List (Html FrontendMsg))
            -> List (Html FrontendMsg)
        withCreatedPlayer data fn =
            case data.player of
                NeedsCharCreated _ ->
                    contentUnavailableToNonCreatedView

                Player cPlayer ->
                    fn data cPlayer

        withLocation :
            PlayerData
            -> (Location -> PlayerData -> CPlayer -> List (Html FrontendMsg))
            -> List (Html FrontendMsg)
        withLocation data fn =
            data.player
                |> Player.getPlayerData
                |> Maybe.andThen (.location >> Location.location)
                |> Maybe.map (\loc -> withCreatedPlayer data (fn loc))
                |> Maybe.withDefault contentUnavailableWhenNotInTownView
    in
    H.div [ HA.id "content" ]
        (case ( model.route, model.worldData ) of
            ( AdminRoute subroute, IsAdmin data ) ->
                case subroute of
                    AdminWorldsList ->
                        adminWorldsListView data

                    AdminWorldDetail worldName ->
                        adminWorldDetailView worldName data

                    AdminPlayersList worldName ->
                        adminPlayersListView worldName data

            ( AdminRoute _, _ ) ->
                contentUnavailableToNonAdminView

            ( WorldsList, _ ) ->
                Debug.todo "worlds list"

            ( About, _ ) ->
                aboutView

            ( News, _ ) ->
                newsView model.zone

            ( NotFound url, _ ) ->
                notFoundView url

            ( Map, IsPlayer data ) ->
                withCreatedPlayer data (mapView model.mapMouseCoords)

            ( Map, _ ) ->
                mapLoggedOutView

            ( PlayerRoute worldRoute, IsPlayer data ) ->
                let
                    withCreatedPlayer_ :
                        (PlayerData -> CPlayer -> List (Html FrontendMsg))
                        -> List (Html FrontendMsg)
                    withCreatedPlayer_ =
                        withCreatedPlayer data

                    withLocation_ :
                        (Location -> PlayerData -> CPlayer -> List (Html FrontendMsg))
                        -> List (Html FrontendMsg)
                    withLocation_ =
                        withLocation data
                in
                case worldRoute of
                    Route.AboutWorld ->
                        withCreatedPlayer_ (aboutWorldView model.zone)

                    Route.Character ->
                        withCreatedPlayer_ (characterView model.hoveredItem)

                    Route.Inventory ->
                        withCreatedPlayer_ inventoryView

                    Route.Ladder ->
                        withCreatedPlayer_ ladderView

                    Route.TownMainSquare ->
                        withLocation_ townMainSquareView

                    Route.TownStore ->
                        withLocation_ (townStoreView model.barter)

                    Route.Fight ->
                        withCreatedPlayer_ (fightView model.fightInfo)

                    Route.Messages ->
                        withCreatedPlayer_ (messagesView model.time model.zone)

                    Route.Message messageId ->
                        withCreatedPlayer_ (messageView model.zone messageId)

                    Route.CharCreation ->
                        newCharView model.hoveredItem model.newChar

                    Route.SettingsFightStrategy ->
                        withCreatedPlayer_ <|
                            settingsFightStrategyView
                                model.fightStrategyText

                    Route.SettingsFightStrategySyntaxHelp ->
                        settingsFightStrategySyntaxHelpView
                            model.hoveredItem
                            model.fightStrategyText

            ( PlayerRoute _, _ ) ->
                contentUnavailableToLoggedOutView
        )


pageTitleView : String -> Html FrontendMsg
pageTitleView title =
    H.h2
        [ HA.id "page-title" ]
        [ H.text title ]


aboutView : List (Html FrontendMsg)
aboutView =
    [ pageTitleView "About"
    , Markdown.toHtml
        [ HA.id "about-content" ]
        """
Welcome to **NuAshworld** - a multiplayer turn-based browser game set in the
universe of Fallout 2.

Do you have what it takes to survive in the post-apocalyptic wasteland? Can you
shape the world for the better?

What more, **can you stand up to the Enclave?**

Many thanks to Patreons:
* DJetelina (iScrE4m)
"""
    ]


notFoundView : Url -> List (Html FrontendMsg)
notFoundView url =
    [ pageTitleView "Not found"
    , """
Page `{URL}` not found.
"""
        |> String.replace "{URL}" (Url.toString url)
        |> Markdown.toHtml [ HA.id "not-found-content" ]
    ]


adminPlayerData : AdminData -> List (Html FrontendMsg)
adminPlayerData data =
    [ pageTitleView "Admin :: Logged In"
    , if Dict.isEmpty data.loggedInPlayers then
        H.text "Nobody's here!"

      else
        data.loggedInPlayers
            |> Dict.toList
            |> List.map
                (\( worldName, playerNames ) ->
                    H.li []
                        [ H.text worldName
                        , H.ul []
                            (playerNames
                                |> List.map (\playerName -> H.li [] [ H.text playerName ])
                            )
                        ]
                )
            |> H.ul []
    ]


mapView :
    Maybe ( TileCoords, Set TileCoords )
    -> PlayerData
    -> CPlayer
    -> List (Html FrontendMsg)
mapView mouseCoords _ player =
    let
        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
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
                    Pathfinding.tickCost
                        { pathTaken = pathTaken
                        , pathfinderPerkRanks = Perk.rank Perk.Pathfinder player.perks
                        }

                tooDistant : Bool
                tooDistant =
                    cost > player.ticks

                ticksString : String
                ticksString =
                    if cost == 1 then
                        "tick"

                    else
                        "ticks"

                bigChunk : BigChunk
                bigChunk =
                    BigChunk.forCoords mouseCoords_
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
                , H.viewIf (Perception.atLeast Perception.Good perceptionLevel) <|
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
                                [ H.div [] [ H.text <| "Path cost: " ++ String.fromInt cost ++ " " ++ ticksString ]
                                , H.viewIf tooDistant <|
                                    H.div [] [ H.text "You don't have enough ticks." ]
                                , H.viewIf shouldShowBigChunks <|
                                    H.div [] [ H.text <| "Map tile difficulty: " ++ BigChunk.difficulty bigChunk ]
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

        bigChunkColor : BigChunk -> String
        bigChunkColor bigChunk =
            case bigChunk of
                C1 ->
                    "lime"

                C2 ->
                    "yellow"

                C3 ->
                    "orange"

                C4 ->
                    "red"

                C5 ->
                    "purple"

        bigChunkLayerView : () -> Html FrontendMsg
        bigChunkLayerView () =
            S.svg
                [ HA.id "map-fog"
                , SA.viewBox <| "0 0 " ++ String.fromInt Map.columns ++ " " ++ String.fromInt Map.rows
                ]
                (BigChunk.all
                    |> List.map
                        (\chunk ->
                            let
                                tiles : List TileCoords
                                tiles =
                                    BigChunk.tileCoords chunk
                            in
                            svgPolygonForTiles (bigChunkColor chunk) tiles
                        )
                )

        shouldShowBigChunks : Bool
        shouldShowBigChunks =
            Perception.atLeast Perception.Perfect perceptionLevel
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
        , H.viewIfLazy shouldShowBigChunks bigChunkLayerView
        , mouseEventCatcherView
        , H.viewMaybe mouseRelatedView mouseCoords
        ]
    ]


svgPolygonForTiles : String -> List TileCoords -> Svg FrontendMsg
svgPolygonForTiles color coords =
    let
        rectangle : TileCoords -> String
        rectangle ( x, y ) =
            let
                left =
                    String.fromInt x

                top =
                    String.fromInt y
            in
            [ "M " ++ left ++ "," ++ top
            , "h 1"
            , "v 1"
            , "h -1"
            , "v -1"
            ]
                |> String.join " "

        path : String
        path =
            coords
                |> List.map rectangle
                |> String.join " "
    in
    S.path
        [ SA.d path
        , SA.fill color
        , SA.fillOpacity "0.25"
        ]
        []


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
            Vendor.isInLocation location

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


townMainSquareView : Location -> PlayerData -> CPlayer -> List (Html FrontendMsg)
townMainSquareView location _ _ =
    [ pageTitleView <| "Town: " ++ Location.name location
    , if Vendor.isInLocation location then
        H.div []
            [ H.button
                [ HE.onClick GoToTownStore ]
                [ H.text "[Visit store]" ]
            ]

      else
        H.div [] [ H.text "No vendor in this town..." ]
    ]


townStoreView :
    Barter.State
    -> Location
    -> PlayerData
    -> CPlayer
    -> List (Html FrontendMsg)
townStoreView barter location world player =
    case Maybe.map (Vendor.getFrom world.vendors) (Vendor.forLocation location) of
        Nothing ->
            contentUnavailableWhenNotInTownView

        Just vendor ->
            let
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
                                    |> Maybe.map (\{ kind } -> Item.baseValue kind * count)
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
                                                { baseValue = count * Item.baseValue kind
                                                , playerBarterSkill = Skill.get player.special player.addedSkillPercentages Skill.Barter
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
                [ HE.onClick (GoToRoute (PlayerRoute Route.TownMainSquare)) ]
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


newCharView : Maybe HoveredItem -> NewChar -> List (Html FrontendMsg)
newCharView hoveredItem newChar =
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
            , newCharHelpView hoveredItem
            ]
        ]
    ]


newCharHelpView : Maybe HoveredItem -> Html FrontendMsg
newCharHelpView maybeHoveredItem =
    let
        helpContent : Html FrontendMsg
        helpContent =
            case maybeHoveredItem of
                Nothing ->
                    H.p [] [ H.text "Hover over an item to show more information about it here!" ]

                Just hoveredItem ->
                    let
                        { title, description } =
                            HoveredItem.text hoveredItem
                    in
                    H.div []
                        [ H.h4
                            [ HA.class "hovered-item-title" ]
                            [ H.text title ]
                        , Markdown.toHtml [] description
                        ]
    in
    H.div
        [ HA.id "new-character-help" ]
        [ H.h3
            [ HA.class "new-character-section-title" ]
            [ H.text "Help" ]
        , helpContent
        ]


newCharDerivedStatsView : NewChar -> Html FrontendMsg
newCharDerivedStatsView newChar =
    let
        finalSpecial =
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
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
            Perception.level
                { perception = finalSpecial.perception
                , hasAwarenessPerk = False
                }
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
                            , special = finalSpecial
                            , lifegiverPerkRanks = 0
                            }
                  , Nothing
                  )
                , ( "Tick heal percentage"
                  , (String.fromInt <|
                        Logic.tickHealPercentage
                            { endurance = finalSpecial.endurance
                            , fasterHealingPerkRanks = 0
                            }
                    )
                        ++ " % of max HP"
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
                            , actionBoyPerkRanks = 0
                            , special = finalSpecial
                            }
                  , Nothing
                  )
                ]
        ]


newCharSpecialView : NewChar -> Html FrontendMsg
newCharSpecialView newChar =
    let
        finalSpecial =
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                }

        specialItemView type_ =
            let
                value =
                    Special.get type_ finalSpecial
            in
            H.tr
                [ HA.class "character-special-attribute"
                , HE.onMouseOver <| HoverItem <| HoveredSpecial type_
                , HE.onMouseOut StopHoveringItem
                ]
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
                , HE.onMouseOver <| HoverItem <| HoveredTrait trait
                , HE.onMouseOut StopHoveringItem
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
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
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


characterView : Maybe HoveredItem -> PlayerData -> CPlayer -> List (Html FrontendMsg)
characterView maybeHoveredItem _ player =
    let
        level =
            Xp.currentLevel player.xp

        applicablePerks : List Perk
        applicablePerks =
            Perk.allApplicable
                { level = level
                , special = player.special
                , addedSkillPercentages = player.addedSkillPercentages
                , perks = player.perks
                }
    in
    [ pageTitleView "Character"
    , if player.availablePerks > 0 && not (List.isEmpty applicablePerks) then
        choosePerkView maybeHoveredItem applicablePerks

      else
        normalCharacterView maybeHoveredItem player
    ]


choosePerkView : Maybe HoveredItem -> List Perk -> Html FrontendMsg
choosePerkView maybeHoveredItem applicablePerks =
    let
        perkView : Perk -> Html FrontendMsg
        perkView perk =
            H.li
                [ HE.onClick <| AskToChoosePerk perk
                , HA.class "character-choose-perk-item"
                , HE.onMouseOver <| HoverItem <| HoveredPerk perk
                , HE.onMouseOut StopHoveringItem
                ]
                [ H.text <| Perk.name perk ]
    in
    H.div
        [ HA.id "character-choose-perk" ]
        [ H.div
            [ HA.id "character-choose-perk-columns" ]
            [ H.div []
                [ H.h3 [] [ H.text "Choose a perk!" ]
                , H.ul
                    [ HA.id "character-choose-perk-list" ]
                    (List.map perkView applicablePerks)
                ]
            , H.viewMaybe perkDescriptionView maybeHoveredItem
            ]
        ]


perkDescriptionView : HoveredItem -> Html FrontendMsg
perkDescriptionView hoveredItem =
    let
        { title, description } =
            HoveredItem.text hoveredItem
    in
    H.div
        [ HA.id "character-perk-description" ]
        [ H.h3 [] [ H.text title ]
        , H.text description
        ]


normalCharacterView : Maybe HoveredItem -> CPlayer -> Html FrontendMsg
normalCharacterView maybeHoveredItem player =
    H.div
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
            , charHelpView maybeHoveredItem
            ]
        ]


charTraitsView : Set_.Set Trait -> Html FrontendMsg
charTraitsView traits =
    let
        itemView : Trait -> Html FrontendMsg
        itemView trait =
            H.li
                [ HA.class "character-traits-trait"
                , HE.onMouseOver <| HoverItem <| HoveredTrait trait
                , HE.onMouseOut StopHoveringItem
                ]
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


charHelpView : Maybe HoveredItem -> Html FrontendMsg
charHelpView maybeHoveredItem =
    let
        helpContent : Html FrontendMsg
        helpContent =
            case maybeHoveredItem of
                Nothing ->
                    H.p [] [ H.text "Hover over an item to show more information about it here!" ]

                Just hoveredItem ->
                    let
                        { title, description } =
                            HoveredItem.text hoveredItem
                    in
                    H.div []
                        [ H.h4
                            [ HA.class "hovered-item-title" ]
                            [ H.text title ]
                        , Markdown.toHtml [] description
                        ]
    in
    H.div
        [ HA.id "character-help" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "Help" ]
        , helpContent
        ]


charDerivedStatsView : CPlayer -> Html FrontendMsg
charDerivedStatsView player =
    let
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
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                }
    in
    H.div
        [ HA.id "character-derived-stats" ]
        [ H.h3
            [ HA.class "character-section-title" ]
            [ H.text "Derived stats" ]
        , H.ul [ HA.id "character-derived-stats-list" ] <|
            List.map itemView
                [ ( "Max HP"
                  , String.fromInt <|
                        Logic.hitpoints
                            { level = Xp.currentLevel player.xp
                            , special = player.special
                            , lifegiverPerkRanks = Perk.rank Perk.Lifegiver player.perks
                            }
                  , Nothing
                  )
                , ( "Tick heal"
                  , let
                        percentage =
                            Logic.tickHealPercentage
                                { endurance = player.special.endurance
                                , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing player.perks
                                }

                        absolute =
                            round <| toFloat player.maxHp * toFloat percentage / 100
                    in
                    String.fromInt absolute
                        ++ " HP ("
                        ++ String.fromInt percentage
                        ++ "% of max HP)"
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
                            , actionBoyPerkRanks = Perk.rank Perk.ActionBoy player.perks
                            , special = player.special
                            }
                  , Nothing
                  )
                ]
        ]


charSpecialView : CPlayer -> Html FrontendMsg
charSpecialView player =
    let
        specialItemView type_ =
            let
                value =
                    Special.get type_ player.special
            in
            H.tr
                [ HA.class "character-special-attribute"
                , HE.onMouseOver <| HoverItem <| HoveredSpecial type_
                , HE.onMouseOut StopHoveringItem
                ]
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
                , HA.attributeIf (not isTaggingDisabled) <| HE.onClick <| onTag skill
                , HE.onMouseOver <| HoverItem <| HoveredSkill skill
                , HE.onMouseOut StopHoveringItem
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
                            [ HE.onClickStopPropagation <| AskToUseSkillPoints skill
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
    skillsView_
        { addedSkillPercentages = player.addedSkillPercentages
        , special = player.special
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
                [ HA.class "character-perks-perk"
                , HE.onMouseOver <| HoverItem <| HoveredPerk perk
                , HE.onMouseOut StopHoveringItem
                ]
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


inventoryView : PlayerData -> CPlayer -> List (Html FrontendMsg)
inventoryView _ player =
    let
        inventoryTotalValue : Int
        inventoryTotalValue =
            player.items
                |> Dict.values
                |> List.map (\{ kind, count } -> Item.baseValue kind * count)
                |> List.sum

        equippedArmorValue : Int
        equippedArmorValue =
            case player.equippedArmor of
                Nothing ->
                    0

                Just { kind, count } ->
                    Item.baseValue kind * count

        totalValue : Int
        totalValue =
            inventoryTotalValue + equippedArmorValue + player.caps

        itemView : Item -> Html FrontendMsg
        itemView item =
            let
                ( isDisabled, tooltip ) =
                    case Logic.canUseItem player item.kind of
                        Ok () ->
                            ( False, Nothing )

                        Err ItemCannotBeUsedDirectly ->
                            ( True, Just "This item cannot be used directly." )

                        Err (YouNeedTicks n) ->
                            ( True, Just <| "You need " ++ String.fromInt n ++ " ticks to use this item." )

                        Err YoureAtFullHp ->
                            ( True, Just "You're at full HP." )
            in
            H.li
                [ HA.class "inventory-item"
                , HA.attributeMaybe HA.title tooltip
                ]
                [ H.button
                    [ HA.class "inventory-item-use-btn"
                    , HE.onClick <| AskToUseItem item.id
                    , HA.disabled isDisabled
                    ]
                    [ H.text "[Use]" ]
                , H.viewIf (Item.isEquippable item.kind) <|
                    H.button
                        [ HA.class "inventory-item-equip-btn"
                        , HE.onClick <| AskToEquipItem item.id
                        ]
                        [ H.text "[Equip]" ]
                , H.span
                    [ HA.class "inventory-item-label" ]
                    [ H.text <| String.fromInt item.count ++ "x " ++ Item.name item.kind ]
                ]

        armorClass =
            Logic.armorClass
                { naturalArmorClass =
                    Logic.naturalArmorClass
                        { special = player.special
                        , hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                        , hasDodgerPerk = Perk.rank Perk.Dodger player.perks > 0
                        }
                , equippedArmor = player.equippedArmor |> Maybe.map .kind
                , apFromPreviousTurn = 0
                , hasHthEvadePerk = Perk.rank Perk.HthEvade player.perks > 0
                , unarmedSkill = Skill.get player.special player.addedSkillPercentages Skill.Unarmed
                }

        damageThreshold : Int
        damageThreshold =
            -- TODO we're not dealing with plasma/... right now, only _normal_ DT
            Logic.damageThresholdNormal
                { naturalDamageThresholdNormal = 0
                , equippedArmor = player.equippedArmor |> Maybe.map .kind
                }

        damageResistance : Int
        damageResistance =
            -- TODO we're not dealing with plasma/... right now, only _normal_ DR
            Logic.damageResistanceNormal
                { naturalDamageResistanceNormal = 0
                , equippedArmor = player.equippedArmor |> Maybe.map .kind
                , toughnessPerkRanks = Perk.rank Perk.Toughness player.perks
                }

        attackStats : AttackStats
        attackStats =
            Logic.unarmedAttackStats
                { special = player.special
                , unarmedSkill = Skill.get player.special player.addedSkillPercentages Skill.Unarmed
                , traits = player.traits
                , perks = player.perks
                , level = Xp.currentLevel player.xp
                , npcExtraBonus = 0
                }

        chanceToHitAtArmorClass : Int -> Int
        chanceToHitAtArmorClass targetArmorClass =
            Logic.unarmedChanceToHit
                { attackerAddedSkillPercentages = player.addedSkillPercentages
                , attackerSpecial = player.special
                , -- TODO parameterize by this after we get non-unarmed combat
                  distanceHexes = 0
                , shotType = ShotType.NormalShot
                , targetArmorClass = targetArmorClass
                }
    in
    [ pageTitleView "Inventory"
    , H.p [] [ H.text <| "Total value: $" ++ String.fromInt totalValue ]
    , if Dict.isEmpty player.items then
        H.p [] [ H.text "You have no items!" ]

      else
        H.ul
            [ HA.id "inventory-list" ]
            (List.map itemView <| Dict.values player.items)
    , H.h3
        [ HA.id "inventory-equipment" ]
        [ H.text "Equipment" ]
    , H.div
        [ HA.id "inventory-equipment-armor" ]
        [ H.text "Armor: "
        , case player.equippedArmor of
            Nothing ->
                H.text "None"

            Just armor ->
                H.span []
                    [ H.text <| Item.name armor.kind
                    , H.button
                        [ HE.onClick AskToUnequipArmor
                        , HA.class "inventory-equipment-unequip-btn"
                        ]
                        [ H.text "[Unequip]" ]
                    ]
        ]
    , H.h3
        [ HA.id "inventory-stats" ]
        [ H.text "Defence stats" ]
    , H.ul
        []
        [ H.li [] [ H.text <| "Armor Class: " ++ String.fromInt armorClass ]
        , H.li [] [ H.text <| "Damage Threshold: " ++ String.fromInt damageThreshold ]
        , H.li [] [ H.text <| "Damage Resistance: " ++ String.fromInt damageResistance ]
        ]
    , H.h3
        [ HA.id "inventory-stats" ]
        [ H.text "Attack stats" ]
    , H.ul
        []
        [ H.li [] [ H.text <| "Min Damage: " ++ String.fromInt attackStats.minDamage ]
        , H.li [] [ H.text <| "Max Damage: " ++ String.fromInt attackStats.maxDamage ]
        , H.li [] [ H.text <| "Chance to hit at target armor class 0: " ++ String.fromInt (chanceToHitAtArmorClass 0) ++ "%" ]
        , H.li [] [ H.text <| "Chance to hit at target armor class 10: " ++ String.fromInt (chanceToHitAtArmorClass 10) ++ "%" ]
        , H.li [] [ H.text <| "Chance to hit at target armor class 20: " ++ String.fromInt (chanceToHitAtArmorClass 20) ++ "%" ]
        ]
    ]


messagesView : Posix -> Time.Zone -> PlayerData -> CPlayer -> List (Html FrontendMsg)
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
                |> Dict.values
                |> List.sortBy (.id >> negate)
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
                            , HE.onClick <| OpenMessage message.id
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
                                , HE.onClickStopPropagation <| AskToRemoveMessage message.id
                                ]
                                [ H.text "✗" ]
                            ]
                    )
            )
        ]
    , H.viewIf (Dict.isEmpty player.messages) <|
        H.div
            [ HA.id "messages-empty-note" ]
            [ H.text "No messages right now!" ]
    ]


messageView : Time.Zone -> Message.Id -> PlayerData -> CPlayer -> List (Html FrontendMsg)
messageView zone messageId _ player =
    case Dict.get messageId player.messages of
        Nothing ->
            contentUnavailableView <|
                "Message #"
                    ++ String.fromInt messageId
                    ++ " not found"

        Just message ->
            let
                perceptionLevel =
                    Perception.level
                        { perception = player.special.perception
                        , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
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
                perceptionLevel
                message
            , H.button
                [ HE.onClick <| GoToRoute (PlayerRoute Route.Messages)
                , HA.id "message-back-button"
                ]
                [ H.text "[Back]" ]
            ]


settingsFightStrategySyntaxHelpView : Maybe HoveredItem -> String -> List (Html FrontendMsg)
settingsFightStrategySyntaxHelpView maybeHoveredItem fightStrategyText =
    let
        viewMarkup : FightStrategyHelp.Markup -> Html FrontendMsg
        viewMarkup markup =
            case markup of
                FightStrategyHelp.Text text ->
                    H.text text

                FightStrategyHelp.Reference reference ->
                    H.span
                        [ HA.class "fight-strategy-syntax-help-reference"
                        , HE.onMouseOver <| HoverItem <| HoveredFightStrategyReference reference
                        , HE.onMouseOut StopHoveringItem
                        ]
                        [ H.text <| FightStrategyHelp.referenceText reference ]

        hoverInfo =
            case maybeHoveredItem of
                Nothing ->
                    { title = "Hover for help"
                    , description = ""
                    }

                Just hoveredItem ->
                    HoveredItem.text hoveredItem
    in
    [ pageTitleView "Fight Strategy syntax help"
    , H.button
        [ HE.onClick (GoToRoute (PlayerRoute Route.SettingsFightStrategy)) ]
        [ H.text "[Back]" ]
    , H.div
        [ HA.class "fight-strategy-syntax-help-grid" ]
        [ H.pre
            [ HA.class "fight-strategy-syntax-help-cheatsheet" ]
            (List.map viewMarkup FightStrategyHelp.help)
        , H.div
            [ HA.class "fight-strategy-syntax-help-hover" ]
            [ H.h3 [] [ H.text hoverInfo.title ]
            , H.pre
                [ HA.class "fight-strategy-syntax-help-hover-description" ]
                [ H.text hoverInfo.description ]
            ]
        ]
    ]


settingsFightStrategyView :
    String
    -> PlayerData
    -> CPlayer
    -> List (Html FrontendMsg)
settingsFightStrategyView fightStrategyText _ player =
    let
        hasTextChanged : Bool
        hasTextChanged =
            fightStrategyText /= player.fightStrategyText

        parseResult : Result (List Parser.DeadEnd) FightStrategy
        parseResult =
            FightStrategy.parse fightStrategyText

        deadEnds : List Parser.DeadEnd
        deadEnds =
            case parseResult of
                Ok _ ->
                    []

                Err deadEnds_ ->
                    deadEnds_

        viewWarning : FightStrategy.ValidationWarning -> Html FrontendMsg
        viewWarning warning =
            H.li
                [ HA.class "fight-strategy-warning" ]
                [ H.text <|
                    case warning of
                        FightStrategy.ItemDoesntHeal itemKind ->
                            "Item doesn't heal: " ++ Item.name itemKind
                ]

        viewDeadEnd : Parser.DeadEnd -> Html FrontendMsg
        viewDeadEnd deadEnd =
            let
                wrapped : String -> String
                wrapped string =
                    "\"" ++ string ++ "\""

                item : String
                item =
                    case deadEnd.problem of
                        Parser.ExpectingInt ->
                            "a number"

                        Parser.Expecting string ->
                            wrapped string

                        Parser.ExpectingSymbol string ->
                            wrapped string

                        Parser.ExpectingKeyword string ->
                            wrapped string

                        Parser.ExpectingEnd ->
                            "end of the strategy"

                        Parser.UnexpectedChar ->
                            -- we're only using `chompIf` for whitespace in nonemptySpaces
                            "a space"

                        _ ->
                            "<HEY YOU FOUND A BUG, PLEASE SHARE ON DISCORD>"
            in
            H.li
                [ HA.class "fight-strategy-dead-end" ]
                [ H.text <| "- " ++ item ]

        deadEndCategorization : Parser.DeadEnd -> ( ( Int, Int ), String, String )
        deadEndCategorization deadEnd =
            let
                ( item, category ) =
                    case deadEnd.problem of
                        Parser.ExpectingInt ->
                            ( "", "int" )

                        Parser.Expecting string ->
                            ( string, "3: token" )

                        Parser.ExpectingSymbol string ->
                            ( string, "2: symbol" )

                        Parser.ExpectingKeyword string ->
                            ( string, "1: keyword" )

                        _ ->
                            ( "", "weird" )
            in
            ( ( deadEnd.row, deadEnd.col )
            , category
            , item
            )

        helpBtn =
            H.button
                [ HA.class "fight-strategy-help-btn"
                , HE.onClick (GoToRoute (PlayerRoute Route.SettingsFightStrategySyntaxHelp))
                ]
                [ H.text "[Syntax cheatsheet]" ]

        firstDeadEnd : Maybe Parser.DeadEnd
        firstDeadEnd =
            List.head deadEnds

        firstDeadEndRow : Int
        firstDeadEndRow =
            Maybe.map .row firstDeadEnd
                |> Maybe.withDefault 1

        firstDeadEndColumn : Int
        firstDeadEndColumn =
            Maybe.map .col firstDeadEnd
                |> Maybe.withDefault 1

        warnings : List FightStrategy.ValidationWarning
        warnings =
            parseResult
                |> Result.map FightStrategy.warnings
                |> Result.withDefault []
    in
    [ pageTitleView "Settings: Fight Strategy"
    , H.div
        [ HA.class "fight-strategy-grid" ]
        [ H.div [ HA.class "fight-strategy-examples" ]
            (H.text "Examples: "
                :: (FightStrategy.all
                        |> List.map
                            (\( name, strategy ) ->
                                H.button
                                    [ HE.onClick <| SetFightStrategyText <| FightStrategy.toString strategy
                                    , HA.class "fight-strategy-example"
                                    ]
                                    [ H.text name ]
                            )
                        |> List.intersperse (H.text ", ")
                   )
            )
        , H.textarea
            [ HE.onInput SetFightStrategyText
            , HA.class "fight-strategy-textarea"
            , HA.value fightStrategyText
            ]
            []
        , firstDeadEnd
            |> H.viewMaybe
                (\{ row, col } ->
                    H.div
                        [ HA.class "fight-strategy-hovered-error"
                        , cssVars
                            [ ( "--error-row", String.fromInt row )
                            , ( "--error-col", String.fromInt col )
                            ]
                        ]
                        []
                )
        , H.div
            [ HA.class "fight-strategy-info" ]
            (H.div
                [ HA.class "fight-strategy-info-heading" ]
                [ H.text "Info:"
                , helpBtn
                ]
                :: (if Result.isOk parseResult then
                        [ H.p
                            [ HA.class "fight-strategy-info-paragraph" ]
                            [ H.text "Your strategy is OK" ]
                        ]

                    else
                        [ H.p
                            [ HA.class "fight-strategy-info-paragraph" ]
                            [ H.text "Your strategy is not finished yet." ]
                        , H.p
                            [ HA.class "fight-strategy-info-paragraph" ]
                            [ H.text "See the yellow indicator on the left and the notes below to figure out where the problem is." ]
                        , H.p
                            [ HA.class "fight-strategy-info-paragraph" ]
                            [ H.text "If needed, ask on Discord in the "
                            , H.a
                                [ HA.href discordFightStrategiesChannelInviteLink
                                , HA.target "_blank"
                                , HA.class "fight-strategy-info-link"
                                ]
                                [ H.text "#fight-strategies" ]
                            , H.text " channel."
                            ]
                        , H.p
                            [ HA.class "fight-strategy-info-paragraph" ]
                            [ H.text <|
                                if String.isEmpty (String.trim fightStrategyText) then
                                    "Start with:"

                                else
                                    "At line "
                                        ++ String.fromInt firstDeadEndRow
                                        ++ ", column "
                                        ++ String.fromInt firstDeadEndColumn
                                        ++ ", there should be"
                                        ++ (if List.length deadEnds > 1 then
                                                " one of:"

                                            else
                                                ":"
                                           )
                            ]
                        , H.ul [ HA.class "fight-strategy-dead-ends" ]
                            (deadEnds
                                |> List.sortBy deadEndCategorization
                                |> List.map viewDeadEnd
                            )
                        ]
                   )
                ++ (if List.isEmpty warnings then
                        []

                    else
                        [ H.p
                            [ HA.class "fight-strategy-info-paragraph" ]
                            [ H.text "Warnings:" ]
                        , H.ul
                            [ HA.class "fight-strategy-warnings" ]
                            (List.map viewWarning warnings)
                        ]
                   )
            )
        ]
    , H.div
        [ HA.class "fight-strategy-buttons" ]
        [ H.button
            [ HA.class "fight-strategy-save-btn"
            , HA.disabled <| not hasTextChanged || Result.isErr parseResult
            , parseResult
                |> Result.toMaybe
                |> HA.attributeMaybe
                    (\strategy ->
                        HE.onClick <|
                            AskToSetFightStrategy ( strategy, fightStrategyText )
                    )
            ]
            [ H.text "[Save]" ]
        , H.button
            [ HA.class "fight-strategy-reset-btn"
            , HA.disabled <| not hasTextChanged
            , HE.onClick <| SetFightStrategyText player.fightStrategyText
            ]
            [ H.text "[Reset to saved]" ]
        ]
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


fightView : Maybe Fight.Info -> PlayerData -> CPlayer -> List (Html FrontendMsg)
fightView maybeFight _ player =
    case maybeFight of
        Nothing ->
            contentUnavailableView "Fight was `Nothing` in fightView"

        Just fight ->
            let
                youAreAttacker =
                    case fight.attacker of
                        Fight.Player { name } ->
                            name == player.name

                        Fight.Npc _ ->
                            False

                perceptionLevel =
                    Perception.level
                        { perception = player.special.perception
                        , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
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
            , Data.Fight.View.view perceptionLevel fight player.name
            , H.button
                [ HE.onClick <| GoToRoute (PlayerRoute Route.Ladder)
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


aboutWorldView : Time.Zone -> PlayerData -> CPlayer -> List (Html FrontendMsg)
aboutWorldView zone data loggedInPlayer =
    [ pageTitleView <| "About world: " ++ data.worldName
    , H.ul []
        [ H.li [] [ H.text <| "Description: " ++ data.description ]
        , H.li []
            [ H.text <|
                "Started at: "
                    ++ DateFormat.format
                        [ DateFormat.yearNumber
                        , DateFormat.text "-"
                        , DateFormat.monthFixed
                        , DateFormat.text "-"
                        , DateFormat.dayOfMonthFixed
                        , DateFormat.text " "
                        , DateFormat.hourMilitaryFixed
                        , DateFormat.text ":"
                        , DateFormat.minuteFixed
                        , DateFormat.text ":"
                        , DateFormat.secondFixed
                        ]
                        zone
                        data.startedAt
            ]
        , H.li []
            [ H.text <|
                "Tick frequency: "
                    ++ Tick.curveToString data.tickPerIntervalCurve
                    ++ " ticks every "
                    ++ Time.intervalToString data.tickFrequency
            ]
        , H.li []
            [ H.text <|
                "Vendor restock frequency: every "
                    ++ Time.intervalToString data.vendorRestockFrequency
            ]
        ]
    ]


ladderView : PlayerData -> CPlayer -> List (Html FrontendMsg)
ladderView data loggedInPlayer =
    let
        players : List COtherPlayer
        players =
            WorldData.allPlayers data
    in
    [ pageTitleView "Ladder"
    , ladderTableView players loggedInPlayer
    ]


ladderTableView : List COtherPlayer -> CPlayer -> Html FrontendMsg
ladderTableView players loggedInPlayer =
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
                , H.th [ HA.class "ladder-fight" ] [ H.text "Fight" ]
                , H.th [ HA.class "ladder-name" ] [ H.text "Name" ]
                , H.th
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
                        H.tr
                            [ HA.classList
                                [ ( "is-player", loggedInPlayer.name == player.name ) ]
                            ]
                            [ H.td
                                [ HA.class "ladder-rank"
                                , HA.title "Rank"
                                ]
                                [ H.text <| String.fromInt <| i + 1 ]
                            , if loggedInPlayer.name == player.name then
                                cantFight "Hey, that's you!"

                              else if loggedInPlayer.hp == 0 then
                                cantFight "Can't fight: you're dead!"

                              else if HealthStatus.isDead player.healthStatus then
                                cantFight "Can't fight this person: they're dead!"

                              else if loggedInPlayer.ticks <= 0 then
                                cantFight "Can't fight: you have no ticks!"

                              else
                                H.td
                                    [ HA.class "ladder-fight"
                                    , HE.onClick <| AskToFight player.name
                                    ]
                                    [ H.text "Fight" ]
                            , H.td
                                [ HA.class "ladder-name"
                                , HA.title "Name"
                                ]
                                [ H.text player.name ]
                            , H.td
                                [ HA.class "ladder-status"
                                , HA.title <|
                                    if loggedInPlayer.special.perception <= 1 then
                                        "Health status. Your perception is so low you genuinely can't say whether they're even alive or dead."

                                    else
                                        "Health status"
                                ]
                                [ H.text <| HealthStatus.label player.healthStatus ]
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
    , H.button
        [ HE.onClick <| GoToRoute News
        , HA.id "message-back-button"
        ]
        [ H.text "[Back]" ]
    ]


notInitializedView : Model -> Html FrontendMsg
notInitializedView model =
    appView
        { leftNav =
            [ loginFormView model.loginForm
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


view_ : Model -> Html FrontendMsg
view_ model =
    let
        leftNav =
            case model.worldData of
                IsAdmin data ->
                    [ alertMessageView model.alertMessage
                    , adminLinksView model.route
                    ]

                IsPlayer data ->
                    [ alertMessageView model.alertMessage
                    , playerInfoView data.player
                    , loggedInLinksView data.player model.route
                    ]

                NotLoggedIn ->
                    [ loginFormView model.loginForm
                    , alertMessageView model.alertMessage
                    , loggedOutLinksView model.route
                    ]
    in
    appView { leftNav = leftNav } model


alertMessageView : Maybe String -> Html FrontendMsg
alertMessageView maybeMessage =
    maybeMessage
        |> H.viewMaybe
            (\message ->
                H.div
                    [ HA.id "alert-message" ]
                    [ H.text message ]
            )


loginFormView : Auth Plaintext -> Html FrontendMsg
loginFormView auth =
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


type LinkType
    = LinkOut String
    | LinkIn
        { route : Route
        , isActive : Route -> Bool
        }
    | LinkMsg FrontendMsg


linkView : Route -> Link -> Html FrontendMsg
linkView currentRoute { label, type_, tooltip, disabled, dimmed } =
    let
        ( tag, linkAttrs ) =
            case type_ of
                LinkOut http ->
                    ( H.a
                    , [ HA.href http
                      , HA.target "_blank"
                      , HA.attributeMaybe HA.title tooltip
                      ]
                    )

                LinkIn { route, isActive } ->
                    ( H.button
                    , [ HE.onClick <| GoToRoute route
                      , HA.attributeMaybe HA.title tooltip
                      , HA.attributeIf (isActive currentRoute) <| HA.class "active"
                      , HA.disabled disabled
                      ]
                    )

                LinkMsg msg ->
                    ( H.button
                    , [ HE.onClick msg
                      , HA.attributeMaybe HA.title tooltip
                      , HA.disabled disabled
                      ]
                    )
    in
    tag
        (HA.class "link"
            :: HA.classList
                [ ( "dimmed", dimmed )
                ]
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
    , dimmed : Bool
    }


linkOut : String -> String -> Maybe String -> Bool -> Link
linkOut label url tooltip disabled =
    Link label (LinkOut url) tooltip disabled False


linkIn : String -> Route -> Maybe String -> Bool -> Link
linkIn label route tooltip disabled =
    Link label
        (LinkIn
            { route = route
            , isActive = (==) route
            }
        )
        tooltip
        disabled
        False


linkInFull : String -> Route -> (Route -> Bool) -> Maybe String -> Bool -> Bool -> Link
linkInFull label route isActive tooltip disabled dimmed =
    Link label
        (LinkIn
            { route = route
            , isActive = isActive
            }
        )
        tooltip
        disabled
        dimmed


linkMsg : String -> FrontendMsg -> Maybe String -> Bool -> Link
linkMsg label msg tooltip disabled =
    Link label (LinkMsg msg) tooltip disabled False


loggedInLinksView : Player CPlayer -> Route -> Html FrontendMsg
loggedInLinksView player currentRoute =
    let
        links =
            case player of
                NeedsCharCreated _ ->
                    [ linkIn "New Char" (PlayerRoute Route.CharCreation) Nothing False
                    , linkMsg "Logout" Logout Nothing False
                    ]

                Player p ->
                    let
                        tickHealPercentage =
                            Logic.tickHealPercentage
                                { endurance = p.special.endurance
                                , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing p.perks
                                }

                        hpHealed =
                            round <| toFloat tickHealPercentage / 100 * toFloat p.maxHp

                        ( healTooltip, healDisabled ) =
                            if p.hp >= p.maxHp then
                                ( Just <| "Heal your HP by " ++ String.fromInt tickHealPercentage ++ " % of your max HP (" ++ String.fromInt hpHealed ++ " HP). Cost: 1 tick. You are at full HP!"
                                , True
                                )

                            else if p.ticks < 1 then
                                ( Just <| "Heal your HP by " ++ String.fromInt tickHealPercentage ++ " % of your max HP (" ++ String.fromInt hpHealed ++ " HP). Cost: 1 tick. You have no ticks left!"
                                , True
                                )

                            else
                                ( Just <| "Heal your HP by " ++ String.fromInt tickHealPercentage ++ " % of your max HP (" ++ String.fromInt hpHealed ++ " HP). Cost: 1 tick"
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
                    , linkIn "Character" (PlayerRoute Route.Character) Nothing False
                    , linkIn "Inventory" (PlayerRoute Route.Inventory) Nothing False
                    , linkIn "Map" Map Nothing False
                    , linkIn "Ladder" (PlayerRoute Route.Ladder) Nothing False
                    , if isInTown then
                        linkIn "Town" (PlayerRoute Route.TownMainSquare) Nothing False

                      else
                        linkMsg "Wander" AskToWander wanderTooltip wanderDisabled
                    , linkIn "Settings"
                        (PlayerRoute Route.SettingsFightStrategy)
                        Nothing
                        False
                    , linkInFull "Messages"
                        (PlayerRoute Route.Messages)
                        Route.isMessagesRelatedRoute
                        Nothing
                        False
                        (Dict.all (always .hasBeenRead) p.messages)
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
            , linkIn "Worlds" (AdminRoute AdminWorldsList) Nothing False
            , linkMsg "Import" ImportButtonClicked Nothing False
            , linkMsg "Export" AskForExport Nothing False
            , linkIn "Ladder" (PlayerRoute Route.Ladder) Nothing False
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
         , linkIn "Map" Map Nothing False
         , linkIn "Ladder" (PlayerRoute Route.Ladder) Nothing False
         ]
            |> List.map (linkView currentRoute)
        )


commonLinksView : Route -> Html FrontendMsg
commonLinksView currentRoute =
    H.div
        [ HA.id "common-links"
        , HA.class "links"
        ]
        ([ linkIn "News" News Nothing False
         , linkIn "About" About Nothing False
         , linkOut "Wiki    →" "https://nu-ashworld.tiddlyhost.com" Nothing False
         , linkOut "Discord →" "https://discord.gg/SxymXxvehS" Nothing False
         , linkOut "Twitter →" "https://twitter.com/NuAshworld" Nothing False
         , linkOut "GitHub  →" "https://github.com/Janiczek/nu-ashworld" Nothing False
         , linkOut "Reddit  →" "https://www.reddit.com/r/NuAshworld/" Nothing False
         , linkOut "Donate  →" "https://patreon.com/janiczek" Nothing False
         ]
            |> List.map (linkView currentRoute)
        )


adminWorldsListView : AdminData -> List (Html FrontendMsg)
adminWorldsListView data =
    [ pageTitleView <| "Admin :: Worlds"
    , data.worlds
        |> Dict.keys
        |> List.map
            (\worldName ->
                H.li []
                    [ H.span [] [ H.text worldName ]
                    , H.button
                        [ HE.onClick (GoToRoute (AdminRoute (Route.AdminWorldDetail worldName))) ]
                        [ H.text "World detail" ]
                    , H.button
                        [ HE.onClick (GoToRoute (AdminRoute (Route.AdminPlayersList worldName))) ]
                        [ H.text "Players list" ]
                    ]
            )
        |> H.ul []
    ]


adminWorldDetailView : World.Name -> AdminData -> List (Html FrontendMsg)
adminWorldDetailView worldName data =
    case Dict.get worldName data.worlds of
        Nothing ->
            contentUnavailableView <|
                "World '"
                    ++ worldName
                    ++ "' not found"

        Just world ->
            [ pageTitleView <| "Admin :: World: " ++ worldName
            , H.div [] [ H.text "Logged in players" ]
            , Dict.get worldName data.loggedInPlayers
                |> Maybe.withDefault []
                |> List.map (\name -> H.li [] [ H.text name ])
                |> H.ul []
            ]


adminPlayersListView : World.Name -> AdminData -> List (Html FrontendMsg)
adminPlayersListView worldName data =
    case Dict.get worldName data.worlds of
        Nothing ->
            contentUnavailableView <|
                "World '"
                    ++ worldName
                    ++ "' not found"

        Just world ->
            [ pageTitleView <| "Admin :: Players of world: " ++ worldName
            , world.players
                |> Dict.keys
                |> List.map (\playerName -> H.li [] [ H.text playerName ])
                |> H.ul []
            ]


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


discordFightStrategiesChannelInviteLink : String
discordFightStrategiesChannelInviteLink =
    "https://discord.gg/9NuCZs3YZa"
