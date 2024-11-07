module Evergreen.V133.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V133.Data.Auth
import Evergreen.V133.Data.Barter
import Evergreen.V133.Data.Fight
import Evergreen.V133.Data.FightStrategy
import Evergreen.V133.Data.Item
import Evergreen.V133.Data.Item.Kind
import Evergreen.V133.Data.Map
import Evergreen.V133.Data.Message
import Evergreen.V133.Data.NewChar
import Evergreen.V133.Data.Perk
import Evergreen.V133.Data.Player
import Evergreen.V133.Data.Player.PlayerName
import Evergreen.V133.Data.Quest
import Evergreen.V133.Data.Skill
import Evergreen.V133.Data.Special
import Evergreen.V133.Data.Trait
import Evergreen.V133.Data.Vendor.Shop
import Evergreen.V133.Data.World
import Evergreen.V133.Data.WorldData
import Evergreen.V133.Data.WorldInfo
import Evergreen.V133.Frontend.HoveredItem
import Evergreen.V133.Frontend.Route
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
        { world : Evergreen.V133.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V133.Data.Auth.Auth Evergreen.V133.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V133.Data.Auth.Auth Evergreen.V133.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V133.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V133.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V133.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V133.Data.Item.Id
    | EquipWeapon Evergreen.V133.Data.Item.Id
    | PreferAmmo Evergreen.V133.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V133.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V133.Data.Skill.Skill
    | UseSkillPoints Evergreen.V133.Data.Skill.Skill
    | ChoosePerk Evergreen.V133.Data.Perk.Perk
    | MoveTo Evergreen.V133.Data.Map.TileCoords (Set.Set Evergreen.V133.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V133.Data.Message.Id
    | RemoveMessage Evergreen.V133.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V133.Data.Barter.State Evergreen.V133.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V133.Data.Quest.Quest
    | StartProgressing Evergreen.V133.Data.Quest.Quest
    | RefuelCar Evergreen.V133.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V133.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V133.Data.Auth.Auth Evergreen.V133.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V133.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V133.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V133.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V133.Data.Map.TileCoords
            , path : Set.Set Evergreen.V133.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V133.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V133.Data.Fight.Info
    , barter : Evergreen.V133.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V133.Data.Quest.Quest
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V133.Data.Player.PlayerName.PlayerName, Evergreen.V133.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V133.Data.World.Name Evergreen.V133.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V133.Data.World.Name, Evergreen.V133.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V133.Data.Player.PlayerName.PlayerName, Evergreen.V133.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V133.Data.Item.Id Int
    | AddVendorItem Evergreen.V133.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V133.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V133.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V133.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V133.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V133.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V133.Frontend.Route.Route
    | GoToTownStore Evergreen.V133.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V133.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V133.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V133.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V133.Data.Item.Id
    | AskToEquipWeapon Evergreen.V133.Data.Item.Id
    | AskToPreferAmmo Evergreen.V133.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V133.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V133.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V133.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V133.Data.Special.Type
    | NewCharDecSpecial Evergreen.V133.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V133.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V133.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V133.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V133.Data.Message.Id
    | AskToRemoveMessage Evergreen.V133.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V133.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V133.Data.Quest.Quest
    | CollapseQuestItem Evergreen.V133.Data.Quest.Quest
    | AskToStopProgressing Evergreen.V133.Data.Quest.Quest
    | AskToStartProgressing Evergreen.V133.Data.Quest.Quest
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V133.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V133.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V133.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V133.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V133.Data.Player.COtherPlayer)
    | CurrentWorlds (List Evergreen.V133.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V133.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V133.Data.World.Name (List Evergreen.V133.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V133.Data.Player.PlayerName.PlayerName, Evergreen.V133.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V133.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V133.Data.Fight.Info, Evergreen.V133.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V133.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V133.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V133.Data.Player.CPlayer Evergreen.V133.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V133.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V133.Data.WorldData.PlayerData, Maybe Evergreen.V133.Data.Barter.Message )
    | BarterMessage Evergreen.V133.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V133.Data.Message.Id Evergreen.V133.Data.Message.Message)
