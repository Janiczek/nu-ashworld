module Evergreen.V8.Types.World exposing (..)

import Evergreen.V8.Types.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V8.Types.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V8.Types.Player.CPlayer
    , otherPlayers : (List Evergreen.V8.Types.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData