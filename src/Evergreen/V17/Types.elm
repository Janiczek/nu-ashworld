module Evergreen.V17.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V17.Data.Auth
import Evergreen.V17.Data.Fight
import Evergreen.V17.Data.NewChar
import Evergreen.V17.Data.Player
import Evergreen.V17.Data.Special
import Evergreen.V17.Data.World
import Evergreen.V17.Frontend.Route
import Lamdera
import Time
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , zone : Time.Zone
    , route : Evergreen.V17.Frontend.Route.Route
    , world : Evergreen.V17.Data.World.World
    , newChar : Evergreen.V17.Data.NewChar.NewChar
    }


type alias BackendModel =
    { players : (Dict.Dict Evergreen.V17.Data.Player.PlayerName (Evergreen.V17.Data.Player.Player Evergreen.V17.Data.Player.SPlayer))
    , loggedInPlayers : (Dict.Dict Lamdera.ClientId Evergreen.V17.Data.Player.PlayerName)
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GoToRoute Evergreen.V17.Frontend.Route.Route
    | Logout
    | Login
    | Register
    | NoOp
    | GetZone Time.Zone
    | AskToFight Evergreen.V17.Data.Player.PlayerName
    | Refresh
    | AskToIncSpecial Evergreen.V17.Data.Special.SpecialType
    | SetAuthName String
    | SetAuthPassword String
    | CreateChar


type ToBackend
    = LogMeIn (Evergreen.V17.Data.Auth.Auth Evergreen.V17.Data.Auth.Hashed)
    | RegisterMe (Evergreen.V17.Data.Auth.Auth Evergreen.V17.Data.Auth.Hashed)
    | CreateNewChar Evergreen.V17.Data.NewChar.NewChar
    | LogMeOut
    | Fight Evergreen.V17.Data.Player.PlayerName
    | RefreshPlease
    | IncSpecial Evergreen.V17.Data.Special.SpecialType


type BackendMsg
    = Connected Lamdera.SessionId Lamdera.ClientId
    | GeneratedFight Lamdera.ClientId Evergreen.V17.Data.Player.SPlayer Evergreen.V17.Data.Fight.FightInfo


type ToFrontend
    = YourCurrentWorld Evergreen.V17.Data.World.WorldLoggedInData
    | CurrentWorld Evergreen.V17.Data.World.WorldLoggedOutData
    | YourFightResult (Evergreen.V17.Data.Fight.FightInfo, Evergreen.V17.Data.World.WorldLoggedInData)
    | YoureLoggedIn Evergreen.V17.Data.World.WorldLoggedInData
    | YoureRegistered Evergreen.V17.Data.World.WorldLoggedInData
    | YouHaveCreatedChar Evergreen.V17.Data.World.WorldLoggedInData
    | YoureLoggedOut Evergreen.V17.Data.World.WorldLoggedOutData