module Evergreen.V63.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V63.Data.Auth
import Evergreen.V63.Data.Barter
import Evergreen.V63.Data.Fight
import Evergreen.V63.Data.Item
import Evergreen.V63.Data.Map
import Evergreen.V63.Data.Message
import Evergreen.V63.Data.NewChar
import Evergreen.V63.Data.Player
import Evergreen.V63.Data.Player.PlayerName
import Evergreen.V63.Data.Special
import Evergreen.V63.Data.Vendor
import Evergreen.V63.Data.World
import Evergreen.V63.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V63.Frontend.Route.Route
    , world : Evergreen.V63.Data.World.World
    , newChar : Evergreen.V63.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V63.Data.Map.TileCoords, Set.Set Evergreen.V63.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V63.Data.Player.PlayerName.PlayerName (Evergreen.V63.Data.Player.Player Evergreen.V63.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V63.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : Evergreen.V63.Data.Vendor.Vendors
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V63.Data.Item.Id Int
    | AddVendorItem Evergreen.V63.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V63.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V63.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V63.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V63.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V63.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V63.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToIncSpecial Evergreen.V63.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V63.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V63.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V63.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V63.Data.Message.Message
    | AskToRemoveMessage Evergreen.V63.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V63.Data.Auth.Auth Evergreen.V63.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V63.Data.Auth.Auth Evergreen.V63.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V63.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V63.Data.Player.PlayerName.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V63.Data.Special.SpecialType
    | MoveTo Evergreen.V63.Data.Map.TileCoords (Set.Set Evergreen.V63.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V63.Data.Message.Message
    | RemoveMessage Evergreen.V63.Data.Message.Message
    | Barter Evergreen.V63.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight
        Lamdera.ClientId
        Evergreen.V63.Data.Player.SPlayer
        { finalAttacker : Evergreen.V63.Data.Player.SPlayer
        , finalTarget : Evergreen.V63.Data.Player.SPlayer
        , fightInfo : Evergreen.V63.Data.Fight.FightInfo
        }
    | GeneratedNewVendorsStock ( Evergreen.V63.Data.Vendor.Vendors, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V63.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V63.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V63.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V63.Data.World.AdminData
    | YourFightResult ( Evergreen.V63.Data.Fight.FightInfo, Evergreen.V63.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V63.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V63.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V63.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V63.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V63.Data.World.AdminData
    | JsonExportDone String
    | BarterDone Evergreen.V63.Data.World.WorldLoggedInData
    | BarterProblem Evergreen.V63.Data.Barter.Problem
