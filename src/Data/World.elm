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

import AssocList as Dict_
import Data.Auth exposing (Auth, Plaintext)
import Data.Ladder as Ladder
import Data.Player
    exposing
        ( COtherPlayer
        , CPlayer
        , Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Vendor as Vendor exposing (Vendor)
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
    , loggedInPlayers : List PlayerName
    , nextWantedTick : Maybe Posix

    -- TODO perhaps have the shops here too, for some manual admin addition of items?
    }


type alias WorldLoggedOutData =
    { players : List COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Player CPlayer
    , otherPlayers : List COtherPlayer
    , -- 1-based rank. The player's position (index) in the ladder is `this - 1`
      playerRank : Int
    , vendors : Dict_.Dict Vendor.Name Vendor
    }


allPlayers : WorldLoggedInData -> List COtherPlayer
allPlayers world =
    case world.player of
        NeedsCharCreated _ ->
            world.otherPlayers

        Player cPlayer ->
            Ladder.sortMixed
                { player = cPlayer
                , playerRank = world.playerRank
                , otherPlayers = world.otherPlayers
                }


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
