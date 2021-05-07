module Evergreen.V85.Data.World exposing (..)

import AssocList
import Evergreen.V85.Data.Auth
import Evergreen.V85.Data.Player
import Evergreen.V85.Data.Player.PlayerName
import Evergreen.V85.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V85.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V85.Data.Player.Player Evergreen.V85.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V85.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V85.Data.Vendor.Name Evergreen.V85.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V85.Data.Player.Player Evergreen.V85.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V85.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V85.Data.Auth.Auth Evergreen.V85.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V85.Data.Auth.Auth Evergreen.V85.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
