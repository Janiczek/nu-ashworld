module Evergreen.V15.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V15.Data.Fight
import Evergreen.V15.Data.Player
import Evergreen.V15.Data.World
import Evergreen.V15.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V15.Frontend.Route.Route
    , world : Evergreen.V15.Data.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V15.Data.Player.PlayerKey Evergreen.V15.Data.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V15.Frontend.Route.Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone
    | AskToFight Evergreen.V15.Data.Player.PlayerName
    | Refresh


type ToBackend
    = LogMeIn
    | Fight Evergreen.V15.Data.Player.PlayerName
    | RefreshPlease


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayerLogHimIn Lamdera.SessionId Lamdera.ClientId Evergreen.V15.Data.Player.SPlayer
    | GeneratedFight Lamdera.SessionId Lamdera.ClientId Evergreen.V15.Data.Player.SPlayer Evergreen.V15.Data.Fight.FightInfo


type ToFrontend
    = YourCurrentWorld Evergreen.V15.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V15.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V15.Data.Fight.FightInfo, Evergreen.V15.Data.World.WorldLoggedInData)
    | YoureLoggedInNow Evergreen.V15.Data.World.WorldLoggedInData