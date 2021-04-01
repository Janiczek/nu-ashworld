module Evergreen.V49.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V49.Data.Auth
import Evergreen.V49.Data.Fight
import Evergreen.V49.Data.Map
import Evergreen.V49.Data.NewChar
import Evergreen.V49.Data.Player
import Evergreen.V49.Data.Special
import Evergreen.V49.Data.World
import Evergreen.V49.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V49.Frontend.Route.Route
    , world : Evergreen.V49.Data.World.World
    , newChar : Evergreen.V49.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V49.Data.Map.TileCoords, (Set.Set Evergreen.V49.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V49.Data.Player.PlayerName (Evergreen.V49.Data.Player.Player Evergreen.V49.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V49.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V49.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V49.Data.Player.PlayerName
    | AskToHeal
    | Refresh
    | AskToIncSpecial Evergreen.V49.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V49.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V49.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V49.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type AdminToBackend
    = Foo


type ToBackend
    = LogMeIn (Evergreen.V49.Data.Auth.Auth Evergreen.V49.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V49.Data.Auth.Auth Evergreen.V49.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V49.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V49.Data.Player.PlayerName
    | HealMe
    | RefreshPlease
    | IncSpecial Evergreen.V49.Data.Special.SpecialType
    | MoveTo Evergreen.V49.Data.Map.TileCoords (Set.Set Evergreen.V49.Data.Map.TileCoords)
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V49.Data.Player.SPlayer Evergreen.V49.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V49.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V49.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V49.Data.World.AdminData
    | YourFightResult (Evergreen.V49.Data.Fight.FightInfo, Evergreen.V49.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V49.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V49.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V49.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V49.Data.World.WorldLoggedOutData
    | AuthError String
    | YoureLoggedInAsAdmin Evergreen.V49.Data.World.AdminData