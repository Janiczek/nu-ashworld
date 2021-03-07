module Data.Player exposing
    ( COtherPlayer
    , CPlayer
    , Player(..)
    , PlayerName
    , SPlayer
    , clientToClientOther
    , fromNewChar
    , getAuth
    , getPlayerData
    , map
    , serverToClient
    , serverToClientOther
    )

import Data.Auth
    exposing
        ( Auth
        , HasAuth
        , Password
        , Verified
        )
import Data.HealthStatus as HealthStatus exposing (HealthStatus)
import Data.Map as Map exposing (TileNum)
import Data.Map.Location as Location
import Data.NewChar exposing (NewChar)
import Data.Special exposing (Special)
import Data.Xp as Xp exposing (Level, Xp)
import Logic
import Set exposing (Set)


type alias PlayerName =
    String


type Player a
    = NeedsCharCreated (Auth Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Xp
    , name : PlayerName
    , special : Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    , location : TileNum
    , knownMapTiles : Set TileNum
    }


type alias COtherPlayer =
    { level : Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : HealthStatus
    }


type alias SPlayer =
    { name : PlayerName
    , password : Password Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    , location : TileNum
    , knownMapTiles : Set TileNum
    }


serverToClient : SPlayer -> CPlayer
serverToClient p =
    { hp = p.hp
    , maxHp = p.maxHp
    , xp = p.xp
    , name = p.name
    , special = p.special
    , availableSpecial = p.availableSpecial
    , caps = p.caps
    , ap = p.ap
    , wins = p.wins
    , losses = p.losses
    , location = p.location
    , knownMapTiles = p.knownMapTiles
    }


serverToClientOther : { perception : Int } -> SPlayer -> COtherPlayer
serverToClientOther { perception } p =
    { level = Xp.currentLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    , healthStatus = HealthStatus.check perception p
    }


clientToClientOther : CPlayer -> COtherPlayer
clientToClientOther p =
    { level = Xp.currentLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    , healthStatus =
        HealthStatus.ExactHp
            { current = p.hp
            , max = p.maxHp
            }
    }


map : (a -> b) -> Player a -> Player b
map fn player =
    case player of
        NeedsCharCreated auth ->
            NeedsCharCreated auth

        Player a ->
            Player <| fn a


getPlayerData : Player a -> Maybe a
getPlayerData player =
    case player of
        NeedsCharCreated _ ->
            Nothing

        Player data ->
            Just data


getAuth : Player (HasAuth a) -> Auth Verified
getAuth player =
    case player of
        NeedsCharCreated auth ->
            auth

        Player data ->
            { name = data.name
            , password = data.password
            }


fromNewChar : Auth Verified -> NewChar -> SPlayer
fromNewChar auth newChar =
    let
        hp : Int
        hp =
            Logic.hitpoints
                { level = 1
                , special = newChar.special
                }

        startingTileNum : TileNum
        startingTileNum =
            Location.default
                |> Location.coords
                |> Map.toTileNum
    in
    { name = auth.name
    , password = auth.password
    , hp = hp
    , maxHp = hp
    , xp = 0
    , special = newChar.special
    , availableSpecial = newChar.availableSpecial
    , caps = 15
    , ap = 10
    , wins = 0
    , losses = 0
    , location = startingTileNum
    , knownMapTiles = Set.singleton startingTileNum
    }
