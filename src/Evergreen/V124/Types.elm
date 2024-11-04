module Evergreen.V124.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V124.Data.Auth
import Evergreen.V124.Data.Barter
import Evergreen.V124.Data.Fight
import Evergreen.V124.Data.FightStrategy
import Evergreen.V124.Data.Item
import Evergreen.V124.Data.Item.Kind
import Evergreen.V124.Data.Map
import Evergreen.V124.Data.Message
import Evergreen.V124.Data.NewChar
import Evergreen.V124.Data.Perk
import Evergreen.V124.Data.Player
import Evergreen.V124.Data.Player.PlayerName
import Evergreen.V124.Data.Quest
import Evergreen.V124.Data.Skill
import Evergreen.V124.Data.Special
import Evergreen.V124.Data.Trait
import Evergreen.V124.Data.Vendor.Shop
import Evergreen.V124.Data.World
import Evergreen.V124.Data.WorldData
import Evergreen.V124.Data.WorldInfo
import Evergreen.V124.Frontend.HoveredItem
import Evergreen.V124.Frontend.Route
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
    | ChangeWorldSpeed
        { world : Evergreen.V124.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V124.Data.Auth.Auth Evergreen.V124.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V124.Data.Auth.Auth Evergreen.V124.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V124.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V124.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V124.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V124.Data.Item.Id
    | EquipWeapon Evergreen.V124.Data.Item.Id
    | PreferAmmo Evergreen.V124.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V124.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V124.Data.Skill.Skill
    | UseSkillPoints Evergreen.V124.Data.Skill.Skill
    | ChoosePerk Evergreen.V124.Data.Perk.Perk
    | MoveTo Evergreen.V124.Data.Map.TileCoords (Set.Set Evergreen.V124.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V124.Data.Message.Id
    | RemoveMessage Evergreen.V124.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V124.Data.Barter.State Evergreen.V124.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V124.Data.Quest.Name
    | StartProgressing Evergreen.V124.Data.Quest.Name
    | RefuelCar Evergreen.V124.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V124.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V124.Data.Auth.Auth Evergreen.V124.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V124.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V124.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V124.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V124.Data.Map.TileCoords, Set.Set Evergreen.V124.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V124.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V124.Data.Fight.Info
    , barter : Evergreen.V124.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V124.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V124.Data.Player.PlayerName.PlayerName, Evergreen.V124.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V124.Data.World.Name Evergreen.V124.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V124.Data.World.Name, Evergreen.V124.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V124.Data.Player.PlayerName.PlayerName, Evergreen.V124.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V124.Data.Item.Id Int
    | AddVendorItem Evergreen.V124.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V124.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V124.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V124.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V124.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V124.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V124.Frontend.Route.Route
    | GoToTownStore Evergreen.V124.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V124.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V124.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V124.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V124.Data.Item.Id
    | AskToEquipWeapon Evergreen.V124.Data.Item.Id
    | AskToPreferAmmo Evergreen.V124.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V124.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V124.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V124.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V124.Data.Special.Type
    | NewCharDecSpecial Evergreen.V124.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V124.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V124.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V124.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V124.Data.Message.Id
    | AskToRemoveMessage Evergreen.V124.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V124.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V124.Data.Quest.Name
    | CollapseQuestItem Evergreen.V124.Data.Quest.Name
    | AskToStopProgressing Evergreen.V124.Data.Quest.Name
    | AskToStartProgressing Evergreen.V124.Data.Quest.Name
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V124.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V124.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V124.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V124.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V124.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V124.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V124.Data.World.Name (List Evergreen.V124.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V124.Data.Player.PlayerName.PlayerName, Evergreen.V124.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V124.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V124.Data.Fight.Info, Evergreen.V124.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V124.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V124.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V124.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V124.Data.Player.CPlayer Evergreen.V124.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V124.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V124.Data.WorldData.PlayerData, Maybe Evergreen.V124.Data.Barter.Message )
    | BarterMessage Evergreen.V124.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V124.Data.Message.Id Evergreen.V124.Data.Message.Message)
