module Evergreen.V37.Data.World exposing (..)

import Evergreen.V37.Data.Auth
import Evergreen.V37.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V37.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V37.Data.Player.Player Evergreen.V37.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V37.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V37.Data.Auth.Auth Evergreen.V37.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V37.Data.Auth.Auth Evergreen.V37.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData