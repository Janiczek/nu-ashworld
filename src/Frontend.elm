module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Common
import Frontend.Route as Route exposing (Route(..))
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Lamdera
import Types exposing (..)
import Types.Player exposing (COtherPlayer, CPlayer)
import Types.World exposing (CWorld)
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
      , route = Route.About
      , world = Nothing
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GoToRoute route ->
            ( if Route.needsLogin route && not (isLoggedIn model) then
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
                | world = Nothing
                , route =
                    if Route.needsLogin model.route then
                        Route.About

                    else
                        model.route
              }
            , Cmd.none
            )

        Login ->
            ( model
            , Lamdera.sendToBackend LogMeIn
            )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        YourCurrentWorld world ->
            ( { model
                | world = Just world
                , route = Route.Ladder
              }
            , Cmd.none
            )


isLoggedIn : Model -> Bool
isLoggedIn model =
    Nothing /= model.world


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "NuAshworld " ++ Common.version
    , body =
        [ stylesLinkView
        , case model.world of
            Nothing ->
                loggedOutView model

            Just world ->
                loggedInView world model
        ]
    }


appView :
    { leftNav : List (Html FrontendMsg)
    , isLoggedIn : Bool
    }
    -> Model
    -> Html FrontendMsg
appView ({ leftNav } as r) model =
    H.div
        [ HA.id "app"
        , HA.classList [ ( "logged-in", r.isLoggedIn ) ]
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
        (case model.route of
            Character ->
                [ H.text "TODO Character page" ]

            Map ->
                [ H.text "TODO Map page" ]

            Ladder ->
                [ H.text "TODO Ladder page" ]

            Town ->
                [ H.text "TODO Town page" ]

            Settings ->
                [ H.text "TODO Settings page" ]

            FAQ ->
                [ H.text "TODO FAQ page" ]

            About ->
                [ H.text "TODO About page" ]
        )


loggedOutView : Model -> Html FrontendMsg
loggedOutView model =
    appView
        { isLoggedIn = False
        , leftNav =
            [ loginFormView
            , loggedOutLinksView model.route
            ]
        }
        model


loggedInView : CWorld -> Model -> Html FrontendMsg
loggedInView world model =
    appView
        { isLoggedIn = True
        , leftNav =
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
        [ H.text "[ (TODO) LOGIN ]"
        ]


type Link
    = LinkOut String
    | LinkIn Route
    | LinkMsg FrontendMsg


linkView : Route -> ( String, Link ) -> Html FrontendMsg
linkView currentRoute ( label, link ) =
    let
        ( tag, linkAttrs, maybeRoute ) =
            case link of
                LinkOut http ->
                    ( H.a
                    , [ HA.href http
                      , HA.target "_blank"
                      ]
                    , Nothing
                    )

                LinkIn route ->
                    ( H.div
                    , [ HE.onClick <| GoToRoute route ]
                    , Just route
                    )

                LinkMsg msg ->
                    ( H.div
                    , [ HE.onClick msg ]
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
        ([ ( "Character", LinkIn Route.Character )
         , ( "Map", LinkIn Route.Map )
         , ( "Ladder", LinkIn Route.Ladder )
         , ( "Town", LinkIn Route.Town )
         , ( "Settings", LinkIn Route.Settings )
         , ( "Logout", LinkMsg Logout )
         ]
            |> List.map (linkView currentRoute)
        )


loggedOutLinksView : Route -> Html FrontendMsg
loggedOutLinksView currentRoute =
    H.div
        [ HA.id "logged-out-links"
        , HA.class "links"
        ]
        ([ ( "Ladder", LinkIn Route.Ladder ) ]
            |> List.map (linkView currentRoute)
        )


commonLinksView : Route -> Html FrontendMsg
commonLinksView currentRoute =
    H.div
        [ HA.id "common-links"
        , HA.class "links"
        ]
        ([ ( "About", LinkIn Route.About )
         , ( "FAQ", LinkIn Route.FAQ )
         , ( "Reddit →", LinkOut "https://www.reddit.com/r/NuAshworld/" )
         , ( "Donate →", LinkOut "https://patreon.com/janiczek" )
         ]
            |> List.map (linkView currentRoute)
        )


playerInfoView : CWorld -> Html msg
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
            , H.div [ HA.class "player-stat-label" ] [ H.text "Cash:" ]
            , H.div [ HA.class "player-stat-value" ] [ H.text <| "$" ++ String.fromInt world.player.cash ]
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
        , HA.href "styles/app.css"
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
