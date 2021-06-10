module Evergreen.V97.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V97.Data.Auth
import Evergreen.V97.Data.Barter
import Evergreen.V97.Data.Fight
import Evergreen.V97.Data.Fight.Generator
import Evergreen.V97.Data.Item
import Evergreen.V97.Data.Map
import Evergreen.V97.Data.Message
import Evergreen.V97.Data.NewChar
import Evergreen.V97.Data.Perk
import Evergreen.V97.Data.Player
import Evergreen.V97.Data.Player.PlayerName
import Evergreen.V97.Data.Skill
import Evergreen.V97.Data.Special
import Evergreen.V97.Data.Trait
import Evergreen.V97.Data.Vendor
import Evergreen.V97.Data.World
import Evergreen.V97.Frontend.HoveredItem
import Evergreen.V97.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V97.Frontend.Route.Route
    , world : Evergreen.V97.Data.World.World
    , newChar : Evergreen.V97.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V97.Data.Map.TileCoords, Set.Set Evergreen.V97.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V97.Frontend.HoveredItem.HoveredItem
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V97.Data.Player.PlayerName.PlayerName (Evergreen.V97.Data.Player.Player Evergreen.V97.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V97.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V97.Data.Vendor.Name Evergreen.V97.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V97.Data.Item.Id Int
    | AddVendorItem Evergreen.V97.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V97.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V97.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V97.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V97.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V97.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V97.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V97.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V97.Data.Perk.Perk
    | AskToEquipItem Evergreen.V97.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V97.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V97.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V97.Data.Special.Type
    | NewCharDecSpecial Evergreen.V97.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V97.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V97.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V97.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V97.Data.Message.Message
    | AskToRemoveMessage Evergreen.V97.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V97.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V97.Data.Auth.Auth Evergreen.V97.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V97.Data.Auth.Auth Evergreen.V97.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V97.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V97.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V97.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V97.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V97.Data.Skill.Skill
    | UseSkillPoints Evergreen.V97.Data.Skill.Skill
    | ChoosePerk Evergreen.V97.Data.Perk.Perk
    | MoveTo Evergreen.V97.Data.Map.TileCoords (Set.Set Evergreen.V97.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V97.Data.Message.Message
    | RemoveMessage Evergreen.V97.Data.Message.Message
    | Barter Evergreen.V97.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V97.Data.Player.SPlayer ( Evergreen.V97.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V97.Data.Vendor.Name Evergreen.V97.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V97.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V97.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V97.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V97.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V97.Data.World.AdminData
    | YourFightResult ( Evergreen.V97.Data.Fight.Info, Evergreen.V97.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V97.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V97.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V97.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V97.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V97.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V97.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V97.Data.World.WorldLoggedInData, Maybe Evergreen.V97.Data.Barter.Message )
    | BarterMessage Evergreen.V97.Data.Barter.Message
