module Evergreen.V137.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V137.Data.Auth
import Evergreen.V137.Data.Barter
import Evergreen.V137.Data.Fight
import Evergreen.V137.Data.FightStrategy
import Evergreen.V137.Data.Item
import Evergreen.V137.Data.Item.Kind
import Evergreen.V137.Data.Map
import Evergreen.V137.Data.Message
import Evergreen.V137.Data.NewChar
import Evergreen.V137.Data.Perk
import Evergreen.V137.Data.Player
import Evergreen.V137.Data.Player.PlayerName
import Evergreen.V137.Data.Quest
import Evergreen.V137.Data.Skill
import Evergreen.V137.Data.Special
import Evergreen.V137.Data.Trait
import Evergreen.V137.Data.Vendor.Shop
import Evergreen.V137.Data.World
import Evergreen.V137.Data.WorldData
import Evergreen.V137.Data.WorldInfo
import Evergreen.V137.Frontend.HoveredItem
import Evergreen.V137.Frontend.Route
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
        { world : Evergreen.V137.Data.World.Name
        , fast : Bool
        }
    | SwitchMaintenance
        { now : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V137.Data.Auth.Auth Evergreen.V137.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V137.Data.Auth.Auth Evergreen.V137.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V137.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V137.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V137.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V137.Data.Item.Id
    | EquipWeapon Evergreen.V137.Data.Item.Id
    | PreferAmmo Evergreen.V137.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V137.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V137.Data.Skill.Skill
    | UseSkillPoints Evergreen.V137.Data.Skill.Skill
    | ChoosePerk Evergreen.V137.Data.Perk.Perk
    | MoveTo Evergreen.V137.Data.Map.TileCoords (Set.Set Evergreen.V137.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V137.Data.Message.Id
    | RemoveMessage Evergreen.V137.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V137.Data.Barter.State Evergreen.V137.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V137.Data.Quest.Quest
    | StartProgressing Evergreen.V137.Data.Quest.Quest
    | RefuelCar Evergreen.V137.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V137.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V137.Data.Auth.Auth Evergreen.V137.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V137.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V137.Data.WorldData.WorldData
    , isInMaintenance : Bool
    , alertMessage : Maybe String
    , newChar : Evergreen.V137.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V137.Data.Map.TileCoords
            , path : Set.Set Evergreen.V137.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V137.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V137.Data.Fight.Info
    , barter : Evergreen.V137.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V137.Data.Quest.Quest
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V137.Data.Player.PlayerName.PlayerName, Evergreen.V137.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V137.Data.World.Name Evergreen.V137.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V137.Data.World.Name, Evergreen.V137.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V137.Data.Player.PlayerName.PlayerName, Evergreen.V137.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    , isInMaintenance : Bool
    }


type BarterMsg
    = AddPlayerItem Evergreen.V137.Data.Item.Id Int
    | AddVendorItem Evergreen.V137.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V137.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V137.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V137.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V137.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V137.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V137.Frontend.Route.Route
    | GoToTownStore Evergreen.V137.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V137.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V137.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V137.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V137.Data.Item.Id
    | AskToEquipWeapon Evergreen.V137.Data.Item.Id
    | AskToPreferAmmo Evergreen.V137.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V137.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V137.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V137.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V137.Data.Special.Type
    | NewCharDecSpecial Evergreen.V137.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V137.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V137.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V137.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V137.Data.Message.Id
    | AskToRemoveMessage Evergreen.V137.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V137.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V137.Data.Quest.Quest
    | CollapseQuestItem Evergreen.V137.Data.Quest.Quest
    | AskToStopProgressing Evergreen.V137.Data.Quest.Quest
    | AskToStartProgressing Evergreen.V137.Data.Quest.Quest
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V137.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V137.Data.World.Name
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
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V137.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V137.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V137.Data.Player.COtherPlayer)
    | CurrentWorlds
        { worlds : List Evergreen.V137.Data.WorldInfo.WorldInfo
        , isInMaintenance : Bool
        }
    | CurrentAdmin Evergreen.V137.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V137.Data.World.Name (List Evergreen.V137.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V137.Data.Player.PlayerName.PlayerName, Evergreen.V137.Data.World.Name, ToBackend ))
    | MaintenanceModeChanged
        { now : Bool
        }
    | YoureLoggedOut (List Evergreen.V137.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V137.Data.Fight.Info, Evergreen.V137.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V137.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V137.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V137.Data.Player.CPlayer Evergreen.V137.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V137.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V137.Data.WorldData.PlayerData, Maybe Evergreen.V137.Data.Barter.Message )
    | BarterMessage Evergreen.V137.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V137.Data.Message.Id Evergreen.V137.Data.Message.Message)
