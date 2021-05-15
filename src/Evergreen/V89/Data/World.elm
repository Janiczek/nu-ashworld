module Evergreen.V89.Data.World exposing (..)

import AssocList
import Evergreen.V89.Data.Auth
import Evergreen.V89.Data.Player
import Evergreen.V89.Data.Player.PlayerName
import Evergreen.V89.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V89.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V89.Data.Player.Player Evergreen.V89.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V89.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V89.Data.Vendor.Name Evergreen.V89.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V89.Data.Player.Player Evergreen.V89.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V89.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V89.Data.Auth.Auth Evergreen.V89.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V89.Data.Auth.Auth Evergreen.V89.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
