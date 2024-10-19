module Evergreen.V101.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V101.Data.Auth
import Evergreen.V101.Data.Barter
import Evergreen.V101.Data.Fight
import Evergreen.V101.Data.Fight.Generator
import Evergreen.V101.Data.FightStrategy
import Evergreen.V101.Data.Item
import Evergreen.V101.Data.Map
import Evergreen.V101.Data.Message
import Evergreen.V101.Data.NewChar
import Evergreen.V101.Data.Perk
import Evergreen.V101.Data.Player
import Evergreen.V101.Data.Player.PlayerName
import Evergreen.V101.Data.Skill
import Evergreen.V101.Data.Special
import Evergreen.V101.Data.Trait
import Evergreen.V101.Data.Vendor
import Evergreen.V101.Data.World
import Evergreen.V101.Frontend.HoveredItem
import Evergreen.V101.Frontend.Route
import File exposing (File)
import Lamdera
import SeqDict
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V101.Frontend.Route.Route
    , world : Evergreen.V101.Data.World.World
    , newChar : Evergreen.V101.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V101.Data.Map.TileCoords, Set.Set Evergreen.V101.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V101.Frontend.HoveredItem.HoveredItem
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V101.Data.Player.PlayerName.PlayerName (Evergreen.V101.Data.Player.Player Evergreen.V101.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V101.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : SeqDict.SeqDict Evergreen.V101.Data.Vendor.Name Evergreen.V101.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V101.Data.Item.Id Int
    | AddVendorItem Evergreen.V101.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V101.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V101.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V101.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V101.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V101.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V101.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V101.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V101.Data.Perk.Perk
    | AskToEquipItem Evergreen.V101.Data.Item.Id
    | AskToUnequipArmor
    | AskToSetFightStrategy Evergreen.V101.Data.FightStrategy.FightStrategy
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V101.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V101.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V101.Data.Special.Type
    | NewCharDecSpecial Evergreen.V101.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V101.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V101.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V101.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V101.Data.Message.Message
    | AskToRemoveMessage Evergreen.V101.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V101.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V101.Data.Auth.Auth Evergreen.V101.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V101.Data.Auth.Auth Evergreen.V101.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V101.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V101.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V101.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V101.Data.Item.Id
    | SetFightStrategy Evergreen.V101.Data.FightStrategy.FightStrategy
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V101.Data.Skill.Skill
    | UseSkillPoints Evergreen.V101.Data.Skill.Skill
    | ChoosePerk Evergreen.V101.Data.Perk.Perk
    | MoveTo Evergreen.V101.Data.Map.TileCoords (Set.Set Evergreen.V101.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V101.Data.Message.Message
    | RemoveMessage Evergreen.V101.Data.Message.Message
    | Barter Evergreen.V101.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V101.Data.Player.SPlayer ( Evergreen.V101.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( SeqDict.SeqDict Evergreen.V101.Data.Vendor.Name Evergreen.V101.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V101.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V101.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V101.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V101.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V101.Data.World.AdminData
    | YourFightResult ( Evergreen.V101.Data.Fight.Info, Evergreen.V101.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V101.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V101.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V101.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V101.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V101.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V101.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V101.Data.World.WorldLoggedInData, Maybe Evergreen.V101.Data.Barter.Message )
    | BarterMessage Evergreen.V101.Data.Barter.Message
