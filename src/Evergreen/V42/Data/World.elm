module Evergreen.V42.Data.World exposing (..)

import Evergreen.V42.Data.Auth
import Evergreen.V42.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V42.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V42.Data.Player.Player Evergreen.V42.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V42.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V42.Data.Auth.Auth Evergreen.V42.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V42.Data.Auth.Auth Evergreen.V42.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData