module Evergreen.V100.Data.World exposing (..)

import AssocList
import Evergreen.V100.Data.Auth
import Evergreen.V100.Data.Player
import Evergreen.V100.Data.Player.PlayerName
import Evergreen.V100.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V100.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V100.Data.Player.Player Evergreen.V100.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V100.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V100.Data.Vendor.Name Evergreen.V100.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V100.Data.Player.Player Evergreen.V100.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V100.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V100.Data.Auth.Auth Evergreen.V100.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V100.Data.Auth.Auth Evergreen.V100.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
