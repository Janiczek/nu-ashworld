module Evergreen.V62.Data.World exposing (..)

import Evergreen.V62.Data.Auth
import Evergreen.V62.Data.Player
import Evergreen.V62.Data.Player.PlayerName
import Evergreen.V62.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V62.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V62.Data.Player.Player Evergreen.V62.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V62.Data.Player.COtherPlayer
    , vendors : Evergreen.V62.Data.Vendor.Vendors
    }


type alias AdminData =
    { players : List (Evergreen.V62.Data.Player.Player Evergreen.V62.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V62.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V62.Data.Auth.Auth Evergreen.V62.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V62.Data.Auth.Auth Evergreen.V62.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
