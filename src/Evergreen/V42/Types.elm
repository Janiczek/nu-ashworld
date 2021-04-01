module Evergreen.V42.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V42.Data.Auth
import Evergreen.V42.Data.Fight
import Evergreen.V42.Data.Map
import Evergreen.V42.Data.NewChar
import Evergreen.V42.Data.Player
import Evergreen.V42.Data.Special
import Evergreen.V42.Data.World
import Evergreen.V42.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V42.Frontend.Route.Route
    , world : Evergreen.V42.Data.World.World
    , newChar : Evergreen.V42.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V42.Data.Map.TileCoords, (Set.Set Evergreen.V42.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V42.Data.Player.PlayerName (Evergreen.V42.Data.Player.Player Evergreen.V42.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V42.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V42.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V42.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V42.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V42.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V42.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V42.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type ToBackend
    = LogMeIn (Evergreen.V42.Data.Auth.Auth Evergreen.V42.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V42.Data.Auth.Auth Evergreen.V42.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V42.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V42.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V42.Data.Special.SpecialType
    | MoveTo Evergreen.V42.Data.Map.TileCoords (Set.Set Evergreen.V42.Data.Map.TileCoords)


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V42.Data.Player.SPlayer Evergreen.V42.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V42.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V42.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V42.Data.Fight.FightInfo, Evergreen.V42.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V42.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V42.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V42.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V42.Data.World.WorldLoggedOutData
    | AuthError String