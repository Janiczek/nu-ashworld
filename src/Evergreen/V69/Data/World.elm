module Evergreen.V69.Data.World exposing (..)

import AssocList
import Evergreen.V69.Data.Auth
import Evergreen.V69.Data.Player
import Evergreen.V69.Data.Player.PlayerName
import Evergreen.V69.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V69.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V69.Data.Player.Player Evergreen.V69.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V69.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V69.Data.Vendor.Name Evergreen.V69.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V69.Data.Player.Player Evergreen.V69.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V69.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V69.Data.Auth.Auth Evergreen.V69.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V69.Data.Auth.Auth Evergreen.V69.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
