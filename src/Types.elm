module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Frontend.Route exposing (Route)
import Lamdera exposing (ClientId, SessionId)
import Types.Player exposing (SPlayer)
import Types.World exposing (CWorld)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , route : Route
    , world : Maybe CWorld
    }


type alias BackendModel =
    { players : Dict SessionId SPlayer
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


type BackendMsg
    = Connected SessionId ClientId
    | GeneratedPlayer ClientId SPlayer


type ToFrontend
    = YoureLoggedIn CWorld
