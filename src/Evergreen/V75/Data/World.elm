module Evergreen.V75.Data.World exposing (..)

import AssocList
import Evergreen.V75.Data.Auth
import Evergreen.V75.Data.Player
import Evergreen.V75.Data.Player.PlayerName
import Evergreen.V75.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V75.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V75.Data.Player.Player Evergreen.V75.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V75.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V75.Data.Vendor.Name Evergreen.V75.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V75.Data.Player.Player Evergreen.V75.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V75.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V75.Data.Auth.Auth Evergreen.V75.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V75.Data.Auth.Auth Evergreen.V75.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
