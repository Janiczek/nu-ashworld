module Evergreen.V45.Data.World exposing (..)

import Evergreen.V45.Data.Auth
import Evergreen.V45.Data.Player
import Set
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V45.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V45.Data.Player.Player Evergreen.V45.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V45.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V45.Data.Player.Player Evergreen.V45.Data.Player.SPlayer))
    , loggedInPlayers : (Set.Set Evergreen.V45.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V45.Data.Auth.Auth Evergreen.V45.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V45.Data.Auth.Auth Evergreen.V45.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData