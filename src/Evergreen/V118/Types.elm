module Evergreen.V118.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V118.Data.Auth
import Evergreen.V118.Data.Barter
import Evergreen.V118.Data.Fight
import Evergreen.V118.Data.FightStrategy
import Evergreen.V118.Data.Item
import Evergreen.V118.Data.Item.Kind
import Evergreen.V118.Data.Map
import Evergreen.V118.Data.Message
import Evergreen.V118.Data.NewChar
import Evergreen.V118.Data.Perk
import Evergreen.V118.Data.Player
import Evergreen.V118.Data.Player.PlayerName
import Evergreen.V118.Data.Quest
import Evergreen.V118.Data.Skill
import Evergreen.V118.Data.Special
import Evergreen.V118.Data.Trait
import Evergreen.V118.Data.Vendor.Shop
import Evergreen.V118.Data.World
import Evergreen.V118.Data.WorldData
import Evergreen.V118.Data.WorldInfo
import Evergreen.V118.Frontend.HoveredItem
import Evergreen.V118.Frontend.Route
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
    = LogMeIn (Evergreen.V118.Data.Auth.Auth Evergreen.V118.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V118.Data.Auth.Auth Evergreen.V118.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V118.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V118.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V118.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V118.Data.Item.Id
    | EquipWeapon Evergreen.V118.Data.Item.Id
    | PreferAmmo Evergreen.V118.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V118.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V118.Data.Skill.Skill
    | UseSkillPoints Evergreen.V118.Data.Skill.Skill
    | ChoosePerk Evergreen.V118.Data.Perk.Perk
    | MoveTo Evergreen.V118.Data.Map.TileCoords (Set.Set Evergreen.V118.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V118.Data.Message.Id
    | RemoveMessage Evergreen.V118.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V118.Data.Barter.State Evergreen.V118.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V118.Data.Quest.Name
    | StartProgressing Evergreen.V118.Data.Quest.Name


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V118.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V118.Data.Auth.Auth Evergreen.V118.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V118.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V118.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V118.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V118.Data.Map.TileCoords, Set.Set Evergreen.V118.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V118.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V118.Data.Fight.Info
    , barter : Evergreen.V118.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V118.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V118.Data.Player.PlayerName.PlayerName, Evergreen.V118.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V118.Data.World.Name Evergreen.V118.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V118.Data.World.Name, Evergreen.V118.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V118.Data.Player.PlayerName.PlayerName, Evergreen.V118.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V118.Data.Item.Id Int
    | AddVendorItem Evergreen.V118.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V118.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V118.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V118.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V118.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V118.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V118.Frontend.Route.Route
    | GoToTownStore Evergreen.V118.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V118.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V118.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V118.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V118.Data.Item.Id
    | AskToEquipWeapon Evergreen.V118.Data.Item.Id
    | AskToPreferAmmo Evergreen.V118.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V118.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V118.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V118.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V118.Data.Special.Type
    | NewCharDecSpecial Evergreen.V118.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V118.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V118.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V118.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V118.Data.Message.Id
    | AskToRemoveMessage Evergreen.V118.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V118.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V118.Data.Quest.Name
    | CollapseQuestItem Evergreen.V118.Data.Quest.Name
    | AskToStopProgressing Evergreen.V118.Data.Quest.Name
    | AskToStartProgressing Evergreen.V118.Data.Quest.Name


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V118.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V118.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V118.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V118.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V118.Data.World.Name (List Evergreen.V118.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V118.Data.Player.PlayerName.PlayerName, Evergreen.V118.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V118.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V118.Data.Fight.Info, Evergreen.V118.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V118.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V118.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V118.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V118.Data.Player.CPlayer Evergreen.V118.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V118.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V118.Data.WorldData.PlayerData, Maybe Evergreen.V118.Data.Barter.Message )
    | BarterMessage Evergreen.V118.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V118.Data.Message.Id Evergreen.V118.Data.Message.Message)
