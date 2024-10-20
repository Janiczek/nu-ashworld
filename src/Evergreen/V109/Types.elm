module Evergreen.V109.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V109.Data.Auth
import Evergreen.V109.Data.Barter
import Evergreen.V109.Data.Fight
import Evergreen.V109.Data.FightStrategy
import Evergreen.V109.Data.Item
import Evergreen.V109.Data.Item.Kind
import Evergreen.V109.Data.Map
import Evergreen.V109.Data.Message
import Evergreen.V109.Data.NewChar
import Evergreen.V109.Data.Perk
import Evergreen.V109.Data.Player
import Evergreen.V109.Data.Player.PlayerName
import Evergreen.V109.Data.Quest
import Evergreen.V109.Data.Skill
import Evergreen.V109.Data.Special
import Evergreen.V109.Data.Trait
import Evergreen.V109.Data.Vendor.Shop
import Evergreen.V109.Data.World
import Evergreen.V109.Data.WorldData
import Evergreen.V109.Data.WorldInfo
import Evergreen.V109.Frontend.HoveredItem
import Evergreen.V109.Frontend.Route
import File
import Lamdera
import Queue
import Random
import SeqSet
import Set
import Time
import Url


type AdminToBackend
    = ExportJson
    | ImportJson String
    | CreateNewWorld String Bool


type ToBackend
    = LogMeIn (Evergreen.V109.Data.Auth.Auth Evergreen.V109.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V109.Data.Auth.Auth Evergreen.V109.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V109.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V109.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V109.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V109.Data.Item.Id
    | EquipWeapon Evergreen.V109.Data.Item.Id
    | PreferAmmo Evergreen.V109.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V109.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V109.Data.Skill.Skill
    | UseSkillPoints Evergreen.V109.Data.Skill.Skill
    | ChoosePerk Evergreen.V109.Data.Perk.Perk
    | MoveTo Evergreen.V109.Data.Map.TileCoords (Set.Set Evergreen.V109.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V109.Data.Message.Id
    | RemoveMessage Evergreen.V109.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V109.Data.Barter.State Evergreen.V109.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V109.Data.Quest.Name
    | StartProgressing Evergreen.V109.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V109.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V109.Data.Auth.Auth Evergreen.V109.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V109.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V109.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V109.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V109.Data.Map.TileCoords, Set.Set Evergreen.V109.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V109.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V109.Data.Fight.Info
    , barter : Evergreen.V109.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V109.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V109.Data.Player.PlayerName.PlayerName, Evergreen.V109.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V109.Data.World.Name Evergreen.V109.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V109.Data.World.Name, Evergreen.V109.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V109.Data.Player.PlayerName.PlayerName, Evergreen.V109.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V109.Data.Item.Id Int
    | AddVendorItem Evergreen.V109.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V109.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V109.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V109.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V109.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V109.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V109.Frontend.Route.Route
    | GoToTownStore Evergreen.V109.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V109.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V109.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V109.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V109.Data.Item.Id
    | AskToEquipWeapon Evergreen.V109.Data.Item.Id
    | AskToPreferAmmo Evergreen.V109.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V109.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V109.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V109.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V109.Data.Special.Type
    | NewCharDecSpecial Evergreen.V109.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V109.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V109.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V109.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V109.Data.Message.Id
    | AskToRemoveMessage Evergreen.V109.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V109.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V109.Data.Quest.Name
    | CollapseQuestItem Evergreen.V109.Data.Quest.Name
    | AskToStopProgressing Evergreen.V109.Data.Quest.Name
    | AskToStartProgressing Evergreen.V109.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V109.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V109.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V109.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V109.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V109.Data.World.Name (List Evergreen.V109.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V109.Data.Player.PlayerName.PlayerName, Evergreen.V109.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V109.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V109.Data.Fight.Info, Evergreen.V109.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V109.Data.WorldData.PlayerData
    | YoureRegistered Evergreen.V109.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V109.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V109.Data.Player.CPlayer Evergreen.V109.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V109.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V109.Data.WorldData.PlayerData, Maybe Evergreen.V109.Data.Barter.Message )
    | BarterMessage Evergreen.V109.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V109.Data.Message.Id Evergreen.V109.Data.Message.Message)
