module Evergreen.V97.Data.World exposing (..)

import AssocList
import Evergreen.V97.Data.Auth
import Evergreen.V97.Data.Player
import Evergreen.V97.Data.Player.PlayerName
import Evergreen.V97.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V97.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V97.Data.Player.Player Evergreen.V97.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V97.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V97.Data.Vendor.Name Evergreen.V97.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V97.Data.Player.Player Evergreen.V97.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V97.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V97.Data.Auth.Auth Evergreen.V97.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V97.Data.Auth.Auth Evergreen.V97.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
