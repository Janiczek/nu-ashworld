module Evergreen.V55.Data.World exposing (..)

import Evergreen.V55.Data.Auth
import Evergreen.V55.Data.Player
import Time


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V55.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V55.Data.Player.Player Evergreen.V55.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V55.Data.Player.COtherPlayer)
    }


type alias AdminData = 
    { players : (List (Evergreen.V55.Data.Player.Player Evergreen.V55.Data.Player.SPlayer))
    , loggedInPlayers : (List Evergreen.V55.Data.Player.PlayerName)
    , nextWantedTick : (Maybe Time.Posix)
    }


type World
    = WorldNotInitialized (Evergreen.V55.Data.Auth.Auth Evergreen.V55.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V55.Data.Auth.Auth Evergreen.V55.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData