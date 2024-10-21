module Evergreen.V110.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V110.Data.Auth
import Evergreen.V110.Data.Barter
import Evergreen.V110.Data.Fight
import Evergreen.V110.Data.FightStrategy
import Evergreen.V110.Data.Item
import Evergreen.V110.Data.Item.Kind
import Evergreen.V110.Data.Map
import Evergreen.V110.Data.Message
import Evergreen.V110.Data.NewChar
import Evergreen.V110.Data.Perk
import Evergreen.V110.Data.Player
import Evergreen.V110.Data.Player.PlayerName
import Evergreen.V110.Data.Quest
import Evergreen.V110.Data.Skill
import Evergreen.V110.Data.Special
import Evergreen.V110.Data.Trait
import Evergreen.V110.Data.Vendor.Shop
import Evergreen.V110.Data.World
import Evergreen.V110.Data.WorldData
import Evergreen.V110.Data.WorldInfo
import Evergreen.V110.Frontend.HoveredItem
import Evergreen.V110.Frontend.Route
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
    = LogMeIn (Evergreen.V110.Data.Auth.Auth Evergreen.V110.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V110.Data.Auth.Auth Evergreen.V110.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V110.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V110.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V110.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V110.Data.Item.Id
    | EquipWeapon Evergreen.V110.Data.Item.Id
    | PreferAmmo Evergreen.V110.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V110.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V110.Data.Skill.Skill
    | UseSkillPoints Evergreen.V110.Data.Skill.Skill
    | ChoosePerk Evergreen.V110.Data.Perk.Perk
    | MoveTo Evergreen.V110.Data.Map.TileCoords (Set.Set Evergreen.V110.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V110.Data.Message.Id
    | RemoveMessage Evergreen.V110.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V110.Data.Barter.State Evergreen.V110.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V110.Data.Quest.Name
    | StartProgressing Evergreen.V110.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V110.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V110.Data.Auth.Auth Evergreen.V110.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V110.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V110.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V110.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V110.Data.Map.TileCoords, Set.Set Evergreen.V110.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V110.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V110.Data.Fight.Info
    , barter : Evergreen.V110.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V110.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V110.Data.Player.PlayerName.PlayerName, Evergreen.V110.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V110.Data.World.Name Evergreen.V110.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V110.Data.World.Name, Evergreen.V110.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V110.Data.Player.PlayerName.PlayerName, Evergreen.V110.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V110.Data.Item.Id Int
    | AddVendorItem Evergreen.V110.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V110.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V110.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V110.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V110.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V110.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V110.Frontend.Route.Route
    | GoToTownStore Evergreen.V110.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V110.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V110.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V110.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V110.Data.Item.Id
    | AskToEquipWeapon Evergreen.V110.Data.Item.Id
    | AskToPreferAmmo Evergreen.V110.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V110.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V110.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V110.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V110.Data.Special.Type
    | NewCharDecSpecial Evergreen.V110.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V110.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V110.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V110.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V110.Data.Message.Id
    | AskToRemoveMessage Evergreen.V110.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V110.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V110.Data.Quest.Name
    | CollapseQuestItem Evergreen.V110.Data.Quest.Name
    | AskToStopProgressing Evergreen.V110.Data.Quest.Name
    | AskToStartProgressing Evergreen.V110.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V110.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V110.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V110.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V110.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V110.Data.World.Name (List Evergreen.V110.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V110.Data.Player.PlayerName.PlayerName, Evergreen.V110.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V110.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V110.Data.Fight.Info, Evergreen.V110.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V110.Data.WorldData.PlayerData
    | YoureRegistered Evergreen.V110.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V110.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V110.Data.Player.CPlayer Evergreen.V110.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V110.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V110.Data.WorldData.PlayerData, Maybe Evergreen.V110.Data.Barter.Message )
    | BarterMessage Evergreen.V110.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V110.Data.Message.Id Evergreen.V110.Data.Message.Message)
