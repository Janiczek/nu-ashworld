module Evergreen.V78.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V78.Data.Auth
import Evergreen.V78.Data.Barter
import Evergreen.V78.Data.Fight
import Evergreen.V78.Data.Fight.Generator
import Evergreen.V78.Data.Item
import Evergreen.V78.Data.Map
import Evergreen.V78.Data.Message
import Evergreen.V78.Data.NewChar
import Evergreen.V78.Data.Perk
import Evergreen.V78.Data.Player
import Evergreen.V78.Data.Player.PlayerName
import Evergreen.V78.Data.Skill
import Evergreen.V78.Data.Special
import Evergreen.V78.Data.Trait
import Evergreen.V78.Data.Vendor
import Evergreen.V78.Data.World
import Evergreen.V78.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V78.Frontend.Route.Route
    , world : Evergreen.V78.Data.World.World
    , newChar : Evergreen.V78.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V78.Data.Map.TileCoords, Set.Set Evergreen.V78.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V78.Data.Player.PlayerName.PlayerName (Evergreen.V78.Data.Player.Player Evergreen.V78.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V78.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V78.Data.Vendor.Name Evergreen.V78.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V78.Data.Item.Id Int
    | AddVendorItem Evergreen.V78.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V78.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V78.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V78.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V78.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V78.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V78.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V78.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V78.Data.Perk.Perk
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V78.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V78.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V78.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V78.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V78.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V78.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V78.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V78.Data.Message.Message
    | AskToRemoveMessage Evergreen.V78.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V78.Data.Auth.Auth Evergreen.V78.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V78.Data.Auth.Auth Evergreen.V78.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V78.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V78.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V78.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V78.Data.Skill.Skill
    | UseSkillPoints Evergreen.V78.Data.Skill.Skill
    | ChoosePerk Evergreen.V78.Data.Perk.Perk
    | MoveTo Evergreen.V78.Data.Map.TileCoords (Set.Set Evergreen.V78.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V78.Data.Message.Message
    | RemoveMessage Evergreen.V78.Data.Message.Message
    | Barter Evergreen.V78.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V78.Data.Player.SPlayer Evergreen.V78.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V78.Data.Vendor.Name Evergreen.V78.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V78.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V78.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V78.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V78.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V78.Data.World.AdminData
    | YourFightResult ( Evergreen.V78.Data.Fight.FightInfo, Evergreen.V78.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V78.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V78.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V78.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V78.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V78.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V78.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V78.Data.World.WorldLoggedInData, Maybe Evergreen.V78.Data.Barter.Message )
    | BarterMessage Evergreen.V78.Data.Barter.Message
