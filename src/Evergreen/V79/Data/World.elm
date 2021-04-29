module Evergreen.V79.Data.World exposing (..)

import AssocList
import Evergreen.V79.Data.Auth
import Evergreen.V79.Data.Player
import Evergreen.V79.Data.Player.PlayerName
import Evergreen.V79.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V79.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V79.Data.Player.Player Evergreen.V79.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V79.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V79.Data.Vendor.Name Evergreen.V79.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V79.Data.Player.Player Evergreen.V79.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V79.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V79.Data.Auth.Auth Evergreen.V79.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V79.Data.Auth.Auth Evergreen.V79.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
