module Evergreen.V70.Data.World exposing (..)

import AssocList
import Evergreen.V70.Data.Auth
import Evergreen.V70.Data.Player
import Evergreen.V70.Data.Player.PlayerName
import Evergreen.V70.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V70.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V70.Data.Player.Player Evergreen.V70.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V70.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V70.Data.Vendor.Name Evergreen.V70.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V70.Data.Player.Player Evergreen.V70.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V70.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V70.Data.Auth.Auth Evergreen.V70.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V70.Data.Auth.Auth Evergreen.V70.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
