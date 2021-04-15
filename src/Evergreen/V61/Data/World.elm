module Evergreen.V61.Data.World exposing (..)

import Evergreen.V61.Data.Auth
import Evergreen.V61.Data.Player
import Evergreen.V61.Data.Player.PlayerName
import Evergreen.V61.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V61.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V61.Data.Player.Player Evergreen.V61.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V61.Data.Player.COtherPlayer
    , vendors : Evergreen.V61.Data.Vendor.Vendors
    }


type alias AdminData =
    { players : List (Evergreen.V61.Data.Player.Player Evergreen.V61.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V61.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V61.Data.Auth.Auth Evergreen.V61.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V61.Data.Auth.Auth Evergreen.V61.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
