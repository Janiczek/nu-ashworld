module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Auth exposing (Auth, Hashed)
import Data.Fight exposing (FightInfo)
import Data.NewChar exposing (NewChar)
import Data.Player
    exposing
        ( Player
        , PlayerName
        , SPlayer
        )
import Data.Special exposing (SpecialType)
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
    , newChar : NewChar
    , authError : Maybe String
    }


type alias BackendModel =
    { players : Dict PlayerName (Player SPlayer)
    , loggedInPlayers : Dict ClientId PlayerName
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GoToRoute Route
    | Logout
    | Login
    | Register
    | NoOp
    | GetZone Time.Zone
    | AskToFight PlayerName
    | Refresh
    | AskToIncSpecial SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar


type ToBackend
    = LogMeIn (Auth Hashed)
    | RegisterMe (Auth Hashed)
    | CreateNewChar NewChar
    | LogMeOut
    | Fight PlayerName
    | RefreshPlease
    | IncSpecial SpecialType


type BackendMsg
    = Connected SessionId ClientId
    | Disconnected SessionId ClientId
    | GeneratedFight ClientId SPlayer FightInfo


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
    | YourFightResult ( FightInfo, WorldLoggedInData )
    | YoureLoggedIn WorldLoggedInData
    | YoureRegistered WorldLoggedInData
    | YouHaveCreatedChar WorldLoggedInData
    | YoureLoggedOut WorldLoggedOutData
    | AuthError String
