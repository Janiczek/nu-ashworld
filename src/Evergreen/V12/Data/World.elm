module Evergreen.V12.Data.World exposing (..)

import Evergreen.V12.Data.Player


type alias WorldLoggedOutData = 
    { players : (List Evergreen.V12.Data.Player.COtherPlayer)
    }


type alias WorldLoggedInData = 
    { player : Evergreen.V12.Data.Player.CPlayer
    , otherPlayers : (List Evergreen.V12.Data.Player.COtherPlayer)
    }


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData