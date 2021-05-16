module Evergreen.V89.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V89.Data.Auth
import Evergreen.V89.Data.Barter
import Evergreen.V89.Data.Fight
import Evergreen.V89.Data.Fight.Generator
import Evergreen.V89.Data.Item
import Evergreen.V89.Data.Map
import Evergreen.V89.Data.Message
import Evergreen.V89.Data.NewChar
import Evergreen.V89.Data.Perk
import Evergreen.V89.Data.Player
import Evergreen.V89.Data.Player.PlayerName
import Evergreen.V89.Data.Skill
import Evergreen.V89.Data.Special
import Evergreen.V89.Data.Trait
import Evergreen.V89.Data.Vendor
import Evergreen.V89.Data.World
import Evergreen.V89.Frontend.HoveredItem
import Evergreen.V89.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V89.Frontend.Route.Route
    , world : Evergreen.V89.Data.World.World
    , newChar : Evergreen.V89.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V89.Data.Map.TileCoords, Set.Set Evergreen.V89.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V89.Frontend.HoveredItem.HoveredItem
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V89.Data.Player.PlayerName.PlayerName (Evergreen.V89.Data.Player.Player Evergreen.V89.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V89.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V89.Data.Vendor.Name Evergreen.V89.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V89.Data.Item.Id Int
    | AddVendorItem Evergreen.V89.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V89.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V89.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V89.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V89.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V89.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V89.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V89.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V89.Data.Perk.Perk
    | AskToEquipItem Evergreen.V89.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V89.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V89.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V89.Data.Special.Type
    | NewCharDecSpecial Evergreen.V89.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V89.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V89.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V89.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V89.Data.Message.Message
    | AskToRemoveMessage Evergreen.V89.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V89.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V89.Data.Auth.Auth Evergreen.V89.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V89.Data.Auth.Auth Evergreen.V89.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V89.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V89.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V89.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V89.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V89.Data.Skill.Skill
    | UseSkillPoints Evergreen.V89.Data.Skill.Skill
    | ChoosePerk Evergreen.V89.Data.Perk.Perk
    | MoveTo Evergreen.V89.Data.Map.TileCoords (Set.Set Evergreen.V89.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V89.Data.Message.Message
    | RemoveMessage Evergreen.V89.Data.Message.Message
    | Barter Evergreen.V89.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V89.Data.Player.SPlayer ( Evergreen.V89.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V89.Data.Vendor.Name Evergreen.V89.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V89.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V89.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V89.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V89.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V89.Data.World.AdminData
    | YourFightResult ( Evergreen.V89.Data.Fight.Info, Evergreen.V89.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V89.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V89.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V89.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V89.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V89.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V89.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V89.Data.World.WorldLoggedInData, Maybe Evergreen.V89.Data.Barter.Message )
    | BarterMessage Evergreen.V89.Data.Barter.Message
