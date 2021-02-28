module Evergreen.V15.Data.World exposing (..)

import Evergreen.V15.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V15.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V15.Data.Player.CPlayer
    , otherPlayers : (List Evergreen.V15.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData