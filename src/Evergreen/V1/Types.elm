module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V1.Frontend.Route
import Evergreen.V1.Types.Player
import Evergreen.V1.Types.World
import Lamdera
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V1.Frontend.Route.Route
    , world : (Maybe Evergreen.V1.Types.World.CWorld)
    }


type alias BackendModel =
    { players : (Dict.Dict Lamdera.SessionId Evergreen.V1.Types.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V1.Frontend.Route.Route
    | Logout
    | Login
    | NoOp


type ToBackend
    = LogMeIn
    | GiveMeCurrentWorld


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayer Lamdera.ClientId Evergreen.V1.Types.Player.SPlayer


type ToFrontend
    = YourCurrentWorld Evergreen.V1.Types.World.CWorld