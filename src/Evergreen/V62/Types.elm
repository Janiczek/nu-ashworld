module Evergreen.V62.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V62.Data.Auth
import Evergreen.V62.Data.Barter
import Evergreen.V62.Data.Fight
import Evergreen.V62.Data.Item
import Evergreen.V62.Data.Map
import Evergreen.V62.Data.Message
import Evergreen.V62.Data.NewChar
import Evergreen.V62.Data.Player
import Evergreen.V62.Data.Player.PlayerName
import Evergreen.V62.Data.Special
import Evergreen.V62.Data.Vendor
import Evergreen.V62.Data.World
import Evergreen.V62.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V62.Frontend.Route.Route
    , world : Evergreen.V62.Data.World.World
    , newChar : Evergreen.V62.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V62.Data.Map.TileCoords, Set.Set Evergreen.V62.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V62.Data.Player.PlayerName.PlayerName (Evergreen.V62.Data.Player.Player Evergreen.V62.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V62.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : Evergreen.V62.Data.Vendor.Vendors
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V62.Data.Item.Id Int
    | AddVendorItem Evergreen.V62.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V62.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V62.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V62.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V62.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V62.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V62.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskForExport
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V62.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial Evergreen.V62.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V62.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V62.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V62.Data.Message.Message
    | AskToRemoveMessage Evergreen.V62.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V62.Data.Auth.Auth Evergreen.V62.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V62.Data.Auth.Auth Evergreen.V62.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V62.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V62.Data.Player.PlayerName.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V62.Data.Special.SpecialType
    | MoveTo Evergreen.V62.Data.Map.TileCoords (Set.Set Evergreen.V62.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V62.Data.Message.Message
    | RemoveMessage Evergreen.V62.Data.Message.Message
    | Barter Evergreen.V62.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight
        Lamdera.ClientId
        Evergreen.V62.Data.Player.SPlayer
        { finalAttacker : Evergreen.V62.Data.Player.SPlayer
        , finalTarget : Evergreen.V62.Data.Player.SPlayer
        , fightInfo : Evergreen.V62.Data.Fight.FightInfo
        }
    | GeneratedNewVendorsStock ( Evergreen.V62.Data.Vendor.Vendors, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V62.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V62.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V62.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V62.Data.World.AdminData
    | YourFightResult ( Evergreen.V62.Data.Fight.FightInfo, Evergreen.V62.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V62.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V62.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V62.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V62.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V62.Data.World.AdminData
    | JsonExportDone String
    | BarterDone Evergreen.V62.Data.World.WorldLoggedInData
    | BarterProblem Evergreen.V62.Data.Barter.Problem
