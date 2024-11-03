module Evergreen.V121.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V121.Data.Auth
import Evergreen.V121.Data.Barter
import Evergreen.V121.Data.Fight
import Evergreen.V121.Data.FightStrategy
import Evergreen.V121.Data.Item
import Evergreen.V121.Data.Item.Kind
import Evergreen.V121.Data.Map
import Evergreen.V121.Data.Message
import Evergreen.V121.Data.NewChar
import Evergreen.V121.Data.Perk
import Evergreen.V121.Data.Player
import Evergreen.V121.Data.Player.PlayerName
import Evergreen.V121.Data.Quest
import Evergreen.V121.Data.Skill
import Evergreen.V121.Data.Special
import Evergreen.V121.Data.Trait
import Evergreen.V121.Data.Vendor.Shop
import Evergreen.V121.Data.World
import Evergreen.V121.Data.WorldData
import Evergreen.V121.Data.WorldInfo
import Evergreen.V121.Frontend.HoveredItem
import Evergreen.V121.Frontend.Route
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
    = LogMeIn (Evergreen.V121.Data.Auth.Auth Evergreen.V121.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V121.Data.Auth.Auth Evergreen.V121.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V121.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V121.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V121.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V121.Data.Item.Id
    | EquipWeapon Evergreen.V121.Data.Item.Id
    | PreferAmmo Evergreen.V121.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V121.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V121.Data.Skill.Skill
    | UseSkillPoints Evergreen.V121.Data.Skill.Skill
    | ChoosePerk Evergreen.V121.Data.Perk.Perk
    | MoveTo Evergreen.V121.Data.Map.TileCoords (Set.Set Evergreen.V121.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V121.Data.Message.Id
    | RemoveMessage Evergreen.V121.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V121.Data.Barter.State Evergreen.V121.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V121.Data.Quest.Name
    | StartProgressing Evergreen.V121.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V121.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V121.Data.Auth.Auth Evergreen.V121.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V121.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V121.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V121.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V121.Data.Map.TileCoords, Set.Set Evergreen.V121.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V121.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V121.Data.Fight.Info
    , barter : Evergreen.V121.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V121.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V121.Data.Player.PlayerName.PlayerName, Evergreen.V121.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V121.Data.World.Name Evergreen.V121.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V121.Data.World.Name, Evergreen.V121.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V121.Data.Player.PlayerName.PlayerName, Evergreen.V121.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V121.Data.Item.Id Int
    | AddVendorItem Evergreen.V121.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V121.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V121.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V121.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V121.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V121.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V121.Frontend.Route.Route
    | GoToTownStore Evergreen.V121.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V121.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V121.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V121.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V121.Data.Item.Id
    | AskToEquipWeapon Evergreen.V121.Data.Item.Id
    | AskToPreferAmmo Evergreen.V121.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V121.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V121.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V121.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V121.Data.Special.Type
    | NewCharDecSpecial Evergreen.V121.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V121.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V121.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V121.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V121.Data.Message.Id
    | AskToRemoveMessage Evergreen.V121.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V121.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V121.Data.Quest.Name
    | CollapseQuestItem Evergreen.V121.Data.Quest.Name
    | AskToStopProgressing Evergreen.V121.Data.Quest.Name
    | AskToStartProgressing Evergreen.V121.Data.Quest.Name
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V121.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V121.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V121.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V121.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V121.Data.World.Name (List Evergreen.V121.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V121.Data.Player.PlayerName.PlayerName, Evergreen.V121.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V121.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V121.Data.Fight.Info, Evergreen.V121.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V121.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V121.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V121.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V121.Data.Player.CPlayer Evergreen.V121.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V121.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V121.Data.WorldData.PlayerData, Maybe Evergreen.V121.Data.Barter.Message )
    | BarterMessage Evergreen.V121.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V121.Data.Message.Id Evergreen.V121.Data.Message.Message)
