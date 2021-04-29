module Evergreen.V81.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V81.Data.Auth
import Evergreen.V81.Data.Barter
import Evergreen.V81.Data.Fight
import Evergreen.V81.Data.Fight.Generator
import Evergreen.V81.Data.Item
import Evergreen.V81.Data.Map
import Evergreen.V81.Data.Message
import Evergreen.V81.Data.NewChar
import Evergreen.V81.Data.Perk
import Evergreen.V81.Data.Player
import Evergreen.V81.Data.Player.PlayerName
import Evergreen.V81.Data.Skill
import Evergreen.V81.Data.Special
import Evergreen.V81.Data.Trait
import Evergreen.V81.Data.Vendor
import Evergreen.V81.Data.World
import Evergreen.V81.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V81.Frontend.Route.Route
    , world : Evergreen.V81.Data.World.World
    , newChar : Evergreen.V81.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V81.Data.Map.TileCoords, Set.Set Evergreen.V81.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V81.Data.Player.PlayerName.PlayerName (Evergreen.V81.Data.Player.Player Evergreen.V81.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V81.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V81.Data.Vendor.Name Evergreen.V81.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V81.Data.Item.Id Int
    | AddVendorItem Evergreen.V81.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V81.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V81.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V81.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V81.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V81.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V81.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V81.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V81.Data.Perk.Perk
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V81.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V81.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V81.Data.Special.Type
    | NewCharDecSpecial Evergreen.V81.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V81.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V81.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V81.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V81.Data.Message.Message
    | AskToRemoveMessage Evergreen.V81.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V81.Data.Auth.Auth Evergreen.V81.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V81.Data.Auth.Auth Evergreen.V81.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V81.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V81.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V81.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V81.Data.Skill.Skill
    | UseSkillPoints Evergreen.V81.Data.Skill.Skill
    | ChoosePerk Evergreen.V81.Data.Perk.Perk
    | MoveTo Evergreen.V81.Data.Map.TileCoords (Set.Set Evergreen.V81.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V81.Data.Message.Message
    | RemoveMessage Evergreen.V81.Data.Message.Message
    | Barter Evergreen.V81.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V81.Data.Player.SPlayer Evergreen.V81.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V81.Data.Vendor.Name Evergreen.V81.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V81.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V81.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V81.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V81.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V81.Data.World.AdminData
    | YourFightResult ( Evergreen.V81.Data.Fight.FightInfo, Evergreen.V81.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V81.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V81.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V81.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V81.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V81.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V81.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V81.Data.World.WorldLoggedInData, Maybe Evergreen.V81.Data.Barter.Message )
    | BarterMessage Evergreen.V81.Data.Barter.Message
