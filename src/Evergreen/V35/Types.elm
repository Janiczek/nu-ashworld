module Evergreen.V35.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V35.Data.Auth
import Evergreen.V35.Data.Fight
import Evergreen.V35.Data.Map
import Evergreen.V35.Data.NewChar
import Evergreen.V35.Data.Player
import Evergreen.V35.Data.Special
import Evergreen.V35.Data.World
import Evergreen.V35.Frontend.Route
import Lamdera
import Set
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , time : Time.Posix
    , zone : Time.Zone
    , route : Evergreen.V35.Frontend.Route.Route
    , world : Evergreen.V35.Data.World.World
    , newChar : Evergreen.V35.Data.NewChar.NewChar
    , authError : (Maybe String)
    , mapMouseCoords : (Maybe (Evergreen.V35.Data.Map.TileCoords, (Set.Set Evergreen.V35.Data.Map.TileCoords)))
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V35.Data.Player.PlayerName (Evergreen.V35.Data.Player.Player Evergreen.V35.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V35.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V35.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | GotZone Time.Zone
    | GotTime Time.Posix
    | AskToFight Evergreen.V35.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V35.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar
    | NewCharIncSpecial Evergreen.V35.Data.Special.SpecialType
    | NewCharDecSpecial Evergreen.V35.Data.Special.SpecialType
    | MapMouseAtCoords Evergreen.V35.Data.Map.TileCoords
    | MapMouseOut
    | MapMouseClick


type ToBackend
    = LogMeIn (Evergreen.V35.Data.Auth.Auth Evergreen.V35.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V35.Data.Auth.Auth Evergreen.V35.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V35.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V35.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V35.Data.Special.SpecialType
    | MoveTo Evergreen.V35.Data.Map.TileCoords (Set.Set Evergreen.V35.Data.Map.TileCoords)


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | Disconnected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V35.Data.Player.SPlayer Evergreen.V35.Data.Fight.FightInfo
    | Tick Time.Posix


type ToFrontend
    = YourCurrentWorld Evergreen.V35.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V35.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V35.Data.Fight.FightInfo, Evergreen.V35.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V35.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V35.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V35.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V35.Data.World.WorldLoggedOutData
    | AuthError String