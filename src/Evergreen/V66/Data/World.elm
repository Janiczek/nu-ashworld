module Evergreen.V66.Data.World exposing (..)

import AssocList
import Evergreen.V66.Data.Auth
import Evergreen.V66.Data.Player
import Evergreen.V66.Data.Player.PlayerName
import Evergreen.V66.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V66.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V66.Data.Player.Player Evergreen.V66.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V66.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V66.Data.Vendor.VendorName Evergreen.V66.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V66.Data.Player.Player Evergreen.V66.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V66.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V66.Data.Auth.Auth Evergreen.V66.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V66.Data.Auth.Auth Evergreen.V66.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
