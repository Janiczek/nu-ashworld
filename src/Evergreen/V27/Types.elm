module Evergreen.V27.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V27.Data.Auth
import Evergreen.V27.Data.Fight
import Evergreen.V27.Data.NewChar
import Evergreen.V27.Data.Player
import Evergreen.V27.Data.Special
import Evergreen.V27.Data.World
import Evergreen.V27.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V27.Frontend.Route.Route
    , world : Evergreen.V27.Data.World.World
    , newChar : Evergreen.V27.Data.NewChar.NewChar
    , authError : (Maybe String)
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V27.Data.Player.PlayerName (Evergreen.V27.Data.Player.Player Evergreen.V27.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V27.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V27.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | NoOp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V27.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V27.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V27.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V27.Data.Special.SpecialType


type ToBackend
    = LogMeIn (Evergreen.V27.Data.Auth.Auth Evergreen.V27.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V27.Data.Auth.Auth Evergreen.V27.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V27.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V27.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V27.Data.Special.SpecialType


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V27.Data.Player.SPlayer Evergreen.V27.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V27.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V27.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V27.Data.Fight.FightInfo, Evergreen.V27.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V27.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V27.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V27.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V27.Data.World.WorldLoggedOutData
    | AuthError String