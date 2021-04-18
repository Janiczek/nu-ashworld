module Types exposing (..)

import AssocList as Dict_
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Auth exposing (Auth, Hashed)
import Data.Barter as Barter
import Data.Fight exposing (FightInfo)
import Data.Item as Item
import Data.Map exposing (TileCoords)
import Data.Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Player
    exposing
        ( Player
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Skill exposing (Skill)
import Data.Special exposing (SpecialType)
import Data.Trait exposing (Trait)
import Data.Vendor exposing (Vendor, VendorName)
import Data.World
    exposing
        ( AdminData
        , World
        , WorldLoggedInData
        , WorldLoggedOutData
        )
import Dict exposing (Dict)
import File exposing (File)
import Frontend.Route exposing (Route)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , time : Posix
    , zone : Time.Zone
    , route : Route
    , world : World
    , newChar : NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( TileCoords, Set TileCoords )
    }


type alias BackendModel =
    { players : Dict PlayerName (Player SPlayer)
    , loggedInPlayers : Dict ClientId PlayerName
    , nextWantedTick : Maybe Posix
    , adminLoggedIn : Maybe ( ClientId, SessionId )
    , time : Posix
    , vendors : Dict_.Dict VendorName Vendor
    , lastItemId : Int
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
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Skill
    | AskToIncSkill Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial SpecialType
    | NewCharDecSpecial SpecialType
    | NewCharToggleTaggedSkill Skill
    | NewCharToggleTrait Trait
    | MapMouseAtCoords TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Message
    | AskToRemoveMessage Message
    | BarterMsg BarterMsg


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
    | RefreshPlease
    | TagSkill Skill
    | IncSkill Skill
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
    | GeneratedFight
        ClientId
        SPlayer
        { finalAttacker : SPlayer
        , finalTarget : SPlayer
        , fightInfo : FightInfo
        }
    | GeneratedNewVendorsStock ( Dict_.Dict VendorName Vendor, Int )
    | Tick Posix
    | CreateNewCharWithTime ClientId NewChar Posix


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
    | CurrentAdminData AdminData
    | YourFightResult ( FightInfo, WorldLoggedInData )
    | YoureLoggedIn WorldLoggedInData
    | YoureRegistered WorldLoggedInData
    | CharCreationError NewChar.CreationError
    | YouHaveCreatedChar WorldLoggedInData
    | YoureLoggedOut WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin AdminData
    | JsonExportDone String
    | BarterDone ( WorldLoggedInData, Maybe Barter.Message )
    | BarterMessage Barter.Message
