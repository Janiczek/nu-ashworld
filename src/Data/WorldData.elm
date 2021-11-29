module Data.WorldData exposing
    ( AdminData
    , PlayerData
    , WorldData(..)
    , allPlayers
    , isAdmin
    , isPlayer
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
import Data.Tick exposing (TickPerIntervalCurve)
import Data.Vendor as Vendor exposing (Vendor)
import Data.World as World exposing (World)
import Dict exposing (Dict)
import Time exposing (Posix)
import Time.Extra as Time


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | NotLoggedIn


type alias AdminData =
    { worlds :
        Dict
            World.Name
            { players : Dict PlayerName (Player SPlayer)
            , nextWantedTick : Maybe Posix
            , description : String
            , startedAt : Posix
            , tickFrequency : Time.Interval
            , tickPerIntervalCurve : TickPerIntervalCurve
            , vendorRestockFrequency : Time.Interval
            }
    , loggedInPlayers : Dict World.Name (List PlayerName)

    -- TODO perhaps have the shops here too, for some manual admin addition of items?
    }


type alias PlayerData =
    { worldName : World.Name
    , tickFrequency : Time.Interval
    , player : Player CPlayer
    , otherPlayers : List COtherPlayer
    , -- 1-based rank. The player's position (index) in the ladder is `this - 1`
      playerRank : Int
    , vendors : Dict_.Dict Vendor.Name Vendor
    }


allPlayers : PlayerData -> List COtherPlayer
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


isPlayer : WorldData -> Bool
isPlayer data =
    case data of
        IsPlayer _ ->
            True

        IsAdmin _ ->
            False

        NotLoggedIn ->
            False


isAdmin : WorldData -> Bool
isAdmin data =
    case data of
        IsAdmin _ ->
            True

        IsPlayer _ ->
            False

        NotLoggedIn ->
            False
