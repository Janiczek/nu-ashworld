module Evergreen.V34.Data.World exposing (..)

import Evergreen.V34.Data.Auth
import Evergreen.V34.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V34.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V34.Data.Player.Player Evergreen.V34.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V34.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V34.Data.Auth.Auth Evergreen.V34.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V34.Data.Auth.Auth Evergreen.V34.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData