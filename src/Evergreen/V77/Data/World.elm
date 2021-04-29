module Evergreen.V77.Data.World exposing (..)

import AssocList
import Evergreen.V77.Data.Auth
import Evergreen.V77.Data.Player
import Evergreen.V77.Data.Player.PlayerName
import Evergreen.V77.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V77.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V77.Data.Player.Player Evergreen.V77.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V77.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V77.Data.Vendor.Name Evergreen.V77.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V77.Data.Player.Player Evergreen.V77.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V77.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V77.Data.Auth.Auth Evergreen.V77.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V77.Data.Auth.Auth Evergreen.V77.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
