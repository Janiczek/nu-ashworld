module Evergreen.V87.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V87.Data.Auth
import Evergreen.V87.Data.Barter
import Evergreen.V87.Data.Fight
import Evergreen.V87.Data.Fight.Generator
import Evergreen.V87.Data.Item
import Evergreen.V87.Data.Map
import Evergreen.V87.Data.Message
import Evergreen.V87.Data.NewChar
import Evergreen.V87.Data.Perk
import Evergreen.V87.Data.Player
import Evergreen.V87.Data.Player.PlayerName
import Evergreen.V87.Data.Skill
import Evergreen.V87.Data.Special
import Evergreen.V87.Data.Trait
import Evergreen.V87.Data.Vendor
import Evergreen.V87.Data.World
import Evergreen.V87.Frontend.Route
import File exposing (File)
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V87.Frontend.Route.Route
    , world : Evergreen.V87.Data.World.World
    , newChar : Evergreen.V87.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V87.Data.Map.TileCoords, Set.Set Evergreen.V87.Data.Map.TileCoords )
    , hoveredPerk : Maybe Evergreen.V87.Data.Perk.Perk
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V87.Data.Player.PlayerName.PlayerName (Evergreen.V87.Data.Player.Player Evergreen.V87.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V87.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V87.Data.Vendor.Name Evergreen.V87.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V87.Data.Item.Id Int
    | AddVendorItem Evergreen.V87.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V87.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V87.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V87.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V87.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V87.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V87.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V87.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V87.Data.Perk.Perk
    | AskToEquipItem Evergreen.V87.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V87.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V87.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V87.Data.Special.Type
    | NewCharDecSpecial Evergreen.V87.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V87.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V87.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V87.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V87.Data.Message.Message
    | AskToRemoveMessage Evergreen.V87.Data.Message.Message
    | BarterMsg BarterMsg
    | HoverPerk Evergreen.V87.Data.Perk.Perk
    | StopHoveringPerk


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V87.Data.Auth.Auth Evergreen.V87.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V87.Data.Auth.Auth Evergreen.V87.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V87.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V87.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V87.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V87.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V87.Data.Skill.Skill
    | UseSkillPoints Evergreen.V87.Data.Skill.Skill
    | ChoosePerk Evergreen.V87.Data.Perk.Perk
    | MoveTo Evergreen.V87.Data.Map.TileCoords (Set.Set Evergreen.V87.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V87.Data.Message.Message
    | RemoveMessage Evergreen.V87.Data.Message.Message
    | Barter Evergreen.V87.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V87.Data.Player.SPlayer Evergreen.V87.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V87.Data.Vendor.Name Evergreen.V87.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V87.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V87.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V87.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V87.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V87.Data.World.AdminData
    | YourFightResult ( Evergreen.V87.Data.Fight.Info, Evergreen.V87.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V87.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V87.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V87.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V87.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V87.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V87.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V87.Data.World.WorldLoggedInData, Maybe Evergreen.V87.Data.Barter.Message )
    | BarterMessage Evergreen.V87.Data.Barter.Message
