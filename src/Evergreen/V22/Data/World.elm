module Evergreen.V22.Data.World exposing (..)

import Evergreen.V22.Data.Auth
import Evergreen.V22.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V22.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V22.Data.Player.Player Evergreen.V22.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V22.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V22.Data.Auth.Auth Evergreen.V22.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V22.Data.Auth.Auth Evergreen.V22.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData