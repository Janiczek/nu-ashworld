module Evergreen.V55.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V55.Data.Auth
import Evergreen.V55.Data.Fight
import Evergreen.V55.Data.Map
import Evergreen.V55.Data.NewChar
import Evergreen.V55.Data.Player
import Evergreen.V55.Data.Special
import Evergreen.V55.Data.World
import Evergreen.V55.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V55.Frontend.Route.Route
    , world : Evergreen.V55.Data.World.World
    , newChar : Evergreen.V55.Data.NewChar.NewChar
    , message : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V55.Data.Map.TileCoords, (Set.Set Evergreen.V55.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V55.Data.Player.PlayerName (Evergreen.V55.Data.Player.Player Evergreen.V55.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V55.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V55.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V55.Data.Player.PlayerName
    | AskToHeal
    | AskForExport
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V55.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial Evergreen.V55.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V55.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V55.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V55.Data.Auth.Auth Evergreen.V55.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V55.Data.Auth.Auth Evergreen.V55.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V55.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V55.Data.Player.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V55.Data.Special.SpecialType
    | MoveTo Evergreen.V55.Data.Map.TileCoords (Set.Set Evergreen.V55.Data.Map.TileCoords)
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V55.Data.Player.SPlayer Evergreen.V55.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V55.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V55.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V55.Data.World.AdminData
    | YourFightResult (Evergreen.V55.Data.Fight.FightInfo, Evergreen.V55.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V55.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V55.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V55.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V55.Data.World.WorldLoggedOutData
    | Message String
    | YoureLoggedInAsAdmin Evergreen.V55.Data.World.AdminData
    | JsonExportDone String