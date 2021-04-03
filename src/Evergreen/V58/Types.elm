module Evergreen.V58.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V58.Data.Auth
import Evergreen.V58.Data.Fight
import Evergreen.V58.Data.Map
import Evergreen.V58.Data.NewChar
import Evergreen.V58.Data.Player
import Evergreen.V58.Data.Special
import Evergreen.V58.Data.World
import Evergreen.V58.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V58.Frontend.Route.Route
    , world : Evergreen.V58.Data.World.World
    , newChar : Evergreen.V58.Data.NewChar.NewChar
    , message : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V58.Data.Map.TileCoords, (Set.Set Evergreen.V58.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V58.Data.Player.PlayerName (Evergreen.V58.Data.Player.Player Evergreen.V58.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V58.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V58.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V58.Data.Player.PlayerName
    | AskToHeal
    | AskForExport
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V58.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial Evergreen.V58.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V58.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V58.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V58.Data.Auth.Auth Evergreen.V58.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V58.Data.Auth.Auth Evergreen.V58.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V58.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V58.Data.Player.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V58.Data.Special.SpecialType
    | MoveTo Evergreen.V58.Data.Map.TileCoords (Set.Set Evergreen.V58.Data.Map.TileCoords)
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V58.Data.Player.SPlayer Evergreen.V58.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V58.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V58.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V58.Data.World.AdminData
    | YourFightResult (Evergreen.V58.Data.Fight.FightInfo, Evergreen.V58.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V58.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V58.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V58.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V58.Data.World.WorldLoggedOutData
    | Message String
    | YoureLoggedInAsAdmin Evergreen.V58.Data.World.AdminData
    | JsonExportDone String