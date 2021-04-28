module Evergreen.V71.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V71.Data.Auth
import Evergreen.V71.Data.Barter
import Evergreen.V71.Data.Fight
import Evergreen.V71.Data.Fight.Generator
import Evergreen.V71.Data.Item
import Evergreen.V71.Data.Map
import Evergreen.V71.Data.Message
import Evergreen.V71.Data.NewChar
import Evergreen.V71.Data.Perk
import Evergreen.V71.Data.Player
import Evergreen.V71.Data.Player.PlayerName
import Evergreen.V71.Data.Skill
import Evergreen.V71.Data.Special
import Evergreen.V71.Data.Trait
import Evergreen.V71.Data.Vendor
import Evergreen.V71.Data.World
import Evergreen.V71.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V71.Frontend.Route.Route
    , world : Evergreen.V71.Data.World.World
    , newChar : Evergreen.V71.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V71.Data.Map.TileCoords, Set.Set Evergreen.V71.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V71.Data.Player.PlayerName.PlayerName (Evergreen.V71.Data.Player.Player Evergreen.V71.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V71.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V71.Data.Vendor.Name Evergreen.V71.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V71.Data.Item.Id Int
    | AddVendorItem Evergreen.V71.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V71.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V71.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V71.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V71.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V71.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V71.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V71.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V71.Data.Perk.Perk
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V71.Data.Skill.Skill
    | AskToIncSkill Evergreen.V71.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V71.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V71.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V71.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V71.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V71.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V71.Data.Message.Message
    | AskToRemoveMessage Evergreen.V71.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V71.Data.Auth.Auth Evergreen.V71.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V71.Data.Auth.Auth Evergreen.V71.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V71.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V71.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V71.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V71.Data.Skill.Skill
    | IncSkill Evergreen.V71.Data.Skill.Skill
    | ChoosePerk Evergreen.V71.Data.Perk.Perk
    | MoveTo Evergreen.V71.Data.Map.TileCoords (Set.Set Evergreen.V71.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V71.Data.Message.Message
    | RemoveMessage Evergreen.V71.Data.Message.Message
    | Barter Evergreen.V71.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V71.Data.Player.SPlayer Evergreen.V71.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V71.Data.Vendor.Name Evergreen.V71.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V71.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V71.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V71.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V71.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V71.Data.World.AdminData
    | YourFightResult ( Evergreen.V71.Data.Fight.FightInfo, Evergreen.V71.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V71.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V71.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V71.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V71.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V71.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V71.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V71.Data.World.WorldLoggedInData, Maybe Evergreen.V71.Data.Barter.Message )
    | BarterMessage Evergreen.V71.Data.Barter.Message
