module Evergreen.V8.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V8.Frontend.Route
import Evergreen.V8.Types.Fight
import Evergreen.V8.Types.Player
import Evergreen.V8.Types.World
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V8.Frontend.Route.Route
    , world : Evergreen.V8.Types.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Lamdera.SessionId Evergreen.V8.Types.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V8.Frontend.Route.Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone


type ToBackend
    = LogMeIn
    | Fight Evergreen.V8.Types.Player.PlayerName


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayerLogHimIn Lamdera.SessionId Lamdera.ClientId Evergreen.V8.Types.Player.SPlayer
    | GeneratedFight Lamdera.SessionId Lamdera.ClientId Evergreen.V8.Types.Fight.FightInfo


type ToFrontend
    = YourCurrentWorld Evergreen.V8.Types.World.WorldLoggedInData
    | CurrentWorld Evergreen.V8.Types.World.WorldLoggedOutData
    | YourFightResult Evergreen.V8.Types.Fight.FightInfo