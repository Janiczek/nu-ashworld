module Evergreen.V50.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V50.Data.Auth
import Evergreen.V50.Data.Fight
import Evergreen.V50.Data.Map
import Evergreen.V50.Data.NewChar
import Evergreen.V50.Data.Player
import Evergreen.V50.Data.Special
import Evergreen.V50.Data.World
import Evergreen.V50.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V50.Frontend.Route.Route
    , world : Evergreen.V50.Data.World.World
    , newChar : Evergreen.V50.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V50.Data.Map.TileCoords, (Set.Set Evergreen.V50.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V50.Data.Player.PlayerName (Evergreen.V50.Data.Player.Player Evergreen.V50.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V50.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V50.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V50.Data.Player.PlayerName
    | AskToHeal
    | AskForExport
    | Refresh
    | AskToIncSpecial Evergreen.V50.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V50.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V50.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V50.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type AdminToBackend
    = ExportJson


type ToBackend
    = LogMeIn (Evergreen.V50.Data.Auth.Auth Evergreen.V50.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V50.Data.Auth.Auth Evergreen.V50.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V50.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V50.Data.Player.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V50.Data.Special.SpecialType
    | MoveTo Evergreen.V50.Data.Map.TileCoords (Set.Set Evergreen.V50.Data.Map.TileCoords)
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V50.Data.Player.SPlayer Evergreen.V50.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V50.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V50.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V50.Data.World.AdminData
    | YourFightResult (Evergreen.V50.Data.Fight.FightInfo, Evergreen.V50.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V50.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V50.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V50.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V50.Data.World.WorldLoggedOutData
    | AuthError String
    | YoureLoggedInAsAdmin Evergreen.V50.Data.World.AdminData
    | JsonExportDone String