module Evergreen.V51.Data.World exposing (..)

import Evergreen.V51.Data.Auth
import Evergreen.V51.Data.Player
import Set
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V51.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V51.Data.Player.Player Evergreen.V51.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V51.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V51.Data.Player.Player Evergreen.V51.Data.Player.SPlayer))
    , loggedInPlayers : (Set.Set Evergreen.V51.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V51.Data.Auth.Auth Evergreen.V51.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V51.Data.Auth.Auth Evergreen.V51.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData