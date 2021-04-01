module Evergreen.V45.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V45.Data.Auth
import Evergreen.V45.Data.Fight
import Evergreen.V45.Data.Map
import Evergreen.V45.Data.NewChar
import Evergreen.V45.Data.Player
import Evergreen.V45.Data.Special
import Evergreen.V45.Data.World
import Evergreen.V45.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V45.Frontend.Route.Route
    , world : Evergreen.V45.Data.World.World
    , newChar : Evergreen.V45.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V45.Data.Map.TileCoords, (Set.Set Evergreen.V45.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V45.Data.Player.PlayerName (Evergreen.V45.Data.Player.Player Evergreen.V45.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V45.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    , adminLoggedIn : (Maybe (Lamdera.ClientId, Lamdera.SessionId))
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V45.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V45.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V45.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V45.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V45.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V45.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type AdminToBackend
    = Foo


type ToBackend
    = LogMeIn (Evergreen.V45.Data.Auth.Auth Evergreen.V45.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V45.Data.Auth.Auth Evergreen.V45.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V45.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V45.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V45.Data.Special.SpecialType
    | MoveTo Evergreen.V45.Data.Map.TileCoords (Set.Set Evergreen.V45.Data.Map.TileCoords)
    | AdminToBackend AdminToBackend


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V45.Data.Player.SPlayer Evergreen.V45.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V45.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V45.Data.World.WorldLoggedOutData
    | CurrentAdminData Evergreen.V45.Data.World.AdminData
    | YourFightResult (Evergreen.V45.Data.Fight.FightInfo, Evergreen.V45.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V45.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V45.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V45.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V45.Data.World.WorldLoggedOutData
    | AuthError String
    | YoureLoggedInAsAdmin Evergreen.V45.Data.World.AdminData