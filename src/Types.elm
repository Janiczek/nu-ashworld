module Types exposing (..)

import AssocList as Dict_
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Auth exposing (Auth, Hashed, Plaintext)
import Data.Barter as Barter
import Data.Fight as Fight
import Data.Fight.Generator exposing (Fight)
import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item
import Data.Map exposing (TileCoords)
import Data.Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk exposing (Perk)
import Data.Player
    exposing
        ( Player
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Skill exposing (Skill)
import Data.Special as Special
import Data.Trait exposing (Trait)
import Data.Vendor as Vendor exposing (Vendor)
import Data.World as World exposing (World)
import Data.WorldData
    exposing
        ( AdminData
        , PlayerData
        , WorldData
        )
import Dict exposing (Dict)
import File exposing (File)
import Frontend.HoveredItem exposing (HoveredItem)
import Frontend.Route
    exposing
        ( PlayerRoute
        , Route
        )
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , route : Route
    , time : Posix
    , zone : Time.Zone
    , loginForm : Auth Plaintext
    , worlds : Maybe (List World.Info)
    , worldData : WorldData
    , worldModel : WorldModel
    }


type alias WorldModel =
    { worldName : World.Name
    , newChar : NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( TileCoords, Set TileCoords )
    , hoveredItem : Maybe HoveredItem
    }


type alias BackendModel =
    { worlds : Dict World.Name World
    , time : Posix
    , loggedInPlayers :
        Dict
            ClientId
            { worldName : World.Name
            , playerName : PlayerName
            }
    , adminLoggedIn : Maybe ( ClientId, SessionId )
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GoToRoute Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight PlayerName
    | AskToHeal
    | AskToUseItem Item.Id
    | AskToWander
    | AskToChoosePerk Perk
    | AskToEquipItem Item.Id
    | AskToUnequipArmor
    | AskToSetFightStrategy ( FightStrategy, String )
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Skill
    | AskToUseSkillPoints Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Special.Type
    | NewCharDecSpecial Special.Type
    | NewCharToggleTaggedSkill Skill
    | NewCharToggleTrait Trait
    | MapMouseAtCoords TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Message
    | AskToRemoveMessage Message
    | BarterMsg BarterMsg
    | HoverItem HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String


type BarterMsg
    = AddPlayerItem Item.Id Int
    | AddVendorItem Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Item.Id Int
    | RemoveVendorItem Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Barter.TransferNPosition String
    | SetTransferNHover Barter.TransferNPosition
    | UnsetTransferNHover


type ToBackend
    = LogMeIn (Auth Hashed)
    | RegisterMe (Auth Hashed)
    | CreateNewChar NewChar
    | LogMeOut
    | Fight PlayerName
    | HealMe
    | UseItem Item.Id
    | Wander
    | EquipItem Item.Id
    | SetFightStrategy ( FightStrategy, String )
    | UnequipArmor
    | RefreshPlease
    | TagSkill Skill
    | UseSkillPoints Skill
    | ChoosePerk Perk
    | MoveTo TileCoords (Set TileCoords)
    | MessageWasRead Message
    | RemoveMessage Message
    | Barter Barter.State
    | AdminToBackend AdminToBackend


type AdminToBackend
    = ExportJson
    | ImportJson String


type BackendMsg
    = Connected SessionId ClientId
    | Disconnected SessionId ClientId
    | GeneratedFight ClientId World.Name SPlayer ( Fight, Int )
    | GeneratedNewVendorsStock World.Name ( Dict_.Dict Vendor.Name Vendor, Int )
    | Tick Posix
    | CreateNewCharWithTime ClientId NewChar Posix
    | LoggedToBackendMsg


type ToFrontend
    = CurrentPlayer PlayerData
    | CurrentWorlds (List World.Info)
    | CurrentAdmin AdminData
    | YoureLoggedOut (List World.Info)
    | YourFightResult ( Fight.Info, PlayerData )
    | YoureLoggedIn PlayerData
    | YoureRegistered PlayerData
    | CharCreationError NewChar.CreationError
    | YouHaveCreatedChar PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin AdminData
    | JsonExportDone String
    | BarterDone ( PlayerData, Maybe Barter.Message )
    | BarterMessage Barter.Message
