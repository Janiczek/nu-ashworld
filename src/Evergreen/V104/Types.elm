module Evergreen.V104.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V104.Data.Auth
import Evergreen.V104.Data.Barter
import Evergreen.V104.Data.Fight
import Evergreen.V104.Data.Fight.Generator
import Evergreen.V104.Data.FightStrategy
import Evergreen.V104.Data.Item
import Evergreen.V104.Data.Map
import Evergreen.V104.Data.Message
import Evergreen.V104.Data.NewChar
import Evergreen.V104.Data.Perk
import Evergreen.V104.Data.Player
import Evergreen.V104.Data.Player.PlayerName
import Evergreen.V104.Data.Skill
import Evergreen.V104.Data.Special
import Evergreen.V104.Data.Trait
import Evergreen.V104.Data.Vendor
import Evergreen.V104.Data.World
import Evergreen.V104.Data.WorldData
import Evergreen.V104.Frontend.HoveredItem
import Evergreen.V104.Frontend.Route
import File exposing (File)
import Lamdera
import Queue
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , route : Evergreen.V104.Frontend.Route.Route
    , time : Time.Posix
    , zone : Time.Zone
    , loginForm : Evergreen.V104.Data.Auth.Auth Evergreen.V104.Data.Auth.Plaintext
    , worlds : Maybe (List Evergreen.V104.Data.World.Info)
    , worldData : Evergreen.V104.Data.WorldData.WorldData
    , alertMessage : Maybe String
    , newChar : Evergreen.V104.Data.NewChar.NewChar
    , mapMouseCoords : Maybe ( Evergreen.V104.Data.Map.TileCoords, Set.Set Evergreen.V104.Data.Map.TileCoords )
    , hoveredItem : Maybe Evergreen.V104.Frontend.HoveredItem.HoveredItem
    , fightInfo : Maybe Evergreen.V104.Data.Fight.Info
    , barter : Evergreen.V104.Data.Barter.State
    , fightStrategyText : String
    , lastTenToBackendMsgs : List ( Evergreen.V104.Data.Player.PlayerName.PlayerName, Evergreen.V104.Data.World.Name )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    }


type alias BackendModel =
    { worlds : Dict.Dict Evergreen.V104.Data.World.Name Evergreen.V104.Data.World.World
    , time : Time.Posix
    , loggedInPlayers :
        Dict.Dict
            Lamdera.ClientId
            { worldName : Evergreen.V104.Data.World.Name
            , playerName : Evergreen.V104.Data.Player.PlayerName.PlayerName
            }
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , lastTenToBackendMsgs : Queue.Queue ( Evergreen.V104.Data.Player.PlayerName.PlayerName, Evergreen.V104.Data.World.Name )
    }


type BarterMsg
    = AddPlayerItem Evergreen.V104.Data.Item.Id Int
    | AddVendorItem Evergreen.V104.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V104.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V104.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V104.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V104.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V104.Frontend.Route.Route
    | GoToTownStore
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V104.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V104.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V104.Data.Perk.Perk
    | AskToEquipItem Evergreen.V104.Data.Item.Id
    | AskToUnequipArmor
    | AskToSetFightStrategy ( Evergreen.V104.Data.FightStrategy.FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V104.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V104.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Evergreen.V104.Data.Special.Type
    | NewCharDecSpecial Evergreen.V104.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V104.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V104.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V104.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V104.Data.Message.Id
    | AskToRemoveMessage Evergreen.V104.Data.Message.Id
    | BarterMsg BarterMsg
    | HoverItem Evergreen.V104.Frontend.HoveredItem.HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | ToggleAdminNewWorldFast
    | AskToCreateNewWorld


type AdminToBackend
    = ExportJson
    | ImportJson String
    | CreateNewWorld String Bool


type ToBackend
    = LogMeIn (Evergreen.V104.Data.Auth.Auth Evergreen.V104.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V104.Data.Auth.Auth Evergreen.V104.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V104.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V104.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V104.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V104.Data.Item.Id
    | SetFightStrategy ( Evergreen.V104.Data.FightStrategy.FightStrategy, String )
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V104.Data.Skill.Skill
    | UseSkillPoints Evergreen.V104.Data.Skill.Skill
    | ChoosePerk Evergreen.V104.Data.Perk.Perk
    | MoveTo Evergreen.V104.Data.Map.TileCoords (Set.Set Evergreen.V104.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V104.Data.Message.Id
    | RemoveMessage Evergreen.V104.Data.Message.Id
    | Barter Evergreen.V104.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V104.Data.World.Name Evergreen.V104.Data.Player.SPlayer ( Evergreen.V104.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock Evergreen.V104.Data.World.Name ( AssocList.Dict Evergreen.V104.Data.Vendor.Name Evergreen.V104.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V104.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer Evergreen.V104.Data.WorldData.PlayerData
    | CurrentWorlds (List Evergreen.V104.Data.World.Info)
    | CurrentAdmin Evergreen.V104.Data.WorldData.AdminData
    | CurrentAdminLoggedInPlayers (Dict.Dict Evergreen.V104.Data.World.Name (List Evergreen.V104.Data.Player.PlayerName.PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( Evergreen.V104.Data.Player.PlayerName.PlayerName, Evergreen.V104.Data.World.Name ))
    | YoureLoggedOut (List Evergreen.V104.Data.World.Info)
    | YourFightResult ( Evergreen.V104.Data.Fight.Info, Evergreen.V104.Data.WorldData.PlayerData )
    | YoureLoggedIn Evergreen.V104.Data.WorldData.PlayerData
    | YoureRegistered Evergreen.V104.Data.WorldData.PlayerData
    | CharCreationError Evergreen.V104.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V104.Data.Player.CPlayer Evergreen.V104.Data.WorldData.PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V104.Data.WorldData.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V104.Data.WorldData.PlayerData, Maybe Evergreen.V104.Data.Barter.Message )
    | BarterMessage Evergreen.V104.Data.Barter.Message
