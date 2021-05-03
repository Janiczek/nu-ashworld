module Evergreen.V83.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V83.Data.Auth
import Evergreen.V83.Data.Barter
import Evergreen.V83.Data.Fight
import Evergreen.V83.Data.Fight.Generator
import Evergreen.V83.Data.Item
import Evergreen.V83.Data.Map
import Evergreen.V83.Data.Message
import Evergreen.V83.Data.NewChar
import Evergreen.V83.Data.Perk
import Evergreen.V83.Data.Player
import Evergreen.V83.Data.Player.PlayerName
import Evergreen.V83.Data.Skill
import Evergreen.V83.Data.Special
import Evergreen.V83.Data.Trait
import Evergreen.V83.Data.Vendor
import Evergreen.V83.Data.World
import Evergreen.V83.Frontend.Route
import File
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V83.Frontend.Route.Route
    , world : Evergreen.V83.Data.World.World
    , newChar : Evergreen.V83.Data.NewChar.NewChar
    , alertMessage : Maybe String
    , mapMouseCoords : Maybe ( Evergreen.V83.Data.Map.TileCoords, Set.Set Evergreen.V83.Data.Map.TileCoords )
    }


type alias BackendModel =
    { players : Dict.Dict Evergreen.V83.Data.Player.PlayerName.PlayerName (Evergreen.V83.Data.Player.Player Evergreen.V83.Data.Player.SPlayer)
    , loggedInPlayers : Dict.Dict Lamdera.ClientId Evergreen.V83.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    , adminLoggedIn : Maybe ( Lamdera.ClientId, Lamdera.SessionId )
    , time : Time.Posix
    , vendors : AssocList.Dict Evergreen.V83.Data.Vendor.Name Evergreen.V83.Data.Vendor.Vendor
    , lastItemId : Int
    }


type BarterMsg
    = AddPlayerItem Evergreen.V83.Data.Item.Id Int
    | AddVendorItem Evergreen.V83.Data.Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Evergreen.V83.Data.Item.Id Int
    | RemoveVendorItem Evergreen.V83.Data.Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter
    | SetTransferNInput Evergreen.V83.Data.Barter.TransferNPosition String
    | SetTransferNHover Evergreen.V83.Data.Barter.TransferNPosition
    | UnsetTransferNHover


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V83.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V83.Data.Player.PlayerName.PlayerName
    | AskToHeal
    | AskToUseItem Evergreen.V83.Data.Item.Id
    | AskToWander
    | AskToChoosePerk Evergreen.V83.Data.Perk.Perk
    | AskToEquipItem Evergreen.V83.Data.Item.Id
    | AskToUnequipArmor
    | AskForExport
    | ImportButtonClicked
    | ImportFileSelected File
    | AskToImport String
    | Refresh
    | AskToTagSkill Evergreen.V83.Data.Skill.Skill
    | AskToUseSkillPoints Evergreen.V83.Data.Skill.Skill
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V83.Data.Special.Type
    | NewCharDecSpecial Evergreen.V83.Data.Special.Type
    | NewCharToggleTaggedSkill Evergreen.V83.Data.Skill.Skill
    | NewCharToggleTrait Evergreen.V83.Data.Trait.Trait
    | MapMouseAtCoords Evergreen.V83.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick
    | OpenMessage Evergreen.V83.Data.Message.Message
    | AskToRemoveMessage Evergreen.V83.Data.Message.Message
    | BarterMsg BarterMsg


type AdminToBackend
    = ExportJson
    | ImportJson String


type ToBackend
    = LogMeIn (Evergreen.V83.Data.Auth.Auth Evergreen.V83.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V83.Data.Auth.Auth Evergreen.V83.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V83.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V83.Data.Player.PlayerName.PlayerName
    | HealMe
    | UseItem Evergreen.V83.Data.Item.Id
    | Wander
    | EquipItem Evergreen.V83.Data.Item.Id
    | UnequipArmor
    | RefreshPlease
    | TagSkill Evergreen.V83.Data.Skill.Skill
    | UseSkillPoints Evergreen.V83.Data.Skill.Skill
    | ChoosePerk Evergreen.V83.Data.Perk.Perk
    | MoveTo Evergreen.V83.Data.Map.TileCoords (Set.Set Evergreen.V83.Data.Map.TileCoords)
    | MessageWasRead Evergreen.V83.Data.Message.Message
    | RemoveMessage Evergreen.V83.Data.Message.Message
    | Barter Evergreen.V83.Data.Barter.State
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V83.Data.Player.SPlayer Evergreen.V83.Data.Fight.Generator.Fight
    | GeneratedNewVendorsStock ( AssocList.Dict Evergreen.V83.Data.Vendor.Name Evergreen.V83.Data.Vendor.Vendor, Int )
    | Tick Time.Posix
    | CreateNewCharWithTime Lamdera.ClientId Evergreen.V83.Data.NewChar.NewChar Time.Posix
    | LoggedToBackendMsg


type ToFrontend
    = YourCurrentWorld Evergreen.V83.Data.World.WorldLoggedInData
    | InitWorld Evergreen.V83.Data.World.WorldLoggedOutData
    | RefreshedLoggedOut Evergreen.V83.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V83.Data.World.AdminData
    | YourFightResult ( Evergreen.V83.Data.Fight.FightInfo, Evergreen.V83.Data.World.WorldLoggedInData )
    | YoureLoggedIn Evergreen.V83.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V83.Data.World.WorldLoggedInData
    | CharCreationError Evergreen.V83.Data.NewChar.CreationError
    | YouHaveCreatedChar Evergreen.V83.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V83.Data.World.WorldLoggedOutData
    | AlertMessage String
    | YoureLoggedInAsAdmin Evergreen.V83.Data.World.AdminData
    | JsonExportDone String
    | BarterDone ( Evergreen.V83.Data.World.WorldLoggedInData, Maybe Evergreen.V83.Data.Barter.Message )
    | BarterMessage Evergreen.V83.Data.Barter.Message
