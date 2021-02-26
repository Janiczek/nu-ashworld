module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Frontend.Route exposing (Route)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Types.Player exposing (SPlayer)
import Types.World exposing (CWorld)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , route : Route
    , world : Maybe CWorld
    , onlinePlayersCount : Int
    }


type alias BackendModel =
    { players : Dict SessionId SPlayer
    , onlinePlayers : Set SessionId
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GoToRoute Route
    | Logout
    | Login
    | NoOp


type ToBackend
    = LogMeIn
    | GiveMeCurrentWorld


type BackendMsg
    = Connected SessionId ClientId
    | Disconnected SessionId ClientId
    | GeneratedPlayer ClientId SPlayer


type ToFrontend
    = YourCurrentWorld CWorld
    | OnlinePlayersCountChanged Int
