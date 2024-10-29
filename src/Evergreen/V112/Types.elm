module Evergreen.V112.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V112.Data.Auth
import Evergreen.V112.Data.Barter
import Evergreen.V112.Data.Fight
import Evergreen.V112.Data.FightStrategy
import Evergreen.V112.Data.Item
import Evergreen.V112.Data.Item.Kind
import Evergreen.V112.Data.Map
import Evergreen.V112.Data.Message
import Evergreen.V112.Data.NewChar
import Evergreen.V112.Data.Perk
import Evergreen.V112.Data.Player
import Evergreen.V112.Data.Player.PlayerName
import Evergreen.V112.Data.Quest
import Evergreen.V112.Data.Skill
import Evergreen.V112.Data.Special
import Evergreen.V112.Data.Trait
import Evergreen.V112.Data.Vendor.Shop
import Evergreen.V112.Data.World
import Evergreen.V112.Data.WorldData
import Evergreen.V112.Data.WorldInfo
import Evergreen.V112.Frontend.HoveredItem
import Evergreen.V112.Frontend.Route
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
    = LogMeIn (Evergreen.V112.Data.Auth.Auth Evergreen.V112.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V112.Data.Auth.Auth Evergreen.V112.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V112.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V112.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V112.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V112.Data.Item.Id
    | EquipWeapon Evergreen.V112.Data.Item.Id
    | PreferAmmo Evergreen.V112.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V112.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V112.Data.Skill.Skill
    | UseSkillPoints Evergreen.V112.Data.Skill.Skill
    | ChoosePerk Evergreen.V112.Data.Perk.Perk
    | MoveTo Evergreen.V112.Data.Map.TileCoords (Set.Set Evergreen.V112.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V112.Data.Message.Id
    | RemoveMessage Evergreen.V112.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V112.Data.Barter.State Evergreen.V112.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V112.Data.Quest.Name
    | StartProgressing Evergreen.V112.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V112.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V112.Data.Auth.Auth Evergreen.V112.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V112.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V112.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V112.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V112.Data.Map.TileCoords, Set.Set Evergreen.V112.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V112.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V112.Data.Fight.Info
    , barter : Evergreen.V112.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V112.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V112.Data.Player.PlayerName.PlayerName, Evergreen.V112.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V112.Data.World.Name Evergreen.V112.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V112.Data.World.Name, Evergreen.V112.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V112.Data.Player.PlayerName.PlayerName, Evergreen.V112.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V112.Data.Item.Id Int
    | AddVendorItem Evergreen.V112.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V112.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V112.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V112.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V112.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V112.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V112.Frontend.Route.Route
    | GoToTownStore Evergreen.V112.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V112.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V112.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V112.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V112.Data.Item.Id
    | AskToEquipWeapon Evergreen.V112.Data.Item.Id
    | AskToPreferAmmo Evergreen.V112.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V112.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V112.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V112.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V112.Data.Special.Type
    | NewCharDecSpecial Evergreen.V112.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V112.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V112.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V112.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V112.Data.Message.Id
    | AskToRemoveMessage Evergreen.V112.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V112.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V112.Data.Quest.Name
    | CollapseQuestItem Evergreen.V112.Data.Quest.Name
    | AskToStopProgressing Evergreen.V112.Data.Quest.Name
    | AskToStartProgressing Evergreen.V112.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V112.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V112.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V112.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V112.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V112.Data.World.Name (List Evergreen.V112.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V112.Data.Player.PlayerName.PlayerName, Evergreen.V112.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V112.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V112.Data.Fight.Info, Evergreen.V112.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V112.Data.WorldData.PlayerData
    | YoureRegistered Evergreen.V112.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V112.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V112.Data.Player.CPlayer Evergreen.V112.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V112.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V112.Data.WorldData.PlayerData, Maybe Evergreen.V112.Data.Barter.Message )
    | BarterMessage Evergreen.V112.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V112.Data.Message.Id Evergreen.V112.Data.Message.Message)
