module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Fight exposing (FightInfo)
import Data.Player exposing (PlayerKey, PlayerName, SPlayer)
import Data.World
    exposing
        ( World
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Dict exposing (Dict)
import Frontend.Route exposing (Route)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , zone : Time.Zone
    , route : Route
    , world : World
    }


type alias BackendModel =
    { players : Dict PlayerKey SPlayer
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GoToRoute Route
    | Logout
    | Login
    | NoOp
    | GetZone Time.Zone
    | AskToFight PlayerName
    | Refresh


type ToBackend
    = LogMeIn
    | Fight PlayerName
    | RefreshPlease


type BackendMsg
    = Connected SessionId ClientId
    | GeneratedPlayerLogHimIn SessionId ClientId SPlayer
    | GeneratedFight SessionId ClientId SPlayer FightInfo


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
    | YourFightResult ( FightInfo, WorldLoggedInData )
    | YoureLoggedInNow WorldLoggedInData
