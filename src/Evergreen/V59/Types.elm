module Evergreen.V59.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V59.Data.Auth
import Evergreen.V59.Data.Fight
import Evergreen.V59.Data.Map
import Evergreen.V59.Data.Message
import Evergreen.V59.Data.NewChar
import Evergreen.V59.Data.Player
import Evergreen.V59.Data.Player.PlayerName
import Evergreen.V59.Data.Special
import Evergreen.V59.Data.World
import Evergreen.V59.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V59.Frontend.Route.Route
    , world : Evergreen.V59.Data.World.World
    , newChar : Evergreen.V59.Data.NewChar.NewChar
    , alertMessage : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V59.Data.Map.TileCoords, (Set.Set Evergreen.V59.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V59.Data.Player.PlayerName.PlayerName (Evergreen.V59.Data.Player.Player Evergreen.V59.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V59.Data.Player.PlayerName.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    , time : Time.Posix
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V59.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V59.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskForExport
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V59.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial Evergreen.V59.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V59.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V59.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V59.Data.Message.Message
    | AskToRemoveMessage Evergreen.V59.Data.Message.Message


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V59.Data.Auth.Auth Evergreen.V59.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V59.Data.Auth.Auth Evergreen.V59.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V59.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V59.Data.Player.PlayerName.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V59.Data.Special.SpecialType
    | MoveTo Evergreen.V59.Data.Map.TileCoords (Set.Set Evergreen.V59.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V59.Data.Message.Message
    | RemoveMessage Evergreen.V59.Data.Message.Message
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V59.Data.Player.SPlayer 
    { finalAttacker : Evergreen.V59.Data.Player.SPlayer
    , finalTarget : Evergreen.V59.Data.Player.SPlayer
    , fightInfo : Evergreen.V59.Data.Fight.FightInfo
    }
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V59.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V59.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V59.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V59.Data.World.AdminData
    | YourFightResult (Evergreen.V59.Data.Fight.FightInfo, Evergreen.V59.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V59.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V59.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V59.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V59.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V59.Data.World.AdminData
    | JsonExportDone String