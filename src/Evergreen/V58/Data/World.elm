module Evergreen.V58.Data.World exposing (..)

import Evergreen.V58.Data.Auth
import Evergreen.V58.Data.Player
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V58.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V58.Data.Player.Player Evergreen.V58.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V58.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V58.Data.Player.Player Evergreen.V58.Data.Player.SPlayer))
    , loggedInPlayers : (List Evergreen.V58.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V58.Data.Auth.Auth Evergreen.V58.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V58.Data.Auth.Auth Evergreen.V58.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData