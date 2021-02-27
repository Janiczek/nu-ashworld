module Data.World exposing
    ( World(..)
    , WorldLoggedInData
    , WorldLoggedOutData
    , allPlayers
    , isLoggedIn
    , toLoggedOut
    )

import Data.Player as Player exposing (COtherPlayer, CPlayer)


type World
    = WorldNotInitialized
    | WorldLoggedOut WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData


type alias WorldLoggedOutData =
    { players : List COtherPlayer
    }


type alias WorldLoggedInData =
    { player : CPlayer
    , otherPlayers : List COtherPlayer
    }


allPlayers : WorldLoggedInData -> List COtherPlayer
allPlayers { player, otherPlayers } =
    Player.clientToClientOther player
        :: otherPlayers


toLoggedOut : World -> World
toLoggedOut world =
    case world of
        WorldNotInitialized ->
            WorldNotInitialized

        WorldLoggedOut data ->
            WorldLoggedOut data

        WorldLoggedIn data ->
            WorldLoggedOut { players = allPlayers data }


isLoggedIn : World -> Bool
isLoggedIn world =
    case world of
        WorldNotInitialized ->
            False

        WorldLoggedOut _ ->
            False

        WorldLoggedIn _ ->
            True
