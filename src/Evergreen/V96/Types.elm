module Evergreen.V96.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V96.Data.Auth
import Evergreen.V96.Data.Barter
import Evergreen.V96.Data.Fight
import Evergreen.V96.Data.Fight.Generator
import Evergreen.V96.Data.Item
import Evergreen.V96.Data.Map
import Evergreen.V96.Data.Message
import Evergreen.V96.Data.NewChar
import Evergreen.V96.Data.Perk
import Evergreen.V96.Data.Player
import Evergreen.V96.Data.Player.PlayerName
import Evergreen.V96.Data.Skill
import Evergreen.V96.Data.Special
import Evergreen.V96.Data.Trait
import Evergreen.V96.Data.Vendor
import Evergreen.V96.Data.World
import Evergreen.V96.Frontend.HoveredItem
import Evergreen.V96.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V96.Frontend.Route.Route
    , world : Evergreen.V96.Data.World.World
    , newChar : Evergreen.V96.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V96.Data.Map.TileCoords, Set.Set Evergreen.V96.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V96.Frontend.HoveredItem.HoveredItem
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V96.Data.Player.PlayerName.PlayerName (Evergreen.V96.Data.Player.Player Evergreen.V96.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V96.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V96.Data.Vendor.Name Evergreen.V96.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V96.Data.Item.Id Int
    | AddVendorItem Evergreen.V96.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V96.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V96.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V96.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V96.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V96.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V96.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V96.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V96.Data.Perk.Perk
    | AskToEquipItem Evergreen.V96.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V96.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V96.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V96.Data.Special.Type
    | NewCharDecSpecial Evergreen.V96.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V96.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V96.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V96.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V96.Data.Message.Message
    | AskToRemoveMessage Evergreen.V96.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V96.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V96.Data.Auth.Auth Evergreen.V96.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V96.Data.Auth.Auth Evergreen.V96.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V96.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V96.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V96.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V96.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V96.Data.Skill.Skill
    | UseSkillPoints Evergreen.V96.Data.Skill.Skill
    | ChoosePerk Evergreen.V96.Data.Perk.Perk
    | MoveTo Evergreen.V96.Data.Map.TileCoords (Set.Set Evergreen.V96.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V96.Data.Message.Message
    | RemoveMessage Evergreen.V96.Data.Message.Message
    | Barter Evergreen.V96.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V96.Data.Player.SPlayer ( Evergreen.V96.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V96.Data.Vendor.Name Evergreen.V96.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V96.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V96.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V96.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V96.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V96.Data.World.AdminData
    | YourFightResult ( Evergreen.V96.Data.Fight.Info, Evergreen.V96.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V96.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V96.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V96.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V96.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V96.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V96.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V96.Data.World.WorldLoggedInData, Maybe Evergreen.V96.Data.Barter.Message )
    | BarterMessage Evergreen.V96.Data.Barter.Message
