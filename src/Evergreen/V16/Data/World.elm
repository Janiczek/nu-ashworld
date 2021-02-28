module Evergreen.V16.Data.World exposing (..)

import Evergreen.V16.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V16.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V16.Data.Player.CPlayer
    , otherPlayers : (List Evergreen.V16.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData