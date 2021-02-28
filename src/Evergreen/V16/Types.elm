module Evergreen.V16.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V16.Data.Fight
import Evergreen.V16.Data.Player
import Evergreen.V16.Data.Special
import Evergreen.V16.Data.World
import Evergreen.V16.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V16.Frontend.Route.Route
    , world : Evergreen.V16.Data.World.World
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V16.Data.Player.PlayerKey Evergreen.V16.Data.Player.SPlayer)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V16.Frontend.Route.Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone
    | AskToFight Evergreen.V16.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V16.Data.Special.SpecialType


type ToBackend
    = LogMeIn
    | Fight Evergreen.V16.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V16.Data.Special.SpecialType


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedPlayerLogHimIn Lamdera.SessionId Lamdera.ClientId Evergreen.V16.Data.Player.SPlayer
    | GeneratedFight Lamdera.SessionId Lamdera.ClientId Evergreen.V16.Data.Player.SPlayer Evergreen.V16.Data.Fight.FightInfo


type ToFrontend
    = YourCurrentWorld Evergreen.V16.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V16.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V16.Data.Fight.FightInfo, Evergreen.V16.Data.World.WorldLoggedInData)
    | YoureLoggedInNow Evergreen.V16.Data.World.WorldLoggedInData