module Evergreen.V78.Data.World exposing (..)

import AssocList
import Evergreen.V78.Data.Auth
import Evergreen.V78.Data.Player
import Evergreen.V78.Data.Player.PlayerName
import Evergreen.V78.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V78.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V78.Data.Player.Player Evergreen.V78.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V78.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V78.Data.Vendor.Name Evergreen.V78.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V78.Data.Player.Player Evergreen.V78.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V78.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V78.Data.Auth.Auth Evergreen.V78.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V78.Data.Auth.Auth Evergreen.V78.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
