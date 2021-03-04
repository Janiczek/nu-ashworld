module Evergreen.V27.Data.World exposing (..)

import Evergreen.V27.Data.Auth
import Evergreen.V27.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V27.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V27.Data.Player.Player Evergreen.V27.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V27.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V27.Data.Auth.Auth Evergreen.V27.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V27.Data.Auth.Auth Evergreen.V27.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData