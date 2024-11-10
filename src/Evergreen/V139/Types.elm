module Evergreen.V139.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V139.Data.Auth
import Evergreen.V139.Data.Barter
import Evergreen.V139.Data.Fight
import Evergreen.V139.Data.FightStrategy
import Evergreen.V139.Data.Item
import Evergreen.V139.Data.Item.Kind
import Evergreen.V139.Data.Map
import Evergreen.V139.Data.Message
import Evergreen.V139.Data.NewChar
import Evergreen.V139.Data.Perk
import Evergreen.V139.Data.Player
import Evergreen.V139.Data.Player.PlayerName
import Evergreen.V139.Data.Quest
import Evergreen.V139.Data.Skill
import Evergreen.V139.Data.Special
import Evergreen.V139.Data.Trait
import Evergreen.V139.Data.Vendor.Shop
import Evergreen.V139.Data.World
import Evergreen.V139.Data.WorldData
import Evergreen.V139.Data.WorldInfo
import Evergreen.V139.Frontend.HoveredItem
import Evergreen.V139.Frontend.Route
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
        { world : Evergreen.V139.Data.World.Name
        , fast : Bool
        }
    | SwitchMaintenance
        { now : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V139.Data.Auth.Auth Evergreen.V139.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V139.Data.Auth.Auth Evergreen.V139.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V139.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V139.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V139.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V139.Data.Item.Id
    | EquipWeapon Evergreen.V139.Data.Item.Id
    | PreferAmmo Evergreen.V139.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V139.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V139.Data.Skill.Skill
    | UseSkillPoints Evergreen.V139.Data.Skill.Skill
    | ChoosePerk Evergreen.V139.Data.Perk.Perk
    | MoveTo Evergreen.V139.Data.Map.TileCoords (Set.Set Evergreen.V139.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V139.Data.Message.Id
    | RemoveMessage Evergreen.V139.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V139.Data.Barter.State Evergreen.V139.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V139.Data.Quest.Quest
    | StartProgressing Evergreen.V139.Data.Quest.Quest
    | RefuelCar Evergreen.V139.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V139.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V139.Data.Auth.Auth Evergreen.V139.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V139.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V139.Data.WorldData.WorldData
    , isInMaintenance : Bool
    , alertMessage : Maybe String
    , newChar : Evergreen.V139.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V139.Data.Map.TileCoords
            , path : Set.Set Evergreen.V139.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V139.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V139.Data.Fight.Info
    , barter : Evergreen.V139.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V139.Data.Quest.Quest
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V139.Data.Player.PlayerName.PlayerName, Evergreen.V139.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V139.Data.World.Name Evergreen.V139.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V139.Data.World.Name, Evergreen.V139.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V139.Data.Player.PlayerName.PlayerName, Evergreen.V139.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    , isInMaintenance : Bool
    }


type BarterMsg
    = AddPlayerItem Evergreen.V139.Data.Item.Id Int
    | AddVendorItem Evergreen.V139.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V139.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V139.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V139.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V139.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V139.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V139.Frontend.Route.Route
    | GoToTownStore Evergreen.V139.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V139.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V139.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V139.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V139.Data.Item.Id
    | AskToEquipWeapon Evergreen.V139.Data.Item.Id
    | AskToPreferAmmo Evergreen.V139.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V139.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V139.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V139.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V139.Data.Special.Type
    | NewCharDecSpecial Evergreen.V139.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V139.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V139.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V139.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V139.Data.Message.Id
    | AskToRemoveMessage Evergreen.V139.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V139.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V139.Data.Quest.Quest
    | CollapseQuestItem Evergreen.V139.Data.Quest.Quest
    | AskToStopProgressing Evergreen.V139.Data.Quest.Quest
    | AskToStartProgressing Evergreen.V139.Data.Quest.Quest
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V139.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V139.Data.World.Name
        , fast : Bool
        }
    | AskToSwitchMaintenance
        { now : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V139.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V139.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V139.Data.Player.COtherPlayer)
    | CurrentWorlds
        { worlds : List Evergreen.V139.Data.WorldInfo.WorldInfo
        , isInMaintenance : Bool
        }
    | CurrentAdmin Evergreen.V139.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V139.Data.World.Name (List Evergreen.V139.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V139.Data.Player.PlayerName.PlayerName, Evergreen.V139.Data.World.Name, ToBackend ))
    | MaintenanceModeChanged
        { now : Bool
        }
    | YoureLoggedOut (List Evergreen.V139.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V139.Data.Fight.Info, Evergreen.V139.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V139.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V139.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V139.Data.Player.CPlayer Evergreen.V139.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V139.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V139.Data.WorldData.PlayerData, Maybe Evergreen.V139.Data.Barter.Message )
    | BarterMessage Evergreen.V139.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V139.Data.Message.Id Evergreen.V139.Data.Message.Message)
