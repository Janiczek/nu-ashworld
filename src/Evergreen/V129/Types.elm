module Evergreen.V129.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V129.Data.Auth
import Evergreen.V129.Data.Barter
import Evergreen.V129.Data.Fight
import Evergreen.V129.Data.FightStrategy
import Evergreen.V129.Data.Item
import Evergreen.V129.Data.Item.Kind
import Evergreen.V129.Data.Map
import Evergreen.V129.Data.Message
import Evergreen.V129.Data.NewChar
import Evergreen.V129.Data.Perk
import Evergreen.V129.Data.Player
import Evergreen.V129.Data.Player.PlayerName
import Evergreen.V129.Data.Quest
import Evergreen.V129.Data.Skill
import Evergreen.V129.Data.Special
import Evergreen.V129.Data.Trait
import Evergreen.V129.Data.Vendor.Shop
import Evergreen.V129.Data.World
import Evergreen.V129.Data.WorldData
import Evergreen.V129.Data.WorldInfo
import Evergreen.V129.Frontend.HoveredItem
import Evergreen.V129.Frontend.Route
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
        { world : Evergreen.V129.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V129.Data.Auth.Auth Evergreen.V129.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V129.Data.Auth.Auth Evergreen.V129.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V129.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V129.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V129.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V129.Data.Item.Id
    | EquipWeapon Evergreen.V129.Data.Item.Id
    | PreferAmmo Evergreen.V129.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V129.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V129.Data.Skill.Skill
    | UseSkillPoints Evergreen.V129.Data.Skill.Skill
    | ChoosePerk Evergreen.V129.Data.Perk.Perk
    | MoveTo Evergreen.V129.Data.Map.TileCoords (Set.Set Evergreen.V129.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V129.Data.Message.Id
    | RemoveMessage Evergreen.V129.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V129.Data.Barter.State Evergreen.V129.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V129.Data.Quest.Name
    | StartProgressing Evergreen.V129.Data.Quest.Name
    | RefuelCar Evergreen.V129.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V129.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V129.Data.Auth.Auth Evergreen.V129.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V129.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V129.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V129.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V129.Data.Map.TileCoords
            , path : Set.Set Evergreen.V129.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V129.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V129.Data.Fight.Info
    , barter : Evergreen.V129.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V129.Data.Quest.Name
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V129.Data.Player.PlayerName.PlayerName, Evergreen.V129.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V129.Data.World.Name Evergreen.V129.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V129.Data.World.Name, Evergreen.V129.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V129.Data.Player.PlayerName.PlayerName, Evergreen.V129.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V129.Data.Item.Id Int
    | AddVendorItem Evergreen.V129.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V129.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V129.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V129.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V129.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V129.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V129.Frontend.Route.Route
    | GoToTownStore Evergreen.V129.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V129.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V129.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V129.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V129.Data.Item.Id
    | AskToEquipWeapon Evergreen.V129.Data.Item.Id
    | AskToPreferAmmo Evergreen.V129.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V129.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V129.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V129.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V129.Data.Special.Type
    | NewCharDecSpecial Evergreen.V129.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V129.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V129.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V129.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V129.Data.Message.Id
    | AskToRemoveMessage Evergreen.V129.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V129.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V129.Data.Quest.Name
    | CollapseQuestItem Evergreen.V129.Data.Quest.Name
    | AskToStopProgressing Evergreen.V129.Data.Quest.Name
    | AskToStartProgressing Evergreen.V129.Data.Quest.Name
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V129.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V129.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V129.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V129.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V129.Data.Player.COtherPlayer)
    | CurrentWorlds (List Evergreen.V129.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V129.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V129.Data.World.Name (List Evergreen.V129.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V129.Data.Player.PlayerName.PlayerName, Evergreen.V129.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V129.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V129.Data.Fight.Info, Evergreen.V129.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V129.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V129.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V129.Data.Player.CPlayer Evergreen.V129.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V129.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V129.Data.WorldData.PlayerData, Maybe Evergreen.V129.Data.Barter.Message )
    | BarterMessage Evergreen.V129.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V129.Data.Message.Id Evergreen.V129.Data.Message.Message)
