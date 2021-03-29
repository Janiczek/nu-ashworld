module Evergreen.V37.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V37.Data.Auth
import Evergreen.V37.Data.Fight
import Evergreen.V37.Data.Map
import Evergreen.V37.Data.NewChar
import Evergreen.V37.Data.Player
import Evergreen.V37.Data.Special
import Evergreen.V37.Data.World
import Evergreen.V37.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V37.Frontend.Route.Route
    , world : Evergreen.V37.Data.World.World
    , newChar : Evergreen.V37.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V37.Data.Map.TileCoords, (Set.Set Evergreen.V37.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V37.Data.Player.PlayerName (Evergreen.V37.Data.Player.Player Evergreen.V37.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V37.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V37.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V37.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V37.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V37.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V37.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V37.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type ToBackend
    = LogMeIn (Evergreen.V37.Data.Auth.Auth Evergreen.V37.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V37.Data.Auth.Auth Evergreen.V37.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V37.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V37.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V37.Data.Special.SpecialType
    | MoveTo Evergreen.V37.Data.Map.TileCoords (Set.Set Evergreen.V37.Data.Map.TileCoords)


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V37.Data.Player.SPlayer Evergreen.V37.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V37.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V37.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V37.Data.Fight.FightInfo, Evergreen.V37.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V37.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V37.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V37.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V37.Data.World.WorldLoggedOutData
    | AuthError String