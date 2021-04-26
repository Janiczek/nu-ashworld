module Evergreen.V68.Data.World exposing (..)

import AssocList
import Evergreen.V68.Data.Auth
import Evergreen.V68.Data.Player
import Evergreen.V68.Data.Player.PlayerName
import Evergreen.V68.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V68.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V68.Data.Player.Player Evergreen.V68.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V68.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V68.Data.Vendor.Name Evergreen.V68.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V68.Data.Player.Player Evergreen.V68.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V68.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V68.Data.Auth.Auth Evergreen.V68.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V68.Data.Auth.Auth Evergreen.V68.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
