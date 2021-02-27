module Evergreen.V10.Types.World exposing (..)

import Evergreen.V10.Types.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V10.Types.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V10.Types.Player.CPlayer
    , otherPlayers : (List Evergreen.V10.Types.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData