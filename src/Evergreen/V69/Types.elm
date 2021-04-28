module Evergreen.V69.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V69.Data.Auth
import Evergreen.V69.Data.Barter
import Evergreen.V69.Data.Fight
import Evergreen.V69.Data.Fight.Generator
import Evergreen.V69.Data.Item
import Evergreen.V69.Data.Map
import Evergreen.V69.Data.Message
import Evergreen.V69.Data.NewChar
import Evergreen.V69.Data.Player
import Evergreen.V69.Data.Player.PlayerName
import Evergreen.V69.Data.Skill
import Evergreen.V69.Data.Special
import Evergreen.V69.Data.Trait
import Evergreen.V69.Data.Vendor
import Evergreen.V69.Data.World
import Evergreen.V69.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V69.Frontend.Route.Route
    , world : Evergreen.V69.Data.World.World
    , newChar : Evergreen.V69.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V69.Data.Map.TileCoords, Set.Set Evergreen.V69.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V69.Data.Player.PlayerName.PlayerName (Evergreen.V69.Data.Player.Player Evergreen.V69.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V69.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V69.Data.Vendor.Name Evergreen.V69.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V69.Data.Item.Id Int
    | AddVendorItem Evergreen.V69.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V69.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V69.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V69.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V69.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V69.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V69.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V69.Data.Item.Id
    | AskToWander
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V69.Data.Skill.Skill
    | AskToIncSkill Evergreen.V69.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V69.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V69.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V69.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V69.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V69.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V69.Data.Message.Message
    | AskToRemoveMessage Evergreen.V69.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V69.Data.Auth.Auth Evergreen.V69.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V69.Data.Auth.Auth Evergreen.V69.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V69.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V69.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V69.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V69.Data.Skill.Skill
    | IncSkill Evergreen.V69.Data.Skill.Skill
    | MoveTo Evergreen.V69.Data.Map.TileCoords (Set.Set Evergreen.V69.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V69.Data.Message.Message
    | RemoveMessage Evergreen.V69.Data.Message.Message
    | Barter Evergreen.V69.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V69.Data.Player.SPlayer Evergreen.V69.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V69.Data.Vendor.Name Evergreen.V69.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V69.Data.NewChar.NewChar Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V69.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V69.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V69.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V69.Data.World.AdminData
    | YourFightResult ( Evergreen.V69.Data.Fight.FightInfo, Evergreen.V69.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V69.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V69.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V69.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V69.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V69.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V69.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V69.Data.World.WorldLoggedInData, Maybe Evergreen.V69.Data.Barter.Message )
    | BarterMessage Evergreen.V69.Data.Barter.Message
