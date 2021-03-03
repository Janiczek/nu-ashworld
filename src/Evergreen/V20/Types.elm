module Evergreen.V20.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V20.Data.Auth
import Evergreen.V20.Data.Fight
import Evergreen.V20.Data.NewChar
import Evergreen.V20.Data.Player
import Evergreen.V20.Data.Special
import Evergreen.V20.Data.World
import Evergreen.V20.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V20.Frontend.Route.Route
    , world : Evergreen.V20.Data.World.World
    , newChar : Evergreen.V20.Data.NewChar.NewChar
    , authError : (Maybe String)
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V20.Data.Player.PlayerName (Evergreen.V20.Data.Player.Player Evergreen.V20.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V20.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V20.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | NoOp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V20.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V20.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar


type ToBackend
    = LogMeIn (Evergreen.V20.Data.Auth.Auth Evergreen.V20.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V20.Data.Auth.Auth Evergreen.V20.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V20.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V20.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V20.Data.Special.SpecialType


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V20.Data.Player.SPlayer Evergreen.V20.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V20.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V20.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V20.Data.Fight.FightInfo, Evergreen.V20.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V20.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V20.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V20.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V20.Data.World.WorldLoggedOutData
    | AuthError String