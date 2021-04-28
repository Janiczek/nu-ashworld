module Evergreen.V71.Data.World exposing (..)

import AssocList
import Evergreen.V71.Data.Auth
import Evergreen.V71.Data.Player
import Evergreen.V71.Data.Player.PlayerName
import Evergreen.V71.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V71.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V71.Data.Player.Player Evergreen.V71.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V71.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V71.Data.Vendor.Name Evergreen.V71.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V71.Data.Player.Player Evergreen.V71.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V71.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V71.Data.Auth.Auth Evergreen.V71.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V71.Data.Auth.Auth Evergreen.V71.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
