module Evergreen.V66.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V66.Data.Auth
import Evergreen.V66.Data.Barter
import Evergreen.V66.Data.Fight
import Evergreen.V66.Data.Item
import Evergreen.V66.Data.Map
import Evergreen.V66.Data.Message
import Evergreen.V66.Data.NewChar
import Evergreen.V66.Data.Player
import Evergreen.V66.Data.Player.PlayerName
import Evergreen.V66.Data.Skill
import Evergreen.V66.Data.Special
import Evergreen.V66.Data.Trait
import Evergreen.V66.Data.Vendor
import Evergreen.V66.Data.World
import Evergreen.V66.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V66.Frontend.Route.Route
    , world : Evergreen.V66.Data.World.World
    , newChar : Evergreen.V66.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V66.Data.Map.TileCoords, Set.Set Evergreen.V66.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V66.Data.Player.PlayerName.PlayerName (Evergreen.V66.Data.Player.Player Evergreen.V66.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V66.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V66.Data.Vendor.VendorName Evergreen.V66.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V66.Data.Item.Id Int
    | AddVendorItem Evergreen.V66.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V66.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V66.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V66.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V66.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V66.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V66.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V66.Data.Skill.Skill
    | AskToIncSkill Evergreen.V66.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V66.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V66.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V66.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V66.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V66.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V66.Data.Message.Message
    | AskToRemoveMessage Evergreen.V66.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V66.Data.Auth.Auth Evergreen.V66.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V66.Data.Auth.Auth Evergreen.V66.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V66.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V66.Data.Player.PlayerName.PlayerName
    | HealMe
    | RefreshPlease
    | TagSkill Evergreen.V66.Data.Skill.Skill
    | IncSkill Evergreen.V66.Data.Skill.Skill
    | MoveTo Evergreen.V66.Data.Map.TileCoords (Set.Set Evergreen.V66.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V66.Data.Message.Message
    | RemoveMessage Evergreen.V66.Data.Message.Message
    | Barter Evergreen.V66.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight
        Lamdera.ClientId
        Evergreen.V66.Data.Player.SPlayer
        { finalAttacker : Evergreen.V66.Data.Player.SPlayer
        , finalTarget : Evergreen.V66.Data.Player.SPlayer
        , fightInfo : Evergreen.V66.Data.Fight.FightInfo
        }
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V66.Data.Vendor.VendorName Evergreen.V66.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V66.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V66.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V66.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V66.Data.World.AdminData
    | YourFightResult ( Evergreen.V66.Data.Fight.FightInfo, Evergreen.V66.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V66.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V66.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V66.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V66.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V66.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V66.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V66.Data.World.WorldLoggedInData, Maybe Evergreen.V66.Data.Barter.Message )
    | BarterMessage Evergreen.V66.Data.Barter.Message
