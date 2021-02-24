module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
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
      , world = Nothing
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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
            ( { model | world = Nothing }, Cmd.none )

        Login ->
            ( model, Lamdera.sendToBackend LogMeIn )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        YoureLoggedIn world ->
            ( { model | world = Just world }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ stylesLinkView
        , case model.world of
            Nothing ->
                loggedOutView

            Just world ->
                loggedInView world
        ]
    }


appView :
    { leftNav : List (Html FrontendMsg)
    , content : List (Html FrontendMsg)
    , isLoggedIn : Bool
    }
    -> Html FrontendMsg
appView { leftNav, content, isLoggedIn } =
    H.div
        [ HA.id "app"
        , HA.classList [ ( "logged-in", isLoggedIn ) ]
        ]
        [ H.div [ HA.id "left-nav" ] (logoView :: leftNav)
        , H.div [ HA.id "content" ] content
        ]


loggedOutView : Html FrontendMsg
loggedOutView =
    appView
        { isLoggedIn = False
        , leftNav =
            [ loginFormView
            , loggedOutLinksView
            , commonLinksView
            ]
        , content = [ H.text "TODO content" ]
        }


loggedInView : CWorld -> Html FrontendMsg
loggedInView world =
    appView
        { isLoggedIn = True
        , leftNav =
            [ userInfoView world
            , loggedInLinksView
            , commonLinksView
            ]
        , content = [ H.text "TODO content" ]
        }


loginFormView : Html FrontendMsg
loginFormView =
    H.div
        [ HA.id "login-form"
        , HE.onClick Login
        ]
        [ H.text "[ (TODO) LOGIN ]"
        ]


linkView : ( String, FrontendMsg ) -> Html FrontendMsg
linkView ( label, msg ) =
    let
        isActive =
            label == "Ladder"
    in
    H.div
        [ HA.class "link"
        , HA.classList [ ( "active", isActive ) ]
        , HE.onClick msg
        ]
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


loggedInLinksView : Html FrontendMsg
loggedInLinksView =
    H.div
        [ HA.id "logged-in-links"
        , HA.class "links"
        ]
        ([ ( "Character", NoOp )
         , ( "Map", NoOp )
         , ( "Ladder", NoOp )
         , ( "Town", NoOp )
         , ( "Settings", NoOp )
         , ( "Logout", Logout )
         ]
            |> List.map linkView
        )


loggedOutLinksView : Html FrontendMsg
loggedOutLinksView =
    H.div
        [ HA.id "logged-out-links"
        , HA.class "links"
        ]
        ([ ( "Ladder", NoOp ) ]
            |> List.map linkView
        )


commonLinksView : Html FrontendMsg
commonLinksView =
    H.div
        [ HA.id "common-links"
        , HA.class "links"
        ]
        ([ ( "FAQ", NoOp )
         , ( "Reddit", NoOp )
         , ( "Donate", NoOp )
         ]
            |> List.map linkView
        )


userInfoView : CWorld -> Html msg
userInfoView world =
    H.div [ HA.id "user-info" ]
        [ H.div [ HA.id "user-name" ] [ H.text world.player.name ]
        , H.div [ HA.id "user-stats" ]
            [ H.div
                [ HA.class "user-stat-label"
                , HA.title "Hitpoints"
                ]
                [ H.text "HP:" ]
            , H.div [ HA.class "user-stat-value" ] [ H.text <| String.fromInt world.player.hp ++ "/" ++ String.fromInt world.player.maxHp ]
            , H.div
                [ HA.class "user-stat-label"
                , HA.title "Experience points"
                ]
                [ H.text "XP:" ]
            , H.div [ HA.class "user-stat-value" ]
                [ H.span [] [ H.text <| String.fromInt world.player.xp ]
                , H.span
                    [ HA.class "deemphasized" ]
                    [ H.text <| "/" ++ String.fromInt (Xp.nextLevelXp world.player.xp) ]
                ]
            , H.div [ HA.class "user-stat-label" ] [ H.text "Level:" ]
            , H.div [ HA.class "user-stat-value" ] [ H.text <| String.fromInt <| Xp.xpToLevel world.player.xp ]
            , H.div
                [ HA.class "user-stat-label"
                , HA.title "Wins/Losses"
                ]
                [ H.text "W/L:" ]
            , H.div [ HA.class "user-stat-value" ] [ H.text <| String.fromInt world.player.wins ++ "/" ++ String.fromInt world.player.losses ]
            , H.div [ HA.class "user-stat-label" ] [ H.text "Cash:" ]
            , H.div [ HA.class "user-stat-value" ] [ H.text <| "$" ++ String.fromInt world.player.cash ]
            , H.div
                [ HA.class "user-stat-label"
                , HA.title "Action points"
                ]
                [ H.text "AP:" ]
            , H.div [ HA.class "user-stat-value" ] [ H.text <| String.fromInt world.player.ap ]
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
    H.img
        [ HA.src "images/logo-black-small.png"
        , HA.alt "NuAshworld Logo"
        , HA.title "NuAshworld - go to homepage"
        , HA.id "logo"
        , HA.width 190
        , HA.height 36
        ]
        []
