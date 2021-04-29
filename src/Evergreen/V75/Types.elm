module Evergreen.V75.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V75.Data.Auth
import Evergreen.V75.Data.Barter
import Evergreen.V75.Data.Fight
import Evergreen.V75.Data.Fight.Generator
import Evergreen.V75.Data.Item
import Evergreen.V75.Data.Map
import Evergreen.V75.Data.Message
import Evergreen.V75.Data.NewChar
import Evergreen.V75.Data.Perk
import Evergreen.V75.Data.Player
import Evergreen.V75.Data.Player.PlayerName
import Evergreen.V75.Data.Skill
import Evergreen.V75.Data.Special
import Evergreen.V75.Data.Trait
import Evergreen.V75.Data.Vendor
import Evergreen.V75.Data.World
import Evergreen.V75.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V75.Frontend.Route.Route
    , world : Evergreen.V75.Data.World.World
    , newChar : Evergreen.V75.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V75.Data.Map.TileCoords, Set.Set Evergreen.V75.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V75.Data.Player.PlayerName.PlayerName (Evergreen.V75.Data.Player.Player Evergreen.V75.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V75.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V75.Data.Vendor.Name Evergreen.V75.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V75.Data.Item.Id Int
    | AddVendorItem Evergreen.V75.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V75.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V75.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V75.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V75.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V75.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V75.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V75.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V75.Data.Perk.Perk
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V75.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V75.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V75.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V75.Data.Special.SpecialType
    | NewCharToggleTaggedSkill Evergreen.V75.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V75.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V75.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V75.Data.Message.Message
    | AskToRemoveMessage Evergreen.V75.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V75.Data.Auth.Auth Evergreen.V75.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V75.Data.Auth.Auth Evergreen.V75.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V75.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V75.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V75.Data.Item.Id
    | Wander
    | RefreshPlease
    | TagSkill Evergreen.V75.Data.Skill.Skill
    | UseSkillPoints Evergreen.V75.Data.Skill.Skill
    | ChoosePerk Evergreen.V75.Data.Perk.Perk
    | MoveTo Evergreen.V75.Data.Map.TileCoords (Set.Set Evergreen.V75.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V75.Data.Message.Message
    | RemoveMessage Evergreen.V75.Data.Message.Message
    | Barter Evergreen.V75.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V75.Data.Player.SPlayer Evergreen.V75.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V75.Data.Vendor.Name Evergreen.V75.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V75.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V75.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V75.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V75.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V75.Data.World.AdminData
    | YourFightResult ( Evergreen.V75.Data.Fight.FightInfo, Evergreen.V75.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V75.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V75.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V75.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V75.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V75.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V75.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V75.Data.World.WorldLoggedInData, Maybe Evergreen.V75.Data.Barter.Message )
    | BarterMessage Evergreen.V75.Data.Barter.Message
