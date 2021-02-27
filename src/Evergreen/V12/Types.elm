module Evergreen.V12.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V12.Data.Fight
import Evergreen.V12.Data.Player
import Evergreen.V12.Data.World
import Evergreen.V12.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V12.Frontend.Route.Route
    , world : Evergreen.V12.Data.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Lamdera.SessionId Evergreen.V12.Data.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V12.Frontend.Route.Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone
    | AskToFight Evergreen.V12.Data.Player.PlayerName


type ToBackend
    = LogMeIn
    | Fight Evergreen.V12.Data.Player.PlayerName


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayerLogHimIn Lamdera.SessionId Lamdera.ClientId Evergreen.V12.Data.Player.SPlayer
    | GeneratedFight Lamdera.SessionId Lamdera.ClientId Evergreen.V12.Data.Player.SPlayer Evergreen.V12.Data.Fight.FightInfo


type ToFrontend
    = YourCurrentWorld Evergreen.V12.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V12.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V12.Data.Fight.FightInfo, Evergreen.V12.Data.World.WorldLoggedInData)