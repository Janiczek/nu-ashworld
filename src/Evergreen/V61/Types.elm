module Evergreen.V61.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V61.Data.Auth
import Evergreen.V61.Data.Barter
import Evergreen.V61.Data.Fight
import Evergreen.V61.Data.Item
import Evergreen.V61.Data.Map
import Evergreen.V61.Data.Message
import Evergreen.V61.Data.NewChar
import Evergreen.V61.Data.Player
import Evergreen.V61.Data.Player.PlayerName
import Evergreen.V61.Data.Special
import Evergreen.V61.Data.Vendor
import Evergreen.V61.Data.World
import Evergreen.V61.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V61.Frontend.Route.Route
    , world : Evergreen.V61.Data.World.World
    , newChar : Evergreen.V61.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V61.Data.Map.TileCoords, Set.Set Evergreen.V61.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V61.Data.Player.PlayerName.PlayerName (Evergreen.V61.Data.Player.Player Evergreen.V61.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V61.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : Evergreen.V61.Data.Vendor.Vendors
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V61.Data.Item.Id Int
    | AddVendorItem Evergreen.V61.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V61.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V61.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V61.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V61.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskForExport
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V61.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial Evergreen.V61.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V61.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V61.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V61.Data.Message.Message
    | AskToRemoveMessage Evergreen.V61.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V61.Data.Auth.Auth Evergreen.V61.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V61.Data.Auth.Auth Evergreen.V61.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V61.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V61.Data.Player.PlayerName.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V61.Data.Special.SpecialType
    | MoveTo Evergreen.V61.Data.Map.TileCoords (Set.Set Evergreen.V61.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V61.Data.Message.Message
    | RemoveMessage Evergreen.V61.Data.Message.Message
    | Barter Evergreen.V61.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight
        Lamdera.ClientId
        Evergreen.V61.Data.Player.SPlayer
        { finalAttacker : Evergreen.V61.Data.Player.SPlayer
        , finalTarget : Evergreen.V61.Data.Player.SPlayer
        , fightInfo : Evergreen.V61.Data.Fight.FightInfo
        }
    | GeneratedNewVendorsStock ( Evergreen.V61.Data.Vendor.Vendors, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V61.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V61.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V61.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V61.Data.World.AdminData
    | YourFightResult ( Evergreen.V61.Data.Fight.FightInfo, Evergreen.V61.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V61.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V61.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V61.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V61.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V61.Data.World.AdminData
    | JsonExportDone String
    | BarterDone Evergreen.V61.Data.World.WorldLoggedInData
    | BarterProblem Evergreen.V61.Data.Barter.Problem
