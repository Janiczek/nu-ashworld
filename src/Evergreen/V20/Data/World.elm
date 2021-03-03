module Evergreen.V20.Data.World exposing (..)

import Evergreen.V20.Data.Auth
import Evergreen.V20.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V20.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V20.Data.Player.Player Evergreen.V20.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V20.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V20.Data.Auth.Auth Evergreen.V20.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V20.Data.Auth.Auth Evergreen.V20.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData