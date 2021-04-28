module Evergreen.V70.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V70.Data.Auth
import Evergreen.V70.Data.Barter
import Evergreen.V70.Data.Fight
import Evergreen.V70.Data.Fight.Generator
import Evergreen.V70.Data.Item
import Evergreen.V70.Data.Map
import Evergreen.V70.Data.Message
import Evergreen.V70.Data.NewChar
import Evergreen.V70.Data.Player
import Evergreen.V70.Data.Player.PlayerName
import Evergreen.V70.Data.Skill
import Evergreen.V70.Data.Special
import Evergreen.V70.Data.Trait
import Evergreen.V70.Data.Vendor
import Evergreen.V70.Data.World
import Evergreen.V70.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V70.Frontend.Route.Route
    , world : Evergreen.V70.Data.World.World
    , newChar : Evergreen.V70.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V70.Data.Map.TileCoords, Set.Set Evergreen.V70.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V70.Data.Player.PlayerName.PlayerName (Evergreen.V70.Data.Player.Player Evergreen.V70.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V70.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V70.Data.Vendor.Name Evergreen.V70.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V70.Data.Item.Id Int
    | AddVendorItem Evergreen.V70.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V70.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V70.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V70.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V70.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V70.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V70.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V70.Data.Item.Id
    | AskToWander
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V70.Data.Skill.Skill
    | AskToIncSkill Evergreen.V70.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V70.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V70.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V70.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V70.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V70.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V70.Data.Message.Message
    | AskToRemoveMessage Evergreen.V70.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V70.Data.Auth.Auth Evergreen.V70.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V70.Data.Auth.Auth Evergreen.V70.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V70.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V70.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V70.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V70.Data.Skill.Skill
    | IncSkill Evergreen.V70.Data.Skill.Skill
    | MoveTo Evergreen.V70.Data.Map.TileCoords (Set.Set Evergreen.V70.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V70.Data.Message.Message
    | RemoveMessage Evergreen.V70.Data.Message.Message
    | Barter Evergreen.V70.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V70.Data.Player.SPlayer Evergreen.V70.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V70.Data.Vendor.Name Evergreen.V70.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V70.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V70.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V70.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V70.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V70.Data.World.AdminData
    | YourFightResult ( Evergreen.V70.Data.Fight.FightInfo, Evergreen.V70.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V70.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V70.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V70.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V70.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V70.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V70.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V70.Data.World.WorldLoggedInData, Maybe Evergreen.V70.Data.Barter.Message )
    | BarterMessage Evergreen.V70.Data.Barter.Message
