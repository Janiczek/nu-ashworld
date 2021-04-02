module Data.World exposing
    ( AdminData
    , World(..)
    , WorldLoggedInData
    , WorldLoggedOutData
    , allPlayers
    , getAuth
    , isAdmin
    , isLoggedIn
    , mapAuth
    )

import Data.Auth exposing (Auth, Plaintext)
import Data.Player as Player
    exposing
        ( COtherPlayer
        , CPlayer
        , Player(..)
        , PlayerName
        , SPlayer
        )
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JDE
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Set exposing (Set)
import Time exposing (Posix)


{-| TODO it would be nice if we didn't have to send the hashed password back to the user
-}
type World
    = WorldNotInitialized (Auth Plaintext)
    | WorldLoggedOut (Auth Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData


{-| Very similar to Types.BackendModel
-}
type alias AdminData =
    { players : List (Player SPlayer)
    , loggedInPlayers : Set PlayerName
    , nextWantedTick : Maybe Posix
    }


type alias WorldLoggedOutData =
    { players : List COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Player CPlayer
    , otherPlayers : List COtherPlayer
    }


allPlayers : WorldLoggedInData -> List COtherPlayer
allPlayers world =
    case world.player of
        NeedsCharCreated _ ->
            world.otherPlayers

        Player cPlayer ->
            Player.clientToClientOther cPlayer
                :: world.otherPlayers


isLoggedIn : World -> Bool
isLoggedIn world =
    case world of
        WorldNotInitialized _ ->
            False

        WorldLoggedOut _ _ ->
            False

        WorldLoggedIn _ ->
            True

        WorldAdmin _ ->
            False


isAdmin : World -> Bool
isAdmin world =
    case world of
        WorldNotInitialized _ ->
            False

        WorldLoggedOut _ _ ->
            False

        WorldLoggedIn _ ->
            False

        WorldAdmin _ ->
            True


getAuth : World -> Maybe (Auth Plaintext)
getAuth world =
    case world of
        WorldNotInitialized auth ->
            Just auth

        WorldLoggedOut auth _ ->
            Just auth

        WorldLoggedIn _ ->
            Nothing

        WorldAdmin _ ->
            Nothing


mapAuth : (Auth Plaintext -> Auth Plaintext) -> World -> World
mapAuth fn world =
    case world of
        WorldNotInitialized auth ->
            WorldNotInitialized <| fn auth

        WorldLoggedOut auth data ->
            WorldLoggedOut (fn auth) data

        WorldLoggedIn data ->
            WorldLoggedIn data

        WorldAdmin data ->
            WorldAdmin data
