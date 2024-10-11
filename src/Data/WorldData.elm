module Data.WorldData exposing
    ( AdminData
    , PlayerData
    , WorldData(..)
    , allPlayers
    , isAdmin
    , isPlayer
    )

import Data.Ladder as Ladder
import Data.Player
    exposing
        ( COtherPlayer
        , CPlayer
        , Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest
import Data.Tick exposing (TickPerIntervalCurve)
import Data.Vendor exposing (Vendor)
import Data.Vendor.Shop exposing (Shop)
import Data.World as World
import Dict exposing (Dict)
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
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
    , description : String
    , startedAt : Posix
    , tickFrequency : Time.Interval
    , tickPerIntervalCurve : TickPerIntervalCurve
    , vendorRestockFrequency : Time.Interval
    , player : Player CPlayer
    , otherPlayers : List COtherPlayer
    , -- 1-based rank. The player's position (index) in the ladder is `this - 1`
      playerRank : Int
    , vendors : SeqDict Shop Vendor
    , questsProgress : SeqDict Quest.Name Quest.Progress
    , questRewardShops : SeqSet Shop
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
