module Evergreen.V88.Data.World exposing (..)

import AssocList
import Evergreen.V88.Data.Auth
import Evergreen.V88.Data.Player
import Evergreen.V88.Data.Player.PlayerName
import Evergreen.V88.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V88.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V88.Data.Player.Player Evergreen.V88.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V88.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V88.Data.Vendor.Name Evergreen.V88.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V88.Data.Player.Player Evergreen.V88.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V88.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V88.Data.Auth.Auth Evergreen.V88.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V88.Data.Auth.Auth Evergreen.V88.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
