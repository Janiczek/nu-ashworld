module Evergreen.V29.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V29.Data.Auth
import Evergreen.V29.Data.Fight
import Evergreen.V29.Data.Map
import Evergreen.V29.Data.NewChar
import Evergreen.V29.Data.Player
import Evergreen.V29.Data.Special
import Evergreen.V29.Data.World
import Evergreen.V29.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V29.Frontend.Route.Route
    , world : Evergreen.V29.Data.World.World
    , newChar : Evergreen.V29.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V29.Data.Map.TileCoords, (Set.Set Evergreen.V29.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V29.Data.Player.PlayerName (Evergreen.V29.Data.Player.Player Evergreen.V29.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V29.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V29.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V29.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V29.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V29.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V29.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V29.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type ToBackend
    = LogMeIn (Evergreen.V29.Data.Auth.Auth Evergreen.V29.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V29.Data.Auth.Auth Evergreen.V29.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V29.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V29.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V29.Data.Special.SpecialType
    | MoveTo Evergreen.V29.Data.Map.TileCoords (Set.Set Evergreen.V29.Data.Map.TileCoords)


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V29.Data.Player.SPlayer Evergreen.V29.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V29.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V29.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V29.Data.Fight.FightInfo, Evergreen.V29.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V29.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V29.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V29.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V29.Data.World.WorldLoggedOutData
    | AuthError String