module Evergreen.V35.Data.World exposing (..)

import Evergreen.V35.Data.Auth
import Evergreen.V35.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V35.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : (Evergreen.V35.Data.Player.Player Evergreen.V35.Data.Player.CPlayer)
    , otherPlayers : (List Evergreen.V35.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized (Evergreen.V35.Data.Auth.Auth Evergreen.V35.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V35.Data.Auth.Auth Evergreen.V35.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData