module Types exposing (..)

import BiDict exposing (BiDict)
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Data.Auth exposing (Auth, Hashed, Plaintext)
import Data.Barter as Barter
import Data.Fight as Fight
import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item
import Data.Item.Kind as ItemKind
import Data.Map exposing (TileCoords)
import Data.Message as Message
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk exposing (Perk)
import Data.Player exposing (CPlayer)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest
import Data.Skill exposing (Skill)
import Data.Special as Special
import Data.Trait exposing (Trait)
import Data.Vendor.Shop exposing (Shop)
import Data.World as World exposing (World)
import Data.WorldData
    exposing
        ( AdminData
        , PlayerData
        , WorldData
        )
import Data.WorldInfo exposing (WorldInfo)
import Dict exposing (Dict)
import File exposing (File)
import Frontend.HoveredItem exposing (HoveredItem)
import Frontend.Route exposing (Route)
import Fusion
import Fusion.Patch
import Lamdera exposing (ClientId, SessionId)
import Queue exposing (Queue)
import Random
import SeqSet exposing (SeqSet)
import Set exposing (Set)
import Time exposing (Posix)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , route : Route
    , time : Posix
    , zone : Time.Zone
    , loginForm : Auth Plaintext
    , worlds : Maybe (List WorldInfo)
    , worldData : WorldData

    -- player frontend state:
    , alertMessage : Maybe String
    , newChar : NewChar
    , mapMouseCoords : Maybe ( TileCoords, Set TileCoords )
    , hoveredItem : Maybe HoveredItem
    , fightInfo : Maybe Fight.Info
    , barter : Barter.State
    , fightStrategyText : String
    , expandedQuests : SeqSet Quest.Name
    , userWantsToShowAreaDanger : Bool

    -- admin state
    , lastTenToBackendMsgs : List ( PlayerName, World.Name, String )
    , adminNewWorldName : String
    , adminNewWorldFast : Bool
    , fusionBackendModel : FusionBackendModel
    }


type FusionBackendModel
    = FNotLoaded
    | FOriginalOnly Fusion.Value
    | FEdited
        { original : Fusion.Value
        , edited : Fusion.Value
        , patch : Fusion.Patch.Patch
        }


type alias BackendModel =
    { worlds : Dict World.Name World
    , time : Posix
    , loggedInPlayers :
        -- Lets multiple browser windows log into the same (WorldName, PlayerName).
        -- BiDict lets us get all the ClientIds for a certain player, meaning we
        -- can compute their data just once.
        BiDict ClientId ( World.Name, PlayerName )
    , adminLoggedIn : Maybe ( ClientId, SessionId )
    , lastTenToBackendMsgs : Queue ( PlayerName, World.Name, String )
    , randomSeed : Random.Seed
    , -- We don't want to send the same data to players over and over when
      -- Tick-ing. This lets us skip that work.
      playerDataCache : Dict ClientId Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | FusionEdit Fusion.Patch.Patch
    | FusionQuery Fusion.Query
    | GoToRoute Route
    | GoToTownStore Shop
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight PlayerName
    | AskToHeal
    | AskToUseItem Item.Id
    | AskToWander
    | AskToChoosePerk Perk
    | AskToEquipArmor Item.Id
    | AskToEquipWeapon Item.Id
    | AskToPreferAmmo ItemKind.Kind
    | AskToUnequipArmor
    | AskToUnequipWeapon
    | AskToClearPreferredAmmo
    | AskToSetFightStrategy ( FightStrategy, String )
    | Refresh
    | AskForWorldsAndGoToWorldsRoute
    | AskToTagSkill Skill
    | AskToUseSkillPoints Skill
    | SetAuthName String
    | SetAuthPassword String
    | SetAuthWorld String
    | CreateChar
    | NewCharIncSpecial Special.Type
    | NewCharDecSpecial Special.Type
    | NewCharToggleTaggedSkill Skill
    | NewCharToggleTrait Trait
    | MapMouseAtCoords TileCoords
    | MapMouseOut
    | MapMouseClick
    | SetShowAreaDanger Bool
    | OpenMessage Message.Id
    | AskToRemoveMessage Message.Id
    | AskToRemoveFightMessages
    | AskToRemoveAllMessages
    | BarterMsg BarterMsg
    | HoverItem HoveredItem
    | StopHoveringItem
    | SetFightStrategyText String
    | SetAdminNewWorldName String
    | SetAdminNewWorldFast Bool
    | AskToCreateNewWorld
    | ExpandQuestItem Quest.Name
    | CollapseQuestItem Quest.Name
    | AskToStopProgressing Quest.Name
    | AskToStartProgressing Quest.Name
    | LoadFusionBackendModel
    | ResetFusionBackendModel
    | PersistFusionBackendModel


type BarterMsg
    = AddPlayerItem Item.Id Int
    | AddVendorItem Item.Id Int
    | AddPlayerCaps Int
    | AddVendorCaps Int
    | RemovePlayerItem Item.Id Int
    | RemoveVendorItem Item.Id Int
    | RemovePlayerCaps Int
    | RemoveVendorCaps Int
    | ResetBarter
    | ConfirmBarter Shop
    | SetTransferNInput Barter.TransferNPosition String
    | SetTransferNActive Barter.TransferNPosition
    | UnsetTransferNActive


type ToBackend
    = LogMeIn (Auth Hashed)
    | RegisterMe (Auth Hashed)
    | CreateNewChar NewChar
    | LogMeOut
    | Fight PlayerName
    | HealMe
    | UseItem Item.Id
    | Wander
    | EquipArmor Item.Id
    | EquipWeapon Item.Id
    | PreferAmmo ItemKind.Kind
    | SetFightStrategy ( FightStrategy, String )
    | UnequipArmor
    | UnequipWeapon
    | ClearPreferredAmmo
    | RefreshPlease
    | WorldsPlease
    | TagSkill Skill
    | UseSkillPoints Skill
    | ChoosePerk Perk
    | MoveTo TileCoords (Set TileCoords)
    | MessageWasRead Message.Id
    | RemoveMessage Message.Id
    | RemoveFightMessages
    | RemoveAllMessages
    | Barter Barter.State Shop
    | AdminToBackend AdminToBackend
    | StopProgressing Quest.Name
    | StartProgressing Quest.Name
    | FusionGiveMeBackendModel
    | ApplyThisFusionPatch Fusion.Patch.Patch


type AdminToBackend
    = CreateNewWorld String Bool


type BackendMsg
    = Connected SessionId ClientId
    | Disconnected SessionId ClientId
    | FirstTick Posix
    | Tick Posix
    | CreateNewCharWithTime ClientId NewChar Posix
    | LoggedToBackendMsg


{-| Only done for getting the automatic `Types.w3_encode_PlayerData_` encoder
(for hashing a type to Int, for caching purposes)
-}
type alias PlayerData_ =
    PlayerData


type ToFrontend
    = CurrentPlayer PlayerData
    | CurrentWorlds (List WorldInfo)
    | CurrentAdmin AdminData
    | CurrentAdminLoggedInPlayers (Dict World.Name (List PlayerName))
    | CurrentAdminLastTenToBackendMsgs (List ( PlayerName, World.Name, String ))
    | YoureLoggedOut (List WorldInfo)
    | YourFightResult ( Fight.Info, PlayerData )
    | YoureLoggedIn PlayerData
    | YoureRegistered PlayerData
    | CharCreationError NewChar.CreationError
    | YouHaveCreatedChar CPlayer PlayerData
    | AlertMessage String
    | YoureLoggedInAsAdmin AdminData
    | BarterDone ( PlayerData, Maybe Barter.Message )
    | BarterMessage Barter.Message
    | YourMessages (Dict Message.Id Message.Message)
    | FusionHeresBackendModel Fusion.Value
