module Types.World exposing (CWorld)

import Types.Player exposing (COtherPlayer, CPlayer)


type alias CWorld =
    { player : CPlayer
    , otherPlayers : List COtherPlayer
    }
