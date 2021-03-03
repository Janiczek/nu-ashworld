module Evergreen.V19.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V19.Data.Auth
import Evergreen.V19.Data.Fight
import Evergreen.V19.Data.NewChar
import Evergreen.V19.Data.Player
import Evergreen.V19.Data.Special
import Evergreen.V19.Data.World
import Evergreen.V19.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V19.Frontend.Route.Route
    , world : Evergreen.V19.Data.World.World
    , newChar : Evergreen.V19.Data.NewChar.NewChar
    , authError : (Maybe String)
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V19.Data.Player.PlayerName (Evergreen.V19.Data.Player.Player Evergreen.V19.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V19.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V19.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | NoOp
    | GetZone Time.Zone
    | AskToFight Evergreen.V19.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V19.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar


type ToBackend
    = LogMeIn (Evergreen.V19.Data.Auth.Auth Evergreen.V19.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V19.Data.Auth.Auth Evergreen.V19.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V19.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V19.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V19.Data.Special.SpecialType


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V19.Data.Player.SPlayer Evergreen.V19.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V19.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V19.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V19.Data.Fight.FightInfo, Evergreen.V19.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V19.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V19.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V19.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V19.Data.World.WorldLoggedOutData
    | AuthError String