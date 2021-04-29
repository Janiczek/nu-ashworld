module Evergreen.V79.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V79.Data.Auth
import Evergreen.V79.Data.Barter
import Evergreen.V79.Data.Fight
import Evergreen.V79.Data.Fight.Generator
import Evergreen.V79.Data.Item
import Evergreen.V79.Data.Map
import Evergreen.V79.Data.Message
import Evergreen.V79.Data.NewChar
import Evergreen.V79.Data.Perk
import Evergreen.V79.Data.Player
import Evergreen.V79.Data.Player.PlayerName
import Evergreen.V79.Data.Skill
import Evergreen.V79.Data.Special
import Evergreen.V79.Data.Trait
import Evergreen.V79.Data.Vendor
import Evergreen.V79.Data.World
import Evergreen.V79.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V79.Frontend.Route.Route
    , world : Evergreen.V79.Data.World.World
    , newChar : Evergreen.V79.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V79.Data.Map.TileCoords, Set.Set Evergreen.V79.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V79.Data.Player.PlayerName.PlayerName (Evergreen.V79.Data.Player.Player Evergreen.V79.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V79.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V79.Data.Vendor.Name Evergreen.V79.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V79.Data.Item.Id Int
    | AddVendorItem Evergreen.V79.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V79.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V79.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V79.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V79.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V79.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V79.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V79.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V79.Data.Perk.Perk
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V79.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V79.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V79.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V79.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V79.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V79.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V79.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V79.Data.Message.Message
    | AskToRemoveMessage Evergreen.V79.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V79.Data.Auth.Auth Evergreen.V79.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V79.Data.Auth.Auth Evergreen.V79.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V79.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V79.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V79.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V79.Data.Skill.Skill
    | UseSkillPoints Evergreen.V79.Data.Skill.Skill
    | ChoosePerk Evergreen.V79.Data.Perk.Perk
    | MoveTo Evergreen.V79.Data.Map.TileCoords (Set.Set Evergreen.V79.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V79.Data.Message.Message
    | RemoveMessage Evergreen.V79.Data.Message.Message
    | Barter Evergreen.V79.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V79.Data.Player.SPlayer Evergreen.V79.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V79.Data.Vendor.Name Evergreen.V79.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V79.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V79.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V79.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V79.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V79.Data.World.AdminData
    | YourFightResult ( Evergreen.V79.Data.Fight.FightInfo, Evergreen.V79.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V79.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V79.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V79.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V79.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V79.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V79.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V79.Data.World.WorldLoggedInData, Maybe Evergreen.V79.Data.Barter.Message )
    | BarterMessage Evergreen.V79.Data.Barter.Message
