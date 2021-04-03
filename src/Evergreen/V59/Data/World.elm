module Evergreen.V59.Data.World exposing (..)

import Evergreen.V59.Data.Auth
import Evergreen.V59.Data.Player
import Evergreen.V59.Data.Player.PlayerName
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V59.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V59.Data.Player.Player Evergreen.V59.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V59.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V59.Data.Player.Player Evergreen.V59.Data.Player.SPlayer))
    , loggedInPlayers : (List Evergreen.V59.Data.Player.PlayerName.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V59.Data.Auth.Auth Evergreen.V59.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V59.Data.Auth.Auth Evergreen.V59.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData