module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Frontend.Route exposing (Route)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time
import Types.Player exposing (SPlayer)
import Types.World
    exposing
        ( World
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , zone : Time.Zone
    , route : Route
    , world : World
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
    | GetZone Time.Zone


type ToBackend
    = LogMeIn
    | GiveMeCurrentWorld


type BackendMsg
    = Connected SessionId ClientId
    | GeneratedPlayer ClientId SPlayer


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
