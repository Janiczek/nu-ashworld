module Evergreen.V85.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V85.Data.Auth
import Evergreen.V85.Data.Barter
import Evergreen.V85.Data.Fight
import Evergreen.V85.Data.Fight.Generator
import Evergreen.V85.Data.Item
import Evergreen.V85.Data.Map
import Evergreen.V85.Data.Message
import Evergreen.V85.Data.NewChar
import Evergreen.V85.Data.Perk
import Evergreen.V85.Data.Player
import Evergreen.V85.Data.Player.PlayerName
import Evergreen.V85.Data.Skill
import Evergreen.V85.Data.Special
import Evergreen.V85.Data.Trait
import Evergreen.V85.Data.Vendor
import Evergreen.V85.Data.World
import Evergreen.V85.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V85.Frontend.Route.Route
    , world : Evergreen.V85.Data.World.World
    , newChar : Evergreen.V85.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V85.Data.Map.TileCoords, Set.Set Evergreen.V85.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V85.Data.Player.PlayerName.PlayerName (Evergreen.V85.Data.Player.Player Evergreen.V85.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V85.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V85.Data.Vendor.Name Evergreen.V85.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V85.Data.Item.Id Int
    | AddVendorItem Evergreen.V85.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V85.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V85.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V85.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V85.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V85.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V85.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V85.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V85.Data.Perk.Perk
    | AskToEquipItem Evergreen.V85.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V85.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V85.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V85.Data.Special.Type
    | NewCharDecSpecial Evergreen.V85.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V85.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V85.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V85.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V85.Data.Message.Message
    | AskToRemoveMessage Evergreen.V85.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V85.Data.Auth.Auth Evergreen.V85.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V85.Data.Auth.Auth Evergreen.V85.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V85.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V85.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V85.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V85.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V85.Data.Skill.Skill
    | UseSkillPoints Evergreen.V85.Data.Skill.Skill
    | ChoosePerk Evergreen.V85.Data.Perk.Perk
    | MoveTo Evergreen.V85.Data.Map.TileCoords (Set.Set Evergreen.V85.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V85.Data.Message.Message
    | RemoveMessage Evergreen.V85.Data.Message.Message
    | Barter Evergreen.V85.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V85.Data.Player.SPlayer Evergreen.V85.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V85.Data.Vendor.Name Evergreen.V85.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V85.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V85.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V85.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V85.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V85.Data.World.AdminData
    | YourFightResult ( Evergreen.V85.Data.Fight.Info, Evergreen.V85.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V85.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V85.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V85.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V85.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V85.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V85.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V85.Data.World.WorldLoggedInData, Maybe Evergreen.V85.Data.Barter.Message )
    | BarterMessage Evergreen.V85.Data.Barter.Message
