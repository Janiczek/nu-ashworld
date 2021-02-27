module Evergreen.V13.Data.World exposing (..)

import Evergreen.V13.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V13.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V13.Data.Player.CPlayer
    , otherPlayers : (List Evergreen.V13.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData