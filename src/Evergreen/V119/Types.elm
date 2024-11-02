module Evergreen.V119.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V119.Data.Auth
import Evergreen.V119.Data.Barter
import Evergreen.V119.Data.Fight
import Evergreen.V119.Data.FightStrategy
import Evergreen.V119.Data.Item
import Evergreen.V119.Data.Item.Kind
import Evergreen.V119.Data.Map
import Evergreen.V119.Data.Message
import Evergreen.V119.Data.NewChar
import Evergreen.V119.Data.Perk
import Evergreen.V119.Data.Player
import Evergreen.V119.Data.Player.PlayerName
import Evergreen.V119.Data.Quest
import Evergreen.V119.Data.Skill
import Evergreen.V119.Data.Special
import Evergreen.V119.Data.Trait
import Evergreen.V119.Data.Vendor.Shop
import Evergreen.V119.Data.World
import Evergreen.V119.Data.WorldData
import Evergreen.V119.Data.WorldInfo
import Evergreen.V119.Frontend.HoveredItem
import Evergreen.V119.Frontend.Route
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
    = LogMeIn (Evergreen.V119.Data.Auth.Auth Evergreen.V119.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V119.Data.Auth.Auth Evergreen.V119.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V119.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V119.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V119.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V119.Data.Item.Id
    | EquipWeapon Evergreen.V119.Data.Item.Id
    | PreferAmmo Evergreen.V119.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V119.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V119.Data.Skill.Skill
    | UseSkillPoints Evergreen.V119.Data.Skill.Skill
    | ChoosePerk Evergreen.V119.Data.Perk.Perk
    | MoveTo Evergreen.V119.Data.Map.TileCoords (Set.Set Evergreen.V119.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V119.Data.Message.Id
    | RemoveMessage Evergreen.V119.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V119.Data.Barter.State Evergreen.V119.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V119.Data.Quest.Name
    | StartProgressing Evergreen.V119.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V119.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V119.Data.Auth.Auth Evergreen.V119.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V119.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V119.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V119.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V119.Data.Map.TileCoords, Set.Set Evergreen.V119.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V119.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V119.Data.Fight.Info
    , barter : Evergreen.V119.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V119.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , lastTenToBackendMsgs : List ( Evergreen.V119.Data.Player.PlayerName.PlayerName, Evergreen.V119.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V119.Data.World.Name Evergreen.V119.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V119.Data.World.Name, Evergreen.V119.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V119.Data.Player.PlayerName.PlayerName, Evergreen.V119.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V119.Data.Item.Id Int
    | AddVendorItem Evergreen.V119.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V119.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V119.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V119.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V119.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V119.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V119.Frontend.Route.Route
    | GoToTownStore Evergreen.V119.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V119.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V119.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V119.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V119.Data.Item.Id
    | AskToEquipWeapon Evergreen.V119.Data.Item.Id
    | AskToPreferAmmo Evergreen.V119.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V119.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V119.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V119.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V119.Data.Special.Type
    | NewCharDecSpecial Evergreen.V119.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V119.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V119.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V119.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V119.Data.Message.Id
    | AskToRemoveMessage Evergreen.V119.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V119.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V119.Data.Quest.Name
    | CollapseQuestItem Evergreen.V119.Data.Quest.Name
    | AskToStopProgressing Evergreen.V119.Data.Quest.Name
    | AskToStartProgressing Evergreen.V119.Data.Quest.Name
    | FailedScrollToGuideSectionViaLink
    | ScrolledToGuideSectionViaLink Int
    | ScrolledToGuideSection String


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V119.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V119.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V119.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V119.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V119.Data.World.Name (List Evergreen.V119.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V119.Data.Player.PlayerName.PlayerName, Evergreen.V119.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V119.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V119.Data.Fight.Info, Evergreen.V119.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V119.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V119.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V119.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V119.Data.Player.CPlayer Evergreen.V119.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V119.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V119.Data.WorldData.PlayerData, Maybe Evergreen.V119.Data.Barter.Message )
    | BarterMessage Evergreen.V119.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V119.Data.Message.Id Evergreen.V119.Data.Message.Message)
