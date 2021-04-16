module Evergreen.V63.Data.World exposing (..)

import Evergreen.V63.Data.Auth
import Evergreen.V63.Data.Player
import Evergreen.V63.Data.Player.PlayerName
import Evergreen.V63.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V63.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V63.Data.Player.Player Evergreen.V63.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V63.Data.Player.COtherPlayer
    , vendors : Evergreen.V63.Data.Vendor.Vendors
    }


type alias AdminData =
    { players : List (Evergreen.V63.Data.Player.Player Evergreen.V63.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V63.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V63.Data.Auth.Auth Evergreen.V63.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V63.Data.Auth.Auth Evergreen.V63.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
