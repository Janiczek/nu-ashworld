module Evergreen.V96.Data.World exposing (..)

import AssocList
import Evergreen.V96.Data.Auth
import Evergreen.V96.Data.Player
import Evergreen.V96.Data.Player.PlayerName
import Evergreen.V96.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V96.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V96.Data.Player.Player Evergreen.V96.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V96.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V96.Data.Vendor.Name Evergreen.V96.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V96.Data.Player.Player Evergreen.V96.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V96.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V96.Data.Auth.Auth Evergreen.V96.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V96.Data.Auth.Auth Evergreen.V96.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
