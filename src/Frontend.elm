module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
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
        [ Html.div
            [ Attrs.style "padding-top" "16px"
            ]
            [ case model.world of
                Nothing ->
                    viewLoggedOut

                Just world ->
                    viewLoggedIn world
            ]
        ]
    }


viewLoggedOut : Html FrontendMsg
viewLoggedOut =
    Html.div []
        [ Html.button
            [ Events.onClick Login ]
            [ Html.text "Login and fetch the world state!" ]
        ]


viewLoggedIn : CWorld -> Html FrontendMsg
viewLoggedIn world =
    Html.div []
        [ Html.button
            [ Events.onClick Logout ]
            [ Html.text "Logout" ]
        , Html.div []
            [ Html.h2 [] [ Html.text "You" ]
            , Html.ul [ Attrs.style "text-align" "left" ]
                [ Html.li []
                    [ Html.strong [] [ Html.text "Name: " ]
                    , Html.text world.player.name
                    ]
                , Html.li []
                    [ Html.strong [] [ Html.text "HP: " ]
                    , Html.text <|
                        String.fromInt world.player.hp
                            ++ " / "
                            ++ String.fromInt world.player.maxHp
                    ]
                , Html.li []
                    [ Html.strong [] [ Html.text "Level: " ]
                    , Html.text <|
                        String.fromInt (Xp.xpToLevel world.player.xp)
                            ++ " (current XP: "
                            ++ String.fromInt world.player.xp
                            ++ ", remainder till next level: "
                            ++ String.fromInt (Xp.xpToNextLevel world.player.xp)
                            ++ ")"
                    ]
                , Html.li []
                    [ Html.strong [] [ Html.text "SPECIAL: " ]
                    , Html.ul []
                        [ Html.li [] [ Html.text <| "Strength: " ++ String.fromInt world.player.special.strength ]
                        , Html.li [] [ Html.text <| "Perception: " ++ String.fromInt world.player.special.perception ]
                        , Html.li [] [ Html.text <| "Endurance: " ++ String.fromInt world.player.special.endurance ]
                        , Html.li [] [ Html.text <| "Charisma: " ++ String.fromInt world.player.special.charisma ]
                        , Html.li [] [ Html.text <| "Intelligence: " ++ String.fromInt world.player.special.intelligence ]
                        , Html.li [] [ Html.text <| "Agility: " ++ String.fromInt world.player.special.agility ]
                        , Html.li [] [ Html.text <| "Luck: " ++ String.fromInt world.player.special.luck ]
                        ]
                    ]
                , Html.li []
                    [ Html.strong [] [ Html.text "Available SPECIAL points: " ]
                    , Html.text <| String.fromInt world.player.availableSpecial
                    ]
                ]
            ]
        , Html.div []
            [ Html.h2 [] [ Html.text "Others" ]
            , world.otherPlayers
                |> List.map (\player -> Html.li [] [ Html.text <| Debug.toString player ])
                |> Html.ul []
            ]
        ]
