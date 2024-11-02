module Evergreen.V120.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V120.Data.Auth
import Evergreen.V120.Data.Barter
import Evergreen.V120.Data.Fight
import Evergreen.V120.Data.FightStrategy
import Evergreen.V120.Data.Item
import Evergreen.V120.Data.Item.Kind
import Evergreen.V120.Data.Map
import Evergreen.V120.Data.Message
import Evergreen.V120.Data.NewChar
import Evergreen.V120.Data.Perk
import Evergreen.V120.Data.Player
import Evergreen.V120.Data.Player.PlayerName
import Evergreen.V120.Data.Quest
import Evergreen.V120.Data.Skill
import Evergreen.V120.Data.Special
import Evergreen.V120.Data.Trait
import Evergreen.V120.Data.Vendor.Shop
import Evergreen.V120.Data.World
import Evergreen.V120.Data.WorldData
import Evergreen.V120.Data.WorldInfo
import Evergreen.V120.Frontend.HoveredItem
import Evergreen.V120.Frontend.Route
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
    = LogMeIn (Evergreen.V120.Data.Auth.Auth Evergreen.V120.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V120.Data.Auth.Auth Evergreen.V120.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V120.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V120.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V120.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V120.Data.Item.Id
    | EquipWeapon Evergreen.V120.Data.Item.Id
    | PreferAmmo Evergreen.V120.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V120.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V120.Data.Skill.Skill
    | UseSkillPoints Evergreen.V120.Data.Skill.Skill
    | ChoosePerk Evergreen.V120.Data.Perk.Perk
    | MoveTo Evergreen.V120.Data.Map.TileCoords (Set.Set Evergreen.V120.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V120.Data.Message.Id
    | RemoveMessage Evergreen.V120.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V120.Data.Barter.State Evergreen.V120.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V120.Data.Quest.Name
    | StartProgressing Evergreen.V120.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V120.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V120.Data.Auth.Auth Evergreen.V120.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V120.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V120.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V120.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V120.Data.Map.TileCoords, Set.Set Evergreen.V120.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V120.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V120.Data.Fight.Info
    , barter : Evergreen.V120.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V120.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , lastTenToBackendMsgs : List ( Evergreen.V120.Data.Player.PlayerName.PlayerName, Evergreen.V120.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V120.Data.World.Name Evergreen.V120.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V120.Data.World.Name, Evergreen.V120.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V120.Data.Player.PlayerName.PlayerName, Evergreen.V120.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V120.Data.Item.Id Int
    | AddVendorItem Evergreen.V120.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V120.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V120.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V120.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V120.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V120.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V120.Frontend.Route.Route
    | GoToTownStore Evergreen.V120.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V120.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V120.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V120.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V120.Data.Item.Id
    | AskToEquipWeapon Evergreen.V120.Data.Item.Id
    | AskToPreferAmmo Evergreen.V120.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V120.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V120.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V120.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V120.Data.Special.Type
    | NewCharDecSpecial Evergreen.V120.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V120.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V120.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V120.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V120.Data.Message.Id
    | AskToRemoveMessage Evergreen.V120.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V120.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V120.Data.Quest.Name
    | CollapseQuestItem Evergreen.V120.Data.Quest.Name
    | AskToStopProgressing Evergreen.V120.Data.Quest.Name
    | AskToStartProgressing Evergreen.V120.Data.Quest.Name
    | ScrolledToGuideSection String
    | ClickedGuideSection Int


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V120.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V120.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V120.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V120.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V120.Data.World.Name (List Evergreen.V120.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V120.Data.Player.PlayerName.PlayerName, Evergreen.V120.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V120.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V120.Data.Fight.Info, Evergreen.V120.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V120.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V120.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V120.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V120.Data.Player.CPlayer Evergreen.V120.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V120.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V120.Data.WorldData.PlayerData, Maybe Evergreen.V120.Data.Barter.Message )
    | BarterMessage Evergreen.V120.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V120.Data.Message.Id Evergreen.V120.Data.Message.Message)
