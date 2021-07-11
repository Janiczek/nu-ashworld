module Evergreen.V102.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V102.Data.Auth
import Evergreen.V102.Data.Barter
import Evergreen.V102.Data.Fight
import Evergreen.V102.Data.Fight.Generator
import Evergreen.V102.Data.FightStrategy
import Evergreen.V102.Data.Item
import Evergreen.V102.Data.Map
import Evergreen.V102.Data.Message
import Evergreen.V102.Data.NewChar
import Evergreen.V102.Data.Perk
import Evergreen.V102.Data.Player
import Evergreen.V102.Data.Player.PlayerName
import Evergreen.V102.Data.Skill
import Evergreen.V102.Data.Special
import Evergreen.V102.Data.Trait
import Evergreen.V102.Data.Vendor
import Evergreen.V102.Data.World
import Evergreen.V102.Frontend.HoveredItem
import Evergreen.V102.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V102.Frontend.Route.Route
    , world : Evergreen.V102.Data.World.World
    , newChar : Evergreen.V102.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V102.Data.Map.TileCoords, Set.Set Evergreen.V102.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V102.Frontend.HoveredItem.HoveredItem
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V102.Data.Player.PlayerName.PlayerName (Evergreen.V102.Data.Player.Player Evergreen.V102.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V102.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V102.Data.Vendor.Name Evergreen.V102.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V102.Data.Item.Id Int
    | AddVendorItem Evergreen.V102.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V102.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V102.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V102.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V102.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V102.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V102.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V102.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V102.Data.Perk.Perk
    | AskToEquipItem Evergreen.V102.Data.Item.Id
    | AskToUnequipArmor
    | AskToSetFightStrategy ( Evergreen.V102.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V102.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V102.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V102.Data.Special.Type
    | NewCharDecSpecial Evergreen.V102.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V102.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V102.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V102.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V102.Data.Message.Message
    | AskToRemoveMessage Evergreen.V102.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V102.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V102.Data.Auth.Auth Evergreen.V102.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V102.Data.Auth.Auth Evergreen.V102.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V102.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V102.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V102.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V102.Data.Item.Id
    | SetFightStrategy ( Evergreen.V102.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V102.Data.Skill.Skill
    | UseSkillPoints Evergreen.V102.Data.Skill.Skill
    | ChoosePerk Evergreen.V102.Data.Perk.Perk
    | MoveTo Evergreen.V102.Data.Map.TileCoords (Set.Set Evergreen.V102.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V102.Data.Message.Message
    | RemoveMessage Evergreen.V102.Data.Message.Message
    | Barter Evergreen.V102.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V102.Data.Player.SPlayer ( Evergreen.V102.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V102.Data.Vendor.Name Evergreen.V102.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V102.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V102.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V102.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V102.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V102.Data.World.AdminData
    | YourFightResult ( Evergreen.V102.Data.Fight.Info, Evergreen.V102.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V102.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V102.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V102.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V102.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V102.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V102.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V102.Data.World.WorldLoggedInData, Maybe Evergreen.V102.Data.Barter.Message )
    | BarterMessage Evergreen.V102.Data.Barter.Message
