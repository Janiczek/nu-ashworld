module Evergreen.V108.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V108.Data.Auth
import Evergreen.V108.Data.Barter
import Evergreen.V108.Data.Fight
import Evergreen.V108.Data.FightStrategy
import Evergreen.V108.Data.Item
import Evergreen.V108.Data.Item.Kind
import Evergreen.V108.Data.Map
import Evergreen.V108.Data.Message
import Evergreen.V108.Data.NewChar
import Evergreen.V108.Data.Perk
import Evergreen.V108.Data.Player
import Evergreen.V108.Data.Player.PlayerName
import Evergreen.V108.Data.Quest
import Evergreen.V108.Data.Skill
import Evergreen.V108.Data.Special
import Evergreen.V108.Data.Trait
import Evergreen.V108.Data.Vendor.Shop
import Evergreen.V108.Data.World
import Evergreen.V108.Data.WorldData
import Evergreen.V108.Data.WorldInfo
import Evergreen.V108.Frontend.HoveredItem
import Evergreen.V108.Frontend.Route
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
    = LogMeIn (Evergreen.V108.Data.Auth.Auth Evergreen.V108.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V108.Data.Auth.Auth Evergreen.V108.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V108.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V108.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V108.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V108.Data.Item.Id
    | EquipWeapon Evergreen.V108.Data.Item.Id
    | PreferAmmo Evergreen.V108.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V108.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | TagSkill Evergreen.V108.Data.Skill.Skill
    | UseSkillPoints Evergreen.V108.Data.Skill.Skill
    | ChoosePerk Evergreen.V108.Data.Perk.Perk
    | MoveTo Evergreen.V108.Data.Map.TileCoords (Set.Set Evergreen.V108.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V108.Data.Message.Id
    | RemoveMessage Evergreen.V108.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V108.Data.Barter.State Evergreen.V108.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V108.Data.Quest.Name
    | StartProgressing Evergreen.V108.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V108.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V108.Data.Auth.Auth Evergreen.V108.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V108.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V108.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V108.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V108.Data.Map.TileCoords, Set.Set Evergreen.V108.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V108.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V108.Data.Fight.Info
    , barter : Evergreen.V108.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V108.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V108.Data.Player.PlayerName.PlayerName, Evergreen.V108.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V108.Data.World.Name Evergreen.V108.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V108.Data.World.Name, Evergreen.V108.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V108.Data.Player.PlayerName.PlayerName, Evergreen.V108.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V108.Data.Item.Id Int
    | AddVendorItem Evergreen.V108.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V108.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V108.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V108.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V108.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V108.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V108.Frontend.Route.Route
    | GoToTownStore Evergreen.V108.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V108.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V108.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V108.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V108.Data.Item.Id
    | AskToEquipWeapon Evergreen.V108.Data.Item.Id
    | AskToPreferAmmo Evergreen.V108.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V108.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V108.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V108.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V108.Data.Special.Type
    | NewCharDecSpecial Evergreen.V108.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V108.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V108.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V108.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V108.Data.Message.Id
    | AskToRemoveMessage Evergreen.V108.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V108.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V108.Data.Quest.Name
    | CollapseQuestItem Evergreen.V108.Data.Quest.Name
    | AskToStopProgressing Evergreen.V108.Data.Quest.Name
    | AskToStartProgressing Evergreen.V108.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V108.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V108.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V108.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V108.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V108.Data.World.Name (List Evergreen.V108.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V108.Data.Player.PlayerName.PlayerName, Evergreen.V108.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V108.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V108.Data.Fight.Info, Evergreen.V108.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V108.Data.WorldData.PlayerData
    | YoureRegistered Evergreen.V108.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V108.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V108.Data.Player.CPlayer Evergreen.V108.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V108.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V108.Data.WorldData.PlayerData, Maybe Evergreen.V108.Data.Barter.Message )
    | BarterMessage Evergreen.V108.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V108.Data.Message.Id Evergreen.V108.Data.Message.Message)
