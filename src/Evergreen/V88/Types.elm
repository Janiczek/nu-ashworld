module Evergreen.V88.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V88.Data.Auth
import Evergreen.V88.Data.Barter
import Evergreen.V88.Data.Fight
import Evergreen.V88.Data.Fight.Generator
import Evergreen.V88.Data.Item
import Evergreen.V88.Data.Map
import Evergreen.V88.Data.Message
import Evergreen.V88.Data.NewChar
import Evergreen.V88.Data.Perk
import Evergreen.V88.Data.Player
import Evergreen.V88.Data.Player.PlayerName
import Evergreen.V88.Data.Skill
import Evergreen.V88.Data.Special
import Evergreen.V88.Data.Trait
import Evergreen.V88.Data.Vendor
import Evergreen.V88.Data.World
import Evergreen.V88.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V88.Frontend.Route.Route
    , world : Evergreen.V88.Data.World.World
    , newChar : Evergreen.V88.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V88.Data.Map.TileCoords, Set.Set Evergreen.V88.Data.Map.TileCoords )
    , hoveredPerk : Maybe Evergreen.V88.Data.Perk.Perk
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V88.Data.Player.PlayerName.PlayerName (Evergreen.V88.Data.Player.Player Evergreen.V88.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V88.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V88.Data.Vendor.Name Evergreen.V88.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V88.Data.Item.Id Int
    | AddVendorItem Evergreen.V88.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V88.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V88.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V88.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V88.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V88.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V88.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V88.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V88.Data.Perk.Perk
    | AskToEquipItem Evergreen.V88.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V88.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V88.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V88.Data.Special.Type
    | NewCharDecSpecial Evergreen.V88.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V88.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V88.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V88.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V88.Data.Message.Message
    | AskToRemoveMessage Evergreen.V88.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverPerk Evergreen.V88.Data.Perk.Perk
    | StopHoveringPerk


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V88.Data.Auth.Auth Evergreen.V88.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V88.Data.Auth.Auth Evergreen.V88.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V88.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V88.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V88.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V88.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V88.Data.Skill.Skill
    | UseSkillPoints Evergreen.V88.Data.Skill.Skill
    | ChoosePerk Evergreen.V88.Data.Perk.Perk
    | MoveTo Evergreen.V88.Data.Map.TileCoords (Set.Set Evergreen.V88.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V88.Data.Message.Message
    | RemoveMessage Evergreen.V88.Data.Message.Message
    | Barter Evergreen.V88.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V88.Data.Player.SPlayer ( Evergreen.V88.Data.Fight.Generator.Fight, Int )
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V88.Data.Vendor.Name Evergreen.V88.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V88.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V88.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V88.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V88.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V88.Data.World.AdminData
    | YourFightResult ( Evergreen.V88.Data.Fight.Info, Evergreen.V88.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V88.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V88.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V88.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V88.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V88.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V88.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V88.Data.World.WorldLoggedInData, Maybe Evergreen.V88.Data.Barter.Message )
    | BarterMessage Evergreen.V88.Data.Barter.Message
