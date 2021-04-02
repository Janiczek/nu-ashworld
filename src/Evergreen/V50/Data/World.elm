module Evergreen.V50.Data.World exposing (..)

import Evergreen.V50.Data.Auth
import Evergreen.V50.Data.Player
import Set
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V50.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V50.Data.Player.Player Evergreen.V50.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V50.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V50.Data.Player.Player Evergreen.V50.Data.Player.SPlayer))
    , loggedInPlayers : (Set.Set Evergreen.V50.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V50.Data.Auth.Auth Evergreen.V50.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V50.Data.Auth.Auth Evergreen.V50.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData