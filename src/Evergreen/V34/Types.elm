module Evergreen.V34.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V34.Data.Auth
import Evergreen.V34.Data.Fight
import Evergreen.V34.Data.Map
import Evergreen.V34.Data.NewChar
import Evergreen.V34.Data.Player
import Evergreen.V34.Data.Special
import Evergreen.V34.Data.World
import Evergreen.V34.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V34.Frontend.Route.Route
    , world : Evergreen.V34.Data.World.World
    , newChar : Evergreen.V34.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V34.Data.Map.TileCoords, (Set.Set Evergreen.V34.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V34.Data.Player.PlayerName (Evergreen.V34.Data.Player.Player Evergreen.V34.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V34.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V34.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V34.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V34.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V34.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V34.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V34.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type ToBackend
    = LogMeIn (Evergreen.V34.Data.Auth.Auth Evergreen.V34.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V34.Data.Auth.Auth Evergreen.V34.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V34.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V34.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V34.Data.Special.SpecialType
    | MoveTo Evergreen.V34.Data.Map.TileCoords (Set.Set Evergreen.V34.Data.Map.TileCoords)


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V34.Data.Player.SPlayer Evergreen.V34.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V34.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V34.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V34.Data.Fight.FightInfo, Evergreen.V34.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V34.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V34.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V34.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V34.Data.World.WorldLoggedOutData
    | AuthError String