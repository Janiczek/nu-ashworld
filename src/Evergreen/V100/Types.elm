module Evergreen.V100.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V100.Data.Auth
import Evergreen.V100.Data.Barter
import Evergreen.V100.Data.Fight
import Evergreen.V100.Data.Fight.Generator
import Evergreen.V100.Data.FightStrategy
import Evergreen.V100.Data.Item
import Evergreen.V100.Data.Map
import Evergreen.V100.Data.Message
import Evergreen.V100.Data.NewChar
import Evergreen.V100.Data.Perk
import Evergreen.V100.Data.Player
import Evergreen.V100.Data.Player.PlayerName
import Evergreen.V100.Data.Skill
import Evergreen.V100.Data.Special
import Evergreen.V100.Data.Trait
import Evergreen.V100.Data.Vendor
import Evergreen.V100.Data.World
import Evergreen.V100.Frontend.HoveredItem
import Evergreen.V100.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V100.Frontend.Route.Route
    , world : Evergreen.V100.Data.World.World
    , newChar : Evergreen.V100.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V100.Data.Map.TileCoords, Set.Set Evergreen.V100.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V100.Frontend.HoveredItem.HoveredItem
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V100.Data.Player.PlayerName.PlayerName (Evergreen.V100.Data.Player.Player Evergreen.V100.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V100.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V100.Data.Vendor.Name Evergreen.V100.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V100.Data.Item.Id Int
    | AddVendorItem Evergreen.V100.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V100.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V100.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V100.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V100.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V100.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V100.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V100.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V100.Data.Perk.Perk
    | AskToEquipItem Evergreen.V100.Data.Item.Id
    | AskToUnequipArmor
    | AskToSetFightStrategy Evergreen.V100.Data.FightStrategy.FightStrategy
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V100.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V100.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V100.Data.Special.Type
    | NewCharDecSpecial Evergreen.V100.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V100.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V100.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V100.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V100.Data.Message.Message
    | AskToRemoveMessage Evergreen.V100.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V100.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V100.Data.Auth.Auth Evergreen.V100.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V100.Data.Auth.Auth Evergreen.V100.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V100.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V100.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V100.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V100.Data.Item.Id
    | SetFightStrategy Evergreen.V100.Data.FightStrategy.FightStrategy
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V100.Data.Skill.Skill
    | UseSkillPoints Evergreen.V100.Data.Skill.Skill
    | ChoosePerk Evergreen.V100.Data.Perk.Perk
    | MoveTo Evergreen.V100.Data.Map.TileCoords (Set.Set Evergreen.V100.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V100.Data.Message.Message
    | RemoveMessage Evergreen.V100.Data.Message.Message
    | Barter Evergreen.V100.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V100.Data.Player.SPlayer ( Evergreen.V100.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V100.Data.Vendor.Name Evergreen.V100.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V100.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V100.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V100.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V100.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V100.Data.World.AdminData
    | YourFightResult ( Evergreen.V100.Data.Fight.Info, Evergreen.V100.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V100.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V100.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V100.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V100.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V100.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V100.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V100.Data.World.WorldLoggedInData, Maybe Evergreen.V100.Data.Barter.Message )
    | BarterMessage Evergreen.V100.Data.Barter.Message
