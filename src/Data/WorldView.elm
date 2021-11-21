module Data.WorldView exposing
    ( AdminView
    , LoggedInView
    , LoggedOutView
    , WorldView(..)
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
type WorldView
    = NotInitialized (Auth Plaintext)
    | LoggedOut (Auth Plaintext) LoggedOutView
    | LoggedIn LoggedInView
    | Admin AdminView


{-| Very similar to Types.BackendModel
-}
type alias AdminView =
    { players : List (Player SPlayer)
    , loggedInPlayers : List PlayerName
    , nextWantedTick : Maybe Posix

    -- TODO perhaps have the shops here too, for some manual admin addition of items?
    }


type alias LoggedOutView =
    { players : List COtherPlayer
    }


type alias LoggedInView =
    { player : Player CPlayer
    , otherPlayers : List COtherPlayer
    , -- 1-based rank. The player's position (index) in the ladder is `this - 1`
      playerRank : Int
    , vendors : Dict_.Dict Vendor.Name Vendor
    }


allPlayers : LoggedInView -> List COtherPlayer
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


isLoggedIn : WorldView -> Bool
isLoggedIn world =
    case world of
        NotInitialized _ ->
            False

        LoggedOut _ _ ->
            False

        LoggedIn _ ->
            True

        Admin _ ->
            False


isAdmin : WorldView -> Bool
isAdmin world =
    case world of
        NotInitialized _ ->
            False

        LoggedOut _ _ ->
            False

        LoggedIn _ ->
            False

        Admin _ ->
            True


getAuth : WorldView -> Maybe (Auth Plaintext)
getAuth world =
    case world of
        NotInitialized auth ->
            Just auth

        LoggedOut auth _ ->
            Just auth

        LoggedIn _ ->
            Nothing

        Admin _ ->
            Nothing


mapAuth : (Auth Plaintext -> Auth Plaintext) -> WorldView -> WorldView
mapAuth fn world =
    case world of
        NotInitialized auth ->
            NotInitialized <| fn auth

        LoggedOut auth data ->
            LoggedOut (fn auth) data

        LoggedIn data ->
            LoggedIn data

        Admin data ->
            Admin data
