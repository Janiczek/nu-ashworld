module Evergreen.V3.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V3.Frontend.Route
import Evergreen.V3.Types.Player
import Evergreen.V3.Types.World
import Lamdera
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V3.Frontend.Route.Route
    , world : Evergreen.V3.Types.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Lamdera.SessionId Evergreen.V3.Types.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V3.Frontend.Route.Route
    | Logout
    | Login
    | NoOp


type ToBackend
    = LogMeIn
    | GiveMeCurrentWorld


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayer Lamdera.ClientId Evergreen.V3.Types.Player.SPlayer


type ToFrontend
    = YourCurrentWorld Evergreen.V3.Types.World.WorldLoggedInData
    | CurrentWorld Evergreen.V3.Types.World.WorldLoggedOutData