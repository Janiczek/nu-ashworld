module Evergreen.V3.Types.World exposing (..)

import Evergreen.V3.Types.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V3.Types.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V3.Types.Player.CPlayer
    , otherPlayers : (List Evergreen.V3.Types.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData