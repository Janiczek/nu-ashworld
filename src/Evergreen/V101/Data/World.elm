module Evergreen.V101.Data.World exposing (..)

import AssocList
import Evergreen.V101.Data.Auth
import Evergreen.V101.Data.Player
import Evergreen.V101.Data.Player.PlayerName
import Evergreen.V101.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V101.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V101.Data.Player.Player Evergreen.V101.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V101.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V101.Data.Vendor.Name Evergreen.V101.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V101.Data.Player.Player Evergreen.V101.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V101.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V101.Data.Auth.Auth Evergreen.V101.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V101.Data.Auth.Auth Evergreen.V101.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
