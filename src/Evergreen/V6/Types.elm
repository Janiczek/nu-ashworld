module Evergreen.V6.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V6.Frontend.Route
import Evergreen.V6.Types.Player
import Evergreen.V6.Types.World
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V6.Frontend.Route.Route
    , world : Evergreen.V6.Types.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Lamdera.SessionId Evergreen.V6.Types.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V6.Frontend.Route.Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone


type ToBackend
    = LogMeIn
    | GiveMeCurrentWorld


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayer Lamdera.ClientId Evergreen.V6.Types.Player.SPlayer


type ToFrontend
    = YourCurrentWorld Evergreen.V6.Types.World.WorldLoggedInData
    | CurrentWorld Evergreen.V6.Types.World.WorldLoggedOutData