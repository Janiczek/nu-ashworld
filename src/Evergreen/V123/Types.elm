module Evergreen.V123.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V123.Data.Auth
import Evergreen.V123.Data.Barter
import Evergreen.V123.Data.Fight
import Evergreen.V123.Data.FightStrategy
import Evergreen.V123.Data.Item
import Evergreen.V123.Data.Item.Kind
import Evergreen.V123.Data.Map
import Evergreen.V123.Data.Message
import Evergreen.V123.Data.NewChar
import Evergreen.V123.Data.Perk
import Evergreen.V123.Data.Player
import Evergreen.V123.Data.Player.PlayerName
import Evergreen.V123.Data.Quest
import Evergreen.V123.Data.Skill
import Evergreen.V123.Data.Special
import Evergreen.V123.Data.Trait
import Evergreen.V123.Data.Vendor.Shop
import Evergreen.V123.Data.World
import Evergreen.V123.Data.WorldData
import Evergreen.V123.Data.WorldInfo
import Evergreen.V123.Frontend.HoveredItem
import Evergreen.V123.Frontend.Route
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
        { world : Evergreen.V123.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V123.Data.Auth.Auth Evergreen.V123.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V123.Data.Auth.Auth Evergreen.V123.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V123.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V123.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V123.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V123.Data.Item.Id
    | EquipWeapon Evergreen.V123.Data.Item.Id
    | PreferAmmo Evergreen.V123.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V123.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V123.Data.Skill.Skill
    | UseSkillPoints Evergreen.V123.Data.Skill.Skill
    | ChoosePerk Evergreen.V123.Data.Perk.Perk
    | MoveTo Evergreen.V123.Data.Map.TileCoords (Set.Set Evergreen.V123.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V123.Data.Message.Id
    | RemoveMessage Evergreen.V123.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V123.Data.Barter.State Evergreen.V123.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V123.Data.Quest.Name
    | StartProgressing Evergreen.V123.Data.Quest.Name
    | RefuelCar Evergreen.V123.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V123.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V123.Data.Auth.Auth Evergreen.V123.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V123.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V123.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V123.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V123.Data.Map.TileCoords, Set.Set Evergreen.V123.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V123.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V123.Data.Fight.Info
    , barter : Evergreen.V123.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V123.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V123.Data.Player.PlayerName.PlayerName, Evergreen.V123.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V123.Data.World.Name Evergreen.V123.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V123.Data.World.Name, Evergreen.V123.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V123.Data.Player.PlayerName.PlayerName, Evergreen.V123.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V123.Data.Item.Id Int
    | AddVendorItem Evergreen.V123.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V123.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V123.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V123.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V123.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V123.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V123.Frontend.Route.Route
    | GoToTownStore Evergreen.V123.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V123.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V123.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V123.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V123.Data.Item.Id
    | AskToEquipWeapon Evergreen.V123.Data.Item.Id
    | AskToPreferAmmo Evergreen.V123.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V123.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V123.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V123.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V123.Data.Special.Type
    | NewCharDecSpecial Evergreen.V123.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V123.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V123.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V123.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V123.Data.Message.Id
    | AskToRemoveMessage Evergreen.V123.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V123.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V123.Data.Quest.Name
    | CollapseQuestItem Evergreen.V123.Data.Quest.Name
    | AskToStopProgressing Evergreen.V123.Data.Quest.Name
    | AskToStartProgressing Evergreen.V123.Data.Quest.Name
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V123.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V123.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V123.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V123.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V123.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V123.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V123.Data.World.Name (List Evergreen.V123.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V123.Data.Player.PlayerName.PlayerName, Evergreen.V123.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V123.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V123.Data.Fight.Info, Evergreen.V123.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V123.Data.WorldData.PlayerData
    | YoureSignedUp Evergreen.V123.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V123.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V123.Data.Player.CPlayer Evergreen.V123.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V123.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V123.Data.WorldData.PlayerData, Maybe Evergreen.V123.Data.Barter.Message )
    | BarterMessage Evergreen.V123.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V123.Data.Message.Id Evergreen.V123.Data.Message.Message)
