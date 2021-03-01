module Evergreen.V17.Data.World exposing (..)

import Evergreen.V17.Data.Auth
import Evergreen.V17.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V17.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V17.Data.Player.Player Evergreen.V17.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V17.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V17.Data.Auth.Auth Evergreen.V17.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V17.Data.Auth.Auth Evergreen.V17.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData