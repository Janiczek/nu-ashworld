module Evergreen.V136.Types exposing (..)

import BiDict
import Browser
import Browser.Navigation
import Dict
import Evergreen.V136.Data.Auth
import Evergreen.V136.Data.Barter
import Evergreen.V136.Data.Fight
import Evergreen.V136.Data.FightStrategy
import Evergreen.V136.Data.Item
import Evergreen.V136.Data.Item.Kind
import Evergreen.V136.Data.Map
import Evergreen.V136.Data.Message
import Evergreen.V136.Data.NewChar
import Evergreen.V136.Data.Perk
import Evergreen.V136.Data.Player
import Evergreen.V136.Data.Player.PlayerName
import Evergreen.V136.Data.Quest
import Evergreen.V136.Data.Skill
import Evergreen.V136.Data.Special
import Evergreen.V136.Data.Trait
import Evergreen.V136.Data.Vendor.Shop
import Evergreen.V136.Data.World
import Evergreen.V136.Data.WorldData
import Evergreen.V136.Data.WorldInfo
import Evergreen.V136.Frontend.HoveredItem
import Evergreen.V136.Frontend.Route
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
        { world : Evergreen.V136.Data.World.Name
        , fast : Bool
        }


type ToBackend
    = LogMeIn (Evergreen.V136.Data.Auth.Auth Evergreen.V136.Data.Auth.Hashed)
    | SignMeUp (Evergreen.V136.Data.Auth.Auth Evergreen.V136.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V136.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V136.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V136.Data.Item.Id
    | Wander
    | EquipArmor Evergreen.V136.Data.Item.Id
    | EquipWeapon Evergreen.V136.Data.Item.Id
    | PreferAmmo Evergreen.V136.Data.Item.Kind.Kind
    | SetFightStrategy ( Evergreen.V136.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Evergreen.V136.Data.Skill.Skill
    | UseSkillPoints Evergreen.V136.Data.Skill.Skill
    | ChoosePerk Evergreen.V136.Data.Perk.Perk
    | MoveTo Evergreen.V136.Data.Map.TileCoords (Set.Set Evergreen.V136.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V136.Data.Message.Id
    | RemoveMessage Evergreen.V136.Data.Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Evergreen.V136.Data.Barter.State Evergreen.V136.Data.Vendor.Shop.Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Evergreen.V136.Data.Quest.Quest
    | StartProgressing Evergreen.V136.Data.Quest.Quest
    | RefuelCar Evergreen.V136.Data.Item.Kind.Kind


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V136.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V136.Data.Auth.Auth Evergreen.V136.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V136.Data.WorldInfo.WorldInfo)
    , worldData : Evergreen.V136.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V136.Data.NewChar.NewChar
    , mapMouseCoords :
        Maybe
            { coords : Evergreen.V136.Data.Map.TileCoords
            , path : Set.Set Evergreen.V136.Data.Map.TileCoords
            }
    , hoveredItem : Maybe Evergreen.V136.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V136.Data.Fight.Info
    , barter : Evergreen.V136.Data.Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet.SeqSet Evergreen.V136.Data.Quest.Quest
    , userWantsToShowAreaDanger : Bool
    , lastGuideTocSectionClick : Int
    , hoveredGuideNavLink : Bool
    , lastTenToBackendMsgs : List ( Evergreen.V136.Data.Player.PlayerName.PlayerName, Evergreen.V136.Data.World.Name, ToBackend )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V136.Data.World.Name Evergreen.V136.Data.World.World
    , time : Time.Posix
    , loggedInPlayers : BiDict.BiDict Lamdera.ClientId ( Evergreen.V136.Data.World.Name, Evergreen.V136.Data.Player.PlayerName.PlayerName )
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V136.Data.Player.PlayerName.PlayerName, Evergreen.V136.Data.World.Name, ToBackend )
    , randomSeed : Random.Seed
    , playerDataCache : Dict.Dict Lamdera.ClientId Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V136.Data.Item.Id Int
    | AddVendorItem Evergreen.V136.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V136.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V136.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Evergreen.V136.Data.Vendor.Shop.Shop
    | SetTransferNInput Evergreen.V136.Data.Barter.TransferNPosition String
    | SetTransferNActive Evergreen.V136.Data.Barter.TransferNPosition
    | UnsetTransferNActive


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V136.Frontend.Route.Route
    | GoToTownStore Evergreen.V136.Data.Vendor.Shop.Shop
    | Logout
    | Login
    | SignUp
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V136.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V136.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V136.Data.Perk.Perk
    | AskToEquipArmor Evergreen.V136.Data.Item.Id
    | AskToEquipWeapon Evergreen.V136.Data.Item.Id
    | AskToPreferAmmo Evergreen.V136.Data.Item.Kind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( Evergreen.V136.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File.File
    | AskToImport String
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Evergreen.V136.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V136.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V136.Data.Special.Type
    | NewCharDecSpecial Evergreen.V136.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V136.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V136.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V136.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Evergreen.V136.Data.Message.Id
    | AskToRemoveMessage Evergreen.V136.Data.Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V136.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Evergreen.V136.Data.Quest.Quest
    | CollapseQuestItem Evergreen.V136.Data.Quest.Quest
    | AskToStopProgressing Evergreen.V136.Data.Quest.Quest
    | AskToStartProgressing Evergreen.V136.Data.Quest.Quest
    | ScrolledToGuideSection String
    | ClickedGuideSection Int
    | HoveredGuideNavLink
    | AskToRefuelCar Evergreen.V136.Data.Item.Kind.Kind
    | AskToChangeWorldSpeed
        { world : Evergreen.V136.Data.World.Name
        , fast : Bool
        }


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | FirstTick Time.Posix
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V136.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V136.Data.WorldData.PlayerData
    | CurrentOtherPlayers (List Evergreen.V136.Data.Player.COtherPlayer)
    | CurrentWorlds (List Evergreen.V136.Data.WorldInfo.WorldInfo)
    | CurrentAdmin Evergreen.V136.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V136.Data.World.Name (List Evergreen.V136.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V136.Data.Player.PlayerName.PlayerName, Evergreen.V136.Data.World.Name, ToBackend ))
    | YoureLoggedOut (List Evergreen.V136.Data.WorldInfo.WorldInfo)
    | YourFightResult ( Evergreen.V136.Data.Fight.Info, Evergreen.V136.Data.WorldData.PlayerData )
    | YoureLoggedInSigningUp
    | YoureLoggedIn Evergreen.V136.Data.WorldData.PlayerData
    | YoureSignedUp
    | CharCreationError Evergreen.V136.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V136.Data.Player.CPlayer Evergreen.V136.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V136.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V136.Data.WorldData.PlayerData, Maybe Evergreen.V136.Data.Barter.Message )
    | BarterMessage Evergreen.V136.Data.Barter.Message
    | YourMessages (Dict.Dict Evergreen.V136.Data.Message.Id Evergreen.V136.Data.Message.Message)
