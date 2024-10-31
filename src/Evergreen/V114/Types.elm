module Evergreen.V114.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V114.Data.Auth
import Evergreen.V114.Data.Barter
import Evergreen.V114.Data.Fight
import Evergreen.V114.Data.FightStrategy
import Evergreen.V114.Data.Item
import Evergreen.V114.Data.Item.Kind
import Evergreen.V114.Data.Map
import Evergreen.V114.Data.Message
import Evergreen.V114.Data.NewChar
import Evergreen.V114.Data.Perk
import Evergreen.V114.Data.Player
import Evergreen.V114.Data.Player.PlayerName
import Evergreen.V114.Data.Quest
import Evergreen.V114.Data.Skill
import Evergreen.V114.Data.Special
import Evergreen.V114.Data.Trait
import Evergreen.V114.Data.Vendor.Shop
import Evergreen.V114.Data.World
import Evergreen.V114.Data.WorldData
import Evergreen.V114.Data.WorldInfo
import Evergreen.V114.Frontend.HoveredItem
import Evergreen.V114.Frontend.Route
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
    = LogMeIn (Evergreen.V114.Data.Auth.Auth Evergreen.V114.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V114.Data.Auth.Auth Evergreen.V114.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V114.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V114.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V114.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V114.Data.Item.Id
    | EquipWeapon Evergreen.V114.Data.Item.Id
    | PreferAmmo Evergreen.V114.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V114.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V114.Data.Skill.Skill
    | UseSkillPoints Evergreen.V114.Data.Skill.Skill
    | ChoosePerk Evergreen.V114.Data.Perk.Perk
    | MoveTo Evergreen.V114.Data.Map.TileCoords (Set.Set Evergreen.V114.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V114.Data.Message.Id
    | RemoveMessage Evergreen.V114.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V114.Data.Barter.State Evergreen.V114.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V114.Data.Quest.Name
    | StartProgressing Evergreen.V114.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V114.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V114.Data.Auth.Auth Evergreen.V114.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V114.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V114.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V114.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V114.Data.Map.TileCoords, Set.Set Evergreen.V114.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V114.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V114.Data.Fight.Info
    , barter : Evergreen.V114.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V114.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V114.Data.Player.PlayerName.PlayerName, Evergreen.V114.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V114.Data.World.Name Evergreen.V114.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V114.Data.World.Name, Evergreen.V114.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V114.Data.Player.PlayerName.PlayerName, Evergreen.V114.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V114.Data.Item.Id Int
    | AddVendorItem Evergreen.V114.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V114.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V114.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V114.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V114.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V114.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V114.Frontend.Route.Route
    | GoToTownStore Evergreen.V114.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V114.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V114.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V114.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V114.Data.Item.Id
    | AskToEquipWeapon Evergreen.V114.Data.Item.Id
    | AskToPreferAmmo Evergreen.V114.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V114.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V114.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V114.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V114.Data.Special.Type
    | NewCharDecSpecial Evergreen.V114.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V114.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V114.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V114.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V114.Data.Message.Id
    | AskToRemoveMessage Evergreen.V114.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V114.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V114.Data.Quest.Name
    | CollapseQuestItem Evergreen.V114.Data.Quest.Name
    | AskToStopProgressing Evergreen.V114.Data.Quest.Name
    | AskToStartProgressing Evergreen.V114.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V114.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V114.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V114.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V114.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V114.Data.World.Name (List Evergreen.V114.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V114.Data.Player.PlayerName.PlayerName, Evergreen.V114.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V114.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V114.Data.Fight.Info, Evergreen.V114.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V114.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V114.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V114.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V114.Data.Player.CPlayer Evergreen.V114.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V114.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V114.Data.WorldData.PlayerData, Maybe Evergreen.V114.Data.Barter.Message )
    | BarterMessage Evergreen.V114.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V114.Data.Message.Id Evergreen.V114.Data.Message.Message)
