module Evergreen.V77.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V77.Data.Auth
import Evergreen.V77.Data.Barter
import Evergreen.V77.Data.Fight
import Evergreen.V77.Data.Fight.Generator
import Evergreen.V77.Data.Item
import Evergreen.V77.Data.Map
import Evergreen.V77.Data.Message
import Evergreen.V77.Data.NewChar
import Evergreen.V77.Data.Perk
import Evergreen.V77.Data.Player
import Evergreen.V77.Data.Player.PlayerName
import Evergreen.V77.Data.Skill
import Evergreen.V77.Data.Special
import Evergreen.V77.Data.Trait
import Evergreen.V77.Data.Vendor
import Evergreen.V77.Data.World
import Evergreen.V77.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V77.Frontend.Route.Route
    , world : Evergreen.V77.Data.World.World
    , newChar : Evergreen.V77.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V77.Data.Map.TileCoords, Set.Set Evergreen.V77.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V77.Data.Player.PlayerName.PlayerName (Evergreen.V77.Data.Player.Player Evergreen.V77.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V77.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V77.Data.Vendor.Name Evergreen.V77.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V77.Data.Item.Id Int
    | AddVendorItem Evergreen.V77.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V77.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V77.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V77.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V77.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V77.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V77.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V77.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V77.Data.Perk.Perk
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V77.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V77.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V77.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V77.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V77.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V77.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V77.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V77.Data.Message.Message
    | AskToRemoveMessage Evergreen.V77.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V77.Data.Auth.Auth Evergreen.V77.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V77.Data.Auth.Auth Evergreen.V77.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V77.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V77.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V77.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V77.Data.Skill.Skill
    | UseSkillPoints Evergreen.V77.Data.Skill.Skill
    | ChoosePerk Evergreen.V77.Data.Perk.Perk
    | MoveTo Evergreen.V77.Data.Map.TileCoords (Set.Set Evergreen.V77.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V77.Data.Message.Message
    | RemoveMessage Evergreen.V77.Data.Message.Message
    | Barter Evergreen.V77.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V77.Data.Player.SPlayer Evergreen.V77.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V77.Data.Vendor.Name Evergreen.V77.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V77.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V77.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V77.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V77.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V77.Data.World.AdminData
    | YourFightResult ( Evergreen.V77.Data.Fight.FightInfo, Evergreen.V77.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V77.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V77.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V77.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V77.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V77.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V77.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V77.Data.World.WorldLoggedInData, Maybe Evergreen.V77.Data.Barter.Message )
    | BarterMessage Evergreen.V77.Data.Barter.Message
