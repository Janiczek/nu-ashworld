module Evergreen.V10.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V10.Frontend.Route
import Evergreen.V10.Types.Fight
import Evergreen.V10.Types.Player
import Evergreen.V10.Types.World
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V10.Frontend.Route.Route
    , world : Evergreen.V10.Types.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Lamdera.SessionId Evergreen.V10.Types.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V10.Frontend.Route.Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone
    | AskToFight Evergreen.V10.Types.Player.PlayerName


type ToBackend
    = LogMeIn
    | Fight Evergreen.V10.Types.Player.PlayerName


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayerLogHimIn Lamdera.SessionId Lamdera.ClientId Evergreen.V10.Types.Player.SPlayer
    | GeneratedFight Lamdera.SessionId Lamdera.ClientId Evergreen.V10.Types.Fight.FightInfo


type ToFrontend
    = YourCurrentWorld Evergreen.V10.Types.World.WorldLoggedInData
    | CurrentWorld Evergreen.V10.Types.World.WorldLoggedOutData
    | YourFightResult Evergreen.V10.Types.Fight.FightInfo