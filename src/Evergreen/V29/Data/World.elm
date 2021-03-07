module Evergreen.V29.Data.World exposing (..)

import Evergreen.V29.Data.Auth
import Evergreen.V29.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V29.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V29.Data.Player.Player Evergreen.V29.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V29.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V29.Data.Auth.Auth Evergreen.V29.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V29.Data.Auth.Auth Evergreen.V29.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData