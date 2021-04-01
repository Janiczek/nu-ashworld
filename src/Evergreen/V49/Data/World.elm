module Evergreen.V49.Data.World exposing (..)

import Evergreen.V49.Data.Auth
import Evergreen.V49.Data.Player
import Set
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V49.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V49.Data.Player.Player Evergreen.V49.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V49.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V49.Data.Player.Player Evergreen.V49.Data.Player.SPlayer))
    , loggedInPlayers : (Set.Set Evergreen.V49.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V49.Data.Auth.Auth Evergreen.V49.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V49.Data.Auth.Auth Evergreen.V49.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData