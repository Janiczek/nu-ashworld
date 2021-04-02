module Evergreen.V51.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V51.Data.Auth
import Evergreen.V51.Data.Fight
import Evergreen.V51.Data.Map
import Evergreen.V51.Data.NewChar
import Evergreen.V51.Data.Player
import Evergreen.V51.Data.Special
import Evergreen.V51.Data.World
import Evergreen.V51.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V51.Frontend.Route.Route
    , world : Evergreen.V51.Data.World.World
    , newChar : Evergreen.V51.Data.NewChar.NewChar
    , message : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V51.Data.Map.TileCoords, (Set.Set Evergreen.V51.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V51.Data.Player.PlayerName (Evergreen.V51.Data.Player.Player Evergreen.V51.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V51.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V51.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V51.Data.Player.PlayerName
    | AskToHeal
    | AskForExport
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V51.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial Evergreen.V51.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V51.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V51.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V51.Data.Auth.Auth Evergreen.V51.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V51.Data.Auth.Auth Evergreen.V51.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V51.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V51.Data.Player.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V51.Data.Special.SpecialType
    | MoveTo Evergreen.V51.Data.Map.TileCoords (Set.Set Evergreen.V51.Data.Map.TileCoords)
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V51.Data.Player.SPlayer Evergreen.V51.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V51.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V51.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V51.Data.World.AdminData
    | YourFightResult (Evergreen.V51.Data.Fight.FightInfo, Evergreen.V51.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V51.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V51.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V51.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V51.Data.World.WorldLoggedOutData
    | Message String
    | YoureLoggedInAsAdmin Evergreen.V51.Data.World.AdminData
    | JsonExportDone String