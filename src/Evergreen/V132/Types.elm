module Evergreen.V132.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V132.Data.Auth
import Evergreen.V132.Data.Barter
import Evergreen.V132.Data.Fight
import Evergreen.V132.Data.FightStrategy
import Evergreen.V132.Data.Item
import Evergreen.V132.Data.Item.Kind
import Evergreen.V132.Data.Map
import Evergreen.V132.Data.Message
import Evergreen.V132.Data.NewChar
import Evergreen.V132.Data.Perk
import Evergreen.V132.Data.Player
import Evergreen.V132.Data.Player.PlayerName
import Evergreen.V132.Data.Quest
import Evergreen.V132.Data.Skill
import Evergreen.V132.Data.Special
import Evergreen.V132.Data.Trait
import Evergreen.V132.Data.Vendor.Shop
import Evergreen.V132.Data.World
import Evergreen.V132.Data.WorldData
import Evergreen.V132.Data.WorldInfo
import Evergreen.V132.Frontend.HoveredItem
import Evergreen.V132.Frontend.Route
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
        { world : Evergreen.V132.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V132.Data.Auth.Auth Evergreen.V132.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V132.Data.Auth.Auth Evergreen.V132.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V132.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V132.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V132.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V132.Data.Item.Id
    | EquipWeapon Evergreen.V132.Data.Item.Id
    | PreferAmmo Evergreen.V132.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V132.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V132.Data.Skill.Skill
    | UseSkillPoints Evergreen.V132.Data.Skill.Skill
    | ChoosePerk Evergreen.V132.Data.Perk.Perk
    | MoveTo Evergreen.V132.Data.Map.TileCoords (Set.Set Evergreen.V132.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V132.Data.Message.Id
    | RemoveMessage Evergreen.V132.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V132.Data.Barter.State Evergreen.V132.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V132.Data.Quest.Quest
    | StartProgressing Evergreen.V132.Data.Quest.Quest
    | RefuelCar Evergreen.V132.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V132.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V132.Data.Auth.Auth Evergreen.V132.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V132.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V132.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V132.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V132.Data.Map.TileCoords
            , path : Set.Set Evergreen.V132.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V132.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V132.Data.Fight.Info
    , barter : Evergreen.V132.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V132.Data.Quest.Quest
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V132.Data.Player.PlayerName.PlayerName, Evergreen.V132.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V132.Data.World.Name Evergreen.V132.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V132.Data.World.Name, Evergreen.V132.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V132.Data.Player.PlayerName.PlayerName, Evergreen.V132.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V132.Data.Item.Id Int
    | AddVendorItem Evergreen.V132.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V132.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V132.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V132.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V132.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V132.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V132.Frontend.Route.Route
    | GoToTownStore Evergreen.V132.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V132.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V132.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V132.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V132.Data.Item.Id
    | AskToEquipWeapon Evergreen.V132.Data.Item.Id
    | AskToPreferAmmo Evergreen.V132.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V132.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V132.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V132.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V132.Data.Special.Type
    | NewCharDecSpecial Evergreen.V132.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V132.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V132.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V132.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V132.Data.Message.Id
    | AskToRemoveMessage Evergreen.V132.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V132.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V132.Data.Quest.Quest
    | CollapseQuestItem Evergreen.V132.Data.Quest.Quest
    | AskToStopProgressing Evergreen.V132.Data.Quest.Quest
    | AskToStartProgressing Evergreen.V132.Data.Quest.Quest
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V132.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V132.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V132.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V132.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V132.Data.Player.COtherPlayer)
    | CurrentWorlds (List Evergreen.V132.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V132.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V132.Data.World.Name (List Evergreen.V132.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V132.Data.Player.PlayerName.PlayerName, Evergreen.V132.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V132.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V132.Data.Fight.Info, Evergreen.V132.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V132.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V132.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V132.Data.Player.CPlayer Evergreen.V132.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V132.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V132.Data.WorldData.PlayerData, Maybe Evergreen.V132.Data.Barter.Message )
    | BarterMessage Evergreen.V132.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V132.Data.Message.Id Evergreen.V132.Data.Message.Message)
