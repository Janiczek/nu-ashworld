module Evergreen.V135.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V135.Data.Auth
import Evergreen.V135.Data.Barter
import Evergreen.V135.Data.Fight
import Evergreen.V135.Data.FightStrategy
import Evergreen.V135.Data.Item
import Evergreen.V135.Data.Item.Kind
import Evergreen.V135.Data.Map
import Evergreen.V135.Data.Message
import Evergreen.V135.Data.NewChar
import Evergreen.V135.Data.Perk
import Evergreen.V135.Data.Player
import Evergreen.V135.Data.Player.PlayerName
import Evergreen.V135.Data.Quest
import Evergreen.V135.Data.Skill
import Evergreen.V135.Data.Special
import Evergreen.V135.Data.Trait
import Evergreen.V135.Data.Vendor.Shop
import Evergreen.V135.Data.World
import Evergreen.V135.Data.WorldData
import Evergreen.V135.Data.WorldInfo
import Evergreen.V135.Frontend.HoveredItem
import Evergreen.V135.Frontend.Route
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
        { world : Evergreen.V135.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V135.Data.Auth.Auth Evergreen.V135.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V135.Data.Auth.Auth Evergreen.V135.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V135.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V135.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V135.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V135.Data.Item.Id
    | EquipWeapon Evergreen.V135.Data.Item.Id
    | PreferAmmo Evergreen.V135.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V135.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V135.Data.Skill.Skill
    | UseSkillPoints Evergreen.V135.Data.Skill.Skill
    | ChoosePerk Evergreen.V135.Data.Perk.Perk
    | MoveTo Evergreen.V135.Data.Map.TileCoords (Set.Set Evergreen.V135.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V135.Data.Message.Id
    | RemoveMessage Evergreen.V135.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V135.Data.Barter.State Evergreen.V135.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V135.Data.Quest.Quest
    | StartProgressing Evergreen.V135.Data.Quest.Quest
    | RefuelCar Evergreen.V135.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V135.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V135.Data.Auth.Auth Evergreen.V135.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V135.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V135.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V135.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V135.Data.Map.TileCoords
            , path : Set.Set Evergreen.V135.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V135.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V135.Data.Fight.Info
    , barter : Evergreen.V135.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V135.Data.Quest.Quest
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V135.Data.Player.PlayerName.PlayerName, Evergreen.V135.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V135.Data.World.Name Evergreen.V135.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V135.Data.World.Name, Evergreen.V135.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V135.Data.Player.PlayerName.PlayerName, Evergreen.V135.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V135.Data.Item.Id Int
    | AddVendorItem Evergreen.V135.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V135.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V135.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V135.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V135.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V135.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V135.Frontend.Route.Route
    | GoToTownStore Evergreen.V135.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V135.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V135.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V135.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V135.Data.Item.Id
    | AskToEquipWeapon Evergreen.V135.Data.Item.Id
    | AskToPreferAmmo Evergreen.V135.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V135.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V135.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V135.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V135.Data.Special.Type
    | NewCharDecSpecial Evergreen.V135.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V135.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V135.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V135.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V135.Data.Message.Id
    | AskToRemoveMessage Evergreen.V135.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V135.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V135.Data.Quest.Quest
    | CollapseQuestItem Evergreen.V135.Data.Quest.Quest
    | AskToStopProgressing Evergreen.V135.Data.Quest.Quest
    | AskToStartProgressing Evergreen.V135.Data.Quest.Quest
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V135.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V135.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V135.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V135.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V135.Data.Player.COtherPlayer)
    | CurrentWorlds (List Evergreen.V135.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V135.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V135.Data.World.Name (List Evergreen.V135.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V135.Data.Player.PlayerName.PlayerName, Evergreen.V135.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V135.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V135.Data.Fight.Info, Evergreen.V135.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V135.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V135.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V135.Data.Player.CPlayer Evergreen.V135.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V135.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V135.Data.WorldData.PlayerData, Maybe Evergreen.V135.Data.Barter.Message )
    | BarterMessage Evergreen.V135.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V135.Data.Message.Id Evergreen.V135.Data.Message.Message)
