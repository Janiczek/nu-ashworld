module Evergreen.V105.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V105.Data.Auth
import Evergreen.V105.Data.Barter
import Evergreen.V105.Data.Fight
import Evergreen.V105.Data.FightStrategy
import Evergreen.V105.Data.Item
import Evergreen.V105.Data.Item.Kind
import Evergreen.V105.Data.Map
import Evergreen.V105.Data.Message
import Evergreen.V105.Data.NewChar
import Evergreen.V105.Data.Perk
import Evergreen.V105.Data.Player
import Evergreen.V105.Data.Player.PlayerName
import Evergreen.V105.Data.Quest
import Evergreen.V105.Data.Skill
import Evergreen.V105.Data.Special
import Evergreen.V105.Data.Trait
import Evergreen.V105.Data.Vendor.Shop
import Evergreen.V105.Data.World
import Evergreen.V105.Data.WorldData
import Evergreen.V105.Data.WorldInfo
import Evergreen.V105.Frontend.HoveredItem
import Evergreen.V105.Frontend.Route
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
    = LogMeIn (Evergreen.V105.Data.Auth.Auth Evergreen.V105.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V105.Data.Auth.Auth Evergreen.V105.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V105.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V105.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V105.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V105.Data.Item.Id
    | EquipWeapon Evergreen.V105.Data.Item.Id
    | PreferAmmo Evergreen.V105.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V105.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | TagSkill Evergreen.V105.Data.Skill.Skill
    | UseSkillPoints Evergreen.V105.Data.Skill.Skill
    | ChoosePerk Evergreen.V105.Data.Perk.Perk
    | MoveTo Evergreen.V105.Data.Map.TileCoords (Set.Set Evergreen.V105.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V105.Data.Message.Id
    | RemoveMessage Evergreen.V105.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V105.Data.Barter.State Evergreen.V105.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V105.Data.Quest.Name
    | StartProgressing Evergreen.V105.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V105.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V105.Data.Auth.Auth Evergreen.V105.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V105.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V105.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V105.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V105.Data.Map.TileCoords, Set.Set Evergreen.V105.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V105.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V105.Data.Fight.Info
    , barter : Evergreen.V105.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V105.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V105.Data.Player.PlayerName.PlayerName, Evergreen.V105.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V105.Data.World.Name Evergreen.V105.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V105.Data.World.Name, Evergreen.V105.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V105.Data.Player.PlayerName.PlayerName, Evergreen.V105.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V105.Data.Item.Id Int
    | AddVendorItem Evergreen.V105.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V105.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V105.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V105.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V105.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V105.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V105.Frontend.Route.Route
    | GoToTownStore Evergreen.V105.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V105.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V105.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V105.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V105.Data.Item.Id
    | AskToEquipWeapon Evergreen.V105.Data.Item.Id
    | AskToPreferAmmo Evergreen.V105.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V105.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V105.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V105.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V105.Data.Special.Type
    | NewCharDecSpecial Evergreen.V105.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V105.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V105.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V105.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V105.Data.Message.Id
    | AskToRemoveMessage Evergreen.V105.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V105.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V105.Data.Quest.Name
    | CollapseQuestItem Evergreen.V105.Data.Quest.Name
    | AskToStopProgressing Evergreen.V105.Data.Quest.Name
    | AskToStartProgressing Evergreen.V105.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V105.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V105.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V105.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V105.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V105.Data.World.Name (List Evergreen.V105.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V105.Data.Player.PlayerName.PlayerName, Evergreen.V105.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V105.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V105.Data.Fight.Info, Evergreen.V105.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V105.Data.WorldData.PlayerData
    | YoureRegistered Evergreen.V105.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V105.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V105.Data.Player.CPlayer Evergreen.V105.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V105.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V105.Data.WorldData.PlayerData, Maybe Evergreen.V105.Data.Barter.Message )
    | BarterMessage Evergreen.V105.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V105.Data.Message.Id Evergreen.V105.Data.Message.Message)
