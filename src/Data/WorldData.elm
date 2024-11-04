module Data.WorldData exposing
    ( AdminData
    , PlayerData
    , WorldData(..)
    , allPlayers
    , isAdmin
    , isPlayer
    , isPlayerSigningUp
    , mapPlayerData
    , setOtherPlayers
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
    | IsPlayerSigningUp
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
    , player : CPlayer
    , otherPlayers : List COtherPlayer
    , -- 1-based rank. The player's position (index) in the ladder is `this - 1`
      playerRank : Int
    , vendors : SeqDict Shop Vendor
    , questsProgress : SeqDict Quest.Name Quest.Progress
    , questRewardShops : SeqSet Shop
    }


allPlayers : PlayerData -> List COtherPlayer
allPlayers world =
    Ladder.sortMixed
        { player = world.player
        , playerRank = world.playerRank
        , otherPlayers = world.otherPlayers
        }


isPlayer : WorldData -> Bool
isPlayer data =
    case data of
        IsPlayer _ ->
            True

        IsPlayerSigningUp ->
            False

        IsAdmin _ ->
            False

        NotLoggedIn ->
            False


isPlayerSigningUp : WorldData -> Bool
isPlayerSigningUp data =
    case data of
        IsPlayerSigningUp ->
            True

        IsPlayer _ ->
            False

        IsAdmin _ ->
            False

        NotLoggedIn ->
            False


isAdmin : WorldData -> Bool
isAdmin data =
    case data of
        IsAdmin _ ->
            True

        IsPlayerSigningUp ->
            False

        IsPlayer _ ->
            False

        NotLoggedIn ->
            False


mapPlayerData : (PlayerData -> PlayerData) -> WorldData -> WorldData
mapPlayerData fn data =
    case data of
        IsPlayer playerData ->
            IsPlayer (fn playerData)

        IsPlayerSigningUp ->
            data

        IsAdmin _ ->
            data

        NotLoggedIn ->
            data


setOtherPlayers : List COtherPlayer -> WorldData -> WorldData
setOtherPlayers otherPlayers world =
    world
        |> mapPlayerData (\playerData -> { playerData | otherPlayers = otherPlayers })
