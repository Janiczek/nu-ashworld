module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Auth exposing (Auth, Hashed)
import Data.Fight exposing (FightInfo)
import Data.Map exposing (TileCoords)
import Data.Message exposing (Message)
import Data.NewChar exposing (NewChar)
import Data.Player
    exposing
        ( Player
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Special exposing (SpecialType)
import Data.Vendor exposing (Vendors)
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
    , vendors : Vendors
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
    | AskToImport String
    | Refresh
    | AskToIncSpecial SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | SetImportValue String
    | CreateChar
    | NewCharIncSpecial SpecialType
    | NewCharDecSpecial SpecialType
    | MapMouseAtCoords TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Message
    | AskToRemoveMessage Message


type ToBackend
    = LogMeIn (Auth Hashed)
    | RegisterMe (Auth Hashed)
    | CreateNewChar NewChar
    | LogMeOut
    | Fight PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial SpecialType
    | MoveTo TileCoords (Set TileCoords)
    | MessageWasRead Message
    | RemoveMessage Message
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
    | GeneratedNewVendorsStock Vendors
    | Tick Posix
    | CreateNewCharWithTime ClientId NewChar Posix


type ToFrontend
    = YourCurrentWorld WorldLoggedInData
    | CurrentWorld WorldLoggedOutData
    | CurrentAdminData AdminData
    | YourFightResult ( FightInfo, WorldLoggedInData )
    | YoureLoggedIn WorldLoggedInData
    | YoureRegistered WorldLoggedInData
    | YouHaveCreatedChar WorldLoggedInData
    | YoureLoggedOut WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin AdminData
    | JsonExportDone String
