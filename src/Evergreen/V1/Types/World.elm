module Evergreen.V1.Types.World exposing (..)

import Evergreen.V1.Types.Player


type alias CWorld = 
    { player : Evergreen.V1.Types.Player.CPlayer
    , otherPlayers : (List Evergreen.V1.Types.Player.COtherPlayer)
    }