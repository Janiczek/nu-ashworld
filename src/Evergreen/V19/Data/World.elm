module Evergreen.V19.Data.World exposing (..)

import Evergreen.V19.Data.Auth
import Evergreen.V19.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V19.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V19.Data.Player.Player Evergreen.V19.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V19.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V19.Data.Auth.Auth Evergreen.V19.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V19.Data.Auth.Auth Evergreen.V19.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData