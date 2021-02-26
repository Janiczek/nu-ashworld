module Evergreen.V6.Types.World exposing (..)

import Evergreen.V6.Types.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V6.Types.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V6.Types.Player.CPlayer
    , otherPlayers : (List Evergreen.V6.Types.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData