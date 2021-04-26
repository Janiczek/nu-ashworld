module Evergreen.V68.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V68.Data.Auth
import Evergreen.V68.Data.Barter
import Evergreen.V68.Data.Fight
import Evergreen.V68.Data.Fight.Generator
import Evergreen.V68.Data.Item
import Evergreen.V68.Data.Map
import Evergreen.V68.Data.Message
import Evergreen.V68.Data.NewChar
import Evergreen.V68.Data.Player
import Evergreen.V68.Data.Player.PlayerName
import Evergreen.V68.Data.Skill
import Evergreen.V68.Data.Special
import Evergreen.V68.Data.Trait
import Evergreen.V68.Data.Vendor
import Evergreen.V68.Data.World
import Evergreen.V68.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V68.Frontend.Route.Route
    , world : Evergreen.V68.Data.World.World
    , newChar : Evergreen.V68.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V68.Data.Map.TileCoords, Set.Set Evergreen.V68.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V68.Data.Player.PlayerName.PlayerName (Evergreen.V68.Data.Player.Player Evergreen.V68.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V68.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V68.Data.Vendor.Name Evergreen.V68.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V68.Data.Item.Id Int
    | AddVendorItem Evergreen.V68.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V68.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V68.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V68.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V68.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V68.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V68.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToWander
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V68.Data.Skill.Skill
    | AskToIncSkill Evergreen.V68.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V68.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V68.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V68.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V68.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V68.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V68.Data.Message.Message
    | AskToRemoveMessage Evergreen.V68.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V68.Data.Auth.Auth Evergreen.V68.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V68.Data.Auth.Auth Evergreen.V68.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V68.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V68.Data.Player.PlayerName.PlayerName
    | HealMe
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V68.Data.Skill.Skill
    | IncSkill Evergreen.V68.Data.Skill.Skill
    | MoveTo Evergreen.V68.Data.Map.TileCoords (Set.Set Evergreen.V68.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V68.Data.Message.Message
    | RemoveMessage Evergreen.V68.Data.Message.Message
    | Barter Evergreen.V68.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V68.Data.Player.SPlayer Evergreen.V68.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V68.Data.Vendor.Name Evergreen.V68.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V68.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V68.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V68.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V68.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V68.Data.World.AdminData
    | YourFightResult ( Evergreen.V68.Data.Fight.FightInfo, Evergreen.V68.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V68.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V68.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V68.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V68.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V68.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V68.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V68.Data.World.WorldLoggedInData, Maybe Evergreen.V68.Data.Barter.Message )
    | BarterMessage Evergreen.V68.Data.Barter.Message
