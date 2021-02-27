module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Common
import DateFormat
import Frontend.News as News exposing (Item)
import Frontend.Route as Route exposing (Route)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HA
import Html.Events as HE
import Html.Extra as H
import Lamdera
import Task
import Time exposing (Posix)
import Types exposing (..)
import Types.Fight exposing (FightInfo)
import Types.Player exposing (COtherPlayer, CPlayer)
import Types.World as World
    exposing
        ( World(..)
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Types.Xp as Xp
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
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , route = Route.News
      , world = WorldNotInitialized
      , zone = Time.utc
      }
    , Task.perform GetZone Time.here
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GoToRoute route ->
            ( if Route.needsLogin route && not (World.isLoggedIn model.world) then
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

        UrlChanged url ->
            ( model, Cmd.none )

        Logout ->
            ( { model
                | world = World.toLoggedOut model.world
                , route =
                    if Route.needsLogin model.route then
                        Route.News

                    else
                        model.route
              }
            , Cmd.none
            )

        Login ->
            ( model
            , Lamdera.sendToBackend LogMeIn
            )

        GetZone zone ->
            ( { model | zone = zone }
            , Cmd.none
            )

        AskToFight playerName ->
            ( model
            , Lamdera.sendToBackend <| Fight playerName
            )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        YourCurrentWorld world ->
            ( { model
                | world = WorldLoggedIn world
                , route = Route.Ladder
              }
            , Cmd.none
            )

        CurrentWorld world ->
            ( { model | world = WorldLoggedOut world }
            , Cmd.none
            )

        YourFightResult ( fightInfo, world ) ->
            ( { model
                | route = Route.Fight fightInfo
                , world = WorldLoggedIn world
              }
            , Cmd.none
            )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "NuAshworld " ++ Common.version
    , body =
        [ stylesLinkView
        , case model.world of
            WorldNotInitialized ->
                notInitializedView model

            WorldLoggedOut _ ->
                loggedOutView model

            WorldLoggedIn data ->
                loggedInView data model
        ]
    }


appView :
    { leftNav : List (Html FrontendMsg) }
    -> Model
    -> Html FrontendMsg
appView ({ leftNav } as r) model =
    H.div
        [ HA.id "app"
        , HA.classList [ ( "logged-in", World.isLoggedIn model.world ) ]
        ]
        [ H.div [ HA.id "left-nav" ]
            (logoView
                :: leftNav
                ++ [ commonLinksView model.route ]
            )
        , contentView model
        ]


contentView : Model -> Html FrontendMsg
contentView model =
    H.div [ HA.id "content" ]
        (case ( model.route, model.world ) of
            ( Route.Character, WorldLoggedIn world ) ->
                [ H.text "TODO Character page" ]

            ( Route.Character, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Map, _ ) ->
                [ H.text "TODO Map page" ]

            ( Route.Ladder, _ ) ->
                ladderView model

            ( Route.Town, WorldLoggedIn world ) ->
                [ H.text "TODO Town page" ]

            ( Route.Town, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.Settings, WorldLoggedIn world ) ->
                [ H.text "TODO Settings page" ]

            ( Route.Settings, _ ) ->
                contentUnavailableToLoggedOutView

            ( Route.FAQ, _ ) ->
                [ H.text "TODO FAQ page" ]

            ( Route.About, _ ) ->
                [ H.text "TODO About page" ]

            ( Route.News, _ ) ->
                newsView model.zone

            ( Route.Fight fightInfo, WorldLoggedIn world ) ->
                fightView fightInfo

            ( Route.Fight _, _ ) ->
                contentUnavailableToLoggedOutView
        )


pageTitleView : String -> Html FrontendMsg
pageTitleView title =
    H.h2
        [ HA.id "page-title" ]
        [ H.text title ]


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


fightView : FightInfo -> List (Html FrontendMsg)
fightView fightInfo =
    [ H.text "TODO fight" ]


ladderView : Model -> List (Html FrontendMsg)
ladderView model =
    case model.world of
        WorldNotInitialized ->
            [ pageTitleView "Ladder"
            , H.div []
                [ H.text "Ladder is loading..."
                , H.span [ HA.class "loading-cursor" ] []
                ]
            ]

        WorldLoggedOut { players } ->
            [ pageTitleView "Ladder"
            , ladderTableView
                { loggedInPlayer = Nothing
                , players = players
                }
            ]

        WorldLoggedIn data ->
            [ pageTitleView "Ladder"
            , ladderTableView
                { loggedInPlayer = Just data.player
                , players = World.allPlayers data
                }
            ]


ladderTableView :
    { loggedInPlayer : Maybe CPlayer
    , players : List COtherPlayer
    }
    -> Html FrontendMsg
ladderTableView { loggedInPlayer, players } =
    H.table [ HA.id "ladder-table" ]
        [ H.thead []
            [ H.tr []
                [ H.th
                    [ HA.class "ladder-rank"
                    , HA.title "Rank"
                    ]
                    [ H.text "#" ]
                , H.viewIf (loggedInPlayer /= Nothing) <|
                    H.th [ HA.class "ladder-fight" ] []
                , H.th [ HA.class "ladder-name" ] [ H.text "Name" ]
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
                |> List.sortBy (.name >> String.toLower)
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
                                        if loggedInPlayer_.name /= player.name then
                                            H.td
                                                [ HA.class "ladder-fight"
                                                , HE.onClick <| AskToFight player.name
                                                ]
                                                [ H.text "Fight" ]

                                        else
                                            H.td
                                                [ HA.class "ladder-fight"
                                                , HA.title "Can't fight yourself!"
                                                ]
                                                [ H.text "-" ]
                                    )
                            , H.td
                                [ HA.class "ladder-name"
                                , HA.title "Name"
                                ]
                                [ H.text player.name ]
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
    [ H.text "Content unavailable (you're not logged in). (Bug? We should have redirected you someplace else. Could you report this to the developers please?)" ]


notInitializedView : Model -> Html FrontendMsg
notInitializedView model =
    appView
        { leftNav =
            [ loginFormView
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
            [ loginFormView
            , loggedOutLinksView model.route
            ]
        }
        model


loggedInView : WorldLoggedInData -> Model -> Html FrontendMsg
loggedInView world model =
    appView
        { leftNav =
            [ playerInfoView world
            , loggedInLinksView model.route
            ]
        }
        model


loginFormView : Html FrontendMsg
loginFormView =
    H.div
        [ HA.id "login-form"
        , HE.onClick Login
        ]
        [ H.text "[ LOGIN ]"
        ]


type Link
    = LinkOut String
    | LinkIn Route
    | LinkMsg FrontendMsg


linkView : Route -> ( String, Link, Maybe String ) -> Html FrontendMsg
linkView currentRoute ( label, link, tooltip ) =
    let
        ( tag, linkAttrs, maybeRoute ) =
            case link of
                LinkOut http ->
                    ( H.a
                    , [ HA.href http
                      , HA.target "_blank"
                      , HA.attributeMaybe HA.title tooltip
                      ]
                    , Nothing
                    )

                LinkIn route ->
                    ( H.div
                    , [ HE.onClick <| GoToRoute route
                      , HA.attributeMaybe HA.title tooltip
                      ]
                    , Just route
                    )

                LinkMsg msg ->
                    ( H.div
                    , [ HE.onClick msg
                      , HA.attributeMaybe HA.title tooltip
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


loggedInLinksView : Route -> Html FrontendMsg
loggedInLinksView currentRoute =
    H.div
        [ HA.id "logged-in-links"
        , HA.class "links"
        ]
        ([ ( "Character", LinkIn Route.Character, Nothing )
         , ( "Map", LinkIn Route.Map, Nothing )
         , ( "Ladder", LinkIn Route.Ladder, Nothing )
         , ( "Town", LinkIn Route.Town, Nothing )
         , ( "Settings", LinkIn Route.Settings, Nothing )
         , ( "Logout", LinkMsg Logout, Nothing )
         ]
            |> List.map (linkView currentRoute)
        )


loggedOutLinksView : Route -> Html FrontendMsg
loggedOutLinksView currentRoute =
    H.div
        [ HA.id "logged-out-links"
        , HA.class "links"
        ]
        ([ ( "Ladder", LinkIn Route.Ladder, Nothing ) ]
            |> List.map (linkView currentRoute)
        )


commonLinksView : Route -> Html FrontendMsg
commonLinksView currentRoute =
    H.div
        [ HA.id "common-links"
        , HA.class "links"
        ]
        ([ ( "News", LinkIn Route.News, Nothing )
         , ( "About", LinkIn Route.About, Nothing )
         , ( "FAQ", LinkIn Route.FAQ, Just "Frequently Asked Questions" )
         , ( "Reddit →", LinkOut "https://www.reddit.com/r/NuAshworld/", Nothing )
         , ( "Donate →", LinkOut "https://patreon.com/janiczek", Nothing )
         ]
            |> List.map (linkView currentRoute)
        )


playerInfoView : WorldLoggedInData -> Html msg
playerInfoView world =
    H.div [ HA.id "player-info" ]
        [ H.div [ HA.id "player-name" ] [ H.text world.player.name ]
        , H.div [ HA.id "player-stats" ]
            [ H.div
                [ HA.class "player-stat-label"
                , HA.title "Hitpoints"
                ]
                [ H.text "HP:" ]
            , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt world.player.hp ++ "/" ++ String.fromInt world.player.maxHp ]
            , H.div
                [ HA.class "player-stat-label"
                , HA.title "Experience points"
                ]
                [ H.text "XP:" ]
            , H.div [ HA.class "player-stat-value" ]
                [ H.span [] [ H.text <| String.fromInt world.player.xp ]
                , H.span
                    [ HA.class "deemphasized" ]
                    [ H.text <| "/" ++ String.fromInt (Xp.nextLevelXp world.player.xp) ]
                ]
            , H.div [ HA.class "player-stat-label" ] [ H.text "Level:" ]
            , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt <| Xp.xpToLevel world.player.xp ]
            , H.div
                [ HA.class "player-stat-label"
                , HA.title "Wins/Losses"
                ]
                [ H.text "W/L:" ]
            , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt world.player.wins ++ "/" ++ String.fromInt world.player.losses ]
            , H.div [ HA.class "player-stat-label" ] [ H.text "Caps:" ]
            , H.div [ HA.class "player-stat-value" ] [ H.text <| "$" ++ String.fromInt world.player.caps ]
            , H.div
                [ HA.class "player-stat-label"
                , HA.title "Action points"
                ]
                [ H.text "AP:" ]
            , H.div [ HA.class "player-stat-value" ] [ H.text <| String.fromInt world.player.ap ]
            ]
        ]


stylesLinkView : Html msg
stylesLinkView =
    H.node "link"
        [ HA.rel "stylesheet"
        , HA.href <| "styles/app.css?v=" ++ Common.version
        ]
        []


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
            [ HA.id "version" ]
            [ H.text Common.version ]
        ]
